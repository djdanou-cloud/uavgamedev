# B. Implementation-Ready Design Bible

Every table here maps 1:1 to a Resource schema in [03-architecture.md §D3](03-architecture.md) (mapping index in B.14). Numbers are the **seed values** for the balance harness (G.2); the harness changes numbers, never structure. Realism-vs-fun questions are marked `[HUMAN]`.

## B.1 Units, frame, time

| Quantity | Unit / rule |
|----------|-------------|
| Distance | metres (1 world unit = 1 m). Map 1 bounds x ∈ [−10,000, +10,000], y ∈ [−6,000, +6,000]; city centre (0, 0); threat axis for map 1 = (−1, 0) (threats come from the east edge, heading west) |
| Time | sim ticks of 1/30 s (`CadConst.TICK_DT`); all durations in tables are seconds and are converted to ticks at def load (`ceil(s × 30)`) |
| Altitude | metres AGL, stored per threat (`alt_m`); bands: LOW < 300, MED 300–3,000, HIGH > 3,000, BALLISTIC (descending from 40,000) |
| RCS | m², log-scale thinking: 0.005 (FPV) … 0.5 (SRBM / decoy apparent) |
| Money | credits (CR), integers |
| Probability | 0.0–1.0 floats; rolled with `CadRng.chance(COMBAT, p)` |

## B.2 Threat roster → `CadThreatDef`

| id | class | cost | hp | speed m/s | alt band | altitude_m | rcs_m2 | apparent_rcs_m2 | guidance | damage | target_pref | eccm_level | jam_radius_m | jam_strength | sensor_radius_m | orbit_time_s | intro_wave | sprite_id |
|----|-------|------|----|-----------|----------|------------|--------|-----------------|----------|--------|-------------|------------|--------------|--------------|-----------------|--------------|------------|-----------|
| cad_thr_recon | RECON | 150 | 20 | 35 | HIGH | 5,000 | 0.05 | 0 | DATALINK | 0 | REVEAL_ORBIT | 0 | 0 | 0 | 4,000 | 90 | 3 | thr_recon |
| cad_thr_fpv | FPV | 20 | 5 | 30 | LOW | 80 | 0.005 | 0 | DATALINK | 8 | EMPLACEMENT_NEAREST | 0 | 0 | 0 | 0 | 0 | 2 | thr_fpv |
| cad_thr_owa | OWA | 100 | 15 | 50 | LOW | 150 | 0.05 | 0 | SATNAV | 40 | DISTRICT_VALUE | phase | 0 | 0 | 0 | 0 | 1 | thr_owa |
| cad_thr_cruise | CRUISE | 800 | 40 | 240 | LOW | 60 | 0.10 | 0 | TERCOM | 160 | DISTRICT_VALUE | 0 | 0 | 0 | 0 | 0 | 4 | thr_cruise |
| cad_thr_srbm | SRBM | 2,500 | 60 | 1,400 | BALLISTIC | 40,000→0 | 0.50 | 0 | BALLISTIC | 400 | DISTRICT_VALUE / EMITTER_REVEALED | 0 | 0 | 0 | 0 | 0 | 12 | thr_srbm |
| cad_thr_decoy | DECOY | 60 | 8 | 200 | LOW | 100 | 0.02 | 0.50 | INS | 0 | PASS_THROUGH | 0 | 0 | 0 | 0 | 0 | 7 | thr_decoy |
| cad_thr_jammer | JAMMER | 300 | 20 | 40 | MED | 1,500 | 0.20 | 0 | DATALINK | 10 | JAM_ORBIT | 1 | 5,000 | 0.50 | 0 | 120 | 9 | thr_jammer |
| cad_thr_sead (Beta stretch) | SEAD | 400 | 15 | 45 | LOW | 200 | 0.03 | 0 | ANTI_RADIATION | 60 | EMITTER_NEAREST | 1 | 0 | 0 | 0 | 0 | 18 | thr_sead |
| cad_thr_glide (Beta stretch) | GLIDE | 500 | 30 | 150 | MED | 3,000→200 | 0.15 | 0 | SATNAV | 120 | DISTRICT_VALUE | 1 | 0 | 0 | 0 | 0 | 22 | thr_glide |

Per-class behaviour (implemented in `CadThreatMotion` state table, D2):

| class | flight profile | terminal | on EW link loss | special |
|-------|----------------|----------|-----------------|---------|
| RECON | straight to orbit point above densest emplacement cluster (k-means not needed: cluster = emplacement with most neighbours within 3,000 m), orbit radius 1,500 m for `orbit_time_s`, then EXITED | none | WANDER 15 s → CRASHED | every emplacement within `sensor_radius_m` for ≥ 10 s cumulative becomes `revealed = true` (persists for the run) |
| FPV | straight to nearest emplacement within 3,000 m of its path, else nearest district | dive at 300 m | WANDER 8 s → CRASHED | spawns in swarms (package `swarm`) |
| OWA | straight to district chosen by value weight | none | WANDER 12 s → CRASHED | `eccm_level` set per wave phase (B.7) |
| CRUISE | straight, alt 60 m (detected only inside `low_alt_horizon_m`) | none | immune (TERCOM) | from wave 14 a `strike` package escorts each cruise with 1–2 decoys spawned 400 m ahead |
| SRBM | appears at apex (alt 40,000 m, 8,000 m short of target along the axis), descends on a straight line to target over 20 s (`alt_m` linear to 0) | impact | immune | detectable by search radars only when `alt_m ≤ radar.max_alt_m` (30,000) → ≈ 15 s engagement window; engageable only by LRSAM (alt coverage BALLISTIC) |
| DECOY | straight through the city, exits west edge | none | immune (INS) | radars report `apparent_rcs_m2` until classified: classified after 8 s (`decoy_classify_s`) of FCR track **or** any passive sensor detection; after classification `min_threat_value` doctrine filters ignore it (value 60) |
| JAMMER | to orbit point 6,000 m from city centre on the axis, orbits 120 s, then EXITED | none | WANDER 15 s → CRASHED | jam field (B.5.2) |
| SEAD | straight to nearest **emitting** radar (search/FCR that detected anything in the last 5 s); decoy emitters attract with weight 3 | dive | WANDER 10 s → CRASHED | if no emitter active for 20 s → loiters (ORBIT) at 5,000 m from centre |
| GLIDE | from alt 3,000 descending to 200 over its run-in | none | WANDER 10 s → CRASHED (SATNAV) | — |

