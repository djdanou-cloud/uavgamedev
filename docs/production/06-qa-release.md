# G. QA, Hardening & Google Play Release Plan

## G.1 Test pyramid

| layer | scope | framework / location | volume target at Beta | runs in | gate |
|-------|-------|----------------------|------------------------|---------|------|
| Sim unit tests | one class per file: stores, spatial hash, rng, event log, each system's pure functions, economy formulas, generator fill rules, schemas, importer, validator, save/migrations | gdUnit4, `test/unit/**/test_cad_<name>.gd`, one suite per source file | ≥ 1 test per public function; 100 % of B.4/B.6 numbers asserted | CI + local | Gate 1 |
| Scenario / integration sims | headless `CadSim` runs with scripted emplacements and command logs: determinism golden, cost exchange bands, worked economy examples, EW link-loss rates, decoy classification, recon reveal, SRBM window, leak-to-next-layer, wave clear/fail conditions, save round-trip at wave boundary | gdUnit4, `test/scenario/test_<topic>.gd`, fixtures in `test/fixtures/replays/` | ≥ 25 suites; every B.5 stage has a scenario | CI (≤ 3 min) | Gate 1 |
| View smoke tests | every scene under `scenes/` instantiates headless without errors; scene flow TITLE→BUILD→WAVE→DEBRIEF→TITLE leaves 0 orphan nodes; `CadSimDriver` tick accounting; MultiMesh instance counts match store alive counts after 60 frames | gdUnit4 + `SceneRunner` (no input simulation in headless), `test/smoke/` | 1 per scene + 4 flow tests | CI | Gate 1 |
| Balance harness | policies × seeds over N waves → win-rate/economy curves (G.2) | `tools/balance/`, output `reports/balance/*.json|md` | 6 policies × 40 seeds × 30 waves ≤ 10 min headless | CI nightly-style job on `main` (manual dispatch) | Gate 2 (numbers reviewed) |
| Perf regression | x86 sim bench vs baseline; on-device bench scene + wave-12 replay + 20-min soak | `tools/bench_runner.gd`, `scenes/bench/cad_bench_render.tscn`, `CadFrameStats` | every merge to `main` (CI) / every Gate 3 (device) | CI / device | Gate 1 / Gate 3 |
| On-device manual scripts | per milestone: `docs/qa/manual_android_<ms>.md` — numbered steps, expected result, pass/fail column, device, build hash | human, 20–40 min per device | 1 script per milestone | device | Gate 3 |

Test conventions: file `test_cad_<name>.gd` extends `GdUnitTestSuite`; test names `test_<behaviour>_<condition>()`; Given/When/Then as three comment lines; parameterised tests for tables (`test_pk_lookup(weapon: StringName, threat: StringName, expected: float, test_parameters := [...])`); no test may depend on wall-clock time, `Engine.get_frames_drawn()`, or global RNG; scenario tests always construct `CadSim` with an explicit seed.

## G.2 Headless balance-simulation harness (`tools/balance/`)

Runner: `$GODOT_BIN --headless --path . -s res://tools/balance/cad_balance_run.gd -- --map map_01 --policy layered_basic --seeds 40 --waves 12 --out reports/balance/` → `<map>_<policy>.json` (per seed: waves cleared, funds per wave, integrity per wave, kills/leaks by class, CR spent per enemy CR killed) + `summary.md` (win rate per wave, median funds curve, exchange ratio, first-failing-wave histogram).

Scripted player policies (each a `CadBalancePolicy` subclass with `func decide_build(sim: CadSim, intel: CadIntelReport) -> Array[CadCommand]` called at every BUILD phase; no in-wave actions except `turtle` doctrine presets):

