# Prompt: review-diff (v1, 2026-09-08)

The human runs this before their own Gate-2 review to get a first pass. The agent reviews; it does not edit. Replace `{{CARD_ID}}` and `{{BRANCH}}`.

---

You are reviewing the branch `{{BRANCH}}` for card `{{CARD_ID}}` against `main`. You may read anything and run read-only commands and tests. You must not modify any file.

1. Read `AGENTS.md` §5–§6 and `docs/production/07-task-card-template.md` §7.2 (STD-GATE). Read the card. Read `/ai/handoffs/{{CARD_ID}}.md`.
2. Run: `git diff --stat main...HEAD`, `python tools/loc.py main..HEAD`, `tools/lint.sh`, `tools/typecheck.sh`, the sim-purity check, `tools/test.sh`, `tools/validate.sh`. Record exit codes.
3. Check, and report each as PASS / FAIL with file:line evidence:
   - Scope: every changed path is in the card's Scope; LOC within ceiling.
   - Contract: class names, signatures, signals, constants, defaults match the card text exactly (list every deviation).
   - Tests: every Test-first case exists as a test; the handoff shows a red run before green; no test was weakened (compare assertions to the card's numbers and the design bible tables).
   - Allocation & lifetime: search the diff for `Array(`, `[]`, `{}`, `str(`, `%`, `func(`, `.new(`, `duplicate(`, `slice(`, `sort`, `for … in` over Variant arrays inside `step/update/rebuild/query_*/_process/_draw`; pooled objects returned; `RefCounted` cycles.
   - Sim purity and STD sets named in the card's Constraints.
   - API integrity: Godot 4.7 names only; no deprecated calls (run `"$GODOT_BIN" --headless --path . --import` and quote any deprecation lines).
   - State machines: every transition in the diff exists in `docs/production/03-architecture.md` §D2.7 or `01-design-bible.md` §B.12.
   - Determinism: no Dictionary iteration, sort, global RNG, wall clock, or order dependence introduced in `src/sim/`.
   - Handoff: STD-HANDOFF items 1–9 complete; `[VERIFY]` items resolved with the engine's actual behaviour quoted.
   - Commandments 1, 2, 3, 5, 10 (`AGENTS.md` §5).
4. Output exactly this structure, nothing else:

```
## Review {{CARD_ID}} @ <commit>
Verdict: MERGE | REVISE | ABANDON
Blocking findings (each: file:line — rule — what to change):
- …
Non-blocking notes:
- …
Commands and exit codes:
- …
Estimated human review minutes remaining: <n>
```

Verdict rules: any FAIL in Scope, Contract, Tests, Allocation, Purity or Determinism → REVISE; a REVISE that would require redesign or a second revision → ABANDON; otherwise MERGE.
