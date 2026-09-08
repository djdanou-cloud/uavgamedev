class_name CadThreatStore
extends RefCounted

## Every in-flight threat, stored as parallel arrays rather than objects (A-04).
##
## Systems sweep these arrays by index, which is why `alive` is rebuilt in ascending order:
## iteration order is part of determinism, not an implementation detail. Capacity is fixed; a full
## store returns CadConst.INVALID rather than growing, and the wave director queues the spawn.
##
## Slot reuse hands out the lowest free index rather than the most recently freed one, so a given
## seed produces the same index layout on every run. `_lowest_free` caches where to start looking,
## making the usual case a single check instead of a scan.

var capacity: int

var alive: PackedInt32Array
var alive_count: int = 0

var def_index: PackedInt32Array
var state: PackedInt32Array
var pos_x: PackedFloat32Array
var pos_y: PackedFloat32Array
var prev_x: PackedFloat32Array
var prev_y: PackedFloat32Array
var vel_x: PackedFloat32Array
var vel_y: PackedFloat32Array
var alt_m: PackedFloat32Array
var hp: PackedFloat32Array
var value: PackedInt32Array
var target_kind: PackedInt32Array
var target_id: PackedInt32Array
var target_x: PackedFloat32Array
var target_y: PackedFloat32Array
var detect_ticks_left: PackedInt32Array
var track_owner: PackedInt32Array
var track_age: PackedInt32Array
var engaged_by: PackedInt32Array
var flags: PackedInt32Array
var state_ticks: PackedInt32Array
var spawn_tick: PackedInt32Array
var eccm_level: PackedInt32Array
var package_id: PackedInt32Array

var _alive_flag: PackedByteArray
var _lowest_free: int = 0


func _init(capacity: int = CadConst.MAX_THREATS) -> void:
	self.capacity = capacity
	alive = CadPacked.ints(capacity)
	def_index = CadPacked.ints(capacity)
	state = CadPacked.ints(capacity)
	value = CadPacked.ints(capacity)
	target_kind = CadPacked.ints(capacity)
	target_id = CadPacked.ints(capacity)
	detect_ticks_left = CadPacked.ints(capacity)
	track_owner = CadPacked.ints(capacity)
	track_age = CadPacked.ints(capacity)
	engaged_by = CadPacked.ints(capacity)
	flags = CadPacked.ints(capacity)
	state_ticks = CadPacked.ints(capacity)
	spawn_tick = CadPacked.ints(capacity)
	eccm_level = CadPacked.ints(capacity)
	package_id = CadPacked.ints(capacity)
	pos_x = CadPacked.floats(capacity)
	pos_y = CadPacked.floats(capacity)
	prev_x = CadPacked.floats(capacity)
	prev_y = CadPacked.floats(capacity)
	vel_x = CadPacked.floats(capacity)
	vel_y = CadPacked.floats(capacity)
	alt_m = CadPacked.floats(capacity)
	hp = CadPacked.floats(capacity)
	target_x = CadPacked.floats(capacity)
	target_y = CadPacked.floats(capacity)
	_alive_flag = CadPacked.bytes(capacity)


## Claims the lowest free slot and resets it completely. Returns CadConst.INVALID when full.
func alloc(def_idx: int, x: float, y: float, alt: float, hp0: float, value0: int, tick: int) -> int:
	var i: int = _lowest_free
	while i < capacity and _alive_flag[i] == 1:
		i += 1
	if i >= capacity:
		return CadConst.INVALID
	_alive_flag[i] = 1
	_lowest_free = i + 1
	def_index[i] = def_idx
	state[i] = CadEnums.ThreatState.SPAWNED
	pos_x[i] = x
	pos_y[i] = y
	prev_x[i] = x
	prev_y[i] = y
	vel_x[i] = 0.0
	vel_y[i] = 0.0
	alt_m[i] = alt
	hp[i] = hp0
	value[i] = value0
	target_kind[i] = CadEnums.TargetKind.NONE
	target_id[i] = CadConst.INVALID
	target_x[i] = 0.0
	target_y[i] = 0.0
	detect_ticks_left[i] = 0
	track_owner[i] = CadConst.INVALID
	track_age[i] = 0
	engaged_by[i] = 0
	flags[i] = 0
	state_ticks[i] = 0
	spawn_tick[i] = tick
	eccm_level[i] = 0
	package_id[i] = CadConst.INVALID
	return i


func release(i: int) -> void:
	_alive_flag[i] = 0
	if i < _lowest_free:
		_lowest_free = i


func is_alive(i: int) -> bool:
	return _alive_flag[i] == 1


## Rewrites `alive` as the ascending list of live slots. O(capacity), allocation-free.
func rebuild_alive() -> void:
	alive_count = 0
	for i: int in capacity:
		if _alive_flag[i] == 1:
			alive[alive_count] = i
			alive_count += 1


## Copies pos into prev for live slots, giving the view its interpolation start point.
func snapshot_prev() -> void:
	for i: int in capacity:
		if _alive_flag[i] == 1:
			prev_x[i] = pos_x[i]
			prev_y[i] = pos_y[i]


func clear_all() -> void:
	_alive_flag.fill(0)
	alive_count = 0
	_lowest_free = 0
