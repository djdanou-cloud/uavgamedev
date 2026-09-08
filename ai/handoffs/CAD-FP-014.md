# Handoff — CAD-FP-014 — CadSpatialHash uniform grid

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T15:38:30Z
- agent: Codex; session: 2; takeover_from: same agent session 1
- All local gates available at this milestone pass. Both CI jobs passed on 67694cf (run 34246221910).

## 2. Branch and checkpoint
- branch: card/CAD-FP-014-spatial-hash
- last_pushed_commit: 67694cf0ff1fb443ac684f8c708ddd4f86ac119e — passing checks and review evidence
- last_green_commit: 67694cf0ff1fb443ac684f8c708ddd4f86ac119e (both remote CI jobs passed)
- Original local 603f02c preserved on checkpoint/CAD-FP-014-local-603f02c. Connected GitHub API publishes matching trees with GitHub author metadata, hence different commit SHAs.
- Dependency CAD-FP-009 confirmed merged at be13226 / 8be41e4 before claim.

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| src/sim/spatial/cad_spatial_hash.gd | Preallocated stable counting-sort grid; exact circle queries | done |
| test/unit/sim/test_cad_spatial_hash.gd | Six card cases plus capacity, sparse IDs, output order and object-count probe | done |
| src/sim/spatial/cad_spatial_hash.gd.uid | Engine-generated class UID | done |
| test/unit/sim/test_cad_spatial_hash.gd.uid | Engine-generated test UID | done |
| ai/handoffs/CAD-FP-014.md | Plan, test evidence, review and resume instructions | done |
| ai/handoffs/INDEX.md | Card registry | done |
| ai/logs/2026-09-08-CAD-FP-014-1.md | Original blocked session record | done |
| ai/logs/2026-09-08-CAD-FP-014-2.md | Implementation session record | done |
| ai/metrics/metrics.csv | Card delivery metrics | done |

Plan recorded and pushed before edits: tests → red run checkpoint → implementation → targeted test checkpoint → all available gates. Implementation 81 / 110 LOC; tests 107 / 150 LOC (`python tools/loc.py main..HEAD`). No existing source reformatted.

## 4. Tests
Environment for commands:
```sh
export GODOT_BIN=/workspace/scratch/d8bc082b1152/toolchain/Godot_v4.7.2-stable_linux.x86_64
export GODOT_SILENCE_ROOT_WARNING=1
export PATH=/workspace/scratch/d8bc082b1152/toolchain-venv/bin:$PATH
```
Use `sh tools/*.sh`: existing wrapper execute bits are absent in this Linux checkout and outside card scope.

| command | exit | evidence |
|---------|------|----------|
| `"$GODOT_BIN" --headless --path . --import` | 0 | no ERROR or WARNING lines in final import |
| `sh tools/lint.sh` | 0 | no problems; 20 files unchanged |
| `sh tools/typecheck.sh` | 0 | OK 19 scripts |
| `sh tools/purity.sh` | 0 | OK purity res://src/sim |
| `sh tools/test.sh res://test/unit/sim/test_cad_spatial_hash.gd` | 0 | 7/7, no errors/failures/orphans, 1.138 s |
| `sh tools/test.sh` | 0 | 66/66 across 9 suites, no errors/failures/orphans, 2.150 s |
| `python tools/tests/test_scaffold.py` | 0 | scaffold checks PASS |
| `git diff --check main..HEAD` | 0 | clean |

- failing_tests: none
- Brute-force 500 points × 50 circles: 15 ms (targeted XML report).
- Tick probe: 512 items × 1,800 rebuild/query iterations; object_count_delta = 0 asserted. This detects Godot object growth, not every native allocation; source audit confirms preallocated buffers, scalar inner-loop math and no hot-path constructors/resizing.
- tools/validate.sh (CAD-FP-023) and tools/bench.sh (CAD-FP-041) do not exist yet. No content or whole-game benchmark claim is made. The card's allocation probe is implemented in its own suite.

### Tests-first red evidence
Tests committed locally at 11e94d2 and published at 1712456e057989dbcbf782c16c72ca4de68b78ec before implementation.
Missing CadSpatialHash caused unresolved-type compilation failures. gdUnit4 printed abnormal 105 while the shell returned 0: this is a failed suite load, never recorded as passing tests.
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
### Latest targeted output
```text

  res://test/unit/sim/test_cad_spatial_hash.gd > test_out_of_bounds_points_clamped_and_found STARTED
  res://test/unit/sim/test_cad_spatial_hash.gd > test_out_of_bounds_points_clamped_and_found PASSED 8ms

  res://test/unit/sim/test_cad_spatial_hash.gd > test_zero_radius_returns_coincident_only STARTED
  res://test/unit/sim/test_cad_spatial_hash.gd > test_zero_radius_returns_coincident_only PASSED 6ms

  res://test/unit/sim/test_cad_spatial_hash.gd > test_out_written_in_place_no_resize STARTED
  res://test/unit/sim/test_cad_spatial_hash.gd > test_out_written_in_place_no_resize PASSED 6ms

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
### Full-suite output
```text
  res://test/unit/test_cad_smoke.gd > test_smoke_int_math STARTED
  res://test/unit/test_cad_smoke.gd > test_smoke_int_math PASSED 9ms

Statistics: 2 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans | PASSED 36ms


Overall Summary: 66 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans |
Executed test suites: (9/9)
Executed test cases : (66/66)
Total execution time: 2s 150ms
 Open XML Report at: file://reports/gdunit/report_3/results.xml
