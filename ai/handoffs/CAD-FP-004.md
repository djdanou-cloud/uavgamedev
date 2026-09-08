# Handoff — CAD-FP-004 — Script typecheck and sim-purity gates

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T05:50:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 55

## 2. Branch and checkpoint
- branch: card/CAD-FP-005-ci
- last_pushed_commit: branch head
- last_green_commit: branch head (all four gates green with negative controls)

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `tools/lib/cad_purity_check.gd` | `CadPurityCheck.scan_text` / `scan_dir`; two token classes | done |
| `tools/check_sim_purity.gd` | SceneTree runner, root from user args, `quit(0/1)` | done |
| `tools/check_scripts.gd` | loads every script under src/scenes/tools/test; `reload()` decides pass/fail | done |
| `tools/lint.sh` `.cmd`, `tools/typecheck.sh` `.cmd`, `tools/purity.sh` `.cmd` | wrappers; `GDLINT`/`GDFORMAT` overridable because gdtoolkit is not on PATH here | done |
| `test/unit/tools/test_cad_purity_check.gd` | 7 cases | done, green |
| `test/fixtures/purity/bad_sim.txt` `good_sim.txt` | one violation per line; a clean sim class that uses `_rng.randf()` | done |
| `.github/workflows/ci.yml` | `Typecheck every script` + `Sim purity` steps | done |
| `00-assumptions-register.md` A.0, backlog card delivery note | the two engine findings below | done |

## 4. Tests
- red run first: the suite failed with `Identifier "CadPurityCheck" not declared` before implementation
- `tools/test.sh res://test/unit/tools/test_cad_purity_check.gd` → **7/7 pass**, 0 orphans
- full suite → **9/9 pass**, exit 0
- typecheck positive: `OK 4 scripts`, exit 0
- typecheck negative 1 (untyped `var`): `FAIL res://src/cad_broken_probe.gd`, exit 1
- typecheck negative 2 (syntax error): `FAIL res://src/cad_syntax_probe.gd`, exit 1
- purity positive: `OK purity res://src/sim`, exit 0
- purity negative (bad fixture copied into `src/sim/`): 14 violations with correct line numbers, exit 1
- `tools/lint.sh` → gdlint clean, gdformat clean (5 files)

## 5. Hypotheses
- none open.

## 6. Exact next step
CAD-FP-009 (`CadConst` + `CadEnums`) — the first simulation card. Every gate it needs now exists and is
proven: lint, format, typecheck, purity, gdUnit4, and the CI job that runs all five.

## 7. Blockers / questions for the human
- Two contract refinements need your nod (item 8, findings 1 and 2). Both were forced by behaviour, not
  preference, and both are covered by tests.

## 8. Resume instructions for a successor
- read: this file → `tools/lib/cad_purity_check.gd` → the CAD-FP-004 card's delivery note.
- do NOT redo: the token-class split, the `reload()` discovery, or the self-load crash investigation.
- findings and contract refinements:
  1. **`FORBIDDEN` had to be split into two classes.** A plain substring match flags `rng.randf(` —
     which is exactly how the sim is *supposed* to draw randomness — and double-counts `preload(`
     because it contains `load(`. `FORBIDDEN` now holds tokens matched anywhere; `FORBIDDEN_GLOBAL`
     holds tokens that only count when not preceded by `.` or an identifier character. Two tests pin
     this (`test_scan_text_allows_method_call_forms`, `test_scan_text_separates_preload_from_load`).
  2. **`scan_dir` takes an `extension` parameter** (default `.gd`) so the fixtures can be scanned as
     `.txt`. Committing a deliberately broken `.gd` fixture would fail lint and typecheck.
  3. **`ResourceLoader.load()` returns a non-null `GDScript` for a file that failed to parse.** The
     card's abandon clause anticipated this; the fix was one line, so the card continued rather than
     stopping: the checker now tests `script.reload() != OK`. Without it, typecheck reported
     `OK 5 scripts` on a tree containing a deliberately broken file — it was passing everything.
  4. **A script that loads itself with `CACHE_MODE_IGNORE` segfaults the engine** (signal 11,
     reproduced twice). `check_scripts.gd` skips its own path via a `SELF_PATH` constant. It stays
     covered because a parse error in it would stop the tool from running at all.
  5. `get_script()` returns `Variant`, and `as Script` on a Variant is an `unsafe_cast` — an Error
     under A-10. That is why the self-path is a literal. Our own gate caught this during the card.

## 9. Self-review checklist
- [x] contract implemented, with the two refinements above documented and tested
- [x] tests written first; red run recorded before implementation
- [x] STD-TOOL respected: SceneTree scripts, work in `_init()`, `quit(0/1)`, one line per action, no deletes
- [x] STD-TYPING: no untyped declarations, no unsafe casts (the gate itself enforces this)
- [x] no new dependency
- [x] diff within Scope plus the CI steps and the documentation of findings
- [x] lint, format, typecheck, purity, suite all green locally, each with a negative control
- [x] handoff finalised; log closed; metrics row appended
- [x] every `[VERIFY]` this card carried is resolved
