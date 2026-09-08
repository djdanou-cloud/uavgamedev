# Handoff — CAD-FP-009 — CadConst and CadEnums (sim contracts)

## 1. Status
- status: IN_PROGRESS (claim)
- last_updated_utc: 2026-09-08T06:40:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 5

## 2. Branch and checkpoint
- branch: card/CAD-FP-009-const-enums
- last_pushed_commit: (claim commit)
- last_green_commit: n/a

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `src/sim/cad_const.gd` | tick rate, capacities, sentinels, `seconds_to_ticks` | planned |
| `src/sim/cad_enums.gd` | the 20 enums every later sim card references | planned |
| `test/unit/sim/test_cad_enums.gd` | enum sizes, `band_bit`, `seconds_to_ticks`, tick maths, capacities | planned |

## 4. Tests
- command: `tools/test.sh res://test/unit/sim/test_cad_enums.gd`
- last_exit_code: not yet run
- plan: write the suite first, record the red run, then implement.

## 5. Hypotheses
- none yet.

## 6. Exact next step
Write `test/unit/sim/test_cad_enums.gd` from the card's Test-first field, parse-check it
(`--check-only`, per the CAD-FP-003 lesson that an unparseable suite hangs the CLI), record the red
run here, then implement the two source files.

## 7. Blockers / questions for the human
- none.

## 8. Resume instructions for a successor
- read: the CAD-FP-009 card in `docs/production/09-execution-backlog.md` (the contract is written out
  in full there) → `docs/production/01-design-bible.md` B.2/B.3/B.12 for the value lists → this file.
- do NOT redo: nothing yet.
- watch for: enum member order is a save-format contract (AGENTS.md §3) — append only, never reorder;
  new `class_name` files need one `--import` before `--check-only` or the tests resolve them.

## 9. Self-review checklist
- [ ] contract implemented exactly
- [ ] tests first (red run recorded)
- [ ] STD-TYPING / STD-SIM met
- [ ] no allocation in tick paths
- [ ] no new dependency
- [ ] diff within Scope and LOC ceiling (≤ 110)
- [ ] lint, typecheck, purity, suite green
- [ ] handoff finalised; log closed; metrics row appended
