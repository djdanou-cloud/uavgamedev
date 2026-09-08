# Handoff — CAD-FP-003 — Install gdUnit4 and the test wrappers

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T04:40:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 45

## 2. Branch and checkpoint
- branch: card/CAD-FP-005-ci (continues the same working branch; see the deviation in item 8)
- last_pushed_commit: branch head
- last_green_commit: branch head (full suite green)

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `addons/gdUnit4/**` (272 files, 1.8 MB) | vendored test framework, MIT, unmodified | done |
| `addons/gdUnit4/VERSION.txt` | version 6.2.1, source URL, zip SHA-256, update procedure | done |
| `tools/test.sh` / `tools/test.cmd` | `tools/test.sh [res://suite]`, defaults to `res://test`; passes gdUnit4's exit code through unchanged | done |
| `test/unit/test_cad_smoke.gd` | two smoke assertions proving the harness runs | done |
| `.github/workflows/ci.yml` | new `gdUnit4 suite` step; `reports/` added to the log artifact | done |
| `AGENTS.md` §2, `07-task-card-template.md` STD-TYPING, `06-qa-release.md` G.1 | the test-suite convention forced by finding 1 below | done |
| `00-assumptions-register.md` A.0 + A-08 | gdUnit4 6.2.1 verified on 4.7.2; version pinned | done |

## 4. Tests
- `sh tools/test.sh res://test/unit/test_cad_smoke.gd` → **exit 0**, 2 test cases, 0 failures, 0 orphans, 18 ms
- deliberately failing suite (`assert_int(1).is_equal(2)`) → **exit 100**, then deleted. Confirms A.0's
  exit-code table (0 pass / 100 failures / 101 warnings) on this version
- `sh tools/test.sh` (whole `res://test`) → exit 0
- reports written: `reports/gdunit/report_1/results.xml` (JUnit) + `index.html`
- `gdlint` and `gdformat --check` over every `.gd` CI would see → exit 0 both
- from-scratch import (`rm -rf .godot && --import`) with the addon present → exit 0, no ERROR/WARNING
- wall time: 2 s for the suite; the addon adds no measurable import cost

## 5. Hypotheses
- none open.

## 6. Exact next step
CAD-FP-004 (`tools/check_scripts.gd`, `tools/lib/cad_purity_check.gd`, `tools/check_sim_purity.gd` and
their gdUnit4 suites). The harness, the wrappers and the CI step it needs all exist now.

## 7. Blockers / questions for the human
- One convention decision was forced and is worth your confirmation (item 8, finding 1).
- The repository is private, so I cannot read Actions results (`api.github.com` returns 404 without
  auth). Either install and authenticate `gh`, or paste the run result when you look at it.

## 8. Resume instructions for a successor
- read: this file → `addons/gdUnit4/VERSION.txt` → `AGENTS.md` §2 Tests row.
- do NOT redo: the vendoring, the exit-code probes, or the lint/format checks.
- findings recorded:
  1. **gdUnit4's fluent assertions collide with `return_value_discarded=2`.** `assert_bool(true).is_true()`
     returns the assert object, so a test suite would not even parse under our gate. Resolved with
     `@warning_ignore_start("return_value_discarded")` under the `extends` line of test suites only —
     verified to work on 4.7.2 — so `untyped_declaration` and every other warning stay Error in tests.
     The alternative (excluding `res://test` in `directory_rules`) would have turned off *all* warnings
     for tests, which the plan does not want.
  2. **Test suites must not declare `class_name`.** gdUnit4 discovers suites by path, and a name like
     `TestCadSmoke` violates the `.gdlintrc` `^Cad[A-Z]` rule. Documented in AGENTS.md §2.
  3. `--check-only` on a suite fails with "Could not find base class GdUnitTestSuite" until the project
     has been imported once after the addon was added; that is a stale class cache, not a real error.
  4. A suite that fails to parse makes the CLI **hang** rather than fail fast (the first run sat for
     over five minutes and had to be killed). CI job timeouts matter; so does parsing a new suite with
     `--check-only` before running it.
- deviation: this work sits on `card/CAD-FP-005-ci` rather than its own branch, because CAD-FP-005 was
  still open and the CI step for the suite belongs to the same change. Split at review if you prefer.

## 9. Self-review checklist
- [x] contract implemented exactly (wrapper CLI shape, exit-code pass-through, smoke suite)
- [x] tests first: the smoke suite was written before the wrappers were proven, and its first run failed
      (parse error) exactly as the card's red-run requirement expects
- [x] the addon is unmodified and pinned; VERSION.txt records source + SHA-256; MIT LICENSE included
- [x] no other dependency added
- [x] diff within Scope plus the documented convention edits
- [x] lint, format, import, suite all green locally
- [x] handoff finalised; log closed; metrics row appended
- [x] every `[VERIFY]` this card carried is resolved (CLI path, flags, exit codes, headless behaviour)
