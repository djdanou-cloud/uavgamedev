# AGENTS.md — Colonel Air-defense: The Danger Wave (prefix `cad`)

You are one of many coding agents working on a Godot 4.7.2 / GDScript / Android-only 2D wave-defense game directed by a single human. Read this file completely before touching anything. `CLAUDE.md` is a byte-identical copy of this file.

## 1. What this project is (60-second version)

- Single-player tower-defense in a modern-warfare setting: waves of UAVs, cruise missiles and ballistic missiles attack a city; the player builds an integrated air defense between waves. Fictional factions and equipment only.
- **The simulation is pure GDScript** (`src/sim/`, `RefCounted` only, no Nodes) running at a fixed 30 Hz tick, deterministic for a seed. **Views** (`src/view/`, Nodes/scenes/shaders) read sim state and interpolate; they change the sim only by enqueuing `CadCommand`s. This separation is the architecture. Any code that breaks it is a defect, not a style issue.
- Entities: threats and interceptors are struct-of-arrays in Packed arrays (`CadThreatStore`, `CadInterceptorStore`); emplacements are pooled objects (`CadEmplacement`); proximity via `CadSpatialHash`; events via `CadEventLog` (ring buffer) drained each frame into `CadEvents` signals.
- Kill chain, simulated explicitly: DETECT (`CadSensorSystem`) → TRACK (`CadTrackSystem`) → ENGAGE (`CadTargeting` + `CadFireControl`) → ASSESS (`CadInterceptorSystem`) → IMPACT (`CadImpactSystem`). Economy: `CadEconomy`, `CadDistrictState`. Waves: `CadWaveGenerator`, `CadWaveDirector`. Facade: `CadSim.step()` in the fixed order of `docs/production/03-architecture.md` §D2.2.
- Content is data: typed `Resource` schemas in `src/data/`, CSV sources in `data/csv/`, generated `.tres` in `data/defs/`, loaded once by `CadDefs`.
- Full plan: `docs/production/README.md`. Design numbers: `docs/production/01-design-bible.md`. Architecture: `03-architecture.md`. Your task format: `07-task-card-template.md`. Cards: `09-execution-backlog.md`.

## 2. Conventions

| topic | rule |
|-------|------|
| Files | `cad_<snake>.gd`, one `class_name Cad<Name>` per file; scenes `cad_<name>.tscn`; tests `test_cad_<name>.gd`; shaders `cad_<name>.gdshader` |
| Typing | every variable, parameter, return and export typed; no `Variant` where a type exists; typed arrays/dictionaries; enums referenced by name (`CadEnums.ThreatState.INGRESS`) |
| Project settings | warnings `untyped_declaration`, `unsafe_*`, `return_value_discarded` are **errors**; a script with a warning does not load; `inferred_declaration` warns (avoid `:=` except for constructor/literal locals) |
| Sim purity (`src/sim/`) | forbidden tokens: `extends Node`, `get_tree(`, `Timer`, `await `, `signal `, `Engine.`, `Time.`, `OS.`, `Input.`, `randf(`, `randi(`, `preload(`, `load(`, `print(` — enforced by `tools/check_sim_purity.gd` in CI |
| Allocation | nothing allocates in tick paths (`step`, `update`, `rebuild`, `query_*`) or in `_process`/`_draw`: no `Array`/`Dictionary`/`String` construction, no `str()`/`%`, no lambdas/`Callable`, no `.new()`, no `duplicate()`, no `for x in <Array>` over Variant arrays; preallocate at init; pool nodes and MultiMesh instances |
| Randomness | only `CadRng` streams in the sim (WAVEGEN / COMBAT / MOTION); view VFX use their own `RandomNumberGenerator` |
| Determinism | ascending index iteration; tie-break by index; no `sort` in tick paths; no Dictionary iteration in the sim; no wall clock in the sim |
| Time | sim time is `tick: int`; seconds are converted at load by `CadDefs`/`CadBalanceConfig.bake()` |
| Data | `extends Resource`, `@export var schema_version: int` first, typed fields with defaults, ids as `StringName` equal to the file name |
| Godot 4 only | no `yield`, `instance()`, string-form `connect`, Godot 3 node names; `Engine.time_scale` never; `get_tree().paused` only for lifecycle/menus |
| UI | sizes in dp (`CadUiScale`), touch targets ≥ 48 dp, icons 26 dp, strings from `CadStrings.get_text(&"key")` (CSV `ui/strings/cad_strings_en.csv`) |
| Tests | gdUnit4 suites `extends GdUnitTestSuite` with **no `class_name`**; put `@warning_ignore_start("return_value_discarded")` under the `extends` line — the fluent assertions (`assert_int(x).is_equal(y)`) return the assert object, which our strict gate would otherwise reject. Every other warning, including `untyped_declaration`, stays active in tests |
| Git | branch `card/<CARD-ID>-<slug>` from `main`; commits `wip(<CARD-ID>): …` at every checkpoint; never push to `main`; squash-merge is the human's job |
| Secrets | never read, write, or mention keystores, passwords, ad unit ids, or Play Console credentials; if you encounter one, stop and report |

