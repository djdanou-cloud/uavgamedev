# Handoff registry (live)

One row per card that has ever been claimed. The human updates status to MERGED/ABANDONED at H-5; agents update the rest at every checkpoint. `tools/handoff_check.py` (AIOPS-4) flags IN_PROGRESS rows older than 7 days.

| card | status | branch | last_update_utc | agent | last_commit | notes |
|------|--------|--------|-----------------|-------|-------------|-------|
| CAD-FP-001 | MERGED (desktop half) | merged to main | 2026-09-08T06:10Z | Claude Opus 5 | 1c7ac67 | Godot 4.7.2 + gdtoolkit installed and verified; JDK/Android SDK deferred to CAD-FP-065 |
| CAD-FP-002 | MERGED | merged to main | 2026-09-08T06:10Z | Claude Opus 5 | 1c7ac67 | import clean; main_scene deferred, exclude_addons -> directory_rules, four .gdignore added |
| CAD-FP-003 | MERGED | merged to main | 2026-09-08T06:10Z | Claude Opus 5 | 1c7ac67 | gdUnit4 6.2.1 vendored; suite exits 0, failing suite exits 100; test-suite warning convention added |
| CAD-FP-004 | MERGED | merged to main | 2026-09-08T06:10Z | Claude Opus 5 | 1c7ac67 | purity + typecheck gates; 7 tests green; found load()-returns-non-null and the self-load segfault |
| CAD-FP-005 | MERGED (stage 1) | merged to main | 2026-09-08T06:10Z | Claude Opus 5 | 1c7ac67 | lint, import, typecheck, purity, typing gate and gdUnit4 steps; first CI run not yet read (private repo) |
| CAD-FP-009 | MERGED | merged to main | 2026-09-08T07:50Z | Claude Opus 5 | 98b7f28 | CadConst + CadEnums; 8/8 green, branch CI green; LOC 121 vs ceiling 110 still open for the human |
| CAD-FP-010 | MERGED | merged to main | 2026-09-08T09:00Z | Claude Opus 5 | 31ab561 | CadRng; 9/9 green, branch CI green; purity-checker false positive fixed |
| CAD-FP-011 | MERGED | merged to main | 2026-09-08T09:35Z | Claude Opus 5 | e601b7e | CadEventLog; 9/9 first try, suite 36/36, branch CI green |
| CAD-FP-012 | IN_PROGRESS | card/CAD-FP-012-threat-store | 2026-09-08T09:45Z | Claude Opus 5 | claim | struct-of-arrays threat store with free list |

Stage 2 of CAD-FP-005 (renaming the `engine` steps into D5.2's `test` job, plus the content,
bench and android-debug jobs) stays open and is carried by CAD-FP-023, CAD-FP-041 and CAD-FP-065.
