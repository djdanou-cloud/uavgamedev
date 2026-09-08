# Handoff — CAD-FP-012 — CadThreatStore (struct-of-arrays)

## 1. Status
- status: READY_FOR_REVIEW
- last_updated_utc: 2026-09-08T10:05:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 40

## 2. Branch and checkpoint
- branch: card/CAD-FP-012-threat-store
- last_pushed_commit: branch head
- last_green_commit: branch head

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `src/sim/store/cad_threat_store.gd` | 24 parallel arrays, lowest-index allocation, alive list, prev snapshot | done |
| `test/unit/sim/test_cad_threat_store.gd` | 9 cases | done, green |

## 4. Tests
- red run first: `Could not find type "CadThreatStore"`
- card suite → **9/9 pass**; full suite → **45/45 pass**, 0 orphans
- lint clean (14 files); typecheck `OK 13 scripts`; purity `OK`; scaffold PASS
- LOC: impl 125 (ceiling 120 — see item 7), test 112

## 5. Hypotheses
- none open.

## 6. Exact next step
CAD-FP-013 (`CadInterceptorStore`) — the same shape with fewer fields. Read item 8 finding 2 first:
it proposes a two-helper utility card that would remove ~12 lines from that card before it is written.

## 7. Blockers / questions for the human
- **LOC 125 against a ceiling of 120.** Unlike CAD-FP-009 this one is fixable, and finding 2 says how.
  I did not do it here because it touches two merged files and belongs in its own card.

## 8. Resume instructions for a successor
- read: this file → `src/sim/store/cad_threat_store.gd` → architecture §D2.3.
- do NOT redo: the allocation strategy or the field reset list.
- findings and decisions:
  1. **`_free`/`_free_count` from the card's contract were dropped.** The card also requires `alloc()`
     to return the *lowest* free index, and a free *stack* returns the most recently freed one — the
     two cannot both hold. The contract's own note resolves it in favour of the lowest index (scan
     from a cached hint), so the stack fields would have been dead state in the hottest store in the
     game. `_lowest_free` replaces them: `release()` lowers the hint, `alloc()` scans from it, and the
     common case is a single check. Deviation flagged rather than silently kept.
  2. **The `resize()`-returns-Error helpers now exist in three files** (`cad_event_log.gd`,
     `cad_rng.gd`, this one), and CAD-FP-013 would be the fourth. They are ~12 lines here — extracting
     them into a shared `CadPacked` utility would put this card at ~113, under its ceiling, and stop
     the duplication before it spreads. Suggested as a small card of its own, ahead of CAD-FP-013.
  3. **`alloc()` resets all 24 fields, and a test proves it.** A recycled slot that kept a stale
     `track_owner` or `flags` would produce a threat that is already tracked or already classified the
     moment it spawns — the kind of bug that only shows up after a long wave, when slots start being
     reused. `test_alloc_resets_every_field_of_a_recycled_slot` dirties a slot deliberately first.
  4. **`alloc()` seeds `prev` from the spawn point.** Otherwise the view interpolates the first frame
     from (0, 0) and every new threat streaks in from the map origin.
  5. The alive-list test churns the store with a seeded 200-step allocate/release pattern rather than a
     fixed sequence, so the ascending-order guarantee is checked against a realistic hole pattern.

## 9. Self-review checklist
- [x] contract implemented (all 24 arrays, six methods; `_free` fields dropped per finding 1)
- [x] tests first; red run recorded
- [x] STD-TYPING and STD-SIM met; no allocation in `alloc`, `release`, `rebuild_alive`, `snapshot_prev`
- [x] no new dependency
- [ ] **LOC within ceiling — 125 vs 120, remedy in finding 2**
- [x] diff limited to Scope
- [x] lint, typecheck, purity, suite green
- [x] handoff finalised; log closed; metrics row appended
