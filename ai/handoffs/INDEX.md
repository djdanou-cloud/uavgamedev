# Handoff registry (live)

One row per card that has ever been claimed. The human updates status to MERGED/ABANDONED at H-5; agents update the rest at every checkpoint. `tools/handoff_check.py` (AIOPS-4) flags IN_PROGRESS rows older than 7 days.

| card | status | branch | last_update_utc | agent | last_commit | notes |
|------|--------|--------|-----------------|-------|-------------|-------|
| CAD-FP-001 | BLOCKED (human) | merged to main | 2026-09-08T00:00Z | Claude Opus 5 | 638a3da | install Godot 4.7.2 + JDK 17 + gdtoolkit; commands prepared in `docs/toolchain.md` §2 |
| CAD-FP-002 | BLOCKED (verification) | merged to main | 2026-09-08T00:00Z | Claude Opus 5 | 638a3da | files written and Python-side tested; the `--import` check is covered by CAD-FP-005's `engine` job once it runs |
| CAD-FP-005 | IN_PROGRESS | card/CAD-FP-005-ci | 2026-09-08T02:10Z | Claude Opus 5 | see branch head | stage 1 (lint + engine import + typing probe); locally validated, needs a push to run |