| policy | behaviour | expected outcome (map 1) — a failed expectation is a balance defect |
|--------|-----------|--------------------------------------------------------------------|
| layered_basic (FP) | radar → AAA ×2 → SHORAD → AAA → SHORAD; restock all; repair cheapest first | clears wave 5 ≥ 90 % of seeds; wave 8 ≤ 40 % |
| layered_optimal (VS+) | maintains ratio radar:FCR:C2 1:1:1, AAA per 2,000 m of axis width, SHORAD ×3, MRSAM when funds ≥ 2,500, EW ×2 by wave 9, LRSAM by wave 14 when unlocked, passive sensors ×2, depot, repair; doctrine per B.10 defaults; banks 30 % | wave 12 ≥ 70 %; wave 30 40–70 % (Beta band); endless wave 40 ≤ 20 % |
| sam_spam | only SHORAD then MRSAM, no AAA/EW | wave 12 ≤ 30 %; exchange ratio ≥ 1.5 CR per enemy CR by wave 10 |
| aaa_spam | only AAA + radar | fails first cruise wave (4–6) ≥ 80 % of seeds |
| turtle | everything within 3,000 m of the centre, ROE TIGHT, min value 100 | wave 12: 30–50 % (works early, loses districts on the edge) |
| greedy_econ | buys only when funds > 3 × cost, repairs everything, max bank | wave 12 ≤ 50 %; highest funds curve |
| no_ew (PA+) | layered_optimal without EW | wave 20 win rate ≥ 20 points lower than layered_optimal (EW must matter) |

Tuning loop (DES-4): run → `summary.md` → human writes the decision in the card → agent edits `data/csv/*.csv` → importer → validator → tests → re-run → PR shows both summaries.

## G.3 Performance regression tests

| test | where | pass rule |
|------|-------|-----------|
| `test/bench/test_sim_bench_regression.gd` | CI (x86) | `tick_p95_ms ≤ baseline × 1.25` and `object_count_delta == 0` over 1,800 ticks at 250/300/60 |
| device bench (`cad_bench_render.tscn`) | Gate 3 | D6 targets: frame p95, draw calls ≤ 120, hitches 0 |
| wave-12 replay (`test/fixtures/replays/wave12_seed42.json`) on device | Gate 3 | p95 within target; sim/render/UI split within budgets |
| 20-min soak (`scenes/bench/cad_soak.tscn`: replays waves 8–12 in a loop at 2×) | Gate 3 (PA onward) | thermal rule D6; `MEMORY_STATIC` growth ≤ 5 %; battery rule |
| cold start | Gate 3 | `am start -W` TotalTime ≤ 4,000 ms, 3 runs after a reboot |

## G.4 Device matrix

| tier | device | must |
|------|--------|------|
| Minimum | low reference device (A-11); Play pre-launch report low-end devices | 30 fps p95, all screens usable, no crash |
| Target | mid reference device | 60 fps p95, all D6 budgets |
| Maximum / must-not-break | 10" tablet 16:10 or 4:3 (borrowed or Android Studio emulator `[VERIFY emulator supports GLES3 for Compatibility]`), 21:9 phone, foldable inner display, phone with display cutout, 1.3× system font scale | layouts readable, no clipped controls, safe area respected; fps not required |

## G.5 Android checks (manual script items with exact commands)

| check | how | expected |
|-------|-----|----------|
| Lifecycle pause/resume | during WAVE: press Home, wait 5 s, return; `adb shell input keyevent KEYCODE_HOME` / `adb shell am start -n com.djdanou.cad/com.godot.game.GodotApp` | game is in PAUSED overlay, sim tick unchanged, resume continues |
| Process death | at BUILD: `adb shell am force-stop com.djdanou.cad`, relaunch → Continue | restored wave, funds, emplacements, doctrine, stock |
| Back gesture / button | `adb shell input keyevent KEYCODE_BACK` in each state | WAVE/BUILD → pause menu; TITLE → Android "quit?" dialog; never a hard exit |
| Cutouts / safe area | device with cutout; `adb shell settings put global cutout_emulation double` on debug builds `[VERIFY property]` | HUD inside `DisplayServer.get_display_safe_area()` |
| Aspect ratios | mid device (20:9), emulator 16:9 and 21:9 | no clipping, build bar reachable |
| Permission-less | `adb shell dumpsys package com.djdanou.cad | grep permission` | no runtime permissions; only INTERNET/AD_ID from the ad SDK (declared) |
| Battery | 20-min soak; `adb shell dumpsys battery` before/after | ≤ 15 % low / ≤ 12 % mid |
| Rotation | rotate device both landscape directions | UI re-anchors; no restart |
| Audio focus | incoming call / other app audio during WAVE | music ducks/pauses, resumes |
| Text scale 1.3× | system font size largest | no overflow (theme uses dp sizes; verify) |
| Offline | airplane mode | game fully playable; ad button shows "unavailable" |

