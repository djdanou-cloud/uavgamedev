# Handoff — CAD-FP-005 — GitHub Actions CI (stage 1: lint + engine import)

## 1. Status
- status: IN_PROGRESS — implementation complete and locally validated; **the card's own test is a CI run,
  which only happens once this branch is pushed**. Nothing about this card is proven until then.
- last_updated_utc: 2026-09-08T02:10:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 40

## 2. Branch and checkpoint
- branch: card/CAD-FP-005-ci
- last_pushed_commit: (this commit) — not yet pushed to origin
- last_green_commit: n/a

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `.github/workflows/ci.yml` | two jobs: `lint` (gdtoolkit 4.5.0, gdlint + gdformat over existing `.gd`, Python tool tests) and `engine` (version-pinned Godot download verified against the release's SHA512 line, `--import` must be warning-free, report-only typing-gate probe, log artifact) | done, unrun |
| `tools/tests/test_scaffold.py` | in-repo version of the CAD-FP-002 checks so CI runs them: `loc.py` parsing/CLI/exit codes, icon SVG well-formedness + palette, `project.godot` structure and four key settings | done, verified locally (PASS) |
| `docs/production/03-architecture.md` §D5.2 | corrected download source and checksum scheme; job list now names the card that adds each step | done |
| `docs/production/00-assumptions-register.md` §A.0 | three new verified rows (release repo, SHA512-only, winget ids); A-32 wording corrected | done |
| `docs/production/09-execution-backlog.md` CAD-FP-005 | delivery note recording the two-stage execution and the dependency inversion | done |

## 4. Tests
- `python tools/tests/test_scaffold.py` → exit 0, `scaffold checks: PASS`
- YAML parse (PyYAML 6.0.3): top keys `name/on/permissions/concurrency/env/jobs`; triggers `push:[main]` +
  `pull_request`; jobs `lint` (6 steps) and `engine` (7 steps); every step has `uses` or `run`
- Third-party actions: none. Only `actions/checkout@v4`, `actions/setup-python@v5`, `actions/cache@v4`,
  `actions/upload-artifact@v4` (A-32 allowlist).
- `bash -n` over every `run:` block → 0 syntax errors
- NOT run: the workflow itself (needs a push). This is the card's real test.

## 5. Hypotheses
- The `--import` step may report benign WARNING lines on a project with no scenes and a `main_scene`
  that does not exist yet (CAD-FP-063 creates it). If the job fails on such a line, the fix is to
  narrow the grep to the specific message, **not** to drop the check — record the actual text first.
- `--check-only -s <script>` may not apply `debug/gdscript/warnings/*` at all; that is exactly why the
  probe step is report-only. Its output decides how CAD-FP-004 implements the hard typing gate.

## 6. Exact next step
1. Push this branch (or merge to `main`) so the workflow runs for the first time.
2. Read both jobs: `lint` should pass with "no .gd files yet"; `engine` should print the verified SHA-512
   line, `4.7.2.stable`, and end with `import clean`.
3. Copy the probe step's output into item 4 here and into `docs/production/00-assumptions-register.md`
   §A.0 — it resolves the highest-risk `[VERIFY]` in the project (A-10 typing gate).
4. Then set this handoff READY_FOR_REVIEW and unblock `/ai/handoffs/CAD-FP-002.md` item 6: a green
   `engine` job is the remote equivalent of that card's blocked `--import` check.

## 7. Blockers / questions for the human
- Nothing blocking. Two decisions: (a) push now to get the first CI signal; (b) still worth installing
  Godot locally — CI is ~3 min per push and cannot replace on-device work from CAD-FP-065 on.

## 8. Resume instructions for a successor
- read: this file → `.github/workflows/ci.yml` → `docs/production/03-architecture.md` §D5.2.
- do NOT redo: the release-asset research (recorded in A.0), the YAML/shell validation, `test_scaffold.py`.
- deviations recorded for review:
  1. **Card order.** CAD-FP-005 was executed before CAD-FP-003/004, which it nominally depends on,
     because the developer machine has no Godot and CI is the only available verification environment.
     The workflow contains only steps whose tools exist; each later card adds its own step. The
     dependency is therefore satisfied in the direction that matters (no step references a missing tool).
  2. **Scope.** `tools/tests/test_scaffold.py` is not in the card's Scope. Reason: the CAD-FP-002 checks
     lived in a scratch directory, so CI had nothing to run; they are now in-repo and repeatable. 91 lines,
     stdlib only, no product code. Reject it at review if you would rather keep card scopes literal.
  3. **Plan edits.** `SHA256` → `SHA512` and `godotengine/godot` → `godotengine/godot-builds` in §D5.2 and
     A-32, from the verified release asset list. This is a `[VERIFY]` resolution, not a design change.
- open `[VERIFY]` after this card: everything in `/ai/handoffs/CAD-FP-002.md` item 8 except the import
  check, which the `engine` job covers once it runs.

## 9. Self-review checklist
- [x] contract implemented (jobs, pinned versions, caching, artifact upload, allowlisted actions only)
- [x] tests written before the code they check (`test_scaffold.py` predates the CI step that runs it)
- [x] STD-TOOL for the Python test (stdlib, exit 0/1, no writes outside the repo)
- [x] no allocation-sensitive code
- [x] no new dependency beyond the pinned `gdtoolkit==4.5.0` the plan already mandates
- [x] no secrets; workflow has `permissions: contents: read` and uses no repository secrets
- [ ] CI green — **pending the first run** (item 6)
- [x] handoff written; log closed
- [ ] every `[VERIFY]` resolved — the probe result lands after the first run
