# Handoff — CAD-FP-011 — CadEventLog ring buffer

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T09:25:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 30

## 2. Branch and checkpoint
- branch: card/CAD-FP-011-event-log
- last_pushed_commit: branch head
- last_green_commit: branch head

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `src/sim/cad_event_log.gd` | six parallel Packed arrays, allocation-free `push`, `clear`, `hash_contents` | done |
| `test/unit/sim/test_cad_event_log.gd` | 9 cases | done, green |

## 4. Tests
- red run first: `Could not find type "CadEventLog"` / `Identifier "CadEventLog" not declared`
- card suite → **9/9 pass**; full suite → **36/36 pass**, 0 orphans
- lint clean; typecheck `OK 11 scripts`; purity `OK`
- LOC: impl 69 (ceiling 70), test 81
- green on the first implementation attempt; no rework

## 5. Hypotheses
- none open.

## 6. Exact next step
CAD-FP-012 (`CadThreatStore`, struct-of-arrays with a free list). It is the first card with real
allocation discipline to prove, and the largest so far at a 120-LOC ceiling.

## 7. Blockers / questions for the human
- none.

## 8. Resume instructions for a successor
- read: this file → `src/sim/cad_event_log.gd` → architecture §D2.3 (the event row layout) and §D2.6.
- do NOT redo: the six-array layout or the hash strategy.
- design notes worth keeping:
  1. **The log drops rather than grows.** A tick producing more than `capacity` events is a simulation
     bug to fix, not a reason to allocate mid-tick, so the surplus increments `dropped` and stays
     visible. `test_overflow_is_counted_not_stored` and `test_arrays_never_resize` pin both halves.
  2. **`hash_contents()` hashes only `0..count`.** Hashing the whole buffer would fold in stale rows
     from a longer previous frame, so two runs that genuinely matched could disagree.
     `test_hash_ignores_events_beyond_the_used_range` covers exactly that: a cleared-and-refilled log
     must hash equal to a fresh one. This matters because the determinism golden test compares these
     hashes per wave, and a false mismatch there would be very hard to chase down.
  3. The `resize()`-returns-Error pattern from CAD-FP-010 recurs; it is factored into two small typed
     helpers rather than repeated six times.

## 9. Self-review checklist
- [x] contract implemented exactly (all fields and ten methods, default capacity from CadConst)
- [x] tests first; red run recorded
- [x] STD-TYPING and STD-SIM met; `push()` writes by index and allocates nothing
- [x] no new dependency
- [x] LOC within ceiling (69 ≤ 70)
- [x] diff limited to Scope
- [x] lint, typecheck, purity, suite green
- [x] handoff finalised; log closed; metrics row appended