## 3. Contract digest (kept in sync by the card that changes a contract)

- Constants: `CadConst` (TICK_HZ 30, TICK_DT 1/30, MAX_TICKS_PER_FRAME 6, MAX_THREATS 512, MAX_INTERCEPTORS 1024, MAX_EMPLACEMENTS 64, MAX_DISTRICTS 16, EVENT_CAPACITY 4096, SPATIAL_CELL_M 500, QUERY_BUFFER 512, INVALID −1).
- Enums: `CadEnums` (ThreatClass, AltBand, Guidance, TargetPref, ThreatState, ThreatFlag, EmpKind, EmpState, Roe, Priority, EngageMode, InterceptorState, WaveState, GameState, CommandType, CommandResult, EventType, TechEffect, RngStream, TargetKind). Enum order is a save-format contract: append, never reorder.
- Stores: `CadThreatStore`, `CadInterceptorStore` (alloc → lowest free index or −1, release, rebuild_alive, alive/alive_count), `CadEmplacementStore` (can_place/place/remove/rebuild_lists/recompute_links), `CadDistrictState`.
- Systems: see §1; each has `_init(defs, …)` and `update(tick, …)`; `CadSim` owns them and calls them in D2.2 order.
- View: `CadSimDriver` (speed 0–3, `alpha`, drains events), `CadEvents` (signals `sim_*`, `ui_*`), `CadApp` (GameState machine, `goto()`, `new_run()`), views bind with `bind(driver, …)` and `set_zoom(zoom)`.
- Commands: `CadCommandQueue.acquire()` → fill → `enqueue()`; results arrive as `sim_command_result(seq, result)`.
- Exact signatures live in the card that created the class (`docs/production/09-execution-backlog.md`) and in the source; when they differ, the source is right and the card is updated in the same PR.

## 4. Exact commands (`GODOT_BIN` must point at the Godot 4.7.2 console binary)

| purpose | command |
|---------|---------|
| import (also proves the project opens without warnings) | `"$GODOT_BIN" --headless --path . --import` |
| lint + format check | `tools/lint.sh` (= `gdlint src test tools && gdformat --check src test tools`) |
| typecheck (loads every script; warnings are errors) | `tools/typecheck.sh` |
| sim purity | `"$GODOT_BIN" --headless --path . -s res://tools/check_sim_purity.gd` |
| all tests | `tools/test.sh` |
| one suite | `tools/test.sh res://test/unit/sim/test_cad_rng.gd` |
| raw test command | `"$GODOT_BIN" --headless --path . -d -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -rd reports/gdunit -c` (exit 0 pass / 100 fail / 101 warnings; report `reports/gdunit/results.xml`) |
| content validation | `tools/validate.sh` |
| CSV → .tres | `tools/import_csv.sh` |
| atlas | `tools/atlas.sh` |
| sim bench | `tools/bench.sh` (250/300/60 × 1,800 ticks; JSON + p95) |
| debug APK | `tools/export_debug.sh` → `build/cad-debug.apk` |
| install + logs | `tools/device_run.sh` |
| LOC count for your diff | `python tools/loc.py main..HEAD` |
| release export | human-only (`docs/production/03-architecture.md` §D5.4) — never run by an agent |

Windows: use the `.cmd` twins (`tools\test.cmd …`). Until a tool exists (early FP cards), the card tells you the raw command.

## 5. The 10 Commandments (verbatim) and their Godot translations

