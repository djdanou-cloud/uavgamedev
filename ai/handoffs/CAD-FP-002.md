# Handoff — CAD-FP-002 — Repository scaffold and project.godot

## 1. Status
- status: READY_FOR_REVIEW — the blocker is gone. Godot 4.7.2 is installed, all four verification
  commands ran, two real defects the import gate exposed were fixed, and every `[VERIFY]` this card
  carried is now resolved with evidence.
- last_updated_utc: 2026-09-08T03:30:00Z
- agent: Claude Opus 5 (Claude Code)  session: 2  takeover_from: session 1
- time_spent_min: 55 + 40

## 2. Branch and checkpoint
- branch: session 1 merged to `main` as `638a3da`; the fixes below ride on `card/CAD-FP-005-ci`
- last_pushed_commit: see branch head
- last_green_commit: same

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `project.godot` | D1.1 settings | done, **engine-verified**; two corrections (below) |
| `.gitignore` `.gitattributes` `.editorconfig` | git hygiene | done; `git check-attr` confirms `text`/`eol=lf` |
| `.gdlintrc` | A-09 values | done, **verified**: a bad file trips `class-name` and `function-name`, exit 1 |
| `art/icons/cad_icon.svg` | app icon | done; imports cleanly (`reimport | cad_icon.svg`) |
| `tools/loc.py` | LOC counter | done, tested |
| `README.md`, 63 × `.gdkeep` | entry points, D7 tree | done |
| `ai/.gdignore` `docs/.gdignore` `data/csv/.gdignore` `test/fixtures/csv/.gdignore` | **new** — stop Godot importing our CSVs as translations | done |

Corrections made after the engine ran:
1. `run/main_scene` removed until CAD-FP-063 creates `scenes/app/cad_boot.tscn`. Pointing at a
   missing scene made every import log `ERROR: Cannot open file`, which the CI gate rejects.
2. `gdscript/warnings/exclude_addons=true` → `gdscript/warnings/directory_rules={"res://addons": 0}`.
   `exclude_addons` is a Godot 3 name that 4.x ignores silently — it would have left the vendored
   gdUnit4 addon under our strict warnings from CAD-FP-003 on, with no error to explain it.

## 4. Tests
- `"$GODOT_BIN" --headless --path . --import` → **no ERROR/WARNING/SCRIPT ERROR** (was: 15 translation
  warnings + 2 missing-scene errors before the fixes)
- `gdlint` / `gdformat --check`: verified against good and bad fixture files (exit 0 / exit 1)
- `git check-attr -a project.godot` → `text: set`, `eol: lf`
- `python tools/tests/test_scaffold.py` → PASS, and its new guards were negative-controlled: adding a
  real `gdscript/warnings/exclude_addons=` line makes it fail, removing it makes it pass
- exit code note: `--import` returned **0 despite logging errors**, which is why the CI gate greps the
  log instead of trusting the exit code

## 5. Hypotheses
- none open.

## 6. Exact next step
Human review, then this card is done. CAD-FP-003 (gdUnit4) is unblocked and is the next card.

## 7. Blockers / questions for the human
- none.

## 8. Resume instructions for a successor
- do NOT redo: the scaffold, the fixes, or the settings probes.
- `[VERIFY]` items resolved by this session (all recorded in A.0):
  - `debug/gdscript/warnings/*` — seven names engine-declared, hint `Ignore,Warn,Error`, gate enforced.
  - `exclude_addons` — does not exist in Godot 4; `directory_rules` replaces it.
  - `importer_defaults.texture` — accepted; the SVG imported at scale 2.0 without complaint.
  - `display/window/handheld/orientation=4` and the `input_devices/pointing/android/*` keys — accepted by
    the engine (they parse and persist; **behaviour on a device is still unproven** until CAD-FP-065).
  - `.gdlintrc` option names — accepted and enforced by gdtoolkit 4.5.0.
- still open: the `[input]` actions (must be generated from the editor's Input Map, not hand-written).

## 9. Self-review checklist
- [x] contract implemented exactly
- [x] tests first where they could exist; engine checks run as soon as the engine existed
- [x] STD-TOOL for `loc.py`
- [x] no new dependency; icon is code-authored
- [x] diff within Scope (plus the four `.gdignore` files the import gate proved necessary)
- [x] lint, import, scaffold tests green
- [x] handoff finalised; log closed
- [x] every `[VERIFY]` resolved except the editor-generated `[input]` block, which is CAD-FP-063's

Note carried from session 1: `tools/loc.py` is 62 lines against the card's 60-line ceiling (docstring +
the utf-8 fix comment). Still flagged for your call.
