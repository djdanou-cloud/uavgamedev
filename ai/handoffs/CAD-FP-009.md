# Handoff — CAD-FP-009 — CadConst and CadEnums (sim contracts)

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T07:30:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 50

## 2. Branch and checkpoint
- branch: card/CAD-FP-009-const-enums
- last_pushed_commit: branch head
- last_green_commit: branch head

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `src/sim/cad_const.gd` | tick rate, capacities, `INVALID`, `seconds_to_ticks` | done |
| `src/sim/cad_enums.gd` | the 20 shared enums + `band_bit` | done |
| `test/unit/sim/test_cad_enums.gd` | 8 cases | done, green |
| `AGENTS.md` / `CLAUDE.md` | new Math row (typed math variants) forced by finding 1 | done |

## 4. Tests
- red run recorded first: `Identifier "CadConst" not declared`, `Identifier "CadEnums" not declared`
- `tools/test.sh res://test/unit/sim/test_cad_enums.gd` → **8/8 pass**, 0 orphans
- full suite → **17/17 pass**, 0 orphans, exit 0
- lint → clean (8 files); typecheck → `OK 7 scripts`; purity → `OK purity res://src/sim`
- scaffold checks → PASS

## 5. Hypotheses
- none open.

## 6. Exact next step
CAD-FP-010 (`CadRng`, seeded multi-stream RNG). Its contract is in the backlog; it depends only on
this card, which is now merged-ready.

## 7. Blockers / questions for the human
- **LOC ceiling exceeded: 121 implementation lines against the card's 110** (see finding 2). Nothing
  can be cut without breaking the contract; the fix belongs in how such cards are sized, not in the code.

## 8. Resume instructions for a successor
- read: this file → `src/sim/cad_enums.gd` → AGENTS.md §3 (contract digest).
- do NOT redo: the enum lists (they match design bible B.2/B.3/B.12 and the card contract exactly).
- findings:
  1. **Godot's untyped math globals return `Variant`.** `int(ceil(x))` fails under A-10 with
     *"argument 1 of the constructor int() requires int, bool or float but Variant was provided"*.
     The typed variants (`ceilf`, `floorf`, `roundf`, `absf`, `maxf`, `minf`) are required in typed
     code. Added as a Math row in AGENTS.md §2 because every later sim card will meet this.
  2. **The 110-LOC ceiling is not reachable for this card.** `cad_enums.gd` counts 103 lines because
     six enums (TargetPref, EmpKind, CommandType, CommandResult, EventType, TechEffect) exceed the
     100-character line limit and are therefore one member per line — EventType alone is 25 members.
     The content is exactly what the card's contract prescribes: 20 enums, no extras. Suggested rule
     change for the human: size declaration-only files by declarations rather than lines, or raise the
     ceiling for cards whose contract is a fixed list. I did not split the file, because "one file per
     class_name" is a stronger convention than the line budget.
  3. **`tools/loc.py` cannot see untracked files** — `git diff` ignores them, so the count reads 0
     until `git add`. Workaround: `git add -N .` (or stage) before measuring. Worth a one-line note in
     the tool's docstring on a later card; out of scope here.
  4. Re-confirmed the CAD-FP-003 hang: the first suite run sat until the 300 s timeout because
     `cad_const.gd` had a parse error. Parse-checking all three files with `--check-only` before
     running the suite is now my standing habit and cost seconds instead of five minutes.

## 9. Self-review checklist
- [x] contract implemented exactly (12 constants, 20 enums, both static helpers, member order as written)
- [x] tests first; red run recorded before implementation
- [x] STD-TYPING and STD-SIM met; purity gate green on the new files
- [x] no allocation concerns (constants and enums only)
- [x] no new dependency
- [ ] **LOC within ceiling — 121 vs 110, flagged above for your decision**
- [x] diff limited to Scope plus the AGENTS.md Math row
- [x] lint, typecheck, purity, suite green
- [x] handoff finalised; log closed; metrics row appended
