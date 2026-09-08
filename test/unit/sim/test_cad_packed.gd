extends GdUnitTestSuite

# gdUnit4 assertions are fluent; see AGENTS.md section 2.
@warning_ignore_start("return_value_discarded")


func test_each_constructor_returns_the_requested_length() -> void:
	# Given a requested size
	# When each typed constructor is called
	# Then the array is exactly that long
	assert_int(CadPacked.ints(7).size()).is_equal(7)
	assert_int(CadPacked.longs(5).size()).is_equal(5)
	assert_int(CadPacked.floats(9).size()).is_equal(9)
	assert_int(CadPacked.bytes(3).size()).is_equal(3)


func test_arrays_start_zero_filled() -> void:
	# Given a fresh array
	# When its contents are read
	# Then every slot is zero: stores rely on this instead of clearing after allocation
	for value: int in CadPacked.ints(4):
		assert_int(value).is_equal(0)
	for value: int in CadPacked.longs(4):
		assert_int(value).is_equal(0)
	for value: float in CadPacked.floats(4):
		assert_float(value).is_equal_approx(0.0, 0.0001)
	for value: int in CadPacked.bytes(4):
		assert_int(value).is_equal(0)


func test_zero_size_is_allowed() -> void:
	# Given a size of zero
	# When a constructor is called
	# Then it returns an empty array rather than failing
	assert_int(CadPacked.ints(0).size()).is_equal(0)
	assert_int(CadPacked.floats(0).size()).is_equal(0)


func test_call_sites_still_size_their_buffers_correctly() -> void:
	# Given the three stores that now share these helpers
	# When each is constructed
	# Then its buffers are exactly capacity long: a regression guard for the extraction
	var log: CadEventLog = CadEventLog.new(12)
	assert_int(log._type.size()).is_equal(12)
	assert_int(log._x.size()).is_equal(12)
	var store: CadThreatStore = CadThreatStore.new(20)
	assert_int(store.pos_x.size()).is_equal(20)
	assert_int(store.flags.size()).is_equal(20)
	assert_int(store.alive.size()).is_equal(20)
	var rng: CadRng = CadRng.new(1)
	assert_int(rng.get_states().size()).is_equal(CadEnums.RngStream.size())
