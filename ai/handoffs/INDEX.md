# Handoff registry (live)

One row per card that has ever been claimed. The human updates status to MERGED/ABANDONED at H-5; agents update the rest at every checkpoint. `tools/handoff_check.py` (AIOPS-4) flags IN_PROGRESS rows older than 7 days.

| card | status | branch | last_update_utc | agent | last_commit | notes |
|------|--------|--------|-----------------|-------|-------------|-------|
