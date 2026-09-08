# Prompt: implement-from-card (v1, 2026-09-08)

Paste everything below the line into a fresh agent session opened at the repository root. Replace `{{CARD_ID}}`.

---

You are implementing exactly one task card in the repository at the current directory.

Card: `{{CARD_ID}}` in `docs/production/09-execution-backlog.md`.

Do the following in order and do not skip steps:

1. Read `AGENTS.md` completely, then `docs/production/07-task-card-template.md` §7.2, then the card, then the sections of `docs/production/03-architecture.md` and `docs/production/01-design-bible.md` that the card cites. Read the source files the card's Scope modifies. Do not read unrelated files.
2. Check every id in the card's **Dependencies** is merged into `main` (`git log --oneline main | grep <id>`). If one is missing, create `/ai/handoffs/{{CARD_ID}}.md` from `/ai/handoffs/_TEMPLATE.md` with status BLOCKED, name the missing id, commit, push, and stop.
3. If `/ai/handoffs/{{CARD_ID}}.md` already exists with a status other than NOT_STARTED or ABANDONED, stop: you must use `/ai/prompts/takeover-from-handoff.md` instead.
4. Create the session log from `/ai/logs/_TEMPLATE.md` at `/ai/logs/<UTC date>-{{CARD_ID}}-1.md`.
5. Create the branch `card/{{CARD_ID}}-<slug>` from `main`. Create the handoff from the template: status IN_PROGRESS, branch, the list of files you will create/modify (from the card's Scope, nothing else), and your ordered plan (tests first, then implementation, then self-check). Commit `wip({{CARD_ID}}): claim` and push. Only now may you edit code.
6. Write the test file(s) named in the card's **Test-first** field. Each Given/When/Then case becomes one `test_…` function whose name says the behaviour and condition. Run the card's exact test command. Paste the last 20 lines of the red output into the handoff (item 4). Commit `wip({{CARD_ID}}): failing tests` and push.
7. Implement the **Interface contract** exactly — same class names, signatures, signal names, constants, field types and defaults. Stay within the Scope paths and the LOC ceiling (`python tools/loc.py main..HEAD`). Obey the STD sets named in **Constraints** and every card-specific constraint. After every test run, update handoff items 4–6 and push a WIP commit.
8. Stop conditions — if any applies, write handoff items 1–9, set the status (BLOCKED / TESTS_FAILING / ABANDONED), commit, push, and stop without further attempts: you need a new dependency, addon or contract change; two consecutive attempts fail the same test; a `[VERIFY]` item in the card does not match what Godot 4.7.2 actually does (record the actual behaviour verbatim — never substitute a guess); you cannot run the test command; your context is close to exhausted.
9. Self-check: `tools/lint.sh`, `tools/typecheck.sh`, the sim-purity check, `tools/test.sh` (full suite), `tools/validate.sh`; if the card touches a tick path or `_process`, run `tools/bench.sh` and record `object_count_delta`. Fix only issues inside your Scope.
10. Finish: handoff status READY_FOR_REVIEW with the self-review checklist from `AGENTS.md` §9 filled honestly; append the metrics row to `ai/metrics/metrics.csv` (columns in `docs/production/08-ai-operating-manual.md` §H4.1); close the log; open the PR titled `{{CARD_ID}}: <card title>` with the body in the `AGENTS.md` §9 format.

Rules that override everything else: no code outside Scope; no `# TODO`; no untyped declarations; nothing allocates in tick paths or `_process`; no Nodes/signals/await/Timers/global RNG in `src/sim/`; never touch `main`, `bench/baseline.json`, secrets, or files under `android/`. If the card and the source disagree about an existing signature, the source is right — note it in the handoff and in the PR under "[VERIFY] items resolved".

Reply in the chat only with: the branch name, the final status, the test command and its exit code, and the LOC counts. Everything else goes into the handoff, the log and the PR.
