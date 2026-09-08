# Handoff — CAD-FP-014 — CadSpatialHash uniform grid

## 1. Status
- status: TESTS_PASSING
- last_updated_utc: 2026-09-08T15:24:57Z
- agent: Codex; session: 1; takeover_from: none
- time_spent_min: 5

## 2. Branch and checkpoint
- branch: card/CAD-FP-014-spatial-hash
- last_pushed_commit: this checkpoint; resolve with `git log -1 -- ai/handoffs/CAD-FP-014.md` after push
- last_green_commit: none in this workspace; main base a96bc7d
- CAD-FP-009 dependency merged: be13226, registry update 8be41e4.

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| src/sim/spatial/cad_spatial_hash.gd | Preallocated counting-sort grid and bounded exact circle queries | planned |
| test/unit/sim/test_cad_spatial_hash.gd | Six card cases plus boundary/capacity coverage | planned |
| ai/handoffs/CAD-FP-014.md | Record plan and environment blocker | done |
| ai/handoffs/INDEX.md | Register blocked card | done |
| ai/logs/2026-09-08-CAD-FP-014-1.md | Close initial session | done |

Ordered plan: write card tests first; record executable red run; implement grid within 110 LOC; run targeted suite, typing, lint, purity and full suite; resolve tick allocation and validation gates before review.

## 4. Tests
- command: `tools/test.sh res://test/unit/sim/test_cad_spatial_hash.gd`
- last_exit_code: 126
- failing_tests: none executed
```text
/bin/bash: line 1: tools/test.sh: Permission denied
```
- Diagnostic using the existing POSIX wrapper: `sh tools/test.sh res://test/unit/sim/test_cad_spatial_hash.gd`
- diagnostic_exit_code: 2
```text
tools/test.sh: 5: GODOT_BIN: set GODOT_BIN to the Godot 4.7.2 console binary (docs/toolchain.md)
```
These are environment failures, not a test-first red run. No test or implementation files were created.

## 5. Hypotheses
- Wrapper is not executable in this checkout. Invoking via sh exposes the underlying unset GODOT_BIN; neither godot nor godot4 is on PATH. gdlint/gdformat are also absent from PATH.
- docs/toolchain.md records a different Windows machine; it does not establish tool availability in this Linux workspace.

## 6. Exact next step (original blocker; resolved below)
After the human authorizes/provides the pinned toolchain, set GODOT_BIN to the available Godot 4.7.2 executable, run `sh tools/test.sh res://test/unit/test_cad_smoke.gd`, then follow takeover and write the card's six tests. Resolve executable wrapper permissions within authorized scope before claiming the exact command works.

## 7. Blockers / questions for the human
- AGENTS.md §7.10 and STD-ABANDON require BLOCKED when the test command cannot run.
- AGENTS.md §5.1 requires explicit permission before installing dependencies; docs/toolchain.md labels install commands human-only.
- May the pinned Godot 4.7.2 and gdtoolkit 4.5.0 toolchain be installed in this workspace?
- tools/bench.sh and tools/validate.sh are not present yet; later cards introduce them. Allocation evidence for this tick-path card still needs an executable probe.

## 8. Resume instructions for a successor
- Read AGENTS.md, CLAUDE.md, this handoff, §7.2 standard sets, CAD-FP-014 and docs/toolchain.md.
- Do not redo task selection or dependency confirmation; no code has been implemented.
- [VERIFY] Packed array in-place mutation and brute-force runtime remain untested.
- Resume from this branch; record takeover and any environment discrepancy.

## 9. Self-review checklist
- [ ] contract implemented exactly
- [ ] tests first, now green; edge/capacity/determinism cases present
- [x] STD constraints met for documentation checkpoint; no code edited
- [ ] no allocation in tick paths / _process verified
- [x] no new dependency / asset introduced
- [x] implementation diff within Scope and LOC ceiling (0 implementation / 0 test LOC)
- [ ] lint, typecheck, purity, tests, validation green
- [x] log closed
- [ ] completion metrics row appended (deferred until card completion)
- [ ] every [VERIFY] resolved and recorded

