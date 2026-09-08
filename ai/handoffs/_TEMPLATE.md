# Handoff — CAD-<MS>-<nnn> — <card title>

<!-- One file per card. Update BEFORE the first edit, AFTER EVERY test run, every 20 min / 3 file-changing actions, and IMMEDIATELY on any stop condition. Commit and push after every update: an un-pushed handoff does not exist. Schema = STD-HANDOFF (docs/production/07-task-card-template.md §7.2). -->

## 1. Status
- status: NOT_STARTED | IN_PROGRESS | BLOCKED | TESTS_FAILING | TESTS_PASSING | READY_FOR_REVIEW | ABANDONED
- last_updated_utc: YYYY-MM-DDTHH:MM:SSZ
- agent: <label/model>  session: <n>  takeover_from: <session id or none>
- time_spent_min: <n>   (15-minute-rule coaching minutes are tracked by the human in metrics.csv)
- DISCREPANCY: <only written by a successor when the observed branch/tests differ from this document>

## 2. Branch and checkpoint
- branch: card/CAD-<MS>-<nnn>-<slug>
- last_pushed_commit: <hash> — <message>
- last_green_commit: <hash or none>

## 3. Files (planned → touched)
| path | intent (one line) | state: planned / partial / done / revert-me |
|------|-------------------|----------------------------------------------|

## 4. Tests
- command: `tools/test.sh res://test/...`
- last_exit_code: <0 | 100 | 101 | other>
- failing_tests: <names, or none>
- last_output_tail (≤ 20 lines):
```
```

## 5. Hypotheses (one sentence per failing test)
- <test name>: <hypothesis>

## 6. Exact next step
<the next command to run or the next edit to make, precise enough to execute without thinking>

## 7. Blockers / questions for the human
- <none, or: what is blocked, what was tried, the precise question>

## 8. Resume instructions for a successor
- read in this order: <files>
- do NOT redo: <what is finished and verified>
- [VERIFY] items resolved so far: <item → actual engine behaviour>

## 9. Self-review checklist (copy from AGENTS.md §9; tick only what is verified)
- [ ] contract implemented exactly
- [ ] tests first (red run recorded above), now green; edge/capacity/determinism cases present
- [ ] STD constraints met; no forbidden patterns
- [ ] no allocation in tick paths / _process
- [ ] no new dependency / asset without licence row
- [ ] diff within Scope and LOC ceiling
- [ ] lint, typecheck, purity, tests, validation green
- [ ] log closed; metrics row appended
- [ ] every [VERIFY] resolved and recorded
