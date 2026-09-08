class_name CadSpatialHash
extends RefCounted

var cells_x: int
var cells_y: int
var cell_size: float
var origin_x: float
var origin_y: float
var max_items: int
var cell_start: PackedInt32Array
var cell_items: PackedInt32Array
var _cell_of_item: PackedInt32Array
var _counts: PackedInt32Array
var _n: int = 0


func _init(world_min: Vector2, world_max: Vector2, cell_m: float, max_items: int) -> void:
	assert(cell_m > 0.0 and max_items >= 0)
	assert(world_max.x > world_min.x and world_max.y > world_min.y)
	cell_size = cell_m
	origin_x = world_min.x
	origin_y = world_min.y
	self.max_items = max_items
	cells_x = maxi(1, int(ceilf((world_max.x - origin_x) / cell_size)))
	cells_y = maxi(1, int(ceilf((world_max.y - origin_y) / cell_size)))
	cell_start = CadPacked.ints(cells_x * cells_y + 1)
	cell_items = CadPacked.ints(max_items)
	_cell_of_item = CadPacked.ints(max_items)
	_counts = CadPacked.ints(cells_x * cells_y)


func cell_of(x: float, y: float) -> int:
	var col: int = clampi(int(floorf((x - origin_x) / cell_size)), 0, cells_x - 1)
	var row: int = clampi(int(floorf((y - origin_y) / cell_size)), 0, cells_y - 1)
	return row * cells_x + col


func rebuild(
	xs: PackedFloat32Array, ys: PackedFloat32Array, indices: PackedInt32Array, n: int
) -> void:
	assert(n >= 0 and n <= max_items and n <= indices.size())
	_n = n
	_counts.fill(0)
	for i: int in n:
		var id: int = indices[i]
		assert(id >= 0 and id < xs.size() and id < ys.size())
		var cell: int = cell_of(xs[id], ys[id])
		_cell_of_item[i] = cell
		_counts[cell] += 1
	cell_start[0] = 0
	for cell: int in _counts.size():
		cell_start[cell + 1] = cell_start[cell] + _counts[cell]
	_counts.fill(0)
	# Stable scatter preserves input order inside each bucket, including sparse entity IDs.
	for i: int in n:
		var cell: int = _cell_of_item[i]
		cell_items[cell_start[cell] + _counts[cell]] = indices[i]
		_counts[cell] += 1


func query_circle(
	cx: float,
	cy: float,
	r: float,
	xs: PackedFloat32Array,
	ys: PackedFloat32Array,
	out: PackedInt32Array
) -> int:
	if _n == 0 or r < 0.0 or out.is_empty():
		return 0
	var min_col: int = clampi(int(floorf((cx - r - origin_x) / cell_size)), 0, cells_x - 1)
	var max_col: int = clampi(int(floorf((cx + r - origin_x) / cell_size)), 0, cells_x - 1)
	var min_row: int = clampi(int(floorf((cy - r - origin_y) / cell_size)), 0, cells_y - 1)
	var max_row: int = clampi(int(floorf((cy + r - origin_y) / cell_size)), 0, cells_y - 1)
	var radius_squared: float = r * r
	var count: int = 0
	for row: int in range(min_row, max_row + 1):
		for col: int in range(min_col, max_col + 1):
			var cell: int = row * cells_x + col
			for slot: int in range(cell_start[cell], cell_start[cell + 1]):
				var id: int = cell_items[slot]
				var dx: float = xs[id] - cx
				var dy: float = ys[id] - cy
				if dx * dx + dy * dy <= radius_squared:
					out[count] = id
					count += 1
					if count == out.size():
						return count
	return count


func item_count() -> int:
	return _n
