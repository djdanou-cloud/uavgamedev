extends SceneTree

## CI gate: loads every project script, so a parse error - or a warning promoted to an error by the
## A-10 settings - fails the build instead of surfacing at runtime. Addons are skipped:
## debug/gdscript/warnings/directory_rules already exempts them from our warning severities.
## Run: godot --headless --path . -s res://tools/check_scripts.gd

const ROOTS: PackedStringArray = ["res://src", "res://scenes", "res://tools", "res://test"]

## Loading the running script with CACHE_MODE_IGNORE segfaults Godot 4.7.2 (verified 2026-09-08),
## so this file skips itself. It stays covered anyway: a parse error here stops the tool running.
## A literal is used rather than get_script(), whose Variant return cannot be cast under A-10.
const SELF_PATH: String = "res://tools/check_scripts.gd"


func _init() -> void:
	var failed: Array[String] = []
	var checked: int = 0
	for root: String in ROOTS:
		checked += _check_dir(root, failed)
	for path: String in failed:
		print("FAIL ", path)
	if failed.is_empty():
		print("OK %d scripts" % checked)
		quit(0)
	else:
		print("FAIL %d of %d scripts" % [failed.size(), checked])
		quit(1)


func _check_dir(root: String, failed: Array[String]) -> int:
	var dir: DirAccess = DirAccess.open(root)
	if dir == null:
		return 0
	var checked: int = 0
	for sub: String in dir.get_directories():
		checked += _check_dir(root.path_join(sub), failed)
	for name: String in dir.get_files():
		if not name.ends_with(".gd"):
			continue
		var path: String = root.path_join(name)
		if path == SELF_PATH:
			continue
		checked += 1
		# load() returns a non-null GDScript even when parsing failed (verified 2026-09-08), so the
		# result is worthless on its own; reload() is what reports the parse status.
		var script: GDScript = (
			ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as GDScript
		)
		if script == null or script.reload() != OK:
			failed.append(path)
	return checked
