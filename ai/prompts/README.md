# Prompt library

Paste-ready templates (H3). Each file carries a version line; a change to a prompt is a commit that also updates this table. The git hash of the prompt file is recorded in every session log so generations are reproducible.

| file | used by | when |
|------|---------|------|
| implement-from-card.md | agent | any implementation card (default) |
| write-tests-from-contract.md | agent | test-only cards; or when the human wants tests reviewed before implementation |
| review-diff.md | agent (read-only) | before the human's Gate-2 review of a PR |
| profile-and-report.md | agent (read-only) | after a Gate-3 failure or before an optimisation card |
| generate-svg-sprite-set.md | agent | art cards |
| balance-sim-report.md | agent (read-only on data/src/test) | tuning loop |
| takeover-from-handoff.md | successor agent | any halted/stalled card |

Evals (AIOPS-3): monthly, re-run three archived cards with the current prompts on a scratch branch and compare first-pass rates in `ai/metrics/`.