## B.3 Emplacement roster → `CadEmplacementDef`

### B.3.1 Sensors

| id | kind | cost | hp | upkeep | detect_ref_range_m (at 1 m²) | low_alt_horizon_m | max_alt_m | alt_coverage | track_capacity | track_range_m | jam_vulnerability | passive_range_m | emits | tech |
|----|------|------|----|--------|-------------------------------|-------------------|-----------|--------------|----------------|---------------|-------------------|-----------------|-------|------|
| cad_emp_search_radar | SENSOR_SEARCH | 400 | 60 | 20 | 15,000 | 6,000 | 30,000 | LOW,MED,HIGH,BALLISTIC | 0 | 0 | 1.0 | 0 | yes | base |
| cad_emp_fcr | SENSOR_FCR | 600 | 50 | 30 | 8,000 | 5,000 | 30,000 | LOW,MED,HIGH,BALLISTIC | 6 | 12,000 | 0.8 | 0 | yes | base |
| cad_emp_passive | SENSOR_PASSIVE | 350 | 30 | 10 | 0 | 0 | 0 | LOW | 0 | 0 | 0.0 | 2,500 | no | base |

### B.3.2 Shooters

| id | kind | cost | hp | upkeep | range_max_m | range_min_m | alt_coverage | shot_interval_s | reload_s | ammo_capacity | stock_max | ammo_cost | interceptor_speed_mps | channels | needs_track_for_full_pk | organic_range_m | jam_vulnerability | is_gun | tech |
|----|------|------|----|--------|-------------|-------------|--------------|-----------------|----------|---------------|-----------|-----------|-----------------------|----------|--------------------------|-----------------|-------------------|--------|------|
| cad_emp_aaa | GUN_AAA | 250 | 80 | 10 | 2,500 | 0 | LOW,MED | 1.5 | 0 | 60 | 300 | 5 | 0 | 1 | no | 3,000 | 0.2 | yes | base |
| cad_emp_ciws | GUN_CIWS | 900 | 70 | 40 | 1,500 | 0 | LOW,MED | 0.5 | 0 | 40 | 200 | 15 | 0 | 1 | no | 2,500 | 0.3 | yes | T2 |
| cad_emp_shorad | LAUNCHER_SHORAD | 500 | 60 | 25 | 6,000 | 500 | LOW,MED | 2.0 | 8 | 4 | 16 | 60 | 600 | 1 | no | 4,000 | 0.4 | no | base |
| cad_emp_mrsam | LAUNCHER_MRSAM | 1,800 | 90 | 60 | 12,000 | 1,500 | LOW,MED,HIGH | 3.0 | 30 | 8 | 24 | 250 | 900 | 2 | yes | 5,000 | 0.5 | no | T1 |
| cad_emp_lrsam | LAUNCHER_LRSAM | 4,500 | 120 | 120 | 20,000 | 3,000 | MED,HIGH,BALLISTIC | 4.0 | 60 | 4 | 12 | 1,200 | 1,600 | 2 | yes | 8,000 | 0.3 | no | T2 |
| cad_emp_uav | LAUNCHER_UAV | 600 | 50 | 20 | 5,000 | 300 | LOW | 4.0 | 20 | 2 | 12 | 40 | 120 | 1 | no | 3,000 | 0.6 | no | T2 |

`ammo_capacity` = rounds loaded on the launcher; `stock_max` = reserve rounds the player may buy at `ammo_cost` each; in-wave reload moves rounds from stock to launcher over `reload_s` when the launcher is empty. Guns: `ammo_capacity` = bursts before an in-wave resupply pause of `reload_s` = 0 (continuous) but stock-limited.

### B.3.3 Support

| id | kind | cost | hp | upkeep | effect_radius_m | effect (fields: `effect_a`, `effect_b`) | tech |
|----|------|------|----|--------|-----------------|------------------------------------------|------|
| cad_emp_ew | EW_JAMMER | 700 | 50 | 30 | 4,000 | `jam_strength` 0.6 → per-second link-loss probability = 0.6 × EW row of Pk table × (1 − 0.25 × threat.eccm_level) | base |
| cad_emp_decoy_emitter | DECOY_EMITTER | 300 | 30 | 10 | 5,000 | attraction weight 3.0 for ANTI_RADIATION seekers; absorbs the hit | T2 |
| cad_emp_c2 | C2_NODE | 800 | 60 | 30 | 8,000 | a shooter is **linked** if within radius of a C2 node that has ≥ 1 sensor within its radius; without any C2 on the map, shooters with `needs_track_for_full_pk = no` are linked by default (voice net) | base |
| cad_emp_depot | LOGISTICS | 600 | 80 | 20 | 6,000 | launchers in radius: `reload_s` × 0.75, `stock_max` × 1.5 | base |
| cad_emp_repair | REPAIR | 500 | 40 | 15 | 4,000 | 5 hp/s to damaged emplacements in radius during WAVE; district repair cap +50 hp/wave for districts whose centre is in radius | base |
| cad_emp_hardening | HARDENING | 400 (per district) | — | 0 | district | district damage × 0.7 (T2 node), × 0.5 with `t3_hardening_2` | T2 |

Placement rules (all kinds): footprint radius 150 m, no overlap of footprints; only inside `build_zones` polygons and outside `no_build_zones`; hardening is bought per district from the inspector, not placed.

## B.4 Pk matrix → `CadPkTable`

Base probability of kill per engagement (weapon row × threat column). Row `cad_emp_ew` is the per-second link-loss base probability, not a Pk.

