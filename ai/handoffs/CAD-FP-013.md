# Handoff — CAD-FP-013 — CadInterceptorStore (struct-of-arrays)

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T11:30:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 30

## 2. Branch and checkpoint
- branch: card/CAD-FP-013-interceptor-store
- last_pushed_commit: branch head
- last_green_commit: branch head

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `src/sim/store/cad_interceptor_store.gd` | 13 parallel arrays, lowest-index allocation, per-launcher count | done |
| `test/unit/sim/test_cad_interceptor_store.gd` | 10 cases | done, green |

## 4. Tests
- red run recorded first: `Could not find type "CadInterceptorStore"`
- card suite → **10/10 pass**; full suite → **59/59 pass**, 0 orphans
- lint clean, and gdformat left both new files unchanged; typecheck `OK 17 scripts`; purity `OK`
- LOC: impl 93 (ceiling 90 — see item 7), test 107
- green on the first implementation attempt; the only edit after writing was none

## 5. Hypotheses
- none open.

## 6. Exact next step
CAD-FP-014 (`CadSpatialHash`). It is the first card with a real algorithm rather than a container, and
its test compares every query against brute force, so expect the debugging to be in the cell maths.

## 7. Blockers / questions for the human
- **LOC 93 against a ceiling of 90**, and this time the cause is purely mechanical: the contract's
  `alloc()` takes nine parameters, the one-line form is ~125 characters, and gdformat therefore wraps
  it one parameter per line — eleven lines where the signature is conceptually one. Nothing else in
  the file is expendable. That is the third ceiling breach in a row caused by formatting rather than
  by content (CAD-FP-009 enums, CAD-FP-012 arrays, this signature), which I think settles the sizing
  question: **a line-based ceiling measures the formatter, not the work.**

## 8. Resume instructions for a successor
- read: this file → `src/sim/store/cad_interceptor_store.gd` → `CadThreatStore`, whose allocation
  strategy this mirrors exactly.
- do NOT redo: the allocation strategy; it is deliberately identical to the threat store so that both
  behave the same under churn.
- design notes:
  1. **A round keeps the probability of kill it was launched with.** The engagement was decided under
     the sensor and jamming conditions of the launch tick; recomputing at impact would let the result
     drift from what the player watched happen, and would make replays diverge.
  2. **`count_for_launcher()` reads the alive list**, so it reflects the last `rebuild_alive()`. That
     is what caps a launcher's simultaneous engagements, and a test checks the count drops after a
     round is released and the list is rebuilt.
  3. `alloc()` seeds `prev` from the launch point for the same reason as the threat store: otherwise
     the first drawn frame streaks in from the map origin.
  4. Only guided rounds live here. Gun bursts resolve instantly by probability roll with view-side
     tracers (A-05), which is why this store holds hundreds of rows rather than thousands.

## 9. Self-review checklist
- [x] contract implemented exactly (13 arrays, seven methods, `count_for_launcher` over alive)
- [x] tests first; red run recorded before implementation
- [x] STD-TYPING and STD-SIM met; no allocation in any tick-path method
- [x] no new dependency; uses `CadPacked` from CAD-FP-012A rather than a fourth private copy
- [ ] **LOC within ceiling — 93 vs 90, cause and recommendation in item 7**
- [x] diff limited to Scope
- [x] lint, typecheck, purity, suite green
- [x] handoff finalised; log closed; metrics row appended
