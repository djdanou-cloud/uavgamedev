# Handoff — CAD-FP-010 — CadRng seeded multi-stream RNG

## 1. Status
- status: IN_PROGRESS (claim)
- last_updated_utc: 2026-09-08T08:00:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 5

## 2. Branch and checkpoint
- branch: card/CAD-FP-010-rng
- last_pushed_commit: (claim commit)
- last_green_commit: n/a

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `src/sim/cad_rng.gd` | three independent streams, state save/restore, `chance()` | planned |
| `test/unit/sim/test_cad_rng.gd` | determinism, stream independence, state round-trip, extremes, bounds | planned |

## 4. Tests
- command: `tools/test.sh res://test/unit/sim/test_cad_rng.gd`
- last_exit_code: not yet run

## 5. Hypotheses
- `PackedInt64Array.resize()` and `append()` return values that A-10 forbids discarding, so
  `get_states()` will have to consume the result rather than ignore it.

## 6. Exact next step
Write the suite, parse-check it, record the red run, then implement `src/sim/cad_rng.gd`.

## 7. Blockers / questions for the human
- none.

## 8. Resume instructions for a successor
- read: the CAD-FP-010 card in `docs/production/09-execution-backlog.md` (full contract) → A-17 and
  A-18 in the assumptions register (why the streams are separate and what determinism means here).
- watch for: `chance()` must not consume randomness at p ≤ 0 or p ≥ 1, or a certainty would shift
  every later draw and break replay determinism.

## 9. Self-review checklist
- [ ] contract implemented exactly
- [ ] tests first (red run recorded)
- [ ] STD-TYPING / STD-SIM met
- [ ] no allocation in tick paths
- [ ] no new dependency
- [ ] diff within Scope and LOC ceiling (≤ 60)
- [ ] lint, typecheck, purity, suite green
- [ ] handoff finalised; log closed; metrics row appended
