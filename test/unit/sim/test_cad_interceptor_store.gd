extends GdUnitTestSuite

# gdUnit4 assertions are fluent; see AGENTS.md section 2.
@warning_ignore_start("return_value_discarded")


func _alloc(store: CadInterceptorStore, launcher: int = 0, target: int = 1) -> int:
	return store.alloc(launcher, target, 3, 0.0, 0.0, 600.0, 0.75, 10, 40)


func test_alloc_returns_the_lowest_free_index() -> void:
	# Given a fresh store
	# When interceptors are launched
	# Then slots are handed out in ascending order, as in every other sim store
	var store: CadInterceptorStore = CadInterceptorStore.new(8)
	assert_int(_alloc(store)).is_equal(0)
	assert_int(_alloc(store)).is_equal(1)
	assert_int(_alloc(store)).is_equal(2)


func test_release_frees_the_slot_for_reuse() -> void:
	# Given three in-flight interceptors with the middle one resolved
	# When another is launched
	# Then the freed slot is reused
	var store: CadInterceptorStore = CadInterceptorStore.new(8)
	_alloc(store)
	_alloc(store)
	_alloc(store)
	store.release(1)
	assert_bool(store.is_alive(1)).is_false()
	assert_int(_alloc(store)).is_equal(1)


func test_full_store_returns_invalid() -> void:
	# Given a store at capacity
	# When another launch is attempted
	# Then it reports INVALID: a salvo that cannot fit is dropped, never grown into
	var store: CadInterceptorStore = CadInterceptorStore.new(2)
	assert_int(_alloc(store)).is_equal(0)
	assert_int(_alloc(store)).is_equal(1)
	assert_int(_alloc(store)).is_equal(CadConst.INVALID)


func test_alloc_resets_every_field_of_a_recycled_slot() -> void:
	# Given a slot left dirty by a resolved interceptor
	# When it is launched again
	# Then nothing leaks: a stale resolve_tick would detonate the new round instantly
	var store: CadInterceptorStore = CadInterceptorStore.new(4)
	var first: int = _alloc(store)
	store.pk[first] = 0.1
	store.resolve_tick[first] = 3
	store.state[first] = CadEnums.InterceptorState.RESOLVED
	store.target_threat[first] = 77
	store.release(first)
	var again: int = store.alloc(5, 12, 9, 100.0, 200.0, 900.0, 0.6, 30, 95)
	assert_int(again).is_equal(first)
	assert_int(store.launcher_index[again]).is_equal(5)
	assert_int(store.target_threat[again]).is_equal(12)
	assert_int(store.weapon_def[again]).is_equal(9)
	assert_float(store.speed_mps[again]).is_equal_approx(900.0, 0.001)
	assert_float(store.pk[again]).is_equal_approx(0.6, 0.001)
	assert_int(store.launch_tick[again]).is_equal(30)
	assert_int(store.resolve_tick[again]).is_equal(95)
	assert_int(store.state[again]).is_equal(CadEnums.InterceptorState.FLYING)


func test_alloc_seeds_prev_from_the_launch_point() -> void:
	# Given a freshly launched interceptor
	# When its interpolation fields are read
	# Then prev equals pos, so its first drawn frame starts at the launcher
	var store: CadInterceptorStore = CadInterceptorStore.new(4)
	var i: int = store.alloc(0, 1, 2, -400.0, 250.0, 600.0, 0.8, 5, 20)
	assert_float(store.prev_x[i]).is_equal_approx(-400.0, 0.001)
	assert_float(store.prev_y[i]).is_equal_approx(250.0, 0.001)


func test_rebuild_alive_lists_indices_in_ascending_order() -> void:
	# Given a store churned by a seeded launch and resolve pattern
	# When the alive list is rebuilt
	# Then it holds exactly the in-flight rounds, ascending
	var store: CadInterceptorStore = CadInterceptorStore.new(32)
	var rng: CadRng = CadRng.new(7)
	var live: Array[int] = []
	for step: int in 150:
		if live.size() > 0 and rng.chance(CadEnums.RngStream.COMBAT, 0.4):
			var victim: int = live[rng.randi_range(CadEnums.RngStream.COMBAT, 0, live.size() - 1)]
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
		assert_int(store.alive[k]).is_greater(previous)
		previous = store.alive[k]


func test_snapshot_prev_touches_only_live_slots() -> void:
	# Given a resolved slot holding stale coordinates
	# When prev positions are snapshotted
	# Then only the in-flight rounds are updated
	var store: CadInterceptorStore = CadInterceptorStore.new(8)
	var keep: int = _alloc(store)
	var dead: int = _alloc(store)
	store.pos_x[keep] = 750.0
	store.prev_x[dead] = 42.0
	store.pos_x[dead] = 999.0
	store.release(dead)
	store.snapshot_prev()
	assert_float(store.prev_x[keep]).is_equal_approx(750.0, 0.001)
	assert_float(store.prev_x[dead]).is_equal_approx(42.0, 0.001)


func test_count_for_launcher_counts_only_live_rounds() -> void:
	# Given several launchers with rounds in flight
	# When one launcher is counted
	# Then only its own live rounds are included: this is what limits a launcher's channels
	var store: CadInterceptorStore = CadInterceptorStore.new(16)
	_alloc(store, 2)
	_alloc(store, 2)
	var third: int = _alloc(store, 2)
	_alloc(store, 5)
	store.rebuild_alive()
	assert_int(store.count_for_launcher(2)).is_equal(3)
	assert_int(store.count_for_launcher(5)).is_equal(1)
	assert_int(store.count_for_launcher(9)).is_equal(0)
	store.release(third)
	store.rebuild_alive()
	assert_int(store.count_for_launcher(2)).is_equal(2)


func test_arrays_never_resize() -> void:
	# Given many launch and resolve cycles
	# When the backing arrays are measured
	# Then they are still exactly capacity long
	var store: CadInterceptorStore = CadInterceptorStore.new(16)
	for cycle: int in 100:
		var index: int = _alloc(store)
		if index != CadConst.INVALID and cycle % 2 == 0:
			store.release(index)
	assert_int(store.pos_x.size()).is_equal(16)
	assert_int(store.pk.size()).is_equal(16)
	assert_int(store.alive.size()).is_equal(16)


func test_clear_all_empties_the_store_but_keeps_buffers() -> void:
	# Given a populated store
	# When it is cleared between runs
	# Then every slot is free and the buffers stay allocated
	var store: CadInterceptorStore = CadInterceptorStore.new(8)
	for i: int in 4:
		_alloc(store)
	store.rebuild_alive()
	store.clear_all()
	assert_int(store.alive_count).is_equal(0)
	assert_bool(store.is_alive(0)).is_false()
	assert_int(store.pos_x.size()).is_equal(8)
	assert_int(_alloc(store)).is_equal(0)
