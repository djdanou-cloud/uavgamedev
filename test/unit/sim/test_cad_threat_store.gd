extends GdUnitTestSuite

# gdUnit4 assertions are fluent; see AGENTS.md section 2.
@warning_ignore_start("return_value_discarded")


func _alloc(store: CadThreatStore, x: float = 0.0) -> int:
	return store.alloc(0, x, 0.0, 100.0, 20.0, 100, 0)


func test_alloc_returns_the_lowest_free_index() -> void:
	# Given a fresh store
	# When slots are allocated
	# Then indices are handed out in ascending order, which keeps iteration deterministic
	var store: CadThreatStore = CadThreatStore.new(8)
	assert_int(_alloc(store)).is_equal(0)
	assert_int(_alloc(store)).is_equal(1)
	assert_int(_alloc(store)).is_equal(2)
	assert_int(store.alive_count).is_equal(0)


func test_release_frees_the_slot_for_reuse() -> void:
	# Given three allocated slots with the middle one released
	# When another is allocated
	# Then the freed index is reused rather than a fresh one taken
	var store: CadThreatStore = CadThreatStore.new(8)
	_alloc(store)
	_alloc(store)
	_alloc(store)
	store.release(1)
	assert_bool(store.is_alive(1)).is_false()
	assert_int(_alloc(store)).is_equal(1)
	assert_bool(store.is_alive(1)).is_true()


func test_full_store_returns_invalid() -> void:
	# Given a store filled to capacity
	# When one more allocation is attempted
	# Then it reports INVALID instead of growing (STD-SIM: capacities are hard limits)
	var store: CadThreatStore = CadThreatStore.new(3)
	assert_int(_alloc(store)).is_equal(0)
	assert_int(_alloc(store)).is_equal(1)
	assert_int(_alloc(store)).is_equal(2)
	assert_int(_alloc(store)).is_equal(CadConst.INVALID)
	store.release(0)
	assert_int(_alloc(store)).is_equal(0)


func test_alloc_resets_every_field_of_a_recycled_slot() -> void:
	# Given a slot left dirty by a previous occupant
	# When it is allocated again
	# Then no state leaks across: a recycled threat must look exactly like a new one
	var store: CadThreatStore = CadThreatStore.new(4)
	var first: int = _alloc(store)
	store.hp[first] = 3.0
	store.track_owner[first] = 9
	store.flags[first] = CadEnums.ThreatFlag.CLASSIFIED | CadEnums.ThreatFlag.JAMMED
	store.engaged_by[first] = 2
	store.state[first] = CadEnums.ThreatState.WANDER
	store.state_ticks[first] = 44
	store.detect_ticks_left[first] = 12
	store.vel_x[first] = 5.0
	store.release(first)
	var again: int = store.alloc(2, 10.0, 20.0, 300.0, 55.0, 800, 7)
	assert_int(again).is_equal(first)
	assert_float(store.hp[again]).is_equal_approx(55.0, 0.001)
	assert_int(store.def_index[again]).is_equal(2)
	assert_int(store.value[again]).is_equal(800)
	assert_int(store.spawn_tick[again]).is_equal(7)
	assert_float(store.alt_m[again]).is_equal_approx(300.0, 0.001)
	assert_int(store.state[again]).is_equal(CadEnums.ThreatState.SPAWNED)
	assert_int(store.track_owner[again]).is_equal(CadConst.INVALID)
	assert_int(store.flags[again]).is_equal(0)
	assert_int(store.engaged_by[again]).is_equal(0)
	assert_int(store.state_ticks[again]).is_equal(0)
	assert_int(store.detect_ticks_left[again]).is_equal(0)
	assert_float(store.vel_x[again]).is_equal_approx(0.0, 0.001)
	assert_int(store.target_kind[again]).is_equal(CadEnums.TargetKind.NONE)


func test_alloc_seeds_prev_position_from_the_spawn_point() -> void:
	# Given a freshly allocated threat
	# When its interpolation fields are read
	# Then prev equals pos, so the view cannot draw it streaking in from the origin
	var store: CadThreatStore = CadThreatStore.new(4)
	var i: int = store.alloc(0, 1200.0, -800.0, 150.0, 20.0, 100, 3)
	assert_float(store.prev_x[i]).is_equal_approx(1200.0, 0.001)
	assert_float(store.prev_y[i]).is_equal_approx(-800.0, 0.001)


func test_rebuild_alive_lists_indices_in_ascending_order() -> void:
	# Given a store churned by a seeded pattern of allocations and releases
	# When the alive list is rebuilt
	# Then it holds exactly the live slots, ascending: systems iterate it, so order is determinism
	var store: CadThreatStore = CadThreatStore.new(64)
	var rng: CadRng = CadRng.new(99)
	var live: Array[int] = []
	for step: int in 200:
		if live.size() > 0 and rng.chance(CadEnums.RngStream.MOTION, 0.35):
			var victim: int = live[rng.randi_range(CadEnums.RngStream.MOTION, 0, live.size() - 1)]
			store.release(victim)
			live.erase(victim)
		else:
			var index: int = _alloc(store)
			if index != CadConst.INVALID:
				live.append(index)
	store.rebuild_alive()
	assert_int(store.alive_count).is_equal(live.size())
	var previous: int = -1
	for k: int in store.alive_count:
		var index: int = store.alive[k]
		assert_int(index).is_greater(previous)
		assert_bool(store.is_alive(index)).is_true()
		previous = index


func test_snapshot_prev_touches_only_live_slots() -> void:
	# Given a released slot holding stale coordinates
	# When prev positions are snapshotted
	# Then the dead slot is left alone and live ones are updated
	var store: CadThreatStore = CadThreatStore.new(8)
	var keep: int = _alloc(store)
	var dead: int = _alloc(store)
	store.pos_x[keep] = 500.0
	store.pos_x[dead] = 900.0
	store.prev_x[dead] = 111.0
	store.release(dead)
	store.rebuild_alive()
	store.snapshot_prev()
	assert_float(store.prev_x[keep]).is_equal_approx(500.0, 0.001)
	assert_float(store.prev_x[dead]).is_equal_approx(111.0, 0.001)


func test_arrays_never_resize() -> void:
	# Given a store driven through many allocate and release cycles
	# When the backing arrays are measured
	# Then they are still exactly capacity long
	var store: CadThreatStore = CadThreatStore.new(16)
	for cycle: int in 100:
		var index: int = _alloc(store)
		if index != CadConst.INVALID and cycle % 2 == 0:
			store.release(index)
	store.rebuild_alive()
	assert_int(store.pos_x.size()).is_equal(16)
	assert_int(store.flags.size()).is_equal(16)
	assert_int(store.alive.size()).is_equal(16)


func test_clear_all_empties_the_store_but_keeps_buffers() -> void:
	# Given a populated store
	# When it is cleared between runs
	# Then every slot is free again and the buffers stay allocated
	var store: CadThreatStore = CadThreatStore.new(8)
	for i: int in 5:
		_alloc(store)
	store.rebuild_alive()
	store.clear_all()
	assert_int(store.alive_count).is_equal(0)
	assert_bool(store.is_alive(0)).is_false()
	assert_int(store.pos_x.size()).is_equal(8)
	assert_int(_alloc(store)).is_equal(0)
