extends GdUnitTestSuite

# gdUnit4's assertions are fluent: assert_x(...) returns the assert object and callers ignore it.
# That is the API's intended use, so return_value_discarded (an Error for src/, A-10) is suppressed
# here. Every other warning, including untyped_declaration, stays active in test suites.
@warning_ignore_start("return_value_discarded")


func test_smoke_true() -> void:
	assert_bool(true).is_true()


func test_smoke_int_math() -> void:
	assert_int(2 + 2).is_equal(4)
