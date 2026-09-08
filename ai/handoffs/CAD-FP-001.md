# Handoff — CAD-FP-001 — Install and verify the toolchain

## 1. Status
- status: TESTS_PASSING (partial) — the desktop half is installed and verified; the Android half
  (JDK 17, Android SDK, adb, export templates) is deliberately deferred to CAD-FP-065, which is the
  first card that needs it. Cards 002–064 are unblocked.
- last_updated_utc: 2026-09-08T03:30:00Z
- agent: Claude Opus 5 (Claude Code)  session: 2  takeover_from: session 1
- time_spent_min: 35

## 2. Branch and checkpoint
- branch: card/CAD-FP-005-ci (this card's artefact is `docs/toolchain.md`)
- last_pushed_commit: see branch head
- last_green_commit: same

## 3. Files
| path | intent | state |
|------|--------|-------|
| `docs/toolchain.md` | state table, install commands, resolved paths, real verification output, and the four engine findings that came out of the first session | done for the desktop half |

## 4. Tests
- `"$GODOT_BIN" --version` → `4.7.2.stable.official.ed1daf0bf` (matches A-01 exactly)
- `gdlint --version` → `gdlint 4.5.0`; `gdformat --version` → `gdformat 4.5.0`
- `"$GODOT_BIN" --headless --path . --import` → no ERROR/WARNING/SCRIPT ERROR after the CAD-FP-002 fixes
- `gdlint` on a deliberately bad file → 2 errors (`class-name`, `function-name`), exit 1: the `.gdlintrc`
  option names in A-09 are real and enforced
- `python tools/tests/test_scaffold.py` → PASS
- deferred: `java -version`, `sdkmanager --list_installed`, `adb version` (CAD-FP-065 / CAD-FP-008)

## 5. Hypotheses
- none open for the desktop half.

## 6. Exact next step
Nothing for this card until CAD-FP-065. At that point: install Temurin 17 + Google.PlatformTools + the
Android SDK packages listed in `docs/toolchain.md` §2, install export templates, then fill the deferred
verification lines in §4.

## 7. Blockers / questions for the human
- gdtoolkit's scripts directory is not on PATH (`...\Python\pythoncore-3.14-64\Scripts\`). Tools call
  the binaries by full path today; add it to PATH once if you prefer bare `gdlint`/`gdformat`.
- `GODOT_BIN` was set with `setx`, so it exists only in shells started after 2026-09-08.

## 8. Resume instructions for a successor
- read: `docs/toolchain.md` (paths, real outputs, the four findings).
- do NOT redo: the winget/pip installs, the package-id lookup, or the settings probes — all recorded.
- the console binary, not the GUI one, is `GODOT_BIN`; both live in the same winget package folder.

## 9. Self-review checklist
- [x] no software installed without the human's explicit instruction ("figure out godot")
- [x] versions verified against A-01, not assumed
- [x] real command output recorded, not paraphrased
- [x] Android half left open with the card that needs it named
