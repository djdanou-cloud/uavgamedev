# Handoff — CAD-FP-001 — Install and verify the toolchain

## 1. Status
- status: BLOCKED (awaiting the human; agents must not install software)
- last_updated_utc: 2026-09-08T00:00:00Z
- agent: Claude Opus 5 (Claude Code) — preparation only  session: 1  takeover_from: none
- time_spent_min: 15 (discovery + install-command preparation)

## 2. Branch and checkpoint
- branch: card/CAD-FP-002-scaffold (this card's only artefact is `docs/toolchain.md`, committed there)
- last_pushed_commit: (this commit)
- last_green_commit: n/a

## 3. Files
| path | intent | state |
|------|--------|-------|
| `docs/toolchain.md` | current-state probe, install commands with verified winget ids, the seven verification commands with paste slots, CI parity note | partial — §3 verification output is empty until the human runs it |

## 4. Tests
- command: the seven verification commands in `docs/toolchain.md` §3
- last_exit_code: not run
- failing_tests: n/a
- probe result (2026-09-08): Godot missing, JDK missing, Android SDK missing, adb missing,
  gdtoolkit missing; Python 3.14.0rc2 present; winget present.
- winget package ids confirmed against the `winget` source today: `GodotEngine.GodotEngine` 4.7.2,
  `EclipseAdoptium.Temurin.17.JDK` 17.0.20.101, `Google.PlatformTools` 37.0.1. This is a second,
  independent confirmation that 4.7.2 is the current stable Godot (A-01).

## 5. Hypotheses
- The winget Godot package may install only the GUI executable; the plan drives the **console** binary.
  If `Godot_v4.7.2-stable_win64_console.exe` is absent after install, use the official Windows zip
  (`docs/toolchain.md` §2 step 1).

## 6. Exact next step
Human: run the four install commands in `docs/toolchain.md` §2, set `GODOT_BIN`, install export
templates, then paste the seven outputs into §3 of that file. The Android SDK (step 4) is only needed
from CAD-FP-065 and may be deferred without blocking cards 002–064.

## 7. Blockers / questions for the human
- Installing software and accepting SDK licences is a human action by policy and by this card's Owner field.
- Decide whether to install the Android SDK now or at CAD-FP-065; the plan works either way.

## 8. Resume instructions for a successor
- read: `docs/toolchain.md`, then this file.
- do NOT redo: the probe or the package-id lookup (recorded above).
- when the human reports the tools are in place, verify by running §3's commands yourself before
  declaring CAD-FP-001 done, then unblock `/ai/handoffs/CAD-FP-002.md` item 6.

## 9. Self-review checklist
- [x] no software installed by the agent
- [x] package ids verified, not guessed
- [x] verification commands match the card's Test-first field
- [ ] outputs pasted — human action
