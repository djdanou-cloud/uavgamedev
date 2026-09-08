# Prompt: profile-and-report (v1, 2026-09-08)

Used after a Gate-3 measurement fails or before an optimisation card is written. Replace `{{DEVICE}}`, `{{BUILD_HASH}}` and attach the JSON/logs listed.

---

You are analysing performance data for the Godot 4.7.2 Android game in this repository. You will produce a report and, if justified, at most two task-card drafts. You must not modify source files.

Inputs (the human attaches or points to them):
- `docs/perf-log.md` rows for device `{{DEVICE}}`, build `{{BUILD_HASH}}`.
- `user://perf/render_bench.json` and/or `user://perf/soak.json` pulled from the device (`CadFrameStats.dump_json` output).
- `tools/bench.sh` output (`tick_p95_ms`, `object_count_delta`, `memory_static_delta`) from the device build's bench button and from the dev PC.
- Optional: Godot profiler CSV export from remote debugging, `adb shell dumpsys meminfo com.djdanou.cad`, `adb shell dumpsys thermalservice` snapshots, `adb logcat -s godot` excerpt.

Do the following:

1. Read `docs/production/03-architecture.md` §D6 (targets and measuring tests) and §D2.2 (tick order). Compare every metric in the inputs with its target for this device tier; list PASS/FAIL with the margin.
2. For each FAIL, attribute the cost using the data you have: sim vs render vs UI split (`cad/sim_ms`, `cad/render_ms`, `cad/ui_ms`), draw calls, memory growth (allocation creep indicator: `MEMORY_STATIC` slope over the soak; `object_count_delta` ≠ 0), hitch timestamps correlated with wave events if a log is attached, thermal state vs minute-p95 drift.
3. Read only the source files implicated by the attribution (e.g. `src/sim/systems/cad_sensor_system.gd` if sim time dominates while sensors are numerous) and identify the concrete hot loop and its per-iteration cost drivers (allocations, `sqrt`, redundant queries, Variant arrays, per-frame string formatting). Quote file:line.
4. Propose fixes ranked by expected gain per LOC, each with: the measurable criterion that proves it worked (which D6 metric, which bench, expected new value), the risk to determinism or contracts, and the LOC estimate. Reject any proposal that changes a `class_name` signature, adds a dependency, or moves logic out of `src/sim/` into Nodes.
5. Output exactly:

```
## Perf report — {{DEVICE}} @ {{BUILD_HASH}}
| metric | value | target | status | margin |
…
### Attribution
…(≤ 10 lines, with file:line)
### Proposals (ranked)
1. <title> — expected: <metric> <from> → <to>; LOC ≤ <n>; risk: <…>; proof: <bench/test>
2. …
### Draft task cards (max 2, full §7 template, ≤ 120 LOC each, failing-test-first = a bench threshold or a unit test)
…
### Not recommended
- <ideas rejected and why>
```

Never recommend GDExtension/C#/threads (A-40, A-04) — if you believe GDScript cannot meet the target, say so with the numbers and stop; that decision is the human's.
