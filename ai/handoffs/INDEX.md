# Handoff registry (live)

One row per card that has ever been claimed. The human updates status to MERGED/ABANDONED at H-5; agents update the rest at every checkpoint. `tools/handoff_check.py` (AIOPS-4) flags IN_PROGRESS rows older than 7 days.

| card | status | branch | last_update_utc | agent | last_commit | notes |
|------|--------|--------|-----------------|-------|-------------|-------|
| CAD-FP-001 | TESTS_PASSING (partial) | card/CAD-FP-005-ci | 2026-09-08T03:30Z | Claude Opus 5 | branch head | Godot 4.7.2 + gdtoolkit installed and verified; JDK/Android SDK deferred to CAD-FP-065 |
| CAD-FP-002 | READY_FOR_REVIEW | main 638a3da + fixes on card/CAD-FP-005-ci | 2026-09-08T03:30Z | Claude Opus 5 | branch head | import clean; main_scene deferred, exclude_addons→directory_rules, four .gdignore added |
| CAD-FP-003 | READY_FOR_REVIEW | card/CAD-FP-005-ci | 2026-09-08T04:40Z | Claude Opus 5 | branch head | gdUnit4 6.2.1 vendored; suite exits 0, failing suite exits 100; test-suite warning convention added |
| CAD-FP-004 | READY_FOR_REVIEW | card/CAD-FP-005-ci | 2026-09-08T05:50Z | Claude Opus 5 | branch head | purity + typecheck gates; 7 tests green; found load()-returns-non-null and the self-load segfault |
| CAD-FP-005 | IN_PROGRESS | card/CAD-FP-005-ci | 2026-09-08T04:40Z | Claude Opus 5 | branch head | lint + import + typing gate + gdUnit4 steps; awaiting first CI run (repo is private, results unreadable from here) |
