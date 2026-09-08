# C. Production Strategy & Milestones

Effort units: **human-day = 8 h** (= 4 calendar weeks at the 2 h/week availability, A-34); **agent session** = one bounded generation run on one card (≈ 20–45 min of agent time, ≤ 120 new LOC). Leverage ratio = share of merged LOC/assets authored by agents (measured from `ai/metrics/metrics.csv`, H4).

## C.1 Milestone table

| Milestone | Primary de-risking goal | Proven on device | Cards (est.) | Human effort | Agent sessions | Leverage | Weeks |
|-----------|-------------------------|------------------|--------------|--------------|----------------|----------|-------|
| First Playable (FP) | GDScript sim ceiling on the low-end device; sim/view separation holds; agent pipeline (card → CI → review) works at 5 cards/week | Low device: 5 waves at ≥ 30 fps p95, 0 hitches; debug APK from CI installs and runs | 69 (I1) | 2.6 human-days (21 h) | ≈ 85 | 85 % | 13 |
| Vertical Slice (VS) | Full kill chain (FCR/C2/EW/decoys/jammers) is fun and readable on a phone; touch controls; save/lifecycle | Mid device: 60 fps at 200 threats, wave 12; save/restore across app kill; back gesture | ≈ 80 | 2.75 human-days (22 h) | ≈ 100 | 85 % | 14 |
| Pre-Alpha (PA) | Map 1 complete (30 waves + endless), SRBM/ABM loop, tech tree, ad SDK go/no-go | Low device wave 30 at ≥ 30 fps; ad spike APK shows a test rewarded ad; 20-min thermal soak | ≈ 70 | 2.5 human-days (20 h) | ≈ 90 | 80 % | 12 |
| Alpha (Feature Complete) | Every 1.0 feature exists; closed test starts (12 testers × 14 days) — the longest external lead time | Play internal + closed tracks install from AAB; pre-launch report clean | ≈ 60 | 2.6 human-days (21 h) | ≈ 75 | 75 % | 12 |
| Beta (Content Complete) | 3 maps × 30 waves balanced by harness + humans; all art/audio final; stretch classes decided | Both devices: full campaign soak logs; vitals from closed test < thresholds | ≈ 60 | 2.5 human-days (20 h) | ≈ 70 | 70 % | 12 |
| Release Candidate (RC) | Zero known P0/P1; store compliance complete; perf regression suite green on both devices | Release AAB (signed with the upload key) on closed track = launch build | ≈ 20 | 1.25 human-days (10 h) | ≈ 25 | 60 % | 5 |
| Gold / Launch (GO) | Staged rollout without vitals breach | Production 10 % → 25 % → 50 % → 100 % | ≈ 5 | 0.5 human-day (4 h) | ≈ 5 | 50 % | 2 |
| Post-launch 1.1 (PL) | Vitals triage, balance patch from real data, first content add (SEAD class if cut) | Same | ≈ 30 | 1.25 human-days (10 h) | ≈ 35 | 75 % | 5 |
| **Total** | | | ≈ 394 | ≈ 16 human-days (128 h) | ≈ 485 | | **75** |

## C.2 Definitions of Done

### First Playable — anchor: one map, ≥ 5 waves, OWA drone + cruise missile, search radar + AAA + SHORAD, full economy loop, low-end device at target fps

- [ ] All 69 I1 cards merged to `main`; `ai/handoffs/INDEX.md` shows no card in IN_PROGRESS/BLOCKED
- [ ] CI green on `main`: gdlint, gdformat, typecheck (warnings-as-errors per A-10), headless import, gdUnit4 suite, content validator, sim bench regression, Android debug APK artifact
- [ ] `test/scenario/test_determinism.gd`: two sims with seed 42 and the same command log produce byte-identical event logs over waves 1–5
- [ ] `test/scenario/test_cost_exchange.gd`: AAA-vs-OWA and SHORAD-vs-cruise expected cost per kill within ±20 % of B.4
- [ ] `test/scenario/test_economy_examples.gd`: wave-1 worked example (B.6) reproduces income 980
- [ ] Low device: map 1 waves 1–5 played to completion; `CadFrameStats` p95 ≤ 33.3 ms, hitches > 50 ms = 0, sim p95 tick ≤ 3.3 ms at bench ceilings (250/300/60) — numbers recorded in `docs/perf-log.md`
- [ ] Mid device: same run, p95 ≤ 16.6 ms
- [ ] Debug APK from the CI artifact installs on both devices without a local build
- [ ] Auto-pause on `NOTIFICATION_APPLICATION_PAUSED` and back-gesture pause menu verified by the manual script `docs/qa/manual_android_fp.md`
- [ ] Every icon legible at 4 mm on the low device (human check against B.13 legend)
- [ ] `docs/perf-log.md`, `ai/metrics/metrics.csv` updated; delegation matrix retuned per H4 rules
- [ ] Zero editor warnings on project open; zero orphan nodes after TITLE → BUILD → WAVE → DEBRIEF → TITLE

