# Prompt: balance-sim-report (v1, 2026-09-08)

Used in the tuning loop (DES-4). The agent runs the harness, writes the report, and proposes CSV changes as a draft card. Replace `{{MAP_ID}}`, `{{POLICIES}}`, `{{SEEDS}}`, `{{WAVES}}`.

---

You are running the headless balance harness for this repository and writing a report the human will use to decide balance changes. You must not modify anything under `data/`, `src/` or `test/` in this session.

1. Read `docs/production/06-qa-release.md` §G.2 (policies, expected outcomes, tuning loop), `docs/production/01-design-bible.md` §B.4, §B.6, §B.7 (the knobs), and `docs/production/05-risks.md` R-08/R-09 (failure modes).
2. Run, for each policy in `{{POLICIES}}`:
   `"$GODOT_BIN" --headless --path . -s res://tools/balance/cad_balance_run.gd -- --map {{MAP_ID}} --policy <policy> --seeds {{SEEDS}} --waves {{WAVES}} --out reports/balance/`
   Record wall time per run.
3. From the JSON outputs compute per policy: win rate per wave (fraction of seeds that cleared wave w), median and p10/p90 funds per wave, median integrity per wave, first-failing-wave histogram, cost-exchange ratio (CR spent / enemy CR killed) per wave band (1–5, 6–12, 13–20, 21–30), kills and leaks by threat class.
4. Compare with the G.2 expectation for each policy on this map and with the milestone band from `docs/production/02-milestones.md`. Mark each expectation MET / NOT MET with the number.
5. For every NOT MET, identify the smallest knob change (one CSV cell or one `CadBalanceConfig` field) most likely to fix it without breaking a MET expectation, and state the predicted direction of every other policy's win rate. Prefer changes in this order: package counts/weights → interceptor `ammo_cost` → `Pk` cell → `budget_*` → district values.
6. Write `reports/balance/summary_{{MAP_ID}}_<UTC date>.md` with the tables above (Markdown, ≤ 120 lines) and copy its first 30 lines into the chat.
7. Draft at most one balance task card (§7 template, Workstream DES, Scope limited to the named CSV cells + the importer run + the bands' tests) in the report under "Proposed card". Do not execute it.

Report structure:

```
## Balance report — {{MAP_ID}} — seeds {{SEEDS}} — waves {{WAVES}} — <commit>
### Win rate by wave (policy rows × wave columns)
### Funds and integrity medians
### Exchange ratios by band
### Expectations
| policy | expectation | measured | status |
### Diagnosis (≤ 10 lines: hopeless vs trivial, which layer/knob)
### Proposed card
```