| weapon \ threat | recon | fpv | owa | cruise | srbm | decoy | jammer | sead | glide |
|-----------------|-------|-----|-----|--------|------|-------|--------|------|-------|
| cad_emp_aaa | 0.05 | 0.30 | 0.25 | 0.08 | 0.00 | 0.25 | 0.15 | 0.25 | 0.10 |
| cad_emp_ciws | 0.05 | 0.45 | 0.40 | 0.30 | 0.00 | 0.40 | 0.20 | 0.40 | 0.30 |
| cad_emp_shorad | 0.70 | 0.60 | 0.75 | 0.40 | 0.00 | 0.75 | 0.80 | 0.70 | 0.50 |
| cad_emp_mrsam | 0.90 | 0.50 | 0.85 | 0.80 | 0.10 | 0.85 | 0.90 | 0.80 | 0.75 |
| cad_emp_lrsam | 0.90 | 0.30 | 0.60 | 0.70 | 0.70 | 0.60 | 0.90 | 0.60 | 0.65 |
| cad_emp_uav | 0.40 | 0.55 | 0.65 | 0.00 | 0.00 | 0.65 | 0.60 | 0.60 | 0.00 |
| cad_emp_ew | 0.10 | 0.25 | 0.12 | 0.00 | 0.00 | 0.00 | 0.05 | 0.08 | 0.06 |

Pk modifiers (multiplicative, applied at launch/burst time, clamped to [0, 0.98]):

| condition | factor | source field |
|-----------|--------|--------------|
| engagement mode ORGANIC (no cue, own sensor only) | × 0.6 | `CadBalanceConfig.organic_pk_mult` |
| engagement mode CUED (detected by any friendly sensor, no FCR track) for a `needs_track_for_full_pk` weapon | × 0.75 | `cued_pk_mult` |
| jam field J at the shooter's position (radar-guided weapons only) | × (1 − 0.5 × J × jam_vulnerability) | `jam_pk_mult` |
| upgrade level 2 / 3 | + 0.05 / + 0.10 additive | `CadUpgradeDef` |
| tech `t1_aaa_prox` (AAA vs FPV/OWA) | + 0.10 additive | `CadTechNode` |
| tech `t3_abm_upgrade` (LRSAM vs SRBM) | + 0.15 additive | `CadTechNode` |

Derived cost-exchange table (expected CR spent per kill = ammo_cost / Pk; enemy cost in the header). These are **test thresholds** for `test/scenario/test_cost_exchange.gd` (±20 % over 2,000 engagements).

| weapon | vs fpv (20) | vs owa (100) | vs cruise (800) | vs srbm (2,500) |
|--------|-------------|--------------|-----------------|-----------------|
| AAA (5/burst) | 17 | 20 | 63 | — |
| CIWS (15) | 33 | 38 | 50 | — |
| SHORAD (60) | 100 | 80 | 150 | — |
| MRSAM (250) | 500 | 294 | 313 | 2,500 |
| LRSAM (1,200) | 4,000 | 2,000 | 1,714 | 1,714 |
| UAV (40) | 73 | 62 | — | — |

Core tension, stated as a rule: the only sub-1:1 exchange against drones is AAA/UAV/EW; the only sub-1:1 exchange against cruise is MRSAM (or a lucky SHORAD); nothing beats an SRBM below 0.7:1.

## B.5 Kill-chain rules (pseudocode; implemented across `CadSensorSystem`, `CadTrackSystem`, `CadTargeting`, `CadFireControl`, `CadInterceptorSystem`, `CadImpactSystem`)

### B.5.1 Precomputed at sim init (no `pow` in tick loops, A-18)

```
for each sensor def s, threat def t:
    rcs = t.apparent_rcs_m2 if t.apparent_rcs_m2 > 0 else t.rcs_m2
    det_range[s][t] = s.detect_ref_range_m * (rcs / cfg.radar_rcs_ref_m2) ^ 0.25   # radar equation, R ∝ RCS^¼
    det_range_true[s][t] = s.detect_ref_range_m * (t.rcs_m2 / cfg.radar_rcs_ref_m2) ^ 0.25   # used once a decoy is classified
```

### B.5.2 Jam field (per tick, per sensor and per shooter position)

```
J(p) = min(0.9, Σ over alive JAMMER threats j: j.jam_strength * max(0, 1 - dist(p, j) / j.jam_radius_m) * (1 - cfg.eccm_step * radar_eccm_level))
```
`radar_eccm_level` = 1 when tech `t2_eccm_radar` is owned, else 0.

### B.5.3 DETECT (`CadSensorSystem.update`)

```
for each sensor emplacement s in index order (state ACTIVE):
    Js = J(s.pos)
    for each threat i in spatial_hash.query_circle(s.pos, s.max_query_radius):
        band = threat.alt_band[i]
        if band not in s.alt_coverage: continue
        if s.kind == SENSOR_PASSIVE:
            detected = band == LOW and dist2 <= passive_range^2          # ignores RCS and J
        else:
            r = det_range_true if flags[i] & CLASSIFIED else det_range
            r = r[s.def][threat.def[i]] * (1 - s.jam_vulnerability * Js)
            if band == LOW: r = min(r, s.low_alt_horizon_m)
            if band == BALLISTIC and threat.alt_m[i] > s.max_alt_m: r = 0
            detected = dist2 <= r * r
        if detected:
            threat.detect_ticks_left[i] = cfg.detection_persist_ticks   # 2 s persistence
            s.last_emit_tick = tick                                      # makes s an "emitter" for SEAD
            if s.kind == SENSOR_PASSIVE and threat.def is DECOY: flags[i] |= CLASSIFIED
            emit THREAT_DETECTED(i, s) on 0→1 transition
for each threat: detect_ticks_left -= 1; on 1→0 emit THREAT_LOST
```

### B.5.4 TRACK (`CadTrackSystem.update`)

```
for each FCR f in index order:
    keep existing tracks whose threat is alive, detected, and within track_range (hysteresis)
    free = f.track_capacity - kept
    candidates = detected threats within track_range not already tracked by any FCR
    choose top `free` candidates by (threat value desc, dist asc, index asc) using a fixed-size insertion buffer (no sort call)
    assign: threat.track_owner[i] = f.index; threat.track_age[i] = 0; emit TRACK_ASSIGNED
for each tracked threat: track_age += 1; if DECOY and track_age >= classify_ticks: flags |= CLASSIFIED

engage_mode(shooter L, threat i):
    if not in_range(L, i) or band not in L.alt_coverage: return NONE
    if threat.track_owner[i] >= 0 and L.linked: return TRACKED
    if threat.detect_ticks_left[i] > 0 and L.linked: return CUED
    if dist2 <= L.organic_range_m^2: return ORGANIC
    return NONE
```
`L.linked` is recomputed only when emplacements change (place/sell/destroy), not per tick (C2 graph, B.3.3).

### B.5.5 ENGAGE (`CadTargeting.select_target`, `CadFireControl.update`)