## Session 2 — toolchain restored and implementation claim
- User explicitly authorized installing the toolchain and pushing commits.
- Godot 4.7.2.stable.official.ed1daf0bf installed under /workspace/scratch/d8bc082b1152/toolchain; archive verified against official SHA512-SUMS.txt.
- gdtoolkit 4.5.0 installed in /workspace/scratch/d8bc082b1152/toolchain-venv; both CLI versions confirmed.
- Import exit 0; smoke: `GODOT_SILENCE_ROOT_WARNING=1 GODOT_BIN=/workspace/scratch/d8bc082b1152/toolchain/Godot_v4.7.2-stable_linux.x86_64 sh tools/test.sh res://test/unit/test_cad_smoke.gd` exit 0, 2/2 passed, 27 ms.
- Shell push lacked authentication; connected GitHub API published identical checkpoint tree at a6e58a90ed0814f7d11eba5fda3a24a62b7becb4. Local original commit preserved on checkpoint/CAD-FP-014-local-603f02c.
- Next: write all six card tests plus sparse IDs, deterministic bucket order, full/zero output capacity, shrinking rebuild, and allocation object-count probe. Record the failing run, then implement prefix-count scatter and exact bounded queries within 110 LOC.
- Use `sh tools/*.sh` because wrapper executable bits are outside this card's scope. No wrapper changes needed.

## Tests-first checkpoint
- Seven tests written before implementation; all card cases plus capacity/order/shrinking/allocation coverage.
- Command: `GODOT_SILENCE_ROOT_WARNING=1 GODOT_BIN=/workspace/scratch/d8bc082b1152/toolchain/Godot_v4.7.2-stable_linux.x86_64 sh tools/test.sh res://test/unit/sim/test_cad_spatial_hash.gd`
- Missing CadSpatialHash prevents suite compilation as expected. Runner prints abnormal exit 105 but shell returns 0; this is not a passing test run. Typecheck/import gates remain necessary.
- Hypothesis: all unresolved type/method diagnostics stem from the not-yet-created CadSpatialHash.
- Next: implement the card interface, import to register the class, rerun seven tests.
```text
  Parse Error: The method "new()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:94
  Parse Error: The method "rebuild()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:97
  Parse Error: The method "item_count()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:98
  Parse Error: The method "query_circle()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:99
  Parse Error: The method "new()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:104
  Parse Error: The method "rebuild()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:111
  Parse Error: The method "rebuild()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:115
  Parse Error: The method "query_circle()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:116
  Parse Error: The method "item_count()" is not present on the inferred type "Variant" (but may be present on a subtype). (Warning treated as error.)
	at res://test/unit/sim/test_cad_spatial_hash.gd:120
Abnormal exit with 105
Run dispose test resources
```

## Implementation checkpoint
- All 7 spatial-grid tests pass on first implementation run, exit 0, 1.138 s.
- Exact circle results match brute force for 500 seeded points and 50 circles.
- [VERIFY] Packed output writes are visible to callers without resizing: confirmed.
- Full-capacity 512-point rebuild/query repeated 1,800 times: object_count_delta = 0 (asserted in passing test). Object-count measurement does not prove absence of every native allocation; source audit also required.
- Stable scatter uses input-slot-indexed scratch cells, so sparse entity IDs work with a small max_items capacity. Truncated output returns written count without resize.
- Next: lint, typecheck, purity, full suite, LOC and final review.
```text
  res://test/unit/sim/test_cad_spatial_hash.gd > test_rebuild_twice_same_order STARTED
  res://test/unit/sim/test_cad_spatial_hash.gd > test_rebuild_twice_same_order PASSED 7ms

  res://test/unit/sim/test_cad_spatial_hash.gd > test_empty_rebuild_query_zero STARTED
  res://test/unit/sim/test_cad_spatial_hash.gd > test_empty_rebuild_query_zero PASSED 7ms

  res://test/unit/sim/test_cad_spatial_hash.gd > test_full_capacity_tick_paths_create_no_objects STARTED
  res://test/unit/sim/test_cad_spatial_hash.gd > test_full_capacity_tick_paths_create_no_objects PASSED 1s 46ms

Statistics: 7 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans | PASSED 1s 138ms


Overall Summary: 7 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans |
Executed test suites: (1/1)
Executed test cases : (7/7)
Total execution time: 1s 138ms
 Open XML Report at: file://reports/gdunit/report_2/results.xml
Open HTML Report at: file://reports/gdunit/report_2/index.html
Exit code: 0
Run dispose test resources
```
