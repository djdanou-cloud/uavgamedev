# Session log — <UTC date> — CAD-<MS>-<nnn> — session <n>

<!-- Immutable after the session ends. Committed with the card branch (deterministic versioning, §4.4). -->

- card: CAD-<MS>-<nnn>
- session: <n>   takeover_from: <session id or none>
- agent_model: <identifier>
- prompt_template: /ai/prompts/<name>.md @ <git hash of the prompt file>
- start_utc: YYYY-MM-DDTHH:MM:SSZ
- end_utc:
- tool_actions: <count>
- test_runs: <n>   first_green_at_run: <k or none>
- files_touched: <list>
- loc_added_impl / loc_added_test: <n> / <n>
- outcome: READY_FOR_REVIEW | BLOCKED | TESTS_FAILING | ABANDONED
- stop_condition (if any): <which one from AGENTS.md §7.10>
- notes (≤ 5 lines):