```
for each shooter L in index order:
    if L.state != ACTIVE or L.doctrine.roe == HOLD or tick < L.ready_tick or L.ammo == 0 or L.channels_busy >= L.channels: continue
    best = -1; best_key = +inf
    for each threat i in spatial_hash.query_circle(L.pos, L.range_max_m):
        mode = engage_mode(L, i)
        if mode == NONE: continue
        if threat.value(i) < L.doctrine.min_threat_value: continue            # value = def.cost, decoys classified → 60
        if threat.engaged_by[i] >= cfg.max_engagements_per_threat (2): continue
        if L.doctrine.roe == TIGHT and not (impact_point(i) within L.defended_radius(6,000 m) of L.pos or target_of(i) == L): continue
        pk = pk_table[L.def][threat.def[i]] * mode_mult(mode) * jam_mult(L) + additive_bonuses(L)
        if pk < cfg.min_pk_to_fire (0.05): continue
        key = doctrine_key(L.doctrine.priority, i, pk):
            NEAREST_IMPACT  → ticks_to_impact(i)
            HIGHEST_VALUE   → -threat.value(i)
            FASTEST         → -speed(i)
            BEST_EXCHANGE   → L.ammo_cost / pk - threat.value(i) * 0.01
        tie-break: index asc
        if key < best_key: best = i; best_key = key
    if best < 0: continue
    if L.is_gun:
        hit = rng.chance(COMBAT, pk); emit BURST_FIRED(L, best, hit); if hit: kill(best, by L)
        L.ammo -= 1; L.ready_tick = tick + L.shot_interval_ticks
    else:
        t_int = intercept_time(L.pos, threat.pos[best], threat.vel[best], L.interceptor_speed_mps)   # closed-form, capped at range/speed
        for s in 1..L.doctrine.salvo (while ammo > 0 and channels free):
            interceptors.alloc(L, best, pk, resolve_tick = tick + ceil(t_int * 30)); L.ammo -= 1; L.channels_busy += 1; threat.engaged_by[best] += 1
            emit SHOT_FIRED(L, best)
        L.ready_tick = tick + L.shot_interval_ticks
    if L.ammo == 0 and L.stock > 0: L.state = RELOADING; L.reload_end_tick = tick + reload_ticks(L)   # depot factor applied
```
Manual fire override (`CommandType.MANUAL_FIRE`): same as the missile branch with doctrine checks skipped, once, then `manual_cooldown_ticks` (3 s).

### B.5.6 ASSESS (`CadInterceptorSystem.update`)

```
for each interceptor k FLYING:
    if target dead or gone: resolve MISS(reason TARGET_GONE) — wasted round
    move k toward target current position at speed (view only; resolution is by resolve_tick)
    if tick >= resolve_tick:
        hit = rng.chance(COMBAT, k.pk)
        emit INTERCEPT_HIT / INTERCEPT_MISS; if hit: kill(target)
        L.channels_busy -= 1; threat.engaged_by[target] -= 1; release k
        if miss and L.doctrine.reengage and target alive: L.ready_tick = tick   # shoot-look-shoot (tech t2_shoot_look_shoot)
```
Leakers need no special handling: a threat not killed stays alive and is re-evaluated by every shooter every tick, so it falls through to the next layer automatically.

### B.5.7 IMPACT (`CadImpactSystem.update`)

```
for each threat with state IMPACTED this tick:
    if target is district d: dmg = def.damage * (1 - hardening(d)); districts.apply_damage(d, dmg); emit DISTRICT_DAMAGED
    if target is emplacement e: e.hp -= def.damage; if e.hp <= 0: e.state = DESTROYED (upkeep 0, refund 0); emit EMPLACEMENT_DESTROYED
    release threat
for each KILLED: economy.salvage += def.cost * cfg.salvage_rate * def.salvage_mult; emit THREAT_KILLED; release
for each CRASHED / EXITED: release (no salvage for CRASHED [HUMAN: 50 % salvage for EW crashes is a candidate])
```

### B.5.8 EW (`CadEwSystem.update`, once per second = every 30 ticks)

```
for each EW emplacement e ACTIVE, for each threat i in query_circle(e.pos, e.effect_radius_m):
    if guidance not in {SATNAV, DATALINK}: continue
    p = e.jam_strength * pk_table[EW][threat.def] * (1 - cfg.eccm_step * threat.eccm_level) * upgrade_mult
    if rng.chance(COMBAT, p): threat.state = WANDER; wander_ticks = class table; emit LINK_LOST
```

## B.6 Economy → `CadBalanceConfig`, `CadDistrictDef`

| symbol | formula | seed value |
|--------|---------|------------|
| district income | `Σ_d value_d × hp_d / max_hp_d` | map 1 full value 800 |
| salvage | `Σ_kills cost × salvage_rate × salvage_mult` | `salvage_rate = 0.15` |
| wave quality q | `clamp(1 − district_damage_this_wave / bonus_damage_denominator, 0, 1)` | denominator 200 |
| wave bonus | `(bonus_base + bonus_per_wave × w) × q` | 200 + 60 w |
| upkeep | `Σ_e upkeep_e` over emplacements not DESTROYED | table B.3 |
| **income(w)** | `district income + salvage + bonus − upkeep` (may be negative; funds floor is unbounded, purchases need funds ≥ cost) | — |
| restock | per round `ammo_cost`; auto-restock at BUILD entry buys cheapest launchers first while funds ≥ 2 × cost (player toggle) | — |
| repair | district `2 CR/hp`, capped at `repair_cap_per_wave` (50, +50 in repair-crew radius); emplacement `3 CR/hp`, uncapped | — |
| sell | refund `cost × 0.5 × hp / max_hp`; stock refunded at `ammo_cost × 0.5` | `sell_refund_rate = 0.5` |
| relocate | `cost × 0.1`, emplacement inactive for the next wave's first 20 s (`relocate_penalty_s`) | `relocate_cost_rate = 0.1` |
| starting funds | map 1: 2,000; map 2: 2,500; map 3: 3,000 | `CadMapDef.starting_funds` |
| tech points | +1 per wave cleared, +10 per scenario clear; awarded at RUN_END | `tech_points_per_wave`, `tech_points_scenario_clear` |
| enemy budget | `B(w) = (budget_base + budget_linear × w + budget_quad × w²) × map.budget_mult`; final wave × `final_wave_budget_mult` | 500 + 150 w + 4 w²; ×1.5 on wave 30 |