1. **Thou shalt not install or import new dependencies without explicit permission; rely first upon existing utilities and native primitives.** → No new addons, plugins, `.gdextension` files, GitHub Actions, pip packages or fonts. The only permitted addon is `addons/gdUnit4` (installed by CAD-FP-003). The ad SDK plugin is installed by the human under E-PA-06. If a card seems to need something new, stop and mark the handoff BLOCKED.
2. **Thou shalt write complete, production-ready code; never leave `// TODO`, placeholders, or truncated snippets.** → No `# TODO`, `pass` bodies, `push_error("not implemented")`, or stubbed returns. If the card's scope cannot be completed, finish what can be and mark the handoff with the exact gap.
3. **Thou shalt enforce strict typing; never resort to `any` or leave interfaces ambiguous.** → No untyped `var`, no `Variant` where a type exists, no duck typing where a `class_name` exists, no `get()`/`set()`/`call()` by string (except `tools/csv_import/` and `CadDefs.migrate_def()`), no `as` casts without a null check.
4. **Thou shalt preserve existing architectural conventions, directory structures, and established naming patterns.** → `docs/production/03-architecture.md` §D7 tree; `Cad` prefix; sim/view split; SoA stores; pooled views.
5. **Thou shalt not alter public APIs, database schemas, or cross-service contracts unless explicitly directed.** → `class_name` signatures, signals, `Resource` schemas, enum orders, the event log layout and the save JSON are contracts. Changing one requires a card that says so and a `schema_version` bump with a migration.
6. **Thou shalt isolate the root cause and plan your changes before editing multi-file logic.** → Write the plan in the handoff (files, order, tests) before the first edit; cross-file edits are listed in the card's Scope or you stop.
7. **Thou shalt keep functions small, single-purpose, and decoupled, avoiding unnecessary abstraction.** → Functions ≤ 40 lines; systems talk through stores, not through each other; no base classes invented for one subclass.
8. **Thou shalt write accompanying unit tests to verify edge cases and prevent regressions.** → gdUnit4 suites under `test/`, headless-runnable, written **before** the implementation (the handoff shows the red run), capacity/edge/determinism cases included.
9. **Thou shalt not clutter code with trivial comments; document only non-obvious business logic and edge cases.** → Comment the radar equation, the tie-break rule, the free-list invariant; never `# increment i`.
10. **Thou shalt deliver minimal, targeted diffs rather than rewriting untouched code.** → Touch only the card's Scope paths; no reformatting of other files; `gdformat` runs only on files you changed.

## 6. Forbidden patterns (review rejects on sight)

- In `src/sim/`: any Node/SceneTree/Timer/signal/await/Engine/Time/OS/Input/global RNG use; `Array`/`Dictionary` in tick paths; `sort`; Dictionary iteration; `print`.
- In `src/view/`: mutating sim fields directly; `_process` that allocates; creating/freeing nodes during WAVE; `Engine.time_scale`; `Input.is_key_pressed`; hard-coded deep `get_node("../../…")` paths; string formatting every frame.
- Anywhere: untyped declarations; `# TODO`; Godot 3 idioms; new dependencies; secrets; editing `bench/baseline.json`, `data/defs/*.tres` by hand (use the importer), `art/atlas/*` by hand (use the builder); "updating the golden" of a determinism test without a human-approved reason in the PR.

## 7. How to pick up a task card

1. Read `docs/production/07-task-card-template.md` §7.2 (STD sets) once per session.
2. Open your card in `docs/production/09-execution-backlog.md`. Confirm every id in **Dependencies** is merged (`git log --oneline main | grep <ID>`); if not, stop and report.
3. Check `/ai/handoffs/INDEX.md` and `/ai/handoffs/<CARD-ID>.md`: if a handoff exists with status other than NOT_STARTED/ABANDONED, you are a **successor** — follow §8.3 (takeover), not a fresh start.
4. Create the session log `/ai/logs/<UTC date>-<CARD-ID>-<n>.md` from `/ai/logs/_TEMPLATE.md`.
5. Create/update the handoff from `/ai/handoffs/_TEMPLATE.md` (status IN_PROGRESS, branch, planned files), create the branch `card/<CARD-ID>-<slug>`, commit and push — **before any code edit**.
6. Write the test file(s) from the card's Test-first field; run them; paste the red output into the handoff; commit `wip(<CARD-ID>): failing tests`; push.
7. Implement within Scope and LOC ceiling. After **every** test run, update the handoff (status, failing tests, hypothesis, next step) and push a WIP commit.
8. Self-check: `tools/lint.sh`, `tools/typecheck.sh`, purity, `tools/test.sh`, `tools/validate.sh`, `python tools/loc.py main..HEAD`; if the card touches a tick path or `_process`, run `tools/bench.sh` and paste the object-count delta.
9. Finish: handoff status READY_FOR_REVIEW with the §9 self-review checklist filled; open the PR in the §9 format; append a row to `ai/metrics/metrics.csv`; close the log.
10. Stop conditions (any → write the handoff immediately with items 1–9 of STD-HANDOFF, set BLOCKED / TESTS_FAILING / ABANDONED, push, and stop): the card needs a dependency or contract change; two consecutive attempts fail the same test; a `[VERIFY]` item turns out wrong; you cannot run the test command; your context is nearly exhausted.

