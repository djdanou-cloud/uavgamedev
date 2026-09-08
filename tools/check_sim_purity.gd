extends SceneTree

## CI gate: fails when anything under res://src/sim (or a root passed after --) uses a construct
## the simulation layer may not contain.
## Run: godot --headless --path . -s res://tools/check_sim_purity.gd


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var root: String = args[0] if args.size() > 0 else "res://src/sim"
	var violations: PackedStringArray = CadPurityCheck.scan_dir(root)
	for violation: String in violations:
		print("PURITY ", violation)
	if violations.is_empty():
		print("OK purity ", root)
		quit(0)
	else:
		print("FAIL %d violations" % violations.size())
		quit(1)
