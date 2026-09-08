class_name CadConst
extends RefCounted

## Fixed simulation constants: tick rate, store capacities and sentinels.
##
## Capacities are hard limits and are never grown at runtime (STD-SIM): an allocation that cannot be
## served returns INVALID instead. The design cap of 200 concurrent threats (A-06) sits well inside
## MAX_THREATS, so the wave director queues spawns rather than dropping them.

const TICK_HZ: int = 30
const TICK_DT: float = 1.0 / 30.0

## Ticks the driver may run in one frame before it lets time dilate instead of spiralling.
const MAX_TICKS_PER_FRAME: int = 6

const MAX_THREATS: int = 512
const MAX_INTERCEPTORS: int = 1024
const MAX_EMPLACEMENTS: int = 64
const MAX_DISTRICTS: int = 16
const MAX_SENSORS: int = 32
const EVENT_CAPACITY: int = 4096

## Size of the caller-provided buffer every spatial query writes into.
const QUERY_BUFFER: int = 512

const SPATIAL_CELL_M: float = 500.0

## Returned by allocations that found no free slot and by lookups that found nothing.
const INVALID: int = -1


## Converts an authored duration into whole ticks, rounding up so that any fraction of a tick still
## costs a full one. Non-positive input yields 0. Called when definitions load, never inside a tick.
static func seconds_to_ticks(seconds: float) -> int:
	if seconds <= 0.0:
		return 0
	# ceilf, not ceil: the untyped global returns Variant, which int() cannot take under A-10.
	return int(ceilf(seconds * float(TICK_HZ)))
