# Handoff registry (live)

One row per card that has ever been claimed. The human updates status to MERGED/ABANDONED at H-5; agents update the rest at every checkpoint. `tools/handoff_check.py` (AIOPS-4) flags IN_PROGRESS rows older than 7 days.

| card | status | branch | last_update_utc | agent | last_commit | notes |
|------|--------|--------|-----------------|-------|-------------|-------|
| CAD-FP-001 | BLOCKED (human) | card/CAD-FP-002-scaffold | 2026-09-08T00:00Z | Claude Opus 5 | see branch head | install Godot 4.7.2 + JDK 17 + gdtoolkit; commands prepared in `docs/toolchain.md` §2 |
| CAD-FP-002 | BLOCKED (verification) | card/CAD-FP-002-scaffold | 2026-09-08T00:00Z | Claude Opus 5 | see branch head | all files written and Python-side tested; engine checks pending CAD-FP-001 |