Worked examples (map 1; tests in `test/scenario/test_economy_examples.gd` assert these exact totals from the same inputs):

| wave | enemy budget / package | player state | district income | salvage | q → bonus | upkeep | **income** | restock / repair | note |
|------|------------------------|--------------|-----------------|---------|-----------|--------|------------|------------------|------|
| 1 | 654 → 6 OWA (600) | radar + AAA + SHORAD (spent 1,150 of 2,000) | Port −40 hp → 800 − 48 = 752 | 5 kills × 100 × 0.15 = 75 | 1 − 40/200 = 0.8 → 260 × 0.8 = 208 | 55 | **980** | 3 SHORAD (180) + 12 AAA bursts (60) + Port repair 40 hp (80) = 320 | funds 850 → 1,830 → 1,510 |
| 10 | 2,400 → strike 1,060 + swarm 840 + probe 350 = 2,250 | radar, FCR, C2, 3 AAA, 2 SHORAD, MRSAM, EW; Port 70 %, Industrial 80 % | 800 − 36 − 22 = 742 | (2,250 − 150 recon − 40 FPV) × 0.15 = 309 | no district damage → 1.0 → 800 | 250 | **1,601** | 2 MRSAM (500) + 5 SHORAD (300) + 40 bursts (200) + AAA repair 16 hp (48) = 1,048 | net +553/wave banked toward LRSAM (4,500) |
| 20 (A: no LRSAM) | 5,100 → ballistic 2,900 + strike 1,120 + saturation 1,100 = 5,120 | SRBM leaks, destroys Government (140); 2 OWA leak (80 dmg) | (800 − 140) × 0.85 = 561 | (5,120 − 2,500 − 200) × 0.15 = 363 | damage 480 → 0 → 0 | 450 | **474** | ≈ 1,000 | a leaked SRBM is a wave-losing event (A-30) |
| 20 (B: LRSAM, 2 ABM shots kill it) | same | +LRSAM upkeep 120 | 800 × 0.85 = 680 | (5,120 − 200) × 0.15 = 738 | damage 80 → 0.6 → 1,400 × 0.6 = 840 | 570 | **1,688** | 2 ABM (2,400) + ≈ 1,000 = 3,400 | ABM defence is a deficit covered by the bank built in waves 12–19 |
| 30 ("the Danger Wave", ×1.5) | 12,900 → 2 ballistic 5,800 + 2 strike 2,240 + 3 saturation 3,300 + swarm 1,120 + probe 350 = 12,810 | full IADS, districts 90 % | 720 | 12,810 × 0.15 = 1,922 (all killed) | damage 40 → 0.8 → 2,000 × 0.8 = 1,600 | 700 | **3,542** | 4 ABM (4,800) + 4 MRSAM (1,000) + 12 SHORAD (720) + 120 bursts (600) + 6 UAV (240) = 7,360 | wave 30 is a planned net loss (−3,818) paid from the bank; endless continues with the same curve |

## B.7 Wave generation → `CadWaveRules`, `CadWavePhase`, `CadPackageDef`

Package archetypes (counts are `[min, max]`, drawn with `CadRng.WAVEGEN`):

| package id | composition | tot_offset_s | spread_s | lateral_spread_m | min_wave |
|------------|-------------|--------------|----------|------------------|----------|
| pkg_swarm_lite | owa [4, 6] | 0 | 20 | 3,000 | 1 |
| pkg_swarm | fpv [6, 24], owa [2, 8] | 0 | 25 | 4,000 | 2 |
| pkg_probe | recon [1, 1], owa [2, 2] | −30 (recon arrives first) | 10 | 2,000 | 3 |
| pkg_strike | cruise [1, 2], decoy [0, 2] (0 before wave 7; escorts from wave 14), owa [2, 4] | 0 | 15 | 2,500 | 4 |
| pkg_saturation | owa [8, 16], jammer [0, 1] (1 from wave 9) | 0 | 30 | 5,000 | 7 |
| pkg_ballistic | srbm [1, 1], owa [4, 4] timed to arrive with the SRBM | 0 | 5 | 1,500 | 12 |
| pkg_sead (stretch) | sead [2, 4], jammer [1, 1] | −10 | 10 | 3,000 | 18 |

Phase table for map 1 (`CadWavePhase` rows; weights are relative):

| phase | waves | package weights | eccm_level (OWA/FPV/jammer) | caps |
|-------|-------|-----------------|-----------------------------|------|
| P1 | 1–3 | swarm_lite 1.0; swarm 0.5 (from wave 2); probe 0.3 (wave 3) | 0 | cruise 0 |
| P2 | 4–6 | strike 0.5, swarm 0.3, probe 0.2 | 0 | cruise ≤ 1 |
| P3 | 7–11 | strike 0.35, swarm 0.25, saturation 0.25, probe 0.15 | 0 (waves 7–9), 1 (10–11) | cruise ≤ 2, jammer ≤ 1 |
| P4 | 12–17 | ballistic 0.3 (even waves only), strike 0.3, saturation 0.25, swarm 0.15 | 1 | srbm ≤ 1, cruise ≤ 2 |
| P5 | 18–24 | ballistic 0.3, strike 0.3, saturation 0.2, swarm 0.1, sead 0.1 | 1 (18–19), 2 (20+) | srbm ≤ 1, cruise ≤ 3, jammer ≤ 2 |
| P6 | 25–30 | ballistic 0.35, strike 0.3, saturation 0.2, sead 0.15 | 2 | srbm ≤ 2 (≤ 3 on wave 30), jammer ≤ 3 |

