# §7 AI Task Card template (mandatory) and standard constraint sets

No card may omit a field. A field may reference a standard set defined in §7.2 (`STD-…`) and add card-specific lines; it may not say "as usual" or "see other card". Cards live in `docs/production/09-execution-backlog.md` (or a milestone appendix file `09-<ms>-cards.md` once a milestone is expanded).

## 7.1 Template (copy verbatim)

```
ID: CAD-<MS>-<nnn>    Title: <imperative, ≤ 60 chars>
Milestone: <FP|VS|PA|AL|BE|RC|GO|PL>    Workstream: <ENG-SIM|ENG-REN|ENG-UI|ENG-DATA|ENG-PLAT|ENG-AUD|ART|DES|CON|AIOPS|PROD>    Owner: agent | human
Goal (one sentence): <what exists after this card that did not before>
Scope: <exact file paths to create/modify>; LOC ceiling: ≤ <n ≤ 120> new LOC (tests excluded, counted separately ≤ 150)
Interface contract: <class_name, extends, signals, typed function signatures, constants, Resource schema — written out>
Test-first: <test file path>; cases (Given/When/Then, each FAILS before and PASSES after); run: <exact headless command>
Constraints: <STD sets> + <card-specific typing/allocation/dependency/determinism/performance rules>
Handoff & takeover artifacts: /ai/handoffs/CAD-<MS>-<nnn>.md; state checklist: STD-HANDOFF + <card-specific items>
Definition of Done: STD-DOD + <card-specific>
Verification gates: <what the human inspects in review; on-device/profiler check if applicable>
Dependencies: <card IDs, all must be merged>
Effort: <n> agent session(s) × <m> human review minutes
Abandon criteria: STD-ABANDON + <card-specific triggers>; manual fallback: <what the human writes by hand>
Prompt template: /ai/prompts/<name>.md
```

## 7.2 Standard sets (referenced by cards; agents must read this section once per session)

### STD-TYPING
- Every variable, parameter, return value and `@export` has an explicit type; `:=` inference only for locals whose right-hand side is a constructor or literal of an unambiguous type (still Warn per A-10); no `Variant` where a type exists; no `Array` without element type; no `Dictionary` without key/value types when both are known (`Dictionary[StringName, int]`).
- Every script starts with `class_name Cad<Name>` then `extends <Base>`; one class per file; file name = `cad_<snake>.gd`.
- No `get()`/`set()`/`call()`/`has_method()` string access outside `tools/csv_import/` and `CadDefs.migrate_def()`; no duck typing where a `class_name` exists; casts with `as` only when the static type cannot be known and a null check follows.
- Enums referenced as `CadEnums.ThreatState.INGRESS` (never raw ints in logic; raw ints allowed only inside Packed arrays with a comment naming the enum).
- Test suites are the one exception to `return_value_discarded`: `extends GdUnitTestSuite`, no `class_name`, and `@warning_ignore_start("return_value_discarded")` under the `extends` line, because gdUnit4 assertions are fluent. No other warning may be suppressed anywhere without a card that says so.

### STD-SIM (any file under `src/sim/`, `src/defs/`)
- `extends RefCounted` only; forbidden tokens: `extends Node`, `get_tree`, `Timer`, `await`, `signal `, `Engine.`, `Time.`, `OS.`, `Input.`, `randf(`, `randi(`, `preload(`, `load(`, `print(` (use the event log), `ResourceLoader` (only `CadDefs`).
- Tick paths (`step`, `update`, `rebuild`, `query_*`, any function called from them) allocate nothing: no `Array`/`Dictionary`/`String`/`StringName` construction, no `str()`/`%`, no lambdas/`Callable`, no `.new()`, no `duplicate()`, no `slice()`/`filter`/`map`, no `for x in <Array>` over Variant arrays (index loops over Packed arrays), no `Vector2` arithmetic returning temporaries inside inner loops when scalar math is possible (allowed at the per-entity level; forbidden inside per-neighbour loops).
- All randomness via the injected `CadRng` and the stream named in the contract; iteration in ascending index order; tie-breaks by index; no `sort`/`sort_custom` in tick paths.
- Time is `tick: int` and tick counts; seconds are converted at load (`CadDefs`), never per tick.
- Capacities from `CadConst`; functions return `-1`/`CadConst.INVALID` on capacity exhaustion, never grow arrays.

### STD-VIEW (any file under `src/view/`, `scenes/`)
- Reads sim state only through public typed fields/getters of the stores; mutates sim only via `CadCommandQueue.enqueue()`.
- No per-frame allocation in `_process`/`_draw`/signal handlers on hot paths: preallocated `MultiMesh` (instance_count fixed at scene ready), pooled nodes (`CadEmplacementView` pool of 64), reused `PackedFloat32Array` buffers; string formatting only when the displayed value changes (cache last value).
- `process_mode` set explicitly on every root node of a scene; timers/tweens must survive `get_tree().paused` per their `process_mode`; no `Engine.time_scale`.
- Godot 4 APIs only: no `yield`, no `instance()`, no `connect("name", obj, "method")` string form, no `KinematicBody2D`, no `Node.get_node()` with hard-coded deep paths outside the owning scene (use `%UniqueName` or `@export var` node references).
- Input: touch via `InputEventScreenTouch`/`InputEventScreenDrag`/`InputEventMagnifyGesture`/`InputEventPanGesture`; keyboard via InputMap actions listed in D1.1; never `Input.is_key_pressed`.

