extends GdUnitTestSuite

# gdUnit4 assertions are fluent; see AGENTS.md section 2.
@warning_ignore_start("return_value_discarded")


func test_push_then_read_back_every_field() -> void:
	# Given an event pushed with all six payload fields
	# When it is read back by index
	# Then every field survives unchanged
	var log: CadEventLog = CadEventLog.new(16)
	log.push(CadEnums.EventType.THREAT_KILLED, 7, 3, 1, 120.5, -60.25)
	assert_int(log.count).is_equal(1)
	assert_int(log.type_at(0)).is_equal(CadEnums.EventType.THREAT_KILLED)
	assert_int(log.a_at(0)).is_equal(7)
	assert_int(log.b_at(0)).is_equal(3)
	assert_int(log.c_at(0)).is_equal(1)
	assert_float(log.x_at(0)).is_equal_approx(120.5, 0.001)
	assert_float(log.y_at(0)).is_equal_approx(-60.25, 0.001)


func test_events_keep_their_order() -> void:
	# Given several events pushed in sequence
	# When they are read back
	# Then they appear in push order, which the view relies on when draining
	var log: CadEventLog = CadEventLog.new(16)
	for i: int in 5:
		log.push(CadEnums.EventType.SHOT_FIRED, i, 0, 0, 0.0, 0.0)
	assert_int(log.count).is_equal(5)
	for i: int in 5:
		assert_int(log.a_at(i)).is_equal(i)


func test_overflow_is_counted_not_stored() -> void:
	# Given a log smaller than the burst pushed into it
	# When it overflows
	# Then the surplus is counted as dropped and the stored events are the first ones
	var log: CadEventLog = CadEventLog.new(4)
	for i: int in 6:
		log.push(CadEnums.EventType.BURST_FIRED, i, 0, 0, 0.0, 0.0)
	assert_int(log.count).is_equal(4)
	assert_int(log.dropped).is_equal(2)
	assert_int(log.a_at(3)).is_equal(3)


func test_arrays_never_resize() -> void:
	# Given a log driven past its capacity
	# When the backing arrays are inspected
	# Then they are still exactly capacity long: push allocates nothing (STD-SIM)
	var log: CadEventLog = CadEventLog.new(8)
	var before: int = log._type.size()
	for i: int in 16:
		log.push(CadEnums.EventType.THREAT_DETECTED, i, 0, 0, 1.0, 2.0)
	assert_int(log._type.size()).is_equal(before)
	assert_int(log._x.size()).is_equal(before)
	assert_int(before).is_equal(8)


func test_clear_resets_counters_but_keeps_capacity() -> void:
	# Given a log that has overflowed
	# When it is cleared at the end of a frame
	# Then counters reset while the buffers stay allocated
	var log: CadEventLog = CadEventLog.new(4)
	for i: int in 6:
		log.push(CadEnums.EventType.THREAT_SPAWNED, i, 0, 0, 0.0, 0.0)
	log.clear()
	assert_int(log.count).is_equal(0)
	assert_int(log.dropped).is_equal(0)
	assert_int(log._type.size()).is_equal(4)
	log.push(CadEnums.EventType.WAVE_CLEARED, 1, 0, 0, 0.0, 0.0)
	assert_int(log.count).is_equal(1)


func test_count_of_type() -> void:
	# Given a mixed batch of events
	# When one type is counted
	# Then only that type is included
	var log: CadEventLog = CadEventLog.new(16)
	log.push(CadEnums.EventType.SHOT_FIRED, 0, 0, 0, 0.0, 0.0)
	log.push(CadEnums.EventType.INTERCEPT_HIT, 0, 0, 0, 0.0, 0.0)
	log.push(CadEnums.EventType.SHOT_FIRED, 1, 0, 0, 0.0, 0.0)
	assert_int(log.count_of_type(CadEnums.EventType.SHOT_FIRED)).is_equal(2)
	assert_int(log.count_of_type(CadEnums.EventType.INTERCEPT_HIT)).is_equal(1)
	assert_int(log.count_of_type(CadEnums.EventType.THREAT_KILLED)).is_equal(0)


func test_hash_matches_for_identical_sequences() -> void:
	# Given two logs fed the same events
	# When their contents are hashed
	# Then the hashes match: this is what the determinism golden test compares
	var first: CadEventLog = CadEventLog.new(16)
	var second: CadEventLog = CadEventLog.new(16)
	for i: int in 5:
		first.push(CadEnums.EventType.THREAT_KILLED, i, i + 1, 0, float(i), float(-i))
		second.push(CadEnums.EventType.THREAT_KILLED, i, i + 1, 0, float(i), float(-i))
	assert_int(first.hash_contents()).is_equal(second.hash_contents())


func test_hash_differs_when_any_field_differs() -> void:
	# Given two logs differing in one payload field
	# When their contents are hashed
	# Then the hashes differ, so a divergent simulation cannot pass unnoticed
	var base: CadEventLog = CadEventLog.new(16)
	var changed_int: CadEventLog = CadEventLog.new(16)
	var changed_float: CadEventLog = CadEventLog.new(16)
	for i: int in 3:
		base.push(CadEnums.EventType.SHOT_FIRED, i, 0, 0, 1.0, 2.0)
		changed_int.push(CadEnums.EventType.SHOT_FIRED, i, 0, 0, 1.0, 2.0)
		changed_float.push(CadEnums.EventType.SHOT_FIRED, i, 0, 0, 1.0, 2.0)
	changed_int.push(CadEnums.EventType.SHOT_FIRED, 99, 0, 0, 1.0, 2.0)
	base.push(CadEnums.EventType.SHOT_FIRED, 3, 0, 0, 1.0, 2.0)
	changed_float.push(CadEnums.EventType.SHOT_FIRED, 3, 0, 0, 1.0, 2.5)
	assert_int(base.hash_contents()).is_not_equal(changed_int.hash_contents())
	assert_int(base.hash_contents()).is_not_equal(changed_float.hash_contents())


func test_hash_ignores_events_beyond_the_used_range() -> void:
	# Given a log cleared and refilled with fewer events
	# When it is hashed
	# Then stale values past `count` do not leak into the hash
	var fresh: CadEventLog = CadEventLog.new(16)
	fresh.push(CadEnums.EventType.WAVE_STARTED, 1, 0, 0, 0.0, 0.0)
	var reused: CadEventLog = CadEventLog.new(16)
	for i: int in 6:
		reused.push(CadEnums.EventType.THREAT_IMPACT, i, i, i, float(i), float(i))
	reused.clear()
	reused.push(CadEnums.EventType.WAVE_STARTED, 1, 0, 0, 0.0, 0.0)
	assert_int(reused.hash_contents()).is_equal(fresh.hash_contents())
