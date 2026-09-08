class_name CadEnums
extends RefCounted

## Every enumeration the simulation, the save file and the event log share.
##
## Member order is a contract (AGENTS.md section 3): saves and the event log store these as plain
## integers, so members may be appended but never reordered or removed.

enum ThreatClass { RECON, FPV, OWA, CRUISE, SRBM, DECOY, JAMMER, SEAD, GLIDE }

## Altitude bands. Emplacement coverage is a bitmask built with band_bit().
enum AltBand { LOW, MED, HIGH, BALLISTIC }

enum Guidance { SATNAV, DATALINK, INS, TERCOM, BALLISTIC, ANTI_RADIATION }

enum TargetPref {
	DISTRICT_VALUE,
	DISTRICT_NEAREST,
	EMPLACEMENT_NEAREST,
	EMITTER_NEAREST,
	EMITTER_REVEALED,
	REVEAL_ORBIT,
	JAM_ORBIT,
	PASS_THROUGH,
}

enum ThreatState { SPAWNED, INGRESS, TERMINAL, ORBIT, WANDER, CRASHED, KILLED, IMPACTED, EXITED }

## Packed into one integer per threat, so each member owns a distinct bit.
enum ThreatFlag { CLASSIFIED = 1, JAMMED = 2, REVEALER = 4 }

enum EmpKind {
	SENSOR_SEARCH,
	SENSOR_FCR,
	SENSOR_PASSIVE,
	GUN_AAA,
	GUN_CIWS,
	LAUNCHER_SHORAD,
	LAUNCHER_MRSAM,
	LAUNCHER_LRSAM,
	LAUNCHER_UAV,
	EW_JAMMER,
	DECOY_EMITTER,
	C2_NODE,
	LOGISTICS,
	REPAIR,
	HARDENING,
}

enum EmpState { PLACING, ACTIVE, RELOADING, RELOCATING, DESTROYED }

enum Roe { HOLD, TIGHT, FREE }

enum Priority { NEAREST_IMPACT, HIGHEST_VALUE, FASTEST, BEST_EXCHANGE }

## How well a shooter can see a threat: no cue, its own sensor, a friendly cue, or a fire-control
## track. Each step multiplies the probability of kill (design bible B.5.5).
enum EngageMode { NONE, ORGANIC, CUED, TRACKED }

enum InterceptorState { FLYING, RESOLVED }

enum WaveState { IDLE, SPAWNING, ACTIVE, CLEARED, FAILED }

enum GameState { BOOT, TITLE, CAMPAIGN, TECH, BUILD, WAVE, DEBRIEF, RUN_END, PAUSED }

enum CommandType {
	PLACE,
	SELL,
	RELOCATE,
	UPGRADE,
	SET_DOCTRINE,
	RESTOCK,
	REPAIR_DISTRICT,
	REPAIR_EMPLACEMENT,
	MANUAL_FIRE,
	HARDEN_DISTRICT,
}

enum CommandResult {
	OK,
	REJECTED_FUNDS,
	REJECTED_ZONE,
	REJECTED_OVERLAP,
	REJECTED_CAPACITY,
	REJECTED_STATE,
	REJECTED_TARGET,
	REJECTED_LOCKED,
}

enum EventType {
	THREAT_SPAWNED,
	THREAT_DETECTED,
	THREAT_LOST,
	TRACK_ASSIGNED,
	TRACK_DROPPED,
	SHOT_FIRED,
	BURST_FIRED,
	INTERCEPT_HIT,
	INTERCEPT_MISS,
	THREAT_KILLED,
	THREAT_IMPACT,
	THREAT_CRASHED,
	THREAT_EXITED,
	DISTRICT_DAMAGED,
	EMPLACEMENT_DAMAGED,
	EMPLACEMENT_DESTROYED,
	LINK_LOST,
	LINK_REGAINED,
	WAVE_STARTED,
	WAVE_CLEARED,
	RUN_ENDED,
	FUNDS_CHANGED,
	COMMAND_RESULT,
	RELOAD_STARTED,
	RELOAD_DONE,
}

enum TechEffect {
	UNLOCK_EMPLACEMENT,
	STAT_MULT,
	STAT_ADD,
	PK_ADD,
	CONFIG_ADD,
	CONFIG_MULT,
	DOCTRINE_UNLOCK,
}

## Independent random streams, so changing combat rolls cannot shift wave composition (A-17).
enum RngStream { WAVEGEN, COMBAT, MOTION }

enum TargetKind { NONE, DISTRICT, EMPLACEMENT, POINT }


## The coverage bit for one altitude band; emplacement coverage masks are these OR-ed together.
static func band_bit(band: int) -> int:
	return 1 << band