Fill algorithm (`CadWaveGenerator.generate`):
```
budget = B(w); spent = 0; plan = []
while spent < 0.95 * budget:
    pick package by phase weights (WAVEGEN stream); skip if min_wave > w or a cap would be exceeded
    roll counts; cost = Σ count × def.cost
    if spent + cost > 1.05 * budget: mark package as tried; if all packages tried: break; else continue
    place package: tot = rand(0, spawn_window) + tot_offset; entries spawn at tot + rand(0, spread_s), lateral offset rand(−lateral, +lateral) along the spawn line
    spent += cost
spawn_window = clamp(60 + 6 w, 60, 240) s; wave 30: all packages tot within [0, 30] s (synchronised raid)
enforce max_concurrent = 200: entries beyond are queued in spawn order (CadWaveDirector releases them as slots free)
```
Decoy rule: decoys only inside `pkg_strike`; ratio ≤ 2 per cruise. Jammer rule: at most one per package, package caps above. Intel quality for the BUILD screen: 0.5 base (counts shown as ranges ±50 %), +0.2 with an FCR on the map, +0.3 with tech `t3_intel_recon`; at 1.0 exact counts and package order are shown.

## B.8 Maps → `CadMapDef`, `CadDistrictDef`

Map 1 "Riverside Capital" (First Playable and Vertical Slice map). Districts (polygons authored in `data/defs/maps/map_01.tres`; centres below):

| district id | display | centre (x, y) m | value_per_wave | max_hp | repair_cap_per_wave |
|-------------|---------|-----------------|----------------|--------|---------------------|
| d_gov | Government Quarter | (0, 0) | 140 | 100 | 50 |
| d_port | River Port | (2,500, 1,500) | 120 | 100 | 50 |
| d_industrial | Industrial Belt | (−3,000, 2,000) | 110 | 100 | 50 |
| d_refinery | Refinery | (4,000, −2,000) | 100 | 100 | 50 |
| d_res_east | East Residential | (2,000, −1,500) | 90 | 100 | 50 |
| d_res_west | West Residential | (−2,500, −1,000) | 90 | 100 | 50 |
| d_airport | Airport | (−5,500, −3,000) | 80 | 100 | 50 |
| d_power | Power Plant | (5,500, 2,500) | 70 | 100 | 50 |

Map-level fields: `world_min (−10,000, −6,000)`, `world_max (10,000, 6,000)`, `threat_axis (−1, 0)`, spawn line from (9,800, −5,500) to (9,800, 5,500), `final_wave 30`, `starting_funds 2,000`, `budget_mult 1.0`, build zones: whole map minus district polygons minus a 1,000 m strip at the spawn edge. Map 2 "Coastal Strait" (threat axis from the south-east, two spawn lines, `budget_mult 1.15`, starting funds 2,500) and map 3 "Mountain Pass" (axis from the north through a valley: `low_alt_horizon` of radars placed in the valley ×0.6 via a `terrain_mask` field, `budget_mult 1.3`, starting funds 3,000) are blocked out in Alpha (E-AL-02).

## B.9 Tech tree → `CadTechNode`

| id | tier | cost TP | prereqs | effect_kind | target | value |
|----|------|---------|---------|-------------|--------|-------|
| t1_mrsam_unlock | 1 | 5 | — | UNLOCK_EMPLACEMENT | cad_emp_mrsam | — |
| t1_aaa_prox | 1 | 3 | — | PK_ADD | cad_emp_aaa vs {fpv, owa} | +0.10 |
| t1_shorad_reload | 1 | 3 | — | STAT_MULT | cad_emp_shorad.reload_s | ×0.7 |
| t1_radar_range | 1 | 3 | — | STAT_MULT | cad_emp_search_radar.detect_ref_range_m | ×1.15 |
| t1_ew_radius | 1 | 3 | — | STAT_MULT | cad_emp_ew.effect_radius_m | ×1.2 |
| t1_depot_stock | 1 | 3 | — | STAT_MULT | cad_emp_depot.effect_b (stock mult) | ×1.33 (1.5 → 2.0) |
| t1_salvage_1 | 1 | 3 | — | CONFIG_ADD | salvage_rate | +0.05 |
| t1_repair_crew_2 | 1 | 3 | — | STAT_MULT | cad_emp_repair.effect_a (hp/s) | ×1.5 |
| t1_passive_net | 1 | 3 | — | STAT_MULT | cad_emp_passive.passive_range_m | ×1.3 |
| t2_lrsam_unlock | 2 | 8 | any 3 T1 | UNLOCK_EMPLACEMENT | cad_emp_lrsam | — |
| t2_fcr_capacity | 2 | 6 | any 3 T1 | STAT_ADD | cad_emp_fcr.track_capacity | +4 |
| t2_ciws_unlock | 2 | 6 | t1_aaa_prox | UNLOCK_EMPLACEMENT | cad_emp_ciws | — |
| t2_hardening_unlock | 2 | 6 | any 3 T1 | UNLOCK_EMPLACEMENT | cad_emp_hardening | — |
| t2_decoy_emitter_unlock | 2 | 6 | t1_radar_range | UNLOCK_EMPLACEMENT | cad_emp_decoy_emitter | — |
| t2_uav_unlock | 2 | 6 | t1_ew_radius | UNLOCK_EMPLACEMENT | cad_emp_uav | — |
| t2_eccm_radar | 2 | 6 | t1_radar_range | STAT_MULT | all SENSOR_*.jam_vulnerability | ×0.5 |
| t2_shoot_look_shoot | 2 | 6 | t1_shorad_reload | DOCTRINE_UNLOCK | reengage | — |
| t2_salvage_2 | 2 | 6 | t1_salvage_1 | CONFIG_ADD | salvage_rate | +0.05 |
| t3_abm_upgrade | 3 | 12 | t2_lrsam_unlock + any 3 T2 | PK_ADD | cad_emp_lrsam vs srbm | +0.15 |
| t3_c2_fusion | 3 | 12 | any 3 T2 | STAT_MULT | cad_emp_c2.effect_radius_m; cued_pk_mult 0.75 → 0.9 | ×1.5 |
| t3_fcr_capacity_2 | 3 | 12 | t2_fcr_capacity | STAT_ADD | cad_emp_fcr.track_capacity | +6 |
| t3_ew_strength | 3 | 12 | t2_uav_unlock | STAT_ADD | cad_emp_ew.jam_strength | +0.2 |
| t3_layered_bonus | 3 | 12 | any 3 T2 | CONFIG_MULT | upkeep when ≥ 3 shooter kinds active | ×0.85 |
| t3_intel_recon | 3 | 12 | any 3 T2 | CONFIG_ADD | intel_quality | +0.3 |
| t3_hardening_2 | 3 | 12 | t2_hardening_unlock | STAT_MULT | cad_emp_hardening.effect_a (damage mult) | 0.7 → 0.5 |

