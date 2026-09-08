extends GdUnitTestSuite
@warning_ignore_start("return_value_discarded")


func test_matches_brute_force() -> void:
	var rng: CadRng = CadRng.new(140)
	var xs: PackedFloat32Array = CadPacked.floats(500)
	var ys: PackedFloat32Array = CadPacked.floats(500)
	var ids: PackedInt32Array = CadPacked.ints(500)
	var out: PackedInt32Array = CadPacked.ints(512)
	var grid: CadSpatialHash = CadSpatialHash.new(Vector2.ZERO, Vector2(20000, 12000), 500, 512)
	for i: int in 500:
		xs[i] = rng.randf_range(CadEnums.RngStream.MOTION, 0, 20000)
		ys[i] = rng.randf_range(CadEnums.RngStream.MOTION, 0, 12000)
		ids[i] = i
	grid.rebuild(xs, ys, ids, 500)
	for trial: int in 50:
		var cx: float = rng.randf_range(CadEnums.RngStream.MOTION, 0, 20000)
		var cy: float = rng.randf_range(CadEnums.RngStream.MOTION, 0, 12000)
		var radius: float = rng.randf_range(CadEnums.RngStream.MOTION, 200, 8000)
		var expected: PackedInt32Array = PackedInt32Array()
		for i: int in 500:
			var dx: float = xs[i] - cx
			var dy: float = ys[i] - cy
			if dx * dx + dy * dy <= radius * radius:
				expected.append(i)
		var count: int = grid.query_circle(cx, cy, radius, xs, ys, out)
		var actual: PackedInt32Array = out.slice(0, count)
		actual.sort()
		assert_array(actual).is_equal(expected)


func test_out_of_bounds_points_clamped_and_found() -> void:
	var grid: CadSpatialHash = CadSpatialHash.new(Vector2(-10, -10), Vector2(10, 10), 10, 4)
	var xs: PackedFloat32Array = PackedFloat32Array([-20, 30, 0, 10])
	var ys: PackedFloat32Array = PackedFloat32Array([-20, 30, 0, 10])
	var out: PackedInt32Array = CadPacked.ints(4)
	grid.rebuild(xs, ys, PackedInt32Array([0, 1, 2, 3]), 4)
	assert_int(grid.cell_of(-20, -20)).is_equal(0)
	assert_int(grid.cell_of(30, 30)).is_equal(3)
	assert_int(grid.cell_of(0, 0)).is_equal(3)
	assert_int(grid.query_circle(-20, -20, 0, xs, ys, out)).is_equal(1)
	assert_int(out[0]).is_equal(0)
	assert_int(grid.query_circle(30, 30, 0, xs, ys, out)).is_equal(1)
	assert_int(out[0]).is_equal(1)


func test_zero_radius_returns_coincident_only() -> void:
	var grid: CadSpatialHash = CadSpatialHash.new(Vector2.ZERO, Vector2(20, 20), 10, 3)
	var xs: PackedFloat32Array = PackedFloat32Array([5, 5, 6])
	var ys: PackedFloat32Array = PackedFloat32Array([5, 5, 5])
	var out: PackedInt32Array = CadPacked.ints(3)
	grid.rebuild(xs, ys, PackedInt32Array([0, 1, 2]), 3)
	assert_int(grid.query_circle(5, 5, 0, xs, ys, out)).is_equal(2)
	assert_array(out.slice(0, 2)).is_equal(PackedInt32Array([0, 1]))


func test_out_written_in_place_no_resize() -> void:
	var grid: CadSpatialHash = CadSpatialHash.new(Vector2.ZERO, Vector2(20, 20), 10, 2)
	var xs: PackedFloat32Array = PackedFloat32Array([0, 3])
	var ys: PackedFloat32Array = PackedFloat32Array([0, 4])
	var out: PackedInt32Array = PackedInt32Array([-1, -1, -1])
	grid.rebuild(xs, ys, PackedInt32Array([0, 1]), 2)
	assert_int(grid.query_circle(0, 0, 5, xs, ys, out)).is_equal(2)
	assert_array(out).is_equal(PackedInt32Array([0, 1, -1]))
	assert_int(out.size()).is_equal(3)
	var short_out: PackedInt32Array = PackedInt32Array([-1])
	assert_int(grid.query_circle(0, 0, 5, xs, ys, short_out)).is_equal(1)
	assert_int(short_out[0]).is_equal(0)
	assert_int(grid.query_circle(0, 0, 5, xs, ys, PackedInt32Array())).is_equal(0)


func test_rebuild_twice_same_order() -> void:
	var grid: CadSpatialHash = CadSpatialHash.new(Vector2.ZERO, Vector2(20, 20), 10, 4)
	var xs: PackedFloat32Array = PackedFloat32Array([15, 0, 2, 10])
	var ys: PackedFloat32Array = PackedFloat32Array([15, 0, 2, 0])
	var ids: PackedInt32Array = PackedInt32Array([0, 2, 1, 3])
	grid.rebuild(xs, ys, ids, 4)
	var first: PackedInt32Array = grid.cell_items.duplicate()
	assert_array(first).is_equal(PackedInt32Array([2, 1, 3, 0]))
	assert_array(grid.cell_start).is_equal(PackedInt32Array([0, 2, 3, 3, 4]))
	grid.rebuild(xs, ys, ids, 4)
	assert_array(grid.cell_items).is_equal(first)
	var out: PackedInt32Array = CadPacked.ints(4)
	assert_int(grid.query_circle(0, 0, 30, xs, ys, out)).is_equal(4)
	assert_array(out).is_equal(first)
	grid.rebuild(xs, ys, PackedInt32Array([3]), 1)
	assert_int(grid.item_count()).is_equal(1)
	assert_int(grid.query_circle(0, 0, 30, xs, ys, out)).is_equal(1)
	assert_int(out[0]).is_equal(3)


func test_empty_rebuild_query_zero() -> void:
	var grid: CadSpatialHash = CadSpatialHash.new(Vector2.ZERO, Vector2(20, 20), 10, 0)
	var empty: PackedFloat32Array = PackedFloat32Array()
	var out: PackedInt32Array = PackedInt32Array([-1])
	grid.rebuild(empty, empty, PackedInt32Array(), 0)
	assert_int(grid.item_count()).is_equal(0)
	assert_int(grid.query_circle(0, 0, 100, empty, empty, out)).is_equal(0)
	assert_int(out[0]).is_equal(-1)


func test_full_capacity_tick_paths_create_no_objects() -> void:
	var grid: CadSpatialHash = CadSpatialHash.new(Vector2.ZERO, Vector2(20000, 12000), 500, 512)
	var xs: PackedFloat32Array = CadPacked.floats(512)
	var ys: PackedFloat32Array = CadPacked.floats(512)
	var ids: PackedInt32Array = CadPacked.ints(512)
	var out: PackedInt32Array = CadPacked.ints(512)
	for i: int in 512:
		ids[i] = i
	grid.rebuild(xs, ys, ids, 512)
	var before: int = int(Performance.get_monitor(Performance.OBJECT_COUNT))
	var count: int = 0
	for tick: int in 1800:
		grid.rebuild(xs, ys, ids, 512)
		count = grid.query_circle(0, 0, 0, xs, ys, out)
	var delta: int = int(Performance.get_monitor(Performance.OBJECT_COUNT)) - before
	assert_int(delta).is_equal(0)
	assert_int(count).is_equal(512)
	assert_int(grid.item_count()).is_equal(512)
	assert_array(out).is_equal(ids)
