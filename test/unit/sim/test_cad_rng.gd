extends GdUnitTestSuite

# gdUnit4 assertions are fluent; see AGENTS.md section 2.
@warning_ignore_start("return_value_discarded")

const SEED: int = 424242


func test_same_seed_reproduces_the_same_sequence() -> void:
	# Given two generators created with the same seed
	# When each stream is drawn a thousand times
	# Then the sequences are identical, which is what makes replays and golden tests possible
	var a: CadRng = CadRng.new(SEED)
	var b: CadRng = CadRng.new(SEED)
	for stream: int in CadEnums.RngStream.size():
		for i: int in 1000:
			assert_float(a.randf(stream)).is_equal(b.randf(stream))


func test_different_seeds_diverge() -> void:
	# Given two generators with different seeds
	# When the same stream is drawn
	# Then the sequences differ
	var a: CadRng = CadRng.new(SEED)
	var b: CadRng = CadRng.new(SEED + 1)
	var same: int = 0
	for i: int in 100:
		if is_equal_approx(a.randf(CadEnums.RngStream.COMBAT), b.randf(CadEnums.RngStream.COMBAT)):
			same += 1
	assert_int(same).is_less(100)


func test_streams_are_independent() -> void:
	# Given a generator whose COMBAT stream has not been touched
	# When a hundred draws are taken from WAVEGEN
	# Then the next COMBAT value is unchanged: combat rolls cannot shift wave composition (A-17)
	var reference: CadRng = CadRng.new(SEED)
	var expected: float = reference.randf(CadEnums.RngStream.COMBAT)
	var rng: CadRng = CadRng.new(SEED)
	for i: int in 100:
		rng.randf(CadEnums.RngStream.WAVEGEN)
	assert_float(rng.randf(CadEnums.RngStream.COMBAT)).is_equal(expected)


func test_state_round_trip_resumes_the_sequence() -> void:
	# Given a saved stream state
	# When it is restored after further draws
	# Then the following fifty values repeat exactly, which is how a save resumes mid-campaign
	var rng: CadRng = CadRng.new(SEED)
	var saved: int = rng.get_state(CadEnums.RngStream.MOTION)
	var expected: Array[float] = []
	for i: int in 50:
		expected.append(rng.randf(CadEnums.RngStream.MOTION))
	rng.set_state(CadEnums.RngStream.MOTION, saved)
	for i: int in 50:
		assert_float(rng.randf(CadEnums.RngStream.MOTION)).is_equal(expected[i])


func test_states_array_round_trips_every_stream() -> void:
	# Given the whole generator state as written into a save file
	# When it is restored into a fresh generator
	# Then every stream continues from where the first one left off
	var rng: CadRng = CadRng.new(SEED)
	for i: int in 10:
		rng.randf(CadEnums.RngStream.WAVEGEN)
		rng.randf(CadEnums.RngStream.COMBAT)
	var states: PackedInt64Array = rng.get_states()
	assert_int(states.size()).is_equal(CadEnums.RngStream.size())
	var restored: CadRng = CadRng.new(SEED + 999)
	restored.set_states(states)
	for stream: int in CadEnums.RngStream.size():
		assert_float(restored.randf(stream)).is_equal(rng.randf(stream))


func test_chance_extremes_consume_no_randomness() -> void:
	# Given a certainty or an impossibility
	# When chance() is asked
	# Then it answers without drawing, so a certain outcome never shifts later rolls
	var rng: CadRng = CadRng.new(SEED)
	var before: int = rng.get_state(CadEnums.RngStream.COMBAT)
	assert_bool(rng.chance(CadEnums.RngStream.COMBAT, 0.0)).is_false()
	assert_bool(rng.chance(CadEnums.RngStream.COMBAT, -0.5)).is_false()
	assert_bool(rng.chance(CadEnums.RngStream.COMBAT, 1.0)).is_true()
	assert_bool(rng.chance(CadEnums.RngStream.COMBAT, 2.0)).is_true()
	assert_int(rng.get_state(CadEnums.RngStream.COMBAT)).is_equal(before)


func test_chance_is_roughly_fair() -> void:
	# Given a probability of one half
	# When it is rolled ten thousand times
	# Then the hit count sits near the middle, and the state has advanced
	var rng: CadRng = CadRng.new(SEED)
	var hits: int = 0
	for i: int in 10000:
		if rng.chance(CadEnums.RngStream.COMBAT, 0.5):
			hits += 1
	assert_int(hits).is_between(4700, 5300)


func test_randi_range_includes_both_bounds() -> void:
	# Given an inclusive integer range
	# When it is sampled many times
	# Then both bounds appear and nothing falls outside
	var rng: CadRng = CadRng.new(SEED)
	var low_seen: bool = false
	var high_seen: bool = false
	for i: int in 10000:
		var value: int = rng.randi_range(CadEnums.RngStream.WAVEGEN, 3, 5)
		assert_int(value).is_between(3, 5)
		low_seen = low_seen or value == 3
		high_seen = high_seen or value == 5
	assert_bool(low_seen).is_true()
	assert_bool(high_seen).is_true()


func test_randf_range_stays_inside_bounds() -> void:
	# Given a float range
	# When it is sampled
	# Then every value lies within it
	var rng: CadRng = CadRng.new(SEED)
	for i: int in 1000:
		var value: float = rng.randf_range(CadEnums.RngStream.MOTION, -PI, PI)
		assert_float(value).is_between(-PI, PI)