Open HTML Report at: file://reports/gdunit/report_3/index.html
Exit code: 0
Run dispose test resources
```

## 5. Hypotheses
- No remaining test failures. Original unresolved-type diagnostics were removed by implementing the missing class.
- gdUnit's suite-load exit mismatch is outside this card; import/typecheck plus explicit executed-test counts prevent treating it as green.

## 6. Exact next step
PR https://github.com/djdanou-cloud/uavgamedev/pull/1 is ready for human review and squash merge. Review stable scatter and boundary behavior; no source changes remain.

## 7. Blockers / questions for the human
- No local toolchain blocker remains. User explicitly authorized installation and branch publishing.
- Godot 4.7.2.stable.official.ed1daf0bf archive verified against the official SHA512-SUMS.txt. gdlint/gdformat both report 4.5.0.
- Native shell push has no authentication. Connected GitHub integration has verified push permission and published each checkpoint successfully.
- Future-milestone content/whole-sim benchmark tools unavailable as noted above; do not fabricate their results.

## 8. Resume instructions
- Read AGENTS.md, CLAUDE.md, this handoff, the CAD-FP-014 card and two new source/test files.
- Do not restart implementation or repeat green local tests without a new defect or code change.
- [VERIFY] Packed array writes in query arguments affect the caller and do not resize: confirmed by test.
- Stable bucket order follows input order; cells are visited in ascending row-major order. Sparse IDs index xs/ys; scratch is indexed by input slot.
- Query buffer exhaustion returns written count, preserving deterministic prefix. Empty output returns zero. Out-of-world positions remain searchable through clamped cells and exact distance filtering.

## 9. Self-review checklist
- [x] contract implemented exactly
- [x] tests first with failed-load red evidence; now 7/7 green, edge/capacity/determinism coverage
- [x] strict typing and sim purity gates green; no forbidden patterns
- [x] preallocated hot paths and scalar inner-loop math; object_count_delta = 0
- [x] toolchain dependency installation explicitly authorized; no new project addon or asset
- [x] source diff within Scope; LOC 81/110 implementation and 107/150 tests
- [x] import, lint, typecheck, purity and full tests green locally
- [ ] content validation / whole-sim bench (tools arrive in later cards)
- [x] log closed; metrics row appended
- [x] Packed-array [VERIFY] resolved and recorded
- [x] remote CI reviewed: both jobs passed, https://github.com/djdanou-cloud/uavgamedev/actions/runs/34246221910

## Final review deliverable
## CAD-FP-014: CadSpatialHash uniform grid
### Diff summary
Threat proximity queries need a deterministic spatial index before sensor and targeting systems can be built.
- src/sim/spatial/cad_spatial_hash.gd: preallocated stable counting-sort grid and bounded exact circle queries; supports sparse IDs and clamped out-of-world positions.
- test/unit/sim/test_cad_spatial_hash.gd: seven tests covering all six card cases, deterministic output, exact boundaries, small/empty output buffers, shrinking rebuilds and capacity.
- Matching .uid files: generated by Godot.
- ai/handoffs/CAD-FP-014.md, INDEX.md, session logs and metrics.csv: plan, failed-load red evidence, toolchain setup and validation results.
- Implementation LOC 81 / 110; test LOC 107 / 150.

### Test output
```text
sh tools/test.sh res://test/unit/sim/test_cad_spatial_hash.gd
7 test cases | 0 errors | 0 failures | 0 skipped | 0 orphans
Executed test suites: 1/1
Executed test cases: 7/7
Total execution time: 1.138 s
Exit code: 0
Brute-force comparison (500 points, 50 circles): 15 ms
512 items, 1800 rebuild/query iterations: object_count_delta = 0

sh tools/test.sh
66 test cases | 0 errors | 0 failures | 0 skipped | 0 orphans
Executed test suites: 9/9
Executed test cases: 66/66
Total execution time: 2.150 s
Exit code: 0
```
Full last-30-line targeted output is in the handoff.
Import, lint/format, typecheck (19 scripts), purity, Python scaffold and whitespace checks also pass.
Existing wrappers are invoked through sh because their executable bits are absent.
tools/validate.sh and tools/bench.sh arrive in later cards; no whole-game benchmark/content-validation result is claimed.

### Handoff status
READY_FOR_REVIEW — ai/handoffs/CAD-FP-014.md @ 67694cf0ff1fb443ac684f8c708ddd4f86ac119e. Both CI jobs passed: https://github.com/djdanou-cloud/uavgamedev/actions/runs/34246221910.

### [VERIFY] items resolved
- Packed output argument mutates caller without resizing: confirmed by passing test.
- Tests-first suite load failed before implementation because CadSpatialHash was absent. gdUnit printed abnormal 105 but shell returned 0; this was not counted as green. Existing import/typecheck gates and executed test counts were inspected.
- Godot 4.7.2 official archive SHA512 verified; engine version 4.7.2.stable.official.ed1daf0bf, gdtoolkit 4.5.0.

### Self-review checklist
- [x] contract implemented exactly
- [x] tests written first (red evidence in handoff), now green; edge/capacity/determinism covered
- [x] strict typing and sim purity pass; no forbidden patterns
- [x] hot paths use preallocated buffers and scalar item math; object-count delta 0 (does not prove absence of all native allocations)
- [x] toolchain installation authorized; no new project dependency or asset
- [x] source diff limited to scope and LOC ceiling; untouched code not reformatted
- [x] available local gates pass
- [x] handoff finalized, session log closed, metrics appended
- [x] card [VERIFY] resolved
- [x] remote CI reviewed
- [ ] future-milestone content validation and whole-sim benchmark

