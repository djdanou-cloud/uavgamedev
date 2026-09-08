# E. Workstream Breakdowns & Interdependencies

Owner codes: **A** = agent produces, **H** = human owns/verifies (per the delegation matrix E.7). Card counts are estimates for epic expansion (I2). Dependencies name workstream task groups (`ENG-SIM-2`) or cards.

## E.1 Engineering

### ENG-SIM — simulation core (`src/sim/`, `src/defs/`)

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| ENG-SIM-1 foundations | `CadConst`, `CadEnums`, `CadRng`, `CadEventLog`, stores, spatial hash (CAD-FP-009…014) | A (contracts H-approved) | repo scaffold |
| ENG-SIM-2 kill chain | sensor, track, targeting, fire control, interceptor, motion, impact systems (CAD-FP-030…036); EW system, decoy classification, recon reveal (VS) | A | ENG-SIM-1, ENG-DATA-1 |
| ENG-SIM-3 economy & waves | `CadEconomy`, `CadDistrictState`, wave generator/director, intel (CAD-FP-027…029, 037, 038; VS intel) | A | ENG-SIM-1 |
| ENG-SIM-4 facade & commands | `CadSim`, `CadCommand(Queue)`, snapshot for save (CAD-FP-025, 039; VS snapshot) | A | ENG-SIM-2, ENG-SIM-3 |
| ENG-SIM-5 verification | scenario suites, determinism golden, bench runner + baseline, allocation-creep probe (CAD-FP-040, 041) | A writes, H reads numbers | ENG-SIM-4 |
| ENG-SIM-6 optimisation | up to 2 cards per milestone driven by profile data (`/ai/prompts/profile-and-report.md`) | A | Gate-3 data |

### ENG-REN — rendering (`src/view/world/`, shaders)

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| ENG-REN-1 driver | `CadSimDriver`, `CadFrameStats`, `CadEvents` drain (CAD-FP-042…044) | A | ENG-SIM-4 |
| ENG-REN-2 bulk views | `CadThreatView`, `CadInterceptorView`, `CadTracerView` (MultiMesh, `cad_icon.gdshader`) (CAD-FP-048…050) | A | ENG-REN-1, ART-2 |
| ENG-REN-3 world | `CadEmplacementView` (pooled), range rings shader, radar sweep, `CadMapView`, `CadCamera` (CAD-FP-051…054) | A | ENG-REN-1 |
| ENG-REN-4 VFX | hit flashes, wander/crash spirals, impact marks, jam-field haze, SRBM re-entry glow (VS/PA) | A | ENG-REN-2 |
| ENG-REN-5 benchmarks | `cad_bench_render.tscn` (CAD-FP-066) + per-milestone profile reports | A produces, H measures on device | ENG-REN-2/3 |

### ENG-UI — UI/UX (`src/view/ui/`, `scenes/ui/`)

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| ENG-UI-1 frame | `CadUiScale`, `CadSafeArea`, theme, `CadStrings` (CAD-FP-047, 055) | A | ART-3 |
| ENG-UI-2 HUD & build | `CadHud`, `CadBuildBar`, `CadPlacementController`, `CadInspector` (CAD-FP-056…059) | A; H touch-feel | ENG-UI-1, ENG-REN-3 |
| ENG-UI-3 flow screens | `CadApp` state machine, title, debrief, run end, pause, settings (CAD-FP-042, 060…064) | A | ENG-UI-1 |
| ENG-UI-4 doctrine & intel | doctrine panel, manual fire, relocate, intel panel with quality (VS) | A; H one-thumb reach | ENG-UI-2 |
| ENG-UI-5 meta | campaign select, tech tree screen, licences, hints (PA/AL) | A | ENG-UI-3, ENG-DATA-2 |