## B.10 Doctrine settings (runtime struct `CadDoctrine`; defaults in `CadDoctrinePreset`)

| field | type | values | default (guns) | default (launchers) | effect |
|-------|------|--------|----------------|---------------------|--------|
| roe | `CadEnums.Roe` | HOLD, TIGHT, FREE | FREE | TIGHT | B.5.5 |
| priority | `CadEnums.Priority` | NEAREST_IMPACT, HIGHEST_VALUE, FASTEST, BEST_EXCHANGE | NEAREST_IMPACT | HIGHEST_VALUE | target key |
| min_threat_value | int | 0, 50, 100, 500, 2,000 | 0 | SHORAD 50, MRSAM 500, LRSAM 2,000 | ignores cheaper threats (classified decoys count as 60) |
| salvo | int | 1, 2 | 1 | 1 | rounds per engagement |
| reengage | bool | requires tech t2_shoot_look_shoot | false | false | B.5.6 |
| defended_radius_m | float | 6,000 (fixed at 1.0) | — | — | TIGHT zone |

Doctrine changes are free, instant, and allowed during WAVE (they are commands, so they are replayable).

## B.11 Upgrades → `CadUpgradeDef`

| id | emplacement | level | cost | stat | multiplier | additive |
|----|-------------|-------|------|------|------------|----------|
| up_aaa_2 | cad_emp_aaa | 2 | 125 | shot_interval_s | 0.8 | 0 |
| up_aaa_3 | cad_emp_aaa | 3 | 190 | range_max_m | 1.2 | 0 |
| up_shorad_2 | cad_emp_shorad | 2 | 250 | reload_s | 0.75 | 0 |
| up_shorad_3 | cad_emp_shorad | 3 | 375 | ammo_capacity | 1.0 | +2 |
| up_radar_2 | cad_emp_search_radar | 2 | 200 | detect_ref_range_m | 1.15 | 0 |
| up_radar_3 | cad_emp_search_radar | 3 | 300 | low_alt_horizon_m | 1.3 | 0 |
| up_fcr_2 | cad_emp_fcr | 2 | 300 | track_capacity | 1.0 | +2 |
| up_fcr_3 | cad_emp_fcr | 3 | 450 | track_range_m | 1.25 | 0 |
| up_mrsam_2 | cad_emp_mrsam | 2 | 900 | reload_s | 0.7 | 0 |
| up_mrsam_3 | cad_emp_mrsam | 3 | 1,350 | channels | 1.0 | +1 |
| up_lrsam_2 | cad_emp_lrsam | 2 | 2,250 | reload_s | 0.7 | 0 |
| up_lrsam_3 | cad_emp_lrsam | 3 | 3,375 | pk (all) | 1.0 | +0.05 |
| up_ew_2 | cad_emp_ew | 2 | 350 | effect_radius_m | 1.25 | 0 |
| up_ew_3 | cad_emp_ew | 3 | 525 | jam_strength | 1.0 | +0.15 |
| up_ciws_2 | cad_emp_ciws | 2 | 450 | shot_interval_s | 0.8 | 0 |
| up_uav_2 | cad_emp_uav | 2 | 300 | ammo_capacity | 1.0 | +2 |
| up_c2_2 | cad_emp_c2 | 2 | 400 | effect_radius_m | 1.3 | 0 |
| up_depot_2 | cad_emp_depot | 2 | 300 | effect_radius_m | 1.3 | 0 |
| up_passive_2 | cad_emp_passive | 2 | 175 | passive_range_m | 1.3 | 0 |

Every level-2/3 shooter upgrade also adds the Pk additive of B.4 (+0.05 / +0.10).

## B.12 Screens and UI state machine → `CadEnums.GameState`, `CadApp`

| state | scene | elements (one-thumb: primary actions in the bottom-right 40 % of width, bottom 25 % of height) | exits |
|-------|-------|----------------------------------------------------------------------------------------------|-------|
| BOOT | `scenes/app/cad_boot.tscn` | logo, load defs + save, ≤ 1.5 s | → TITLE |
| TITLE | `scenes/ui/cad_title.tscn` | Continue (if save), New campaign, Settings, Licences | → CAMPAIGN, SETTINGS overlay |
| CAMPAIGN | `scenes/ui/cad_campaign.tscn` | map cards (locked/unlocked, best wave), TP balance, Tech tree button | → TECH, → BUILD (starts run), → TITLE |
| TECH | `scenes/ui/cad_tech.tscn` | 3 tier columns, node cards with cost/prereqs, Buy | → CAMPAIGN |
| BUILD | `scenes/world/cad_world.tscn` + `cad_build_ui.tscn` | map, range rings on, build bar (bottom), inspector (right slide-in), intel panel (top-left), funds/integrity/wave HUD (top), Start Wave (bottom-right), Auto-restock toggle | → WAVE (Start), PAUSED overlay, → TITLE (confirm) |
| WAVE | same world scene + `cad_wave_ui.tscn` | speed buttons ‖/1×/2×/3× (bottom-right), inspector limited to doctrine + manual fire, hitch-free HUD | → DEBRIEF (wave cleared), → RUN_END (integrity 0), PAUSED |
| DEBRIEF | `scenes/ui/cad_debrief.tscn` | income table (district, salvage, bonus, upkeep, net), kills by class, leakers, exchange ratio, Continue | → BUILD |
| RUN_END | `scenes/ui/cad_run_end.tscn` | VICTORY/DEFEAT, waves survived, TP earned, Endless (on victory), Back to campaign | → BUILD (endless), → CAMPAIGN |
| PAUSED | `scenes/ui/cad_pause_menu.tscn` overlay (also lifecycle pause) | Resume, Settings, Quit to title | → previous |
| SETTINGS | overlay | SFX/music volume, UI scale ±, range rings on/off, colour-blind check pattern, auto-restock default | → previous |

Transition table (illegal transitions are programming errors → `push_error` + no-op):

