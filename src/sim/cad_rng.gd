class_name CadRng
extends RefCounted

## Deterministic randomness for the simulation, split into independent streams (A-17).
##
## Each stream is its own generator seeded `seed_value + stream`, so a change in combat rolls cannot
## shift wave composition for the same seed. Every draw in the simulation goes through here: the
## global `randf`/`randi` are forbidden in src/sim precisely because they share one hidden stream.
## Stream states are saved and restored at wave boundaries, which is what lets a save resume.

var seed_value: int
var _streams: Array[RandomNumberGenerator] = []


func _init(seed: int) -> void:
	seed_value = seed
	for stream: int in CadEnums.RngStream.size():
		var generator: RandomNumberGenerator = RandomNumberGenerator.new()
		generator.seed = seed + stream
		_streams.append(generator)


func randf(stream: int) -> float:
	return _streams[stream].randf()


func randf_range(stream: int, from: float, to: float) -> float:
	return _streams[stream].randf_range(from, to)


## Inclusive on both bounds.
func randi_range(stream: int, from: int, to: int) -> int:
	return _streams[stream].randi_range(from, to)


## A weighted coin. The extremes answer without drawing: spending randomness on an outcome that was
## never in doubt would shift every later roll and break replays.
func chance(stream: int, p: float) -> bool:
	if p <= 0.0:
		return false
	if p >= 1.0:
		return true
	return _streams[stream].randf() < p


func get_state(stream: int) -> int:
	return _streams[stream].state


func set_state(stream: int, state: int) -> void:
	_streams[stream].state = state


func get_states() -> PackedInt64Array:
	var out: PackedInt64Array = PackedInt64Array()
	# resize() returns an Error that A-10 forbids discarding, so it is checked rather than ignored.
	var resize_error: int = out.resize(_streams.size())
	assert(resize_error == OK, "could not size the RNG state buffer")
	for i: int in _streams.size():
		out[i] = _streams[i].state
	return out


## Restores as many streams as the save holds, so an older save with fewer streams still loads.
func set_states(states: PackedInt64Array) -> void:
	for i: int in mini(states.size(), _streams.size()):
		_streams[i].state = states[i]
