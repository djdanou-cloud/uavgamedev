extends GdUnitTestSuite

# gdUnit4 assertions are fluent; see AGENTS.md section 2.
@warning_ignore_start("return_value_discarded")

const BAD_FIXTURE: String = "res://test/fixtures/purity/bad_sim.txt"
const GOOD_FIXTURE: String = "res://test/fixtures/purity/good_sim.txt"


func _read(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_object(file).is_not_null()
	var text: String = file.get_as_text()
	file.close()
	return text


func test_scan_text_reports_every_forbidden_token() -> void:
	# Given a file with exactly one forbidden construct per line
	# When it is scanned
	# Then one violation per line is reported, in ascending line order
	var violations: PackedStringArray = CadPurityCheck.scan_text(_read(BAD_FIXTURE))
	assert_int(violations.size()).is_equal(14)
	assert_str(violations[0]).contains("1:")
	assert_str(violations[0]).contains("extends Node")
	assert_str(violations[13]).contains("14:")
	assert_str(violations[13]).contains("print(")
	var previous: int = 0
	for entry: String in violations:
		var line: int = entry.split(":")[0].to_int()
		assert_int(line).is_greater_equal(previous)
		previous = line


func test_scan_text_accepts_clean_sim_code() -> void:
	# Given a valid RefCounted sim class that uses an injected RandomNumberGenerator
	# When it is scanned
	# Then nothing is reported
	assert_int(CadPurityCheck.scan_text(_read(GOOD_FIXTURE)).size()).is_equal(0)


func test_scan_text_reports_tokens_inside_comments() -> void:
	# Given a forbidden token that appears only in a comment
	# When it is scanned
	# Then it is still reported: the rule is textual on purpose
	assert_int(CadPurityCheck.scan_text("# do not print( here\n").size()).is_equal(1)


func test_scan_text_allows_method_call_forms() -> void:
	# Given calls that merely end with a forbidden global's name
	# When they are scanned
	# Then they are not reported: only the global form is forbidden
	var text: String = "var a: float = rng.randf()\nvar b: int = _rng.randi()\n"
	assert_int(CadPurityCheck.scan_text(text).size()).is_equal(0)


func test_scan_text_separates_preload_from_load() -> void:
	# Given a preload call
	# When it is scanned
	# Then it counts once, as preload, not twice via the load substring
	var violations: PackedStringArray = CadPurityCheck.scan_text('var s = preload("res://a.gd")\n')
	assert_int(violations.size()).is_equal(1)
	assert_str(violations[0]).contains("preload(")


func test_scan_text_allows_declarations_of_those_names() -> void:
	# Given the simulation declaring its own randf/randi API (CadRng)
	# When the declarations are scanned
	# Then they are not violations: only a call to the global generator is
	assert_int(CadPurityCheck.scan_text("func randf(stream: int) -> float:").size()).is_equal(0)
	assert_int(CadPurityCheck.scan_text("static func randi(a: int) -> int:").size()).is_equal(0)
	# A real call to the global generator is still caught.
	assert_int(CadPurityCheck.scan_text("var x: float = randf()").size()).is_equal(1)


func test_scan_dir_prefixes_paths() -> void:
	# Given a directory holding the fixtures
	# When it is scanned for .txt files
	# Then every entry carries its file path and the good fixture contributes nothing
	var found: PackedStringArray = CadPurityCheck.scan_dir("res://test/fixtures/purity", ".txt")
	assert_int(found.size()).is_equal(14)
	for entry: String in found:
		assert_str(entry).contains("bad_sim.txt")


func test_scan_dir_returns_empty_for_missing_root() -> void:
	# Given a root that does not exist
	# When it is scanned
	# Then the result is empty rather than an error
	assert_int(CadPurityCheck.scan_dir("res://no/such/dir", ".gd").size()).is_equal(0)