| from \ to | TITLE | CAMPAIGN | TECH | BUILD | WAVE | DEBRIEF | RUN_END | PAUSED |
|-----------|-------|----------|------|-------|------|---------|---------|--------|
| BOOT | ✓ | | | | | | | |
| TITLE | | ✓ | | ✓ (Continue) | | | | |
| CAMPAIGN | ✓ | | ✓ | ✓ | | | | |
| TECH | | ✓ | | | | | | |
| BUILD | ✓ | | | | ✓ | | | ✓ |
| WAVE | | | | | | ✓ | ✓ | ✓ |
| DEBRIEF | | | | ✓ | | | | |
| RUN_END | | ✓ | | ✓ (endless) | | | | |
| PAUSED | ✓ (quit) | | | ✓ | ✓ | | | |

## B.13 Tactical-display readability spec → `CadPalette`, `CadAtlasMap`, `ui/theme/cad_theme.tres`

Sizes (dp; 1 dp = 1/160 in; the `CadUiScale` factor makes 1 dp ≈ 1 physical dp on every device):

| element | size | rule |
|---------|------|------|
| entity icon glyph | 26 dp (≈ 4.1 mm) | screen-space constant (shader divides by camera zoom); never below 22 dp |
| selection ring | icon + 8 dp | 2 dp stroke |
| range ring stroke | 1.5 dp; fill alpha 0.06 | search radar dashed (8/6 dp), FCR dotted, shooters solid, EW double line |
| tracer | 2 dp × 14 dp streak | TTL 0.4 s, alpha fade |
| missile trail | 2 dp, 24 segments, 1.2 s | |
| HUD text | 18 dp; counters 24 dp tabular | |
| build-bar button | 64 × 64 dp, gap 8 dp, cost label 14 dp | max 7 visible + scroll |
| touch targets | ≥ 48 dp | including speed buttons |
| radar sweep | 1 rev / 4 s, 30° trailing wedge, alpha 0.25→0 | shader `cad_radar_sweep.gdshader` |

Palette (dark theme only; deuteranopia-checked — hostile/friendly differ in hue **and** luminance ≥ 40 %; `CadPalette` fields in the first column):

| field | hex | use |
|-------|-----|-----|
| bg | #0B1220 | map background |
| grid | #16324A | 1,000 m grid lines |
| friendly | #35D0FF | emplacement icons, rings |
| friendly_dim | #1C7A99 | inactive/relocating |
| hostile | #FF5A3C | threats |
| hostile_high | #FFB03C | ballistic / high-value threats |
| track | #FFFFFF | tracked-threat outline |
| ew | #B26BFF | jam fields, EW rings |
| warning | #FFC53D | low ammo, link lost |
| danger | #FF2E2E | district destroyed, integrity < 25 % |
| text | #E6F0FF | UI text |
| text_dim | #8FA3BF | secondary text |
| district_ok | #1F4D3A | district fill 100 % |
| district_hit | #4D2A1F | district fill < 50 % (lerped) |

Icon legend (all glyphs are 2-colour flat SVG on a transparent 64×64 canvas, stroke 4 px, authored per `/ai/prompts/generate-svg-sprite-set.md`):

| sprite_id | glyph | sprite_id | glyph |
|-----------|-------|-----------|-------|
| emp_search_radar | fan (quarter disc) with 3 arcs | thr_owa | filled triangle pointing along velocity |
| emp_fcr | fan with a centre dot | thr_fpv | small filled circle with a 4-dot halo |
| emp_passive | ear-shaped arc pair | thr_cruise | elongated diamond with a tail bar |
| emp_aaa | two crossed barrels | thr_srbm | tall chevron with a flame base; drawn with `hostile_high` |
| emp_ciws | hexagon with a barrel | thr_recon | hollow circle with a centre dot |
| emp_shorad | small chevron on a box | thr_decoy | hollow diamond (hostile colour until classified, then `text_dim`) |
| emp_mrsam | double chevron on a box | thr_jammer | triangle with 3 wave arcs |
| emp_lrsam | triple chevron on a wide box | thr_sead | triangle with a ring (anti-radiation) |
| emp_uav | small X-quad outline | thr_glide | swept-wing outline |
| emp_ew | three nested arcs on a box | fx_tracer | 2×14 streak |
| emp_decoy_emitter | hollow fan | fx_trail | 2×2 dot |
| emp_c2 | hexagon with a node dot | ui_glyph_pause / play / speed2 / speed3 | standard |
| emp_depot | box with a bar | ui_glyph_restock / sell / relocate / doctrine | wrench, coin, arrows, shield |
| emp_repair | wrench in a circle | ui_glyph_link_ok / link_lost | chain / broken chain |
| emp_hardening | shield outline | ui_glyph_intel | eye |

## B.14 Table → schema mapping index

| table | schema (D3) | file(s) |
|-------|-------------|---------|
| B.2 threats | `CadThreatDef` | `data/csv/threats.csv` → `data/defs/threats/*.tres` |
| B.3.1–B.3.3 emplacements | `CadEmplacementDef` | `data/csv/emplacements.csv` → `data/defs/emplacements/*.tres` |
| B.4 Pk matrix | `CadPkTable` | `data/csv/pk_table.csv` → `data/defs/pk/cad_pk_table.tres` |
| B.4 modifiers, B.6 formulas | `CadBalanceConfig` | `data/defs/balance/cad_balance_config.tres` |
| B.7 packages / phases / curve | `CadPackageDef`, `CadWavePhase`, `CadWaveRules` | `data/csv/packages.csv`, `data/csv/wave_phases_map_01.csv` → `data/defs/waves/map_01_rules.tres` |
| B.8 maps / districts | `CadMapDef`, `CadDistrictDef` | `data/defs/maps/map_0N.tres` (districts inline sub-resources) |
| B.9 tech | `CadTechNode` | `data/csv/tech.csv` → `data/defs/tech/*.tres` |
| B.10 doctrine defaults | `CadDoctrinePreset` | `data/defs/doctrine/defaults.tres` |
| B.11 upgrades | `CadUpgradeDef` | `data/csv/upgrades.csv` → `data/defs/upgrades/*.tres` |
| B.12 states | `CadEnums.GameState` + `CadApp.TRANSITIONS` | `src/sim/cad_enums.gd`, `src/view/autoload/cad_app.gd` |
| B.13 palette / icons / sizes | `CadPalette`, `CadAtlasMap`, `cad_theme.tres` | `ui/theme/cad_palette.tres`, `art/atlas/cad_atlas_map.tres`, `ui/theme/cad_theme.tres` |
| A-29 hints | `CadHintRules` | `data/defs/hints/map_01_hints.tres` |
