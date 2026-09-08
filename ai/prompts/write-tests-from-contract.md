# Prompt: write-tests-from-contract (v1, 2026-09-08)

Use for test-only cards (e.g. CAD-FP-040) and for the "tests first" half of any card when the human wants the tests reviewed before implementation begins. Replace `{{CARD_ID}}`.

---

You are writing gdUnit4 tests only. You will not write or modify implementation code.

Card: `{{CARD_ID}}` in `docs/production/09-execution-backlog.md`.

1. Read `AGENTS.md`, `docs/production/07-task-card-template.md` §7.2, the card, and the **Interface contract** of every class the card's tests exercise (find each class's card in the backlog and its current source under `src/`). Read `docs/production/06-qa-release.md` §G.1 test conventions.
2. Claim the card exactly as in `/ai/prompts/implement-from-card.md` steps 3–5 (log, branch `card/{{CARD_ID}}-tests`, handoff IN_PROGRESS, push).
3. For every Given/When/Then case in the card's **Test-first** field write one test function `test_<behaviour>_<condition>() -> void` with three comment lines `# Given … # When … # Then …` and gdUnit4 assertions (`assert_int`, `assert_float(...).is_equal_approx`, `assert_bool`, `assert_array`, `assert_signal`, `assert_object`). Use `test_parameters` for table-driven cases (Pk matrix, radar ranges, economy examples). Construct every sim object with an explicit seed; never use wall-clock time, `Engine.get_frames_drawn()` or global RNG.
4. Where the card lists numbers, the assertion uses the number from `docs/production/01-design-bible.md` verbatim (cite the table in a comment: `# B.4`).
5. Tests must compile against the contract; if a needed method does not exist in the contract, do not invent it — record the gap in the handoff (BLOCKED) and stop.
6. Run the card's exact test command. Expected outcome for a test-only card whose implementation does not exist yet: compile errors or failures — paste the output into the handoff item 4 as the "red run". For scenario cards over an existing implementation: failures reveal sim defects — do not change the sim; keep the failing test, mark it with gdUnit4's skip mechanism only if the human asked, otherwise leave it red, describe the defect in the handoff (hypothesis, reproduction seed, tick), set status BLOCKED, push, stop.
7. Finish per `/ai/prompts/implement-from-card.md` step 10 with status READY_FOR_REVIEW (or BLOCKED as above). Test LOC per file ≤ 150.

Reply in the chat only with: branch, status, number of tests written, test command and exit code.
