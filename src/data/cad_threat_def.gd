class_name CadThreatDef
extends Resource

@export var schema_version: int = 1
@export var id: StringName = &""
@export var display_name: String = ""
@export var threat_class: CadEnums.ThreatClass = CadEnums.ThreatClass.RECON
@export var cost: int = 0
@export var hp: float = 0.0
@export var speed_mps: float = 0.0
@export var alt_band: CadEnums.AltBand = CadEnums.AltBand.LOW
@export var altitude_m: float = 0.0
@export var rcs_m2: float = 0.0
@export var apparent_rcs_m2: float = 0.0
@export var guidance: CadEnums.Guidance = CadEnums.Guidance.SATNAV
@export var damage: float = 0.0
@export var target_pref: CadEnums.TargetPref = CadEnums.TargetPref.DISTRICT_VALUE
@export var eccm_level: int = 0
@export var jam_radius_m: float = 0.0
@export var jam_strength: float = 0.0
@export var sensor_radius_m: float = 0.0
@export var orbit_time_s: float = 0.0
@export var wander_time_s: float = 12.0
@export var intro_wave: int = 1
@export var salvage_mult: float = 1.0
@export var sprite_id: StringName = &""


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if id == &"":
		errors.append("id must not be empty")
	if cost < 0:
		errors.append("cost must be nonnegative")
	if hp <= 0.0:
		errors.append("hp must be positive")
	if speed_mps <= 0.0:
		errors.append("speed_mps must be positive")
	if rcs_m2 <= 0.0:
		errors.append("rcs_m2 must be positive")
	if intro_wave < 1:
		errors.append("intro_wave must be at least 1")
	if apparent_rcs_m2 < 0.0:
		errors.append("apparent_rcs_m2 must be nonnegative")
	if jam_radius_m > 0.0 and jam_strength <= 0.0:
		errors.append("jam_strength must be positive when jam_radius_m is positive")
	return errors
