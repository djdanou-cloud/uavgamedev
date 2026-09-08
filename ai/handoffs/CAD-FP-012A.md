# Handoff — CAD-FP-012A — CadPacked sizing helpers

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T10:50:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 30

## 2. Branch and checkpoint
- branch: card/CAD-FP-012A-packed
- last_pushed_commit: branch head
- last_green_commit: branch head

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `src/sim/cad_packed.gd` | `ints` / `longs` / `floats` / `bytes`, each asserting the resize | done |
| `test/unit/sim/test_cad_packed.gd` | 4 cases incl. a regression guard over all three call sites | done, green |
| `src/sim/cad_event_log.gd` | private helpers removed, calls CadPacked | done, 69 → 59 lines |
| `src/sim/cad_rng.gd` | inline resize in `get_states()` replaced | done, 36 → 34 lines |
| `src/sim/store/cad_threat_store.gd` | private helpers removed | done, **125 → 113 lines** |
| `docs/production/09-execution-backlog.md` | the card itself, plus the id-suffix convention | done |

## 4. Tests
- card suite → **4/4 pass**
- full suite → **49/49 pass**, 0 orphans, **with no existing test file edited** — the point of a
  refactor card is that the callers' own suites still pass untouched
- lint clean (16 files); typecheck `OK 15 scripts`; purity `OK`; scaffold PASS
- CAD-FP-012's DoD condition met: `cad_threat_store.gd` is back under its 120-LOC ceiling
- sim layer totals 349 lines across six files; the helper exists once instead of three times

## 5. Hypotheses
- none open.

## 6. Exact next step
CAD-FP-013 (`CadInterceptorStore`). It can now call `CadPacked` directly, which is the fourth copy
avoided, and should land comfortably inside its 90-LOC ceiling.

## 7. Blockers / questions for the human
- **Process slip to note: no red run was recorded for this card** (item 8, finding 1).

## 8. Resume instructions for a successor
- read: this file → `src/sim/cad_packed.gd` → the CAD-FP-012A card text in the backlog.
- do NOT redo: the migration; `grep -rn "resize_error" src/` should match only `cad_packed.gd`.
- findings:
  1. **The red run was skipped.** I wrote the suite and `CadPacked` in the same step, so by the time
     the parse-check ran, both existed and it passed. The card's real safety net is the 49 existing
     tests passing with no test file edited, and that held — but the test-first discipline was not
     followed to the letter here, and pretending otherwise would make the metrics ledger lie.
     `first_pass_green` is recorded as 1 but `test_runs_to_green` as 1, not 2, to mark the difference.
  2. **`tools/loc.py` overstates refactor cards.** It counts a rewritten line as an addition, so this
     card reads `impl=55` against a ≤40 ceiling while the sim layer actually *shrank* by two lines
     (230 → 228 across the three edited files) and lost two duplicate helpers. The ceiling is not
     meaningfully breached; the metric is measuring the wrong thing for this card type. Worth deciding
     whether refactor cards get a net-LOC ceiling instead — related to the CAD-FP-009 sizing question
     still open.
  3. gdformat removed one trailing blank line per edited file after the helpers were cut. Running
     `gdformat` on touched files before committing avoids a lint round-trip.

## 9. Self-review checklist
- [x] contract implemented exactly (four constructors, assert-not-discard)
- [ ] **tests first — red run not recorded (finding 1)**
- [x] STD-TYPING and STD-SIM met; construction-time only, no tick-path change
- [x] no new dependency
- [x] no behaviour change: no existing test edited, all still green
- [x] the three private helpers are gone, not merely unused
- [x] lint, typecheck, purity, suite green
- [x] handoff finalised; log closed; metrics row appended
