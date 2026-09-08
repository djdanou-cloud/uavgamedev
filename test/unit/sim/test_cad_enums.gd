extends GdUnitTestSuite

# gdUnit4 assertions are fluent; see AGENTS.md section 2.
@warning_ignore_start("return_value_discarded")


func test_enum_sizes_match_design() -> void:
	# Given the design bible rosters and screen list
	# When the enums are counted
	# Then each matches the documented number of members
	assert_int(CadEnums.ThreatClass.size()).is_equal(9)
	assert_int(CadEnums.EmpKind.size()).is_equal(15)
	assert_int(CadEnums.EventType.size()).is_equal(25)
	assert_int(CadEnums.GameState.size()).is_equal(9)
	assert_int(CadEnums.CommandType.size()).is_equal(10)
	assert_int(CadEnums.AltBand.size()).is_equal(4)
	assert_int(CadEnums.RngStream.size()).is_equal(3)


func test_enum_ordinals_are_frozen() -> void:
	# Given that saves and the event log store enum members as integers
	# When their ordinals are read
	# Then they hold the documented values: appending is allowed, reordering is not
	assert_int(CadEnums.ThreatState.SPAWNED).is_equal(0)
	assert_int(CadEnums.ThreatState.INGRESS).is_equal(1)
	assert_int(CadEnums.ThreatState.EXITED).is_equal(8)
	assert_int(CadEnums.GameState.BOOT).is_equal(0)
	assert_int(CadEnums.GameState.BUILD).is_equal(4)
	assert_int(CadEnums.GameState.PAUSED).is_equal(8)
	assert_int(CadEnums.EmpKind.SENSOR_SEARCH).is_equal(0)
	assert_int(CadEnums.EmpKind.HARDENING).is_equal(14)
	assert_int(CadEnums.Roe.HOLD).is_equal(0)
	assert_int(CadEnums.Roe.FREE).is_equal(2)
	assert_int(CadEnums.CommandResult.OK).is_equal(0)


func test_threat_flags_are_distinct_bits() -> void:
	# Given flags stored in one packed integer per threat
	# When they are combined
	# Then each occupies its own bit
	assert_int(CadEnums.ThreatFlag.CLASSIFIED).is_equal(1)
	assert_int(CadEnums.ThreatFlag.JAMMED).is_equal(2)
	assert_int(CadEnums.ThreatFlag.REVEALER).is_equal(4)
	var combined: int = CadEnums.ThreatFlag.CLASSIFIED | CadEnums.ThreatFlag.REVEALER
	assert_int(combined & CadEnums.ThreatFlag.JAMMED).is_equal(0)
	assert_int(combined & CadEnums.ThreatFlag.CLASSIFIED).is_equal(1)


func test_band_bit_maps_each_band_to_its_own_bit() -> void:
	# Given the altitude coverage bitmask used by every emplacement definition
	# When band_bit is called
	# Then it returns 1 << band, and the four bands do not overlap
	assert_int(CadEnums.band_bit(CadEnums.AltBand.LOW)).is_equal(1)
	assert_int(CadEnums.band_bit(CadEnums.AltBand.MED)).is_equal(2)
	assert_int(CadEnums.band_bit(CadEnums.AltBand.HIGH)).is_equal(4)
	assert_int(CadEnums.band_bit(CadEnums.AltBand.BALLISTIC)).is_equal(8)
	var low_med: int = CadEnums.band_bit(CadEnums.AltBand.LOW) | CadEnums.band_bit(CadEnums.AltBand.MED)
	assert_int(low_med & CadEnums.band_bit(CadEnums.AltBand.HIGH)).is_equal(0)


func test_seconds_to_ticks_rounds_up() -> void:
	# Given durations authored in seconds in the design tables
	# When they are converted at definition-load time
	# Then any fraction of a tick counts as a whole tick
	assert_int(CadConst.seconds_to_ticks(2.0)).is_equal(60)
	assert_int(CadConst.seconds_to_ticks(0.033)).is_equal(1)
	assert_int(CadConst.seconds_to_ticks(1.0 / 30.0)).is_equal(1)
	assert_int(CadConst.seconds_to_ticks(8.0)).is_equal(240)


func test_seconds_to_ticks_clamps_non_positive() -> void:
	# Given a zero or negative duration
	# When it is converted
	# Then the result is zero rather than a negative tick count
	assert_int(CadConst.seconds_to_ticks(0.0)).is_equal(0)
	assert_int(CadConst.seconds_to_ticks(-1.0)).is_equal(0)


func test_tick_constants_are_consistent() -> void:
	# Given the fixed 30 Hz simulation tick
	# When TICK_DT and TICK_HZ are combined
	# Then they describe the same rate
	assert_int(CadConst.TICK_HZ).is_equal(30)
	assert_float(CadConst.TICK_DT * float(CadConst.TICK_HZ)).is_equal_approx(1.0, 1e-9)


func test_capacities_are_positive_and_ordered() -> void:
	# Given the preallocated stores
	# When their capacities are read
	# Then all are positive, and interceptors outnumber threats as the design requires
	assert_int(CadConst.MAX_THREATS).is_greater(0)
	assert_int(CadConst.MAX_INTERCEPTORS).is_greater_equal(CadConst.MAX_THREATS)
	assert_int(CadConst.MAX_EMPLACEMENTS).is_greater(0)
	assert_int(CadConst.MAX_DISTRICTS).is_greater(0)
	assert_int(CadConst.EVENT_CAPACITY).is_greater(0)
	assert_int(CadConst.QUERY_BUFFER).is_greater(0)
	assert_int(CadConst.MAX_TICKS_PER_FRAME).is_greater(0)
	assert_float(CadConst.SPATIAL_CELL_M).is_greater(0.0)
	assert_int(CadConst.INVALID).is_equal(-1)
