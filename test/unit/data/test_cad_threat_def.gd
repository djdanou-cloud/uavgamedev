extends GdUnitTestSuite
@warning_ignore_start("return_value_discarded")


func test_defaults() -> void:
	var def: CadThreatDef = CadThreatDef.new()
	assert_int(def.schema_version).is_equal(1)
	assert_float(def.salvage_mult).is_equal(1.0)
	assert_int(def.eccm_level).is_equal(0)
	assert_float(def.wander_time_s).is_equal(12.0)
	assert_int(def.intro_wave).is_equal(1)
	assert_float(def.apparent_rcs_m2).is_equal(0.0)
	assert_float(def.jam_radius_m).is_equal(0.0)
	assert_float(def.jam_strength).is_equal(0.0)
	assert_float(def.sensor_radius_m).is_equal(0.0)
	assert_float(def.orbit_time_s).is_equal(0.0)


func test_validate_flags_each_rule(
	rule: int, _test_parameters: Array[Array] = [[0], [1], [2], [3], [4], [5], [6], [7]]
) -> void:
	var def: CadThreatDef = _valid_def()
	var fields: PackedStringArray = [
		"id", "cost", "hp", "speed_mps", "rcs_m2", "intro_wave", "apparent_rcs_m2", "jam_strength"
	]
	match rule:
		0:
			def.id = &""
		1:
			def.cost = -1
		2:
			def.hp = 0.0
		3:
			def.speed_mps = 0.0
		4:
			def.rcs_m2 = 0.0
		5:
			def.intro_wave = 0
		6:
			def.apparent_rcs_m2 = -0.1
		7:
			def.jam_strength = 0.0
	var errors: PackedStringArray = def.validate()
	assert_int(errors.size()).is_equal(1)
	if errors.size() == 1:
		assert_str(errors[0]).contains(fields[rule])


func test_valid_boundaries_and_disabled_jammer() -> void:
	var def: CadThreatDef = _valid_def()
	def.cost = 0
	def.hp = 0.001
	def.speed_mps = 0.001
	def.rcs_m2 = 0.001
	def.intro_wave = 1
	def.apparent_rcs_m2 = 0.0
	def.jam_radius_m = 0.0
	def.jam_strength = 0.0
	assert_array(def.validate()).is_empty()
	def.jam_radius_m = 0.001
	def.jam_strength = 0.001
	assert_array(def.validate()).is_empty()


func test_reports_all_errors_in_field_order_without_mutation() -> void:
	var def: CadThreatDef = _valid_def()
	def.id = &""
	def.cost = -1
	def.hp = -1.0
	def.speed_mps = -1.0
	def.rcs_m2 = -1.0
	def.intro_wave = -1
	def.apparent_rcs_m2 = -1.0
	def.jam_strength = -1.0
	var first: PackedStringArray = def.validate()
	assert_int(first.size()).is_equal(8)
	assert_array(def.validate()).is_equal(first)
	assert_float(def.hp).is_equal(-1.0)
	assert_float(def.jam_strength).is_equal(-1.0)


func test_tres_roundtrip() -> void:
	var original: CadThreatDef = _valid_def()
	var error: Error = DirAccess.make_dir_recursive_absolute("user://t")
	assert_int(error).is_equal(OK)
	assert_int(ResourceSaver.save(original, "user://t/threat.tres")).is_equal(OK)
	var restored: CadThreatDef = (
		ResourceLoader.load("user://t/threat.tres", "", ResourceLoader.CACHE_MODE_IGNORE)
		as CadThreatDef
	)
	assert_object(restored).is_not_null()
	if restored == null:
		return
	assert_bool(restored == original).is_false()
	_assert_same_fields(original, restored)
	assert_array(restored.validate()).is_empty()


func _valid_def() -> CadThreatDef:
	var def: CadThreatDef = CadThreatDef.new()
	def.id = &"cad_thr_jammer"
	def.display_name = "Signal decoy"
	def.threat_class = CadEnums.ThreatClass.JAMMER
	def.cost = 321
	def.hp = 22.5
	def.speed_mps = 45.5
	def.alt_band = CadEnums.AltBand.HIGH
	def.altitude_m = 1600.5
	def.rcs_m2 = 0.25
	def.apparent_rcs_m2 = 0.5
	def.guidance = CadEnums.Guidance.INS
	def.damage = 10.5
	def.target_pref = CadEnums.TargetPref.JAM_ORBIT
	def.eccm_level = 2
	def.jam_radius_m = 5000.5
	def.jam_strength = 0.75
	def.sensor_radius_m = 4000.5
	def.orbit_time_s = 90.5
	def.wander_time_s = 15.5
	def.intro_wave = 9
	def.salvage_mult = 1.5
	def.sprite_id = &"thr_jammer"
	return def


func _assert_same_fields(a: CadThreatDef, b: CadThreatDef) -> void:
	assert_int(b.schema_version).is_equal(a.schema_version)
	assert_str(b.id).is_equal(a.id)
	assert_str(b.display_name).is_equal(a.display_name)
	assert_int(b.threat_class).is_equal(a.threat_class)
	assert_int(b.cost).is_equal(a.cost)
	assert_float(b.hp).is_equal(a.hp)
	assert_float(b.speed_mps).is_equal(a.speed_mps)
	assert_int(b.alt_band).is_equal(a.alt_band)
	assert_float(b.altitude_m).is_equal(a.altitude_m)
	assert_float(b.rcs_m2).is_equal(a.rcs_m2)
	assert_float(b.apparent_rcs_m2).is_equal(a.apparent_rcs_m2)
	assert_int(b.guidance).is_equal(a.guidance)
	assert_float(b.damage).is_equal(a.damage)
	assert_int(b.target_pref).is_equal(a.target_pref)
	assert_int(b.eccm_level).is_equal(a.eccm_level)
	assert_float(b.jam_radius_m).is_equal(a.jam_radius_m)
	assert_float(b.jam_strength).is_equal(a.jam_strength)
	assert_float(b.sensor_radius_m).is_equal(a.sensor_radius_m)
	assert_float(b.orbit_time_s).is_equal(a.orbit_time_s)
	assert_float(b.wander_time_s).is_equal(a.wander_time_s)
	assert_int(b.intro_wave).is_equal(a.intro_wave)
	assert_float(b.salvage_mult).is_equal(a.salvage_mult)
	assert_str(b.sprite_id).is_equal(a.sprite_id)
