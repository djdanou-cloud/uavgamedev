# Prompt: takeover-from-handoff (v1, 2026-09-08)

Used when an agent session halted, crashed, ran out of context, or stalled. A successor agent resumes from the handoff document alone. Replace `{{CARD_ID}}`.

---

You are agent B taking over card `{{CARD_ID}}` from a previous agent session. Your job is to finish the card from where it stopped, not to restart it.

1. Read `AGENTS.md` §7–§9, then `/ai/handoffs/{{CARD_ID}}.md` top to bottom, then the card in `docs/production/09-execution-backlog.md`, then only the files listed in the handoff's item 3 (modified files).
2. Fetch and check out the branch named in the handoff (`git fetch && git checkout <branch> && git pull`). Confirm the last commit hash matches item 2; if it does not, note it (you trust the branch).
3. Create your session log `/ai/logs/<UTC date>-{{CARD_ID}}-<n+1>.md` with `takeover_from: <previous session id from the handoff>`.
4. Run the exact test command from handoff item 4. Compare the result with the recorded state:
   - identical → continue;
   - different → add a `DISCREPANCY:` line under the handoff header stating what differs and that you trust the observed result; adjust items 4–6 accordingly.
5. Add a header line `taken_over_at: <UTC>, by: <your label>`; set status IN_PROGRESS; commit `wip({{CARD_ID}}): takeover`; push.
6. Continue from item 6 ("exact next step"). Respect item 8 ("what NOT to redo") and the time already spent against the 15-minute rule. Do not reformat, rename, or re-plan unless the status was ABANDONED with an explicit restart note from the human.
7. From here, follow `/ai/prompts/implement-from-card.md` steps 7–10 unchanged (checkpoint after every test run; stop conditions; self-check; finish). If the handoff status was BLOCKED and the blocker is still present, verify it is real (run the failing command), refine the question in item 7 if you can, and stop — do not work around a blocker.
8. In the metrics row for this card set `sessions += 1`, `takeover_attempted = 1`; leave `takeover_success` for the human.

Reply in the chat only with: branch, whether a DISCREPANCY was recorded, the status you reached, the test command and exit code.
