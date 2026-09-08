class_name CadPacked
extends RefCounted

## Typed constructors for zero-filled Packed arrays.
##
## `resize()` returns an Error that A-10 forbids discarding, so every store was carrying its own
## private copy of the same four-line helper. This is that helper, once. Construction only: none of
## these are tick-path functions, and the simulation never resizes a buffer after it is built.


static func ints(size: int) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	var resize_error: int = out.resize(size)
	assert(resize_error == OK, "could not size a PackedInt32Array")
	return out


static func longs(size: int) -> PackedInt64Array:
	var out: PackedInt64Array = PackedInt64Array()
	var resize_error: int = out.resize(size)
	assert(resize_error == OK, "could not size a PackedInt64Array")
	return out


static func floats(size: int) -> PackedFloat32Array:
	var out: PackedFloat32Array = PackedFloat32Array()
	var resize_error: int = out.resize(size)
	assert(resize_error == OK, "could not size a PackedFloat32Array")
	return out


static func bytes(size: int) -> PackedByteArray:
	var out: PackedByteArray = PackedByteArray()
	var resize_error: int = out.resize(size)
	assert(resize_error == OK, "could not size a PackedByteArray")
	return out