## G.6 Pre-release checklist (RC; all `[HUMAN]` unless noted)

- [ ] Store listing: title, short/long description (agent draft in `docs/release/listing.md`), icon 512², feature graphic 1024×500, ≥ 4 screenshots per form factor used (phone), category Strategy, contact email, no real-world equipment names in text
- [ ] Content rating: IARC questionnaire — fictional military violence, no blood, no gambling, no user interaction, ads present (rewarded) `[VERIFY questionnaire items]`
- [ ] Data safety: declares ad SDK data (advertising ID, device/other ids, crash logs as collected by Google Play services if applicable) `[VERIFY against the chosen plugin's SDK disclosure]`; no data collected by the app itself; data not shared beyond the ad SDK; privacy policy URL
- [ ] Privacy policy: hosted on GitHub Pages from `docs/release/privacy.md`; states local-only saves, ad SDK disclosure, contact
- [ ] Target API ≥ current requirement (36 at writing; `[VERIFY]` at RC date); 16 KB check green; arm64 AAB; version code monotonic
- [ ] App Signing enrolled; upload key backed up (D5.4)
- [ ] Pre-launch report on the RC build: 0 crashes, accessibility and security findings triaged
- [ ] Closed test: ≥ 14 days, ≥ 12 testers, production access granted
- [ ] Android vitals on the closed track: user-perceived crash rate < 1.09 %, ANR < 0.47 %, no device > 8 % `[VERIFY current thresholds]`
- [ ] Ads: real ad unit ids pasted by the human into `data/defs/ads/ads_config.tres` (not in any card or prompt), test devices removed, UMP consent verified in an EEA-simulated region
- [ ] Licence register complete; `AUTHORED.txt` complete; fiction glossary reviewed
- [ ] Release notes; tag `v1.0.0`; `docs/release/checklist-1.0.md` signed with date

## G.7 Staged rollout, crash triage, hotfix protocol

Rollout: production 10 % (day 0) → 25 % (day 3) → 50 % (day 7) → 100 % (day 14). Each step requires: no new crash cluster ≥ 0.2 % of sessions, overall rates under thresholds, no 1-star review naming a reproducible bug without a fix in flight.

Crash triage (Play Console → Android vitals → Crashes & ANRs only; no in-app reporting, A-25):
1. Weekly (Launch: daily for 14 days): export the top clusters; for each, record stack, device family, Android version, app version in `docs/release/triage.md`.
2. Classify: P0 (crash on launch / data loss / > 1 % sessions), P1 (blocks a wave / > 0.2 %), P2 (cosmetic / rare).
3. P0/P1 → hotfix card(s) (≤ 60 LOC each, bug-fix-only branch from the release tag); P2 → 1.1 backlog.
4. Godot-side crashes without a GDScript frame (native stack in `libgodot_android.so`) → search godotengine/godot issues for the 4.7.x tag; if unfixed upstream, mitigate by avoiding the API path or pin a 4.7.x patch at the next freeze point (A-43).

Hotfix protocol: branch `hotfix/1.0.x` from tag → cards → CI green → human-local release export with `version/code + 1` → internal track smoke on both devices (10 min) → promote to production at the current rollout percentage → resume rollout schedule after 48 h without regression. Maximum 2 hotfix releases per week; anything else waits for 1.0.x+1.
