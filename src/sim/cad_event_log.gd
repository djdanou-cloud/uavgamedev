class_name CadEventLog
extends RefCounted

## The simulation's only channel out to the view: a fixed-size, allocation-free record of what
## happened this tick (D2.6).
##
## Six parallel arrays hold one row per event - a type from CadEnums.EventType plus three integer
## payload slots and a world position. Nothing here is a Node and nothing emits a signal: the driver
## drains the log once per frame and re-emits it as CadEvents signals on the view side.
##
## The log deliberately drops rather than grows. A tick that produces more events than capacity is a
## simulation problem to fix, not a reason to allocate mid-tick, so the surplus is counted in
## `dropped` and stays visible.

var capacity: int
var count: int = 0
var dropped: int = 0

var _type: PackedInt32Array
var _a: PackedInt32Array
var _b: PackedInt32Array
var _c: PackedInt32Array
var _x: PackedFloat32Array
var _y: PackedFloat32Array


func _init(capacity: int = CadConst.EVENT_CAPACITY) -> void:
	self.capacity = capacity
	_type = _sized_ints(capacity)
	_a = _sized_ints(capacity)
	_b = _sized_ints(capacity)
	_c = _sized_ints(capacity)
	_x = _sized_floats(capacity)
	_y = _sized_floats(capacity)


## Records one event. Tick-path: index writes only, no allocation, no branching on strings.
func push(type: int, a: int, b: int, c: int, x: float, y: float) -> void:
	if count >= capacity:
		dropped += 1
		return
	_type[count] = type
	_a[count] = a
	_b[count] = b
	_c[count] = c
	_x[count] = x
	_y[count] = y
	count += 1


func type_at(i: int) -> int:
	return _type[i]


func a_at(i: int) -> int:
	return _a[i]


func b_at(i: int) -> int:
	return _b[i]


func c_at(i: int) -> int:
	return _c[i]


func x_at(i: int) -> float:
	return _x[i]


func y_at(i: int) -> float:
	return _y[i]


func count_of_type(type: int) -> int:
	var total: int = 0
	for i: int in count:
		if _type[i] == type:
			total += 1
	return total


## Resets the counters and leaves the buffers allocated, ready for the next frame.
func clear() -> void:
	count = 0
	dropped = 0


## Hashes only the used range, so values left behind by a longer previous frame cannot leak in.
## The determinism golden test compares this per wave (A-18).
func hash_contents() -> int:
	var value: int = hash(_type.slice(0, count))
	value = value * 31 + hash(_a.slice(0, count))
	value = value * 31 + hash(_b.slice(0, count))
	value = value * 31 + hash(_c.slice(0, count))
	value = value * 31 + hash(_x.slice(0, count))
	value = value * 31 + hash(_y.slice(0, count))
	return value


static func _sized_ints(size: int) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	# resize() returns an Error that A-10 forbids discarding, so it is checked rather than ignored.
	var resize_error: int = out.resize(size)
	assert(resize_error == OK, "could not size the event log")
	return out


static func _sized_floats(size: int) -> PackedFloat32Array:
	var out: PackedFloat32Array = PackedFloat32Array()
	var resize_error: int = out.resize(size)
	assert(resize_error == OK, "could not size the event log")
	return out