### ENG-DATA — data tooling (`src/data/`, `tools/`)

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| ENG-DATA-1 schemas | all Resource classes (CAD-FP-015…020; tech/upgrade/hint schemas PA) | A; H schema design | ENG-SIM-1 enums |
| ENG-DATA-2 importer & validator | CSV importer, content validator, `CadDefs` registry (CAD-FP-021…023) | A; H non-destructive review | ENG-DATA-1 |
| ENG-DATA-3 atlas | `CadAtlasMap`, `tools/atlas_build.gd` (CAD-FP-046) | A | ART-1 |
| ENG-DATA-4 save | `CadSave`, migrations, fixtures (VS) | A; H corruption audit | ENG-SIM-4 |

### ENG-PLAT — platform / lifecycle / build (`src/view/platform/`, `.github/`, `export_presets.cfg`)

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| ENG-PLAT-1 toolchain & CI | scaffold, gdUnit4, check scripts, ci.yml (CAD-FP-001…005) | A; H installs and secrets | — |
| ENG-PLAT-2 export | debug preset + CI APK job (CAD-FP-065); release preset, gradle template, 16 KB check (AL) | A; H keystore/signing | ENG-PLAT-1 |
| ENG-PLAT-3 lifecycle | `CadLifecycle` pause/resume/back (CAD-FP-064); save-on-pause (VS) | A; H device checks | ENG-UI-3 |
| ENG-PLAT-4 ads | plugin install (H-approved), `CadAds` wrapper, consent, reward → command (PA spike, AL integration) | A; H policy | ENG-PLAT-2 |
| ENG-PLAT-5 Play | Console setup, listing, Data safety, IARC, tracks (AL/RC) | H | ENG-PLAT-2 |

### ENG-AUD — audio (`src/view/audio/`, `audio/`)

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| ENG-AUD-1 bus & pool | bus layout, `CadAudio` pooled SFX with caps, event → SFX map (VS) | A | ENG-REN-1 |
| ENG-AUD-2 music | `CadMusic` layered playback via `AudioStreamInteractive` `[VERIFY]`, state-driven transitions (PA) | A; H dynamic range | ENG-AUD-1 |
| ENG-AUD-3 assets | CC0/CC-BY SFX selection, licence rows (VS→BE) | A proposes, H clears IP | D4 register |

## E.2 Art & Audio pipeline