## 8. Inter-agent documentation and handoff protocol

### 8.1 Files
- `/ai/handoffs/<CARD-ID>.md` — the single document a successor needs. Schema: `/ai/handoffs/_TEMPLATE.md` (STD-HANDOFF items 1–9).
- `/ai/handoffs/INDEX.md` — one row per card in flight: id, status, branch, last update (UTC), agent label, last commit.
- `/ai/logs/<date>-<CARD-ID>-<n>.md` — immutable session record.
- `/ai/metrics/metrics.csv` — one row per card.

### 8.2 When to write the handoff
Before the first edit (claim), after every test run, every 20 minutes of activity or 3 file-changing actions (whichever first), and immediately on any stop condition. Every handoff update is followed by `git add -A && git commit -m "wip(<CARD-ID>): <what>" && git push`. An un-pushed handoff does not exist.

### 8.3 Takeover (you are agent B resuming agent A's card)
1. Read the handoff top to bottom; check out the branch; run the exact test command in item 4.
2. If the observed result differs from the recorded one, write a `DISCREPANCY:` line (what differs; you trust the tests) at the top of the handoff.
3. Continue from item 6 ("exact next step"). Do not restart, do not reformat, do not re-derive the plan unless the status is ABANDONED with a restart note.
4. Record `takeover_from: <A's session id>` in your log and in the handoff header; set `takeover_attempted = 1` in the metrics row.

### 8.4 Time budget
The human applies a 15-minute rule per card (`docs/production/08-ai-operating-manual.md` §H2.5). If you find yourself needing the human to explain the card, the card is defective: mark BLOCKED with the precise question instead of guessing.

## 9. Required deliverable format (PR body; also pasted at the end of the handoff)

```
## <CARD-ID>: <title>
### Diff summary
- <file>: <what and why> (one line per file; total impl LOC <n> / ceiling <m>; test LOC <n>)
### Test output
<last 30 lines of `tools/test.sh <suite>` plus the exit code; for tick-path cards: `tools/bench.sh` line with object_count_delta>
### Handoff status
READY_FOR_REVIEW — /ai/handoffs/<CARD-ID>.md @ <commit>
### [VERIFY] items resolved
- <item>: confirmed / differs (<what the engine actually does>)
### Self-review checklist
- [ ] contract implemented exactly (names, types, signals, constants)
- [ ] tests written first (red run in handoff), now green; edge/capacity/determinism cases present
- [ ] STD-TYPING / STD-SIM or STD-VIEW / STD-DATA / STD-TOOL constraints met; no forbidden patterns (§6)
- [ ] no allocation in tick paths or _process; pools/preallocation used
- [ ] no new dependency, addon, action, font or asset without a licence row
- [ ] diff limited to Scope; LOC within ceiling; no reformatting of untouched code
- [ ] lint, typecheck, purity, tests, content validation green locally
- [ ] handoff finalised; log closed; metrics row appended
- [ ] every [VERIFY] the card mentions is resolved and recorded above
```

## 10. Where things are

| need | path |
|------|------|
| numbers (stats, Pk, economy, waves, tech, doctrine, palette) | `docs/production/01-design-bible.md` |
| settings, presets, tick loop, schemas, save format, CI, budgets, tree | `docs/production/03-architecture.md` |
| card template and STD sets | `docs/production/07-task-card-template.md` |
| session protocol, metrics | `docs/production/08-ai-operating-manual.md` |
| prompts | `/ai/prompts/` |
| assumptions and `[VERIFY]` ledger | `docs/production/00-assumptions-register.md` |
