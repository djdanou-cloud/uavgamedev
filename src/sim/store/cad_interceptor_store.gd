class_name CadInterceptorStore
extends RefCounted

## Every guided round in flight, in the same struct-of-arrays shape as CadThreatStore (A-04).
##
## Only guided interceptors live here. Gun bursts resolve instantly by probability roll and their
## tracers are drawn view-side (A-05), so the store holds hundreds of rows rather than thousands.
##
## A round carries the probability of kill it was launched with, not one recomputed at impact: the
## engagement was decided under the sensor and jamming conditions of the launch tick, and letting it
## drift afterwards would make replays diverge from what the player saw.

var capacity: int

var alive: PackedInt32Array
var alive_count: int = 0

var launcher_index: PackedInt32Array
var target_threat: PackedInt32Array
var weapon_def: PackedInt32Array
var state: PackedInt32Array
var pos_x: PackedFloat32Array
var pos_y: PackedFloat32Array
var prev_x: PackedFloat32Array
var prev_y: PackedFloat32Array
var speed_mps: PackedFloat32Array
var pk: PackedFloat32Array
var launch_tick: PackedInt32Array
var resolve_tick: PackedInt32Array

var _alive_flag: PackedByteArray
var _lowest_free: int = 0


func _init(capacity: int = CadConst.MAX_INTERCEPTORS) -> void:
	self.capacity = capacity
	alive = CadPacked.ints(capacity)
	launcher_index = CadPacked.ints(capacity)
	target_threat = CadPacked.ints(capacity)
	weapon_def = CadPacked.ints(capacity)
	state = CadPacked.ints(capacity)
	launch_tick = CadPacked.ints(capacity)
	resolve_tick = CadPacked.ints(capacity)
	pos_x = CadPacked.floats(capacity)
	pos_y = CadPacked.floats(capacity)
	prev_x = CadPacked.floats(capacity)
	prev_y = CadPacked.floats(capacity)
	speed_mps = CadPacked.floats(capacity)
	pk = CadPacked.floats(capacity)
	_alive_flag = CadPacked.bytes(capacity)


## Claims the lowest free slot and resets it. Returns CadConst.INVALID when the store is full.
func alloc(
	launcher: int,
	target: int,
	weapon: int,
	x: float,
	y: float,
	speed: float,
	pk0: float,
	tick: int,
	resolve: int
) -> int:
	var i: int = _lowest_free
	while i < capacity and _alive_flag[i] == 1:
		i += 1
	if i >= capacity:
		return CadConst.INVALID
	_alive_flag[i] = 1
	_lowest_free = i + 1
	launcher_index[i] = launcher
	target_threat[i] = target
	weapon_def[i] = weapon
	state[i] = CadEnums.InterceptorState.FLYING
	pos_x[i] = x
	pos_y[i] = y
	prev_x[i] = x
	prev_y[i] = y
	speed_mps[i] = speed
	pk[i] = pk0
	launch_tick[i] = tick
	resolve_tick[i] = resolve
	return i


func release(i: int) -> void:
	_alive_flag[i] = 0
	if i < _lowest_free:
		_lowest_free = i


func is_alive(i: int) -> bool:
	return _alive_flag[i] == 1


## Rewrites `alive` as the ascending list of in-flight rounds. O(capacity), allocation-free.
func rebuild_alive() -> void:
	alive_count = 0
	for i: int in capacity:
		if _alive_flag[i] == 1:
			alive[alive_count] = i
			alive_count += 1


func snapshot_prev() -> void:
	for i: int in capacity:
		if _alive_flag[i] == 1:
			prev_x[i] = pos_x[i]
			prev_y[i] = pos_y[i]


## Rounds a launcher currently has in the air, which is what caps its simultaneous engagements.
## Reads the alive list, so it reflects the last rebuild_alive().
func count_for_launcher(launcher: int) -> int:
	var total: int = 0
	for k: int in alive_count:
		if launcher_index[alive[k]] == launcher:
			total += 1
	return total


func clear_all() -> void:
	_alive_flag.fill(0)
	alive_count = 0
	_lowest_free = 0