Kill criteria (any one forces the listed action):

| observation | action |
|-------------|--------|
| Low device sim p95 tick > 3.3 ms at 250/300/60 after two optimisation cards (CAD-FP-041 baseline + 2 follow-ups) | `[HUMAN]` cut design cap to 120 concurrent threats and tick to 20 Hz (A-03/A-06); if still failing, GDExtension spike decision (A-40) |
| Human review > 20 min/card average over 20 consecutive cards | LOC ceiling → 80 for that task type; human writes contracts for sim cards (H4 rule R2) |
| Agent first-pass test pass rate < 40 % over 20 cards | Human authors tests for sim cards; agents implement only (H4 rule R1) |
| Abandonment count ≥ 6 in FP | Stop; audit prompts and card granularity before any new card |

### Vertical Slice — map 1 waves 1–12; + FPV, recon, decoy, jammer; + FCR, C2, EW, MRSAM, passive sensor, depot, repair; doctrine UI; manual fire; relocate; intel panel; save/load; lifecycle save; title/campaign flow; SFX pass 1; sprite set 2

- [ ] All VS epic cards merged; CI green
- [ ] Kill chain observable end-to-end on device: detection appears → track outline → launch → hit/miss → leak to next layer, at 1×, 2×, 3× with no visual desync (interpolation)
- [ ] Doctrine changes during a wave alter engagement (scenario test + on-device check)
- [ ] EW causes OWA drones to wander/crash at the B.4 rates (scenario test ±20 %)
- [ ] Save at BUILD entry, force-stop app (`adb shell am force-stop com.djdanou.cad`), relaunch → Continue restores wave, funds, emplacements, doctrine, ammo (manual script `docs/qa/manual_android_vs.md`)
- [ ] Mid device: wave 12 at 60 fps p95 with ≥ 150 concurrent threats; low device ≥ 30 fps
- [ ] Balance harness v1 with 4 policies (G.2) runs in CI; "Layered-basic" clears wave 12 ≥ 70 % of seeds; "SAM-spam" clears wave 12 ≤ 30 %
- [ ] Touch playtest (2 external testers, human-observed): place radar + AAA + SHORAD and start a wave in ≤ 90 s without instruction
- [ ] `[HUMAN]` realism review of B.5 behaviour recorded in `docs/decisions/ADR-00N.md` (A-30 decided)

Kill criteria: testers need > 90 s twice → UI redesign epic (2 weeks) before Pre-Alpha; "SAM-spam" ≥ 60 % → economy rebalance before Pre-Alpha; any save corruption in a 50-cycle save/kill/restore loop → hold.

### Pre-Alpha — map 1 waves 1–30 + endless; SRBM/LRSAM/CIWS/decoy emitter/UAV/hardening; tech tree data + UI; meta save; music system; settings; ad SDK spike with its own gate

