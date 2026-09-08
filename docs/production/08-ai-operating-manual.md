# H. AI Operating Manual

H1 (the full text of `AGENTS.md`) lives at the repo root (`/AGENTS.md`, copy `/CLAUDE.md`). H3 prompt templates live in `/ai/prompts/`. This file holds H2 (session protocol) and H4 (metrics).

## H2 Agent session protocol

### H2.1 Human steps (per card, ≈ 3 minutes before, ≈ 12 minutes after)

| step | action | artefact |
|------|--------|----------|
| H-1 pick | choose the next card whose Dependencies are all merged; confirm no handoff exists or its status is NOT_STARTED/ABANDONED-with-restart-note | `ai/handoffs/INDEX.md` row → IN_PROGRESS with the assigned agent label |
| H-2 launch | open a fresh agent session in the repo root; paste `/ai/prompts/implement-from-card.md` (or the card's named template) with the card ID filled | session log created by the agent |
| H-3 wait | no coaching during generation; if the agent asks a question, answer only via the handoff `BLOCKED` block or abandon (15-minute rule budget starts at the first coaching message) | — |
| H-4 review | open the PR; run STD-GATE + the card's Verification gates; on device if the card says so; record minutes | PR review; `ai/metrics/metrics.csv` row updated with review_minutes and defects |
| H-5 merge or kill | squash-merge, or request one revision (max one), or abandon | `INDEX.md` row → MERGED / ABANDONED |

### H2.2 Agent steps (every session; identical for a fresh start and for a takeover)

| step | action | checkpoint |
|------|--------|------------|
| A-0 load context | read `AGENTS.md`, `docs/production/07-task-card-template.md` §7.2, the card, the architecture sections it cites, the existing handoff (if any), `git log --oneline -20` | — |
| A-1 open log | create `/ai/logs/<UTC date>-<CARD-ID>-<session n>.md` from `_TEMPLATE.md` with model name, prompt template name + version, start time | log |
| A-2 claim | create/update `/ai/handoffs/<CARD-ID>.md` (status IN_PROGRESS, branch, planned files); create branch `card/<CARD-ID>-<slug>`; commit and push the handoff ("wip(<CARD-ID>): claim") | **checkpoint 1 (before any edit)** |
| A-3 tests first | write the test file from the card; run it; paste the red output into the handoff; commit `wip(<CARD-ID>): failing tests` and push | **checkpoint 2** |
| A-4 implement | write the implementation within Scope and LOC ceiling; after **every** test run (pass or fail) update handoff items 4–6 and push a WIP commit | checkpoint after each test run |
| A-5 self-check | lint + format + typecheck + full test suite + content validation + allocation probe if hot path; fill the self-review checklist in the handoff | checkpoint |
| A-6 finish | status READY_FOR_REVIEW; open the PR with the deliverable format; append the metrics row; close the log with end time and first-pass result | final |
| A-halt | on context saturation, tool failure, or any STD-ABANDON trigger: write items 1–9 of STD-HANDOFF immediately, set status (BLOCKED / TESTS_FAILING / ABANDONED), commit and push; stop | **mandatory** |

Heartbeat rule: the handoff must be updated at least every 20 minutes of agent activity or every 3 tool actions that change files, whichever comes first. A successor agent treats a handoff older than 24 h with status IN_PROGRESS as stale: it trusts the branch state + tests over the text, records the discrepancy, and continues.

### H2.3 Takeover (agent B resumes agent A's card)

1. Paste `/ai/prompts/takeover-from-handoff.md` with the card ID.
2. B reads the handoff, checks out the branch, runs the exact test command from item 4, and compares with the recorded state; if they differ, B writes a `DISCREPANCY` line (what differs, which it trusts: the tests).
3. B continues from item 6 ("exact next step"); B never restarts from scratch unless the handoff says ABANDONED with a restart note.
4. B records `takeover_from: <session id>` in its log and the handoff; the metrics row gets `takeover_attempted = 1` and, on READY_FOR_REVIEW without human rewrite, `takeover_success = 1`.

### H2.4 What "done" means

A card is done when the PR is squash-merged into `main` by the human. READY_FOR_REVIEW is not done. A card whose tests pass but whose diff exceeds Scope, whose handoff is incomplete, or whose PR lacks the deliverable format is returned once; a second return is an abandonment (metrics: `abandoned = 1`, reason).

### H2.5 The 15-minute rule (operational)

The human keeps a timer per card. Counted: writing clarifications to the agent, editing agent code to make tests pass, re-running failed generations. Not counted: the normal review (STD-GATE). At 15 minutes: abandon, record the reason category (`contract_unclear` / `agent_drift` / `toolchain` / `too_big` / `verify_mismatch`) in metrics, and either write the code by hand (log the LOC as human-authored) or split the card.

### H2.6 Logging (`/ai/logs/`)

One file per session, schema in `/ai/logs/_TEMPLATE.md`: card id, session number, agent/model, prompt template + version (git hash of the prompt file), start/end UTC, tool actions count, test runs (n, first green at run k), files touched, LOC added/removed, outcome (READY_FOR_REVIEW / BLOCKED / TESTS_FAILING / ABANDONED), takeover_from, notes (≤ 5 lines). Logs are committed with the card branch (they are part of deterministic versioning, §4.4) and are never edited after the session.

## H4 Metrics and the delegation retune rule

### H4.1 Ledger `ai/metrics/metrics.csv` (one row per card, appended by the agent at A-6, completed by the human at H-4/H-5)

| column | filled by | definition |
|--------|-----------|------------|
| card_id | agent | `CAD-<MS>-<nnn>` |
| task_type | agent | sim / view / ui / data / tool / platform / art / balance / content / aiops |
| agent_model | agent | model identifier |
| sessions | agent | number of sessions incl. takeovers |
| first_pass_green | agent | 1 if the full suite was green at the end of the first session without human edits |
| test_runs_to_green | agent | k |
| loc_impl / loc_test | agent | from `tools/loc.py` |
| review_minutes | human | H-4 time |
| coaching_minutes | human | 15-minute-rule budget used |
| abandoned / abandon_reason | human | 1 + category (H2.5) |
| takeover_attempted / takeover_success | agent/human | H2.3 |
| defects_escaped_to_device | human | bugs found at Gate 3 or later attributable to this card (updated retroactively) |
| merged_date | human | ISO date |

`tools/ai_metrics.py` (stdlib only) prints per task_type over the last N cards: first-pass rate, mean review minutes, abandonment rate, takeover success rate, escaped defects per card.

### H4.2 Targets

| metric | target | alarm |
|--------|--------|-------|
| first-pass test pass rate | ≥ 60 % (sim/data), ≥ 50 % (view/ui) | < 40 % over the last 10 cards of a type |
| review minutes per card | ≤ 12 | > 20 mean over 10 cards |
| abandonment count | ≤ 1 per 10 cards | ≥ 3 per 10 |
| takeover success rate | ≥ 80 % | < 70 % over the last 5 takeovers |
| defects escaped to device | ≤ 0.2 per card | > 0.5 per card of a type |

### H4.3 Retune rules (applied at every gate and whenever an alarm trips; the human records the change in `docs/decisions/ADR-nnn.md` and updates E.7)

| rule | condition | change to the delegation matrix / cards |
|------|-----------|------------------------------------------|
| R1 | first-pass rate < 40 % for a task type | human authors the tests for that type (agents implement only) for the next 10 cards; prompt template for the type gets a worked example |
| R2 | review minutes > 20 mean for a type | LOC ceiling → 80 for that type; contracts must include a pseudocode block |
| R3 | abandonment ≥ 3 per 10 | pause new cards of that type; run AIOPS-3 eval on 3 archived cards; fix prompts or split cards before resuming |
| R4 | takeover success < 70 % | STD-HANDOFF gains a mandatory "state diff" (output of `git diff --stat main...HEAD`) and a "last green commit" field; heartbeat → 10 minutes |
| R5 | escaped defects > 0.5 per card for a type | that type's Verification gates gain an on-device step; scenario tests required for every card of the type |
| R6 | all targets met for 20 consecutive cards of a type | LOC ceiling for that type may rise to 150 (never above), and the human may pre-approve contracts drafted by agents without edits |
