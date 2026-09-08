class_name CadPurityCheck
extends RefCounted

## Textual purity scan for the simulation layer (AGENTS.md section 2, "Sim purity").
##
## The rule is textual on purpose: comments are not exempt, so no one can argue a construct back in
## by hiding it. Two token classes exist because a plain substring match would be useless:
## `rng.randf()` is how the sim is *supposed* to draw randomness, and `preload(` contains `load(`.

## Matched anywhere on the line.
const FORBIDDEN: PackedStringArray = [
	"extends Node",
	"get_tree(",
	"Timer",
	"await ",
	"signal ",
	"Engine.",
	"Time.",
	"OS.",
	"Input.",
]

## Matched only in their global form: a match preceded by "." or by an identifier character is a
## method call or a longer name (rng.randf, preload) and is not a violation.
const FORBIDDEN_GLOBAL: PackedStringArray = [
	"randf(",
	"randi(",
	"preload(",
	"load(",
	"print(",
]

const IDENT_CHARS: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"


## Returns "<line>:<token>" per violation, in ascending line order.
static func scan_text(text: String) -> PackedStringArray:
	var out: Array[String] = []
	var lines: PackedStringArray = text.split("\n")
	for i: int in lines.size():
		var line: String = lines[i]
		for token: String in FORBIDDEN:
			if line.find(token) >= 0:
				out.append("%d:%s" % [i + 1, token])
		for token: String in FORBIDDEN_GLOBAL:
			if _has_global_call(line, token):
				out.append("%d:%s" % [i + 1, token])
	return PackedStringArray(out)


## Returns "<path>:<line>:<token>" for every matching file under root, recursively.
static func scan_dir(root: String, extension: String = ".gd") -> PackedStringArray:
	var out: Array[String] = []
	_scan_into(root, extension, out)
	return PackedStringArray(out)


static func _scan_into(root: String, extension: String, out: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(root)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		_scan_into(root.path_join(sub), extension, out)
	for name: String in dir.get_files():
		if not name.ends_with(extension):
			continue
		var path: String = root.path_join(name)
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var text: String = file.get_as_text()
		file.close()
		for violation: String in scan_text(text):
			out.append("%s:%s" % [path, violation])


static func _has_global_call(line: String, token: String) -> bool:
	var at: int = line.find(token)
	while at >= 0:
		if at == 0:
			return true
		var previous: String = line.substr(at - 1, 1)
		if previous != "." and IDENT_CHARS.find(previous) < 0:
			return true
		at = line.find(token, at + 1)
	return false