### STD-DATA (any file under `src/data/`, `data/`)
- `extends Resource`; first field `@export var schema_version: int = <n>`; every field typed with a default; no methods with side effects (pure lookups/validation only); `.tres` text format; ids are `StringName` and match the file name.

### STD-TOOL (any file under `tools/`)
- Scripts run with `-s` extend `SceneTree`, do their work in `_init()`, and call `quit(<code>)` with 0 = success, 1 = failure; arguments via `OS.get_cmdline_user_args()` `[VERIFY]`; they print one line per action and a final `OK`/`FAIL <count>` line; they never delete files, never write outside the paths given as arguments or `user://`.

### STD-HANDOFF (the state checklist an agent must log in `/ai/handoffs/<CARD-ID>.md` before ending a session or upon halt — schema in `/ai/handoffs/_TEMPLATE.md`)
1. `status` ∈ NOT_STARTED / IN_PROGRESS / BLOCKED / TESTS_FAILING / TESTS_PASSING / READY_FOR_REVIEW / ABANDONED, with timestamp (UTC ISO-8601).
2. Branch name and last WIP commit hash (pushed) — a handoff without a pushed commit is invalid.
3. Modified/created files with one-line intent each and per-file state (`done` / `partial` / `revert-me`).
4. Exact test command(s) run, last exit code, names of failing tests, the last 20 lines of output pasted.
5. Current hypothesis for each failing test (one sentence each).
6. Exact next step (the next command or edit the successor should perform).
7. Blockers (missing contract, `[VERIFY]` mismatch, dependency not merged) with the question the human must answer, if any.
8. Resume instructions: files to read in order, what NOT to redo, time already spent (minutes) against the 15-minute rule budget.
9. Self-review checklist status (AGENTS.md §9) — which items are done.

### STD-DOD
- CI green on the card branch (lint, format, typecheck, import, tests, content validation, sim bench regression).
- Zero editor warnings when opening the project (`$GODOT_BIN --headless --path . --import` prints no `WARNING`).
- Diff touches only the paths in Scope; new LOC within ceiling (measured with `tools/loc.py <base>..HEAD`).
- Tests from the Test-first field exist, failed before implementation (the handoff log shows the red run), pass after.
- Handoff file finalised with status READY_FOR_REVIEW; session log written to `/ai/logs/`; `ai/metrics/metrics.csv` row appended.
- PR opened with the deliverable format (AGENTS.md §9): diff summary, test output, handoff status, self-review checklist.
- If the card touches a tick path or `_process`: allocation probe result (object count delta 0) pasted in the PR.

### STD-GATE (what the human inspects on every card, in addition to the card's own list)
- Contract implemented exactly (names, types, signals) — compare with the card text.
- Allocation & lifetime: search the diff for the STD-SIM/STD-VIEW forbidden constructs; check pooled objects are returned; `RefCounted` cycles (parent ↔ child references) broken with `weakref` or index references.
- API integrity: Godot 4.7 API names only; deprecated calls (editor prints) none.
- State machine: every transition in the diff exists in the D2.7 tables.
- Determinism: no new source of order dependence (Dictionary iteration, sort, global RNG, wall clock).

### STD-ABANDON (the 15-minute rule, generic triggers)
- The human has spent 15 cumulative minutes coaxing this card's output (re-prompting, hand-fixing failing tests, explaining the contract again) → stop; mark the handoff ABANDONED with reason; the human writes it by hand or re-scopes the card into two.
- The agent proposes changing the contract, adding a dependency/addon, or touching files outside Scope → stop immediately (agent marks BLOCKED with the proposal; the human decides in the weekly slot).
- Two consecutive generation attempts fail the same test → agent marks TESTS_FAILING with hypotheses and stops (no third attempt without a human note in the handoff).
- The agent cannot run the test command (toolchain problem) → BLOCKED, not IN_PROGRESS.

## 7.3 Card sizing rules

- One file or one discrete function group; ≤ 120 new LOC of implementation; ≤ 150 LOC of tests; a card that needs more is split before it is issued (the split is itself a planning action recorded in the backlog, not an agent decision).
- Every card names its failing test first; a card whose behaviour cannot be tested headless (pure visuals, touch feel) states the smallest headless proxy (instance counts, node tree shape, emitted signals) and defers the rest to Gate 3.
- Human cards use the same template; their "Test-first" is the verification command/output the human records.