- [ ] Ad gate (separate from the milestone gate): spike APK on both devices loads and shows a **test** rewarded ad, grants the reward through a `CadCommand`, survives pause/resume mid-ad, passes 16 KB alignment check (`tools/check_16kb.sh` on the AAB's `.so` files with `objdump -p | grep LOAD` alignment 0x4000 `[VERIFY method]`), targets API 36; UMP consent form displays in a simulated EEA region
- [ ] Map 1 wave 30 cleared by "Layered-optimal" harness policy ≥ 50 % of seeds; endless wave 40 reached ≤ 20 %
- [ ] Low device: wave 25–30 at ≥ 30 fps p95, 20-minute soak within thermal rule (D6)
- [ ] Tech tree: buy/prereq/persist across runs (scenario + manual)
- [ ] Music layers switch at BUILD/WAVE/last-30-s-of-wave without clicks (human listening check)
- [ ] Content validator covers every schema; CSV round-trip test green

Kill criteria: ad spike fails its gate twice → 1.0 ships **without ads** (A-24 revisit; store listing/Data safety simplified); mid device < 60 fps at 200 threats → design cap 150 (A-06).

### Alpha (Feature Complete) — maps 2–3 blockouts playable; all emplacement kinds; all doctrine; hints; licences screen; Play Console listing draft; closed testing live

- [ ] Every feature of 1.0 exists in some state; no feature cards remain, only content/polish/bug cards
- [ ] Release AAB built by the human procedure (D5.4) uploads to the internal track; Play pre-launch report: 0 crashes
- [ ] Closed test track: ≥ 12 opted-in testers, day-14 clock running (start date recorded in `docs/release/closed-test.md`)
- [ ] Data safety form draft, privacy policy URL live (GitHub Pages of this repo), IARC questionnaire answered (fictional military violence)
- [ ] Target API = current Play requirement (`[VERIFY]` API 36 or 37 at this date); 16 KB check green
- [ ] Android checks pass on both devices: lifecycle, back gesture, cutouts/safe area, no permissions requested, battery ≤ 15 %/20 min

Kill criteria: < 12 testers after 4 weeks of recruiting → `[HUMAN]` recruit via public devlog; schedule slips 1:1 (blocking for production access); closed-test crash rate > 1.09 % → feature freeze until fixed.

### Beta (Content Complete)

- [ ] 3 maps × 30 waves + endless tuned: harness win-rate bands per map (G.2) met; two human full-campaign playthroughs logged
- [ ] All 25 tech nodes, 19 upgrades, hints, strings final; all sprite sets and SFX/music final; licence register complete
- [ ] Stretch classes (SEAD, glide) in or cut per A-26 (decision recorded)
- [ ] Perf regression suite green on both devices; RSS ≤ 350 MB mid / ≤ 300 MB low; install ≤ 80 MB
- [ ] Closed-test vitals under thresholds for 14 consecutive days; production access requested/granted

Kill criteria: stretch classes not green by Beta mid-point (week 6) → cut; map 3 outside balance bands after 3 tuning rounds → ship 2 maps + endless.

### Release Candidate

- [ ] Bug-fix-only branch policy; no card > 60 LOC
- [ ] Pre-release checklist G.5 complete: listing assets, IARC, Data safety, privacy policy, pre-launch report, target API, 16 KB, signing
- [ ] Device matrix run (G.4) on both physical devices + Play pre-launch report devices; 0 P0/P1 open
- [ ] Release notes, version code/name bumped, tag `v1.0.0`

Kill criteria: pre-launch report crashes on ≥ 2 device families → delay 2 weeks; install > 80 MB → drop music bitrate to 96 kbps.

### Gold / Launch

- [ ] Production rollout 10 % → 25 % (day 3) → 50 % (day 7) → 100 % (day 14), each step gated on vitals < thresholds and 0 new P0
- [ ] Hotfix protocol (G.7) rehearsed once on the closed track

Kill criteria: crash rate ≥ 1.09 % or ANR ≥ 0.47 % at any step → halt rollout, hotfix.

### Post-launch 1.1

- [ ] Vitals triage weekly for 4 weeks; top-3 crash signatures fixed
- [ ] Balance patch from harness re-run against real win-rate reports (players' local stats screen only — no analytics)
- [ ] One content addition (SEAD class or map 4 blockout) if cut earlier

## C.3 Calendar projection (2 h/week; week 1 = Monday 2026-09-14)

| Milestone | Weeks | Dates | Fixed external dates inside the window |
|-----------|-------|-------|-----------------------------------------|
| First Playable | 1–13 | 2026-09-14 → 2026-12-13 | Play Console account + identity verification started week 1 (lead time unknown, `[VERIFY]`) |
| Vertical Slice | 14–27 (+1 holiday) | 2026-12-14 → 2027-03-28 | Godot 4.7.x patch adoption window at the VS gate (A-43) |
| Pre-Alpha | 28–39 | 2027-03-29 → 2027-06-20 | Ad SDK gate no later than week 36 (2027-05-30) |
| Alpha | 40–51 | 2027-06-21 → 2027-09-12 | **Play target-API deadline 2027-08-31** (`[VERIFY]` expected API 37); closed test must start by week 48 (2027-08-22) |
| Beta | 52–63 | 2027-09-13 → 2027-12-05 | Production access request after day 14 of closed test |
| Release Candidate | 64–68 | 2027-12-06 → 2028-01-09 | Holiday weeks 66–67 count as 1 |
| Gold / Launch | 69–70 | 2028-01-10 → 2028-01-23 | Rollout to 100 % by 2028-02-06 |
| Post-launch 1.1 | 71–75 | 2028-01-24 → 2028-02-27 | |

Rules for the calendar: a milestone that ends > 3 weeks late triggers a scope review against its kill criteria, never a "work more hours" plan; the human's 2 h/week is a hard cap (F risk R-16). If a gate fails, the following milestone does not start; the gap is spent only on cards that address the failed DoD item.