| stage | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| ART-1 concept | icon legend B.13 (done), style sheet `docs/art/style.md` (1 page: stroke, palette, do/don't) | H writes with agent draft | — |
| ART-2 SVG sprite sets | set 1: 5 FP entities + 6 UI glyphs (CAD-FP-045); set 2: full roster (VS); set 3: VFX + tech icons (PA) | A; H polish/IP | ART-1 |
| ART-3 UI theme | `cad_theme.tres`, palette, fonts (CAD-FP-047) | A; H readability | ART-1 |
| ART-4 VFX | procedural (`_draw`/shader/particles configs) — no textures beyond the atlas | A | ENG-REN-2 |
| ART-5 store art | icon 512, feature graphic, screenshots (AL/RC) | A drafts SVG; H alters/captures | ART-2 |
| AUD-1 integration | SFX map per event type (VS); music stems per map (PA→BE) | A | ENG-AUD-1/2 |

## E.3 Design & Balance

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| DES-1 map blockouts | map 1 (CAD-FP-024), maps 2–3 (AL) as `.tres` + `docs/design/map_0N.md` | A drafts, H approves | ENG-DATA-1 |
| DES-2 wave scripting | phase/package CSVs per map; wave-30 raid script | A | DES-1 |
| DES-3 harness | `tools/balance/`: policies (`layered_basic` FP; `sam_spam`, `aaa_spam`, `turtle`, `greedy_econ`, `layered_optimal` VS/PA), runner, JSON + Markdown report (CAD-FP-067, VS/PA epics) | A; H reads curves | ENG-SIM-5 |
| DES-4 tuning loop | per milestone: run harness (N=40 seeds) → report → H decides → CSV change card → re-run; targets in G.2 | A runs, H judges | DES-3 |
| DES-5 realism review | `[HUMAN]` ADRs on kill-chain fidelity (A-30 and B.5 notes) | H | VS |

## E.4 Content

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| CON-1 defs | all threat/emplacement/upgrade/tech CSVs + generated .tres (FP subset → BE complete) | A; H numbers | ENG-DATA-2 |
| CON-2 strings & hints | `cad_strings_en.csv`, hint rules map 1 | A; H tone | ENG-UI-1 |
| CON-3 store text | listing, privacy policy text, Data safety answers draft (`docs/release/`) | A drafts; H submits | ENG-PLAT-5 |

## E.5 AI Operations

| group | deliverables | owner | depends on |
|-------|--------------|-------|------------|
| AIOPS-1 context | `AGENTS.md`/`CLAUDE.md`, `07-task-card-template.md`, architecture digest kept in sync (a card that changes a contract updates AGENTS.md §3 in the same PR) | A maintains, H approves | — |
| AIOPS-2 prompt library | `/ai/prompts/*.md` (7 templates) + changelog; versions committed with the code they produced | A; H validates | — |
| AIOPS-3 evals | monthly: re-run 3 archived cards with the current prompts on a scratch branch; compare first-pass rate (H4) | A | AIOPS-2 |
| AIOPS-4 handoff registry | `/ai/handoffs/INDEX.md` live table; stale-handoff check (`tools/handoff_check.py`: any IN_PROGRESS handoff not updated for > 7 days is flagged in the weekly planning slot) | A | — |
| AIOPS-5 metrics | `ai/metrics/metrics.csv` + `tools/ai_metrics.py` summary; retune rules H4 | A computes, H decides | — |

## E.6 Critical-path analysis

### Chain gating First Playable (each arrow is a hard dependency)

```
CAD-FP-001 toolchain (H) ─► FP-002 scaffold ─► FP-003 gdUnit4 ─► FP-004 check scripts ─► FP-005 CI
                                                     │
FP-009 enums/const ─► FP-010 rng ─► FP-011 events ─► FP-012/013 stores ─► FP-014 spatial hash
        │                                                                          │
        └─► FP-015…020 schemas ─► FP-021 defs registry ─► FP-022 importer ─► FP-023 validator ─► FP-024 FP content
                                                                                    │
FP-025 commands ─► FP-026/027 emplacements ─► FP-028 districts ─► FP-029 economy ─► FP-030 sensors ─► FP-031 tracks
        ─► FP-032 targeting ─► FP-033 fire control ─► FP-034 interceptors ─► FP-035 motion ─► FP-036 impacts
        ─► FP-037 wave gen ─► FP-038 director ─► FP-039 CadSim ─► FP-040 scenarios ─► FP-041 sim bench  ◄── SPOF-1
                                                                                    │
FP-042 autoloads ─► FP-043 driver ─► FP-044 frame stats ─► FP-045 sprites ─► FP-046 atlas ─► FP-047 theme
        ─► FP-048 threat view ─► FP-049/050 interceptor/tracer views ─► FP-051…054 world views/camera
        ─► FP-055 ui scale ─► FP-056…062 HUD/build/inspector/screens ─► FP-063 scene assembly ─► FP-064 lifecycle
                                                                                    │
FP-006 Play account (H, long lead) ─┐   FP-007 keystore (H)   FP-008 devices (H) ─► FP-065 export + CI APK  ◄── SPOF-2
                                    └──────────────────────────────────────────────► FP-066 render bench ─► FP-067 balance v0
                                                                                    ─► FP-068 Gate 3 on device (H) ─► FP-069 FP gate (H)
```

### Chain gating Alpha (epics, I2)

`E-VS-01 kill chain complete → E-VS-03 doctrine/manual/relocate UI → E-VS-05 save/lifecycle → E-PA-01 SRBM/ABM → E-PA-03 tech tree → E-PA-06 ad spike (SPOF-3) → E-AL-02 maps 2–3 → E-AL-07 release export + Play internal (SPOF-2) → E-AL-08 closed test start (SPOF-4)`.

### Single points of failure

| SPOF | what | why single | early signal | fallback |
|------|------|------------|--------------|----------|
| SPOF-1 | GDScript sim ceiling on the low device | every feature scales with tick cost | CAD-FP-041 baseline on device > 2.5 ms p95 at 250/300/60 | A-03/A-06 cuts; A-40 decision |
| SPOF-2 | Android export/signing pipeline (SDK versions, gradle template, 16 KB, target API) | one broken link = no build | CI `android-debug` red after an engine or SDK update | pin versions (A-01), keep last-good runner image cached, human-local export as bypass |
| SPOF-3 | Ad SDK integration | third-party native code, policy surface | spike gate misses twice | ship without ads (A-24) |
| SPOF-4 | 12 testers × 14 days | external humans; blocks production access | < 12 opted-in after 2 weeks of recruiting | public devlog recruiting; schedule slip is the only other option |
| SPOF-5 | The human's 2 h/week | review is the only merge path | review queue > 10 cards | freeze new cards; agents only work on cards already in review-ready state; H4 rule R3 |
| SPOF-6 | Upload keystore loss | cannot update the app (Play App Signing allows a key reset with support, slow) | — | two offline copies; password manager |

## E.7 Full delegation matrix (expands §4.6)

| domain | agents produce | human verifies / owns | escalation to human required when |
|--------|----------------|------------------------|-----------------------------------|
| Sim core: entity stores, spatial hash | implementation + unit tests from contracts | contract text, capacity constants, determinism rules | any proposal to change a `class_name` signature or store layout |
| Sim core: kill chain | systems from B.5 pseudocode + scenario tests | realism decisions (detection model, Pk modifiers, EW behaviour, SRBM economics), determinism, balance judgement | an agent believes the pseudocode is unrealistic or self-contradictory (must stop and ask via handoff `BLOCKED`) |
| Sim core: economy & waves | formulas, generator, harness policies | formula changes, worked-example targets, fun/pacing | any change to B.6/B.7 numbers |
| Rendering | MultiMesh views, shaders, pooling, VFX, bench scene | on-device frame time, draw calls, thermal, visual style | draw calls > 120 or per-frame allocation needed |
| UI/UX | scene scaffolds, control logic, layout adapters, strings wiring | touch feel, one-thumb reach, 4 mm readability, information hierarchy | new screen or navigation path not in B.12 |
| Data tooling | importer, validator, atlas builder, save code, migrations | schema design, non-destructive behaviour, corruption audit | schema field added/removed |
| Android platform | lifecycle handling, presets, CI YAML, 16 KB/target-API checks | keystore, Play Console, signing, policy forms, device tests | any file under `android/`, any permission, any SDK version change |
| Art & VFX | SVG sets, procedural VFX, particle configs, atlas | style unity, polish, IP clearance, store art alteration | any raster or third-party art proposal |
| Audio | bus layout, pooled players, SFX map, music transitions | frequency clashes, dynamic range, licences | any asset without a licence row |
| Balance | harness, policies, reports, CSV change proposals | fun, pacing, difficulty sign-off, ADRs | harness bands (G.2) not met after 2 tuning cards |
| Content | CSVs, strings, hints, store text drafts | numbers, tone, legal text submission | fiction touches a real manufacturer/flag/conflict |
| Ads/monetisation | wrapper code, consent flow, reward commands, test-ad verification | account, ad unit ids (never in agent context until the human pastes them into `ads_config.tres` at RC), policy | any change to placements (A-24) |
| Agent ops & continuity | handoff cards, logs, metrics, prompt changes, stale-handoff checks | workflow integrity, prompt validation, handover audit, retune decisions | takeover fails (successor cannot resume from the handoff) |
| Release | checklists, release notes draft, version bumps in a card | upload, rollout steps, vitals watch, hotfix decision | vitals threshold breach |
