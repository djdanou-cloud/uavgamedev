# Handoff — CAD-FP-010 — CadRng seeded multi-stream RNG

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T08:40:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 45

## 2. Branch and checkpoint
- branch: card/CAD-FP-010-rng
- last_pushed_commit: branch head
- last_green_commit: branch head

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `src/sim/cad_rng.gd` | three seeded streams, state save/restore, `chance()` | done |
| `test/unit/sim/test_cad_rng.gd` | 9 cases | done, green |
| `tools/lib/cad_purity_check.gd` | **cross-card fix**: a declaration is not a call (finding 1) | done |
| `test/unit/tools/test_cad_purity_check.gd` | one case pinning that fix | done, green |

## 4. Tests
- red run first: `Could not find type "CadRng"` / `Identifier "CadRng" not declared`
- `tools/test.sh res://test/unit/sim/test_cad_rng.gd` → **9/9 pass**
- full suite → **27/27 pass**, 0 orphans, exit 0
- lint clean (10 files); typecheck `OK 9 scripts`; purity `OK`; scaffold PASS
- purity negative control re-run after the checker change: still `FAIL 14 violations`
- LOC: impl 44 (ceiling 60), test 79

## 5. Hypotheses
- none open.

## 6. Exact next step
CAD-FP-011 (`CadEventLog`, the allocation-free ring buffer). Depends only on CAD-FP-009, already merged.

## 7. Blockers / questions for the human
- One cross-card edit to `tools/lib/cad_purity_check.gd` (finding 1). It was that or rename the
  contract's `randf`/`randi_range` methods, which would have been the wrong fix.

## 8. Resume instructions for a successor
- read: this file → `src/sim/cad_rng.gd` → A-17/A-18 in the assumptions register.
- do NOT redo: the stream layout, the `chance()` short-circuit, or the purity-checker fix.
- findings:
  1. **The purity checker flagged `func randf(` as a forbidden global call.** CadRng's contract
     names those methods, so the checker was wrong, not the code: `_is_global_call_at()` now treats a
     match preceded by `func ` as a declaration. A test pins both halves — declarations pass, a real
     `randf()` call is still caught — and the 14-violation negative control still fires.
  2. **`chance()` must not draw at p ≤ 0 or p ≥ 1.** Spending a roll on a certain outcome would shift
     every later draw for the same seed and break replays. `test_chance_extremes_consume_no_randomness`
     asserts the stream state is unchanged across four extreme calls.
  3. **`PackedInt64Array.resize()` returns an Error that A-10 forbids discarding.** `get_states()`
     captures it into a typed variable and asserts on it rather than suppressing the warning.
  4. **GDScript accepts a literal newline inside a `"..."` string; gdtoolkit 4.5.0's parser does not.**
     A test line that Godot compiled and ran happily made `gdlint` fail with a parser error. Lint can
     therefore reject code the engine accepts — keep string literals on one line.
  5. Confirmed harmless: a parameter named `seed` shadows the global `seed()` but produces no
     Error-level warning, and Warn-level GDScript warnings never appear in headless output at all
     (probed before writing the class), so the CI import gate cannot trip on them.

## 9. Self-review checklist
- [x] contract implemented exactly (all nine members, streams seeded `seed_value + stream`)
- [x] tests first; red run recorded
- [x] STD-TYPING and STD-SIM met; purity green on the new file
- [x] no allocation in tick paths (`get_states` is a save-time call, and it is the only allocator)
- [x] no new dependency
- [x] diff within Scope plus the documented cross-card checker fix
- [x] LOC within ceiling (44 ≤ 60)
- [x] lint, typecheck, purity, suite green
- [x] handoff finalised; log closed; metrics row appended
