# D. Technical Architecture & Tooling Pipeline

Godot 4.7.2, GDScript only, Compatibility renderer, Android arm64 only (A-01, A-02, A-12). Anything marked `[VERIFY]` must be confirmed by the agent executing the card that first touches it, and the result recorded in the card's handoff.

## D1 Engine configuration

### D1.1 `project.godot` (authoritative keys; CAD-FP-002 writes this file)

```ini
config_version=5

[application]
config/name="Colonel Air-defense: The Danger Wave"
config/version="0.1.0"
run/main_scene="res://scenes/app/cad_boot.tscn"
config/features=PackedStringArray("4.7", "GL Compatibility")
config/quit_on_go_back=false
run/low_processor_mode=false
run/max_fps=0
config/icon="res://art/icons/cad_icon.svg"

[autoload]
CadEvents="*res://src/view/autoload/cad_events.gd"
CadApp="*res://src/view/autoload/cad_app.gd"

[debug]
gdscript/warnings/untyped_declaration=2
gdscript/warnings/inferred_declaration=1
gdscript/warnings/unsafe_property_access=2
gdscript/warnings/unsafe_method_access=2
gdscript/warnings/unsafe_cast=2
gdscript/warnings/unsafe_call_argument=2
gdscript/warnings/return_value_discarded=2
gdscript/warnings/exclude_addons=true
; [VERIFY] all names/values above against Godot 4.7 ProjectSettings (2 = Error, 1 = Warn)

[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
window/handheld/orientation=4
; 4 = sensor_landscape [VERIFY enum value]

[gui]
theme/custom="res://ui/theme/cad_theme.tres"

[input]
; keyboard bindings exist for desktop testing only; touch is handled in code
cad_pause={"deadzone":0.5,"events":[<InputEventKey physical_keycode=32>]}
cad_speed_1={"events":[<InputEventKey physical_keycode=49>]}
cad_speed_2={"events":[<InputEventKey physical_keycode=50>]}
cad_speed_3={"events":[<InputEventKey physical_keycode=51>]}
cad_cancel={"events":[<InputEventKey physical_keycode=4194305>]}
cad_confirm={"events":[<InputEventKey physical_keycode=4194309>]}
cad_debug_overlay={"events":[<InputEventKey physical_keycode=4194334>]}
; keycodes: Space, 1, 2, 3, Escape, Enter, F3 [VERIFY numeric values; write actions from the editor and commit the generated text]

[input_devices]
pointing/emulate_touch_from_mouse=true
pointing/emulate_mouse_from_touch=false
pointing/android/enable_pan_and_scale_gestures=true
pointing/android/enable_long_press_as_right_click=false
; [VERIFY both android/* keys exist in 4.7]

[importer_defaults]
texture={"compress/mode":0,"mipmaps/generate":true,"svg/scale":2.0,"process/premult_alpha":true}
oggvorbisstr={"loop":false}
wav={"compress/mode":0,"edit/trim":true}
; [VERIFY importer_defaults key names]

[physics]
common/physics_ticks_per_second=30

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/vram_compression/import_etc2_astc=true
textures/canvas_textures/default_texture_filter=1
2d/snap/snap_2d_transforms_to_pixel=false
2d/snap/snap_2d_vertices_to_pixel=false
```

### D1.2 `export_presets.cfg` (CAD-FP-065 debug; release preset added in E-AL-07)

```ini
[preset.0]
name="Android Debug"
platform="Android"
runnable=true
export_filter="all_resources"
exclude_filter="test/*,tools/*,ai/*,docs/*,bench/baseline.json,data/csv/*"
export_path="build/cad-debug.apk"

[preset.0.options]
gradle_build/use_gradle_build=false
gradle_build/export_format=0
gradle_build/min_sdk="24"
gradle_build/target_sdk="36"
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
version/code=1
version/name="0.1.0"
package/unique_name="com.djdanou.cad"
package/name="Colonel Air-defense"
package/signed=true
package/app_category=2
package/retain_data_on_uninstall=false
package/exclude_from_recents=false
package/show_in_android_tv=false
package/show_in_app_library=true
package/show_as_launcher_app=false
launcher_icons/main_192x192="res://art/icons/cad_icon_192.png"
launcher_icons/adaptive_foreground_432x432="res://art/icons/cad_icon_fg_432.png"
launcher_icons/adaptive_background_432x432="res://art/icons/cad_icon_bg_432.png"
launcher_icons/adaptive_monochrome_432x432="res://art/icons/cad_icon_mono_432.png"
graphics/opengl_debug=false
xr_features/xr_mode=0
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
user_data_backup/allow=false
gesture/swipe_to_dismiss=false
shader_baker/enabled=false
; [VERIFY] min_sdk/target_sdk string-vs-int type, app_category value for Game, shader_baker key; keystore/* fields stay EMPTY in the repo (debug keystore from editor settings; release via env vars, D5.4)

[preset.1]
name="Android Release"
platform="Android"
runnable=false
export_filter="all_resources"
exclude_filter="test/*,tools/*,ai/*,docs/*,bench/baseline.json,data/csv/*"
export_path="build/cad-release.aab"

[preset.1.options]
gradle_build/use_gradle_build=true
gradle_build/export_format=1
gradle_build/min_sdk="24"
gradle_build/target_sdk="36"
gradle_build/compress_native_libraries=false
architectures/arm64-v8a=true
architectures/armeabi-v7a=false
; remaining options identical to preset.0; version/code bumped by the release procedure
```

### D1.3 Editor settings needed for export (human machine and CI; file `~/.config/godot/editor_settings-4.7.tres` on Linux, `%APPDATA%\Godot\editor_settings-4.7.tres` on Windows `[VERIFY file name]`)

```ini
[gd_resource type="EditorSettings" format=3]
[resource]
export/android/android_sdk_path = "<ANDROID_HOME>"
export/android/java_sdk_path = "<JAVA_HOME of JDK 17>"
export/android/debug_keystore = "<home>/.android/debug.keystore"
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
```
Debug keystore creation (if Godot does not auto-generate it `[VERIFY]`): `keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"`.

### D1.4 Sim tick and speed (`CadSimDriver`, CAD-FP-043)

| parameter | value |
|-----------|-------|
| `CadConst.TICK_HZ` / `TICK_DT` | 30 / 0.033333 |
| speed → ticks per 1/30 s wall | 0 → 0 (tactical pause), 1 → 1, 2 → 2, 3 → 3 |
| `MAX_TICKS_PER_FRAME` | 6 (at 3× and 30 fps: 3 ticks/frame nominal; 6 absorbs one dropped frame, then time dilates instead of spiralling) |
| accumulator | `acc += min(delta, 0.1) × speed; while acc ≥ TICK_DT and n < MAX: sim.step(); acc −= TICK_DT; n += 1` |
| interpolation alpha | `acc / TICK_DT` (0..1) exposed as `CadSimDriver.alpha` |
| lifecycle pause | `get_tree().paused = true`; driver `process_mode = PROCESS_MODE_PAUSABLE`; UI overlays `PROCESS_MODE_WHEN_PAUSED` |

## D2 Runtime architecture

### D2.1 Sim/view separation

```
                 commands (CadCommand)                  events (CadEventLog)
  UI/touch ───────────────► CadCommandQueue ──► CadSim.step() ──► ring buffer ──► CadSimDriver drains per frame
                                                   │  ▲                              │
              src/view/* (Nodes, scenes, shaders)   │  │ reads typed getters only     ▼
  ◄─────────────────────────────────────────────────┘  └───────────── CadEvents (autoload signals) ──► views, audio, HUD
  src/sim/* (RefCounted only; no Node, SceneTree, Timer, signal, await, Engine, Time, OS, Input)
```

Rules (enforced by review and by `tools/check_sim_purity.gd` in CI from CAD-FP-004): no file under `src/sim/` may contain the tokens `extends Node`, `get_tree`, `Timer`, `await`, `signal `, `Engine.`, `Time.`, `OS.`, `Input.`, `randf(`, `randi(`, `preload(`, `load(` (defs are injected by `CadDefs`, which lives in `src/defs/` and is the only sim-facing loader).

### D2.2 Tick loop order (`CadSim.step()`, CAD-FP-039) — fixed for determinism

| # | stage | class | reads | writes |
|---|-------|-------|-------|--------|
| 1 | apply queued commands (in enqueue order) | `CadCommandQueue` → `CadSim.apply_command` | funds, emplacements | emplacements, doctrine, funds, events(COMMAND_RESULT) |
| 2 | snapshot `prev_x/prev_y` ← `pos_x/pos_y` | stores | | prev arrays |
| 3 | spawn due entries | `CadWaveDirector` | plan, threats.count | threats (alloc), events(THREAT_SPAWNED) |
| 4 | threat motion & state | `CadThreatMotion` | threats, map | pos/vel/state/alt |
| 5 | spatial hash rebuild (threats) | `CadSpatialHash.rebuild` | pos | buckets |
| 6 | jam field per sensor/shooter | `CadEwSystem.compute_fields` | jammer threats | `jam_at_emp: PackedFloat32Array` |
| 7 | detect | `CadSensorSystem` | hash, defs, jam | detect_ticks_left, flags, events |
| 8 | track | `CadTrackSystem` | detected | track_owner, track_age, flags |
| 9 | engage (targeting inside) | `CadFireControl` + `CadTargeting` | tracks, doctrine, pk | interceptors (alloc), ammo, ready ticks, events |
| 10 | interceptors advance/resolve | `CadInterceptorSystem` | interceptors, threats | kills, channels, events |
| 11 | friendly EW (every 30th tick) | `CadEwSystem.apply` | ew emplacements | threat state → WANDER |
| 12 | impacts / kills / crashes cleanup | `CadImpactSystem` | states | districts hp, emplacement hp, salvage, release slots |
| 13 | alive-list rebuild | stores.`rebuild_alive()` | | alive index arrays |
| 14 | wave state check | `CadWaveDirector.is_cleared`, districts.integrity | | wave_state, events(WAVE_CLEARED / RUN_ENDED) |
| 15 | `tick += 1` | | | |

### D2.3 Entity model (A-04)

| store | layout | capacity | key fields |
|-------|--------|----------|------------|
| `CadThreatStore` | SoA `Packed*Array`s + free list + `alive` index list | `CadConst.MAX_THREATS = 512` | def_index, state, pos_x/y, prev_x/y, vel_x/y, alt_m, hp, target_kind, target_id, target_x/y, detect_ticks_left, track_owner, track_age, engaged_by, flags (bit 0 CLASSIFIED, bit 1 JAMMED, bit 2 REVEALER), state_ticks, spawn_tick, eccm_level, package_id |
| `CadInterceptorStore` | SoA + free list | `MAX_INTERCEPTORS = 1024` | launcher_index, target_threat, weapon_def, pos_x/y, prev_x/y, speed, pk, resolve_tick, state |
| `CadEmplacementStore` | `Array[CadEmplacement]` preallocated (objects reused, `active` flag) + `shooters`, `sensors`, `ew`, `support` index lists rebuilt on change | `MAX_EMPLACEMENTS = 64` | see CAD-FP-026 contract |
| `CadDistrictState` | SoA over districts | `MAX_DISTRICTS = 16` | hp, max_hp, value, hardening_mult, damage_this_wave, repair_cap |
| `CadEventLog` | ring of (type, a, b, c: int; x, y: float) | `EVENT_CAPACITY = 4096` per tick-batch; overflow counted, never allocates | — |

Free-list discipline: `alloc()` returns the lowest free index (deterministic); `release()` pushes to the free stack; `rebuild_alive()` scans 0..capacity−1 and writes ascending alive indices; all systems iterate `alive[0..alive_count)`.

### D2.4 Spatial hash (A-07, CAD-FP-014)

Uniform grid over `world_min..world_max`, cell 500 m (40 × 24 = 960 cells for map 1). Rebuild each tick by counting sort: `cell_count[c]++` → prefix sums → scatter indices into `cell_items`. `query_circle(cx, cy, r, out)` visits cells overlapping the circle's bounding box and writes indices whose exact `dist² ≤ r²` into the caller-provided `PackedInt32Array` (pre-sized to capacity), returning the count. Threats are hashed; emplacements query. Interceptors are not hashed (each knows its target).

### D2.5 RNG and determinism (A-17, A-18)

`CadRng` streams: WAVEGEN (composition/timing), COMBAT (Pk rolls, EW rolls), MOTION (wander headings). State is `RandomNumberGenerator.state` (int) per stream, saved at wave boundaries. Rules: no sim code calls global `randf/randi`; no iteration over `Dictionary` keys in the sim (unordered); `Array.sort_custom` forbidden in tick paths; top-K selection uses fixed-size insertion; all tie-breaks by ascending index. Golden test: `test/scenario/test_determinism.gd` hashes the event log (`hash(PackedInt32Array)`) per wave.

### D2.6 Event bus

Sim → view: `CadEventLog` only. View: `CadSimDriver` drains it each frame and emits typed signals on the `CadEvents` autoload (`threat_killed(index: int, def_index: int, x: float, y: float)` etc., full list in CAD-FP-042). View → sim: `CadCommandQueue.enqueue(CadCommand)` only. UI ↔ UI: signals on `CadEvents` prefixed `ui_` (`ui_emplacement_selected(index: int)`, `ui_state_changed(from: int, to: int)`).

### D2.7 State machines (enums in `src/sim/cad_enums.gd`; transitions validated in code with `push_error` on illegal moves)

Threat (`ThreatState`):

| from | to | condition |
|------|----|-----------|
| SPAWNED | INGRESS | first motion tick |
| INGRESS | TERMINAL | dist to target ≤ terminal_dist (FPV 300 m; SRBM alt ≤ 5,000; GLIDE alt ≤ 200) |
| INGRESS / TERMINAL | ORBIT | RECON/JAMMER/SEAD-loiter reached orbit point |
| INGRESS / TERMINAL / ORBIT | WANDER | EW link loss (guidance SATNAV/DATALINK) |
| WANDER | CRASHED | `state_ticks ≥ wander_ticks(class)` |
| ORBIT | EXITED | orbit_time elapsed (RECON/JAMMER); DECOY reaches map edge → EXITED |
| INGRESS / TERMINAL | IMPACTED | reached target point |
| any alive | KILLED | hp ≤ 0 or Pk hit |
| CRASHED / KILLED / IMPACTED / EXITED | (released) | impact stage same tick |

Emplacement (`EmpState`): PLACING (ghost, view-only) → ACTIVE (command PLACE accepted) → RELOADING (ammo 0 and stock > 0; back to ACTIVE at `reload_end_tick`) → RELOCATING (command RELOCATE; ACTIVE after `relocate_penalty_ticks` at next wave start) → DESTROYED (hp ≤ 0; terminal; SELL removes the object). Interceptor: FLYING → RESOLVED (released same tick). Wave (`WaveState`): IDLE → SPAWNING (START_WAVE) → ACTIVE (plan exhausted, threats alive) → CLEARED (no threats alive, plan exhausted) | FAILED (integrity ≤ 0 → RUN_ENDED). Game (`GameState`): table in B.12.

## D3 Data management

### D3.1 Resource schemas (all `extends Resource`, `@tool` not used, `@export` typed fields, `schema_version: int` first field; file `src/data/<snake>.gd`, `class_name Cad…`)

| schema | fields (type = default) |
|--------|------------------------|
| `CadThreatDef` | schema_version: int = 1; id: StringName; display_name: String; threat_class: CadEnums.ThreatClass; cost: int; hp: float; speed_mps: float; alt_band: CadEnums.AltBand; altitude_m: float; rcs_m2: float; apparent_rcs_m2: float = 0.0; guidance: CadEnums.Guidance; damage: float; target_pref: CadEnums.TargetPref; eccm_level: int = 0; jam_radius_m: float = 0.0; jam_strength: float = 0.0; sensor_radius_m: float = 0.0; orbit_time_s: float = 0.0; wander_time_s: float = 12.0; intro_wave: int = 1; salvage_mult: float = 1.0; sprite_id: StringName |
| `CadEmplacementDef` | schema_version = 1; id; display_name; kind: CadEnums.EmpKind; cost: int; hp: float; upkeep: int; footprint_m: float = 150.0; detect_ref_range_m: float = 0; low_alt_horizon_m: float = 0; max_alt_m: float = 0; alt_coverage: int (bitmask of AltBand) = 0; track_capacity: int = 0; track_range_m: float = 0; passive_range_m: float = 0; emits: bool = false; range_max_m: float = 0; range_min_m: float = 0; shot_interval_s: float = 0; reload_s: float = 0; ammo_capacity: int = 0; stock_max: int = 0; ammo_cost: int = 0; interceptor_speed_mps: float = 0; channels: int = 1; needs_track_for_full_pk: bool = false; organic_range_m: float = 0; jam_vulnerability: float = 0; is_gun: bool = false; effect_radius_m: float = 0; effect_a: float = 0; effect_b: float = 0; tech_required: StringName = &""; upgrade_ids: Array[StringName]; sprite_id: StringName |
| `CadPkTable` | schema_version = 1; weapon_ids: Array[StringName]; threat_ids: Array[StringName]; pk: PackedFloat32Array (row-major, size = weapons × threats) |
| `CadBalanceConfig` | schema_version = 1; salvage_rate = 0.15; bonus_base = 200.0; bonus_per_wave = 60.0; bonus_damage_denominator = 200.0; district_repair_cost_per_hp = 2.0; emplacement_repair_cost_per_hp = 3.0; sell_refund_rate = 0.5; relocate_cost_rate = 0.1; relocate_penalty_s = 20.0; organic_pk_mult = 0.6; cued_pk_mult = 0.75; jam_pk_mult = 0.5; eccm_step = 0.25; detection_persist_s = 2.0; decoy_classify_s = 8.0; radar_rcs_ref_m2 = 1.0; max_engagements_per_threat = 2; min_pk_to_fire = 0.05; manual_fire_cooldown_s = 3.0; defended_radius_m = 6000.0; tech_points_per_wave = 1; tech_points_scenario_clear = 10; intel_base = 0.5; intel_fcr_bonus = 0.2 |
| `CadDistrictDef` | schema_version = 1; id; display_name; polygon: PackedVector2Array; center: Vector2; value_per_wave: int; max_hp: float = 100.0; repair_cap_per_wave: float = 50.0 |
| `CadMapDef` | schema_version = 1; id; display_name; world_min: Vector2; world_max: Vector2; city_center: Vector2; threat_axis: Vector2; spawn_line_a: Vector2; spawn_line_b: Vector2; districts: Array[CadDistrictDef]; build_zones: Array[PackedVector2Array]; no_build_zones: Array[PackedVector2Array]; final_wave: int = 30; starting_funds: int; budget_mult: float = 1.0; wave_rules: CadWaveRules; terrain_texture: Texture2D; hint_rules: CadHintRules |
| `CadPackageDef` | schema_version = 1; id; entry_threat_ids: Array[StringName]; entry_min: PackedInt32Array; entry_max: PackedInt32Array; tot_offset_s: float; spread_s: float; lateral_spread_m: float; min_wave: int |
| `CadWavePhase` | schema_version = 1; wave_from: int; wave_to: int; package_ids: Array[StringName]; package_weights: PackedFloat32Array; eccm_level: int; cap_class_ids: Array[StringName]; cap_counts: PackedInt32Array |
| `CadWaveRules` | schema_version = 1; budget_base = 500.0; budget_linear = 150.0; budget_quad = 4.0; final_wave_budget_mult = 1.5; phases: Array[CadWavePhase]; packages: Array[CadPackageDef]; max_concurrent = 200; spawn_window_base_s = 60.0; spawn_window_per_wave_s = 6.0; spawn_window_max_s = 240.0; fill_min = 0.95; fill_max = 1.05 |
| `CadTechNode` | schema_version = 1; id; display_name; description: String; tier: int; cost_tp: int; prereq_ids: Array[StringName]; prereq_any_of_tier: int = 0; prereq_any_count: int = 0; effect_kind: CadEnums.TechEffect; target_id: StringName; target_stat: StringName; value: float; threat_filter_ids: Array[StringName] |
| `CadUpgradeDef` | schema_version = 1; id; emplacement_id: StringName; level: int; cost: int; stat: StringName; multiplier: float = 1.0; additive: float = 0.0; pk_additive: float = 0.0 |
| `CadDoctrinePreset` | schema_version = 1; kind: CadEnums.EmpKind; roe: CadEnums.Roe; priority: CadEnums.Priority; min_threat_value: int; salvo: int = 1; reengage: bool = false |
| `CadAtlasMap` | schema_version = 1; atlas_texture: Texture2D; sprite_ids: Array[StringName]; frames: Array[Rect2i]; pivot: Vector2 = (0.5, 0.5) |
| `CadPalette` | schema_version = 1; bg, grid, friendly, friendly_dim, hostile, hostile_high, track, ew, warning, danger, text, text_dim, district_ok, district_hit: Color |
| `CadHintRules` | schema_version = 1; hint_ids: Array[StringName]; trigger_wave: PackedInt32Array; trigger_state: PackedInt32Array (GameState); once: bool = true |

Enum `CadEnums.TechEffect { UNLOCK_EMPLACEMENT, STAT_MULT, STAT_ADD, PK_ADD, CONFIG_ADD, CONFIG_MULT, DOCTRINE_UNLOCK }`. Schema change procedure: bump `schema_version`, add a migration in `CadDefs.migrate_def()` (resources) or `CadSaveMigrations` (saves), add a validator rule, update B.14.

### D3.2 CSV importer (`tools/csv_import/cad_csv_import.gd`, CAD-FP-022)

- Runs headless: `$GODOT_BIN --headless --path . -s res://tools/csv_import/cad_csv_import.gd -- --in data/csv/threats.csv --schema CadThreatDef --out data/defs/threats`
- Header row = property names; a column not present on the schema → error `CSV001`; a schema property absent from the CSV keeps its default; conversion by declared type from `get_property_list()` (int, float, bool `true/false`, StringName, enum by name via `CadEnums` constant lookup, `Array[StringName]` as `a|b|c`, bitmask as `LOW|MED`)
- Non-destructive: renders the `.tres` text into memory, compares bytes with the existing file, writes only on difference; never deletes files; prints a one-line summary per row `wrote|unchanged <path>`
- `data/csv/*.csv` are the source of truth for balance; `.tres` files are committed too (so the game never depends on the importer at runtime)

### D3.3 Save schema (`CadSave`, `CadSaveMigrations`, epic E-VS-05)

```json
{
  "schema_version": 1,
  "campaign_id": "default",
  "saved_at_unix": 1760000000,
  "app_version": "0.3.0",
  "tech": {"tp": 7, "unlocked": ["t1_mrsam_unlock"]},
  "best_wave": {"map_01": 12},
  "run": {
    "map_id": "map_01", "seed": 123456789, "wave_index": 6, "funds": 1510,
    "rng_state": {"wavegen": 8123, "combat": 991, "motion": 42},
    "districts": [{"id": "d_gov", "hp": 100.0}],
    "hardened": ["d_gov"],
    "revealed": [3],
    "emplacements": [{"id": 3, "def": "cad_emp_aaa", "x": 1200.0, "y": -300.0, "hp": 80.0, "level": 1,
                       "ammo": 60, "stock": 120, "state": 1,
                       "doctrine": {"roe": 2, "priority": 0, "min_threat_value": 0, "salvo": 1, "reengage": false}}]
  },
  "settings": {"sfx": 0.8, "music": 0.6, "ui_scale": 1.0, "rings": true, "auto_restock": true}
}
```
Rules: written only at BUILD entry and at RUN_END; `CadSave.write(path, dict)` → `FileAccess.open(path + ".tmp", WRITE)`, `store_string(JSON.stringify(dict, "\t"))`, `flush()`, `close()`, then `DirAccess.rename_absolute(tmp, path)` `[VERIFY overwrite]`; on read, parse errors or a missing `schema_version` → the file is moved to `<name>.corrupt-<unix>.json` and the title shows "save unreadable, moved aside"; migrations are pure functions `v1_to_v2(d: Dictionary) -> Dictionary` applied in order; a test fixture per version lives in `test/fixtures/saves/`.

### D3.4 Content validator (`tools/validate_content.gd`, CAD-FP-023; CI job `content`)

| code | rule |
|------|------|
| CV001 | duplicate `id` within a def directory |
| CV002 | reference to unknown id (pk table, packages, phases, tech targets, upgrades, hints, map wave_rules) |
| CV003 | Pk matrix missing a (weapon, threat) pair or size ≠ weapons × threats; value outside [0, 1] |
| CV004 | a package's `min_wave` < any of its entries' `intro_wave` |
| CV005 | `sprite_id` not in `CadAtlasMap` |
| CV006 | `schema_version` ≠ current for the class |
| CV007 | NaN, negative cost/hp/range, `entry_min > entry_max` |
| CV008 | wave phases with gaps or overlaps in 1..final_wave |
| CV009 | district polygon self-intersecting or < 3 points; `center` outside polygon |
| CV010 | map without build zones or spawn line inside a build zone |
| CV011 | tech prerequisite cycle or unknown prereq |
| CV012 | UI string key used in code (`CadStrings.get_text(&"key")` grep) missing from `ui/strings/cad_strings_en.csv` |
| CV013 | doctrine preset missing for a shooter kind |

Exit code 0 on success, 1 on any error; prints `CVnnn <file> <detail>` lines.

## D4 Asset pipeline

| stage | tool | rule |
|-------|------|------|
| Sprite authoring | agent-written SVG (`art/svg/<sprite_id>.svg`, 64×64 viewBox, 2 colours from `CadPalette`, stroke 4) → human polish in Inkscape 1.x if needed | prompt `/ai/prompts/generate-svg-sprite-set.md`; no raster AI images ever (§4.4) |
| Atlas | `tools/atlas_build.gd` (headless) → `art/atlas/cad_atlas.png` (2048², lossless) + `art/atlas/cad_atlas_map.tres` | frames sorted by `sprite_id`; 2 px padding; rerun on any SVG change (CI check: rebuilt atlas bytes == committed bytes) |
| Terrain/background | agent-authored procedural (`CadMapView._draw` grid + district polygons) at 1.0; optional 2048×1228 PNG per map, VRAM compressed | ≤ 3 MB per map |
| Import presets | project `importer_defaults` (D1.1): lossless, mipmaps, `svg/scale=2.0`; terrain `.import` override `compress/mode=2` | |
| Naming | files snake_case with prefix by kind: `thr_`, `emp_`, `fx_`, `ui_glyph_`, `ui_`; scenes `cad_<name>.tscn`; scripts `cad_<name>.gd`; class names `Cad<Name>`; test files `test_cad_<name>.gd` | |
| Audio | SFX: WAV 16-bit 44.1 kHz mono, ≤ 1 s, named `sfx_<event>_<variant>.wav`; music: OGG Vorbis q5 stereo, stems `mus_<map>_<layer>.ogg` (layers: base, tension, climax) | bus layout `audio/cad_bus_layout.tres` (Master, Music, SFX, UI); SFX concurrency cap 4 per clip / 100 ms; 32 pooled `AudioStreamPlayer2D` |
| Fonts | `art/fonts/<Family>-*.ttf` + licence file next to them | OFL only |
| Licence register | `art/LICENSES.md`, one row per third-party asset: `path | source URL | author | licence | modified (y/n) | added by card` | CI job `licences` fails if a file under `art/` or `audio/` not authored in-repo (listed in `art/AUTHORED.txt`) lacks a row |
| Store assets | `docs/store/` icon 512², feature graphic 1024×500, ≥ 4 phone screenshots (captured from the mid device) | human-altered captures only |

## D5 Build, CI/CD

### D5.1 Repository conventions

- Trunk-based (A-31): `main` protected; branch `card/<CARD-ID>-<slug>`; PR title `<CARD-ID>: <title>`; squash-merge by the human; PR body = the agent's deliverable format (AGENTS.md §9)
- WIP commits on card branches are mandatory at every handoff checkpoint (`wip(<CARD-ID>): <what>`), pushed immediately
- `.gitignore`: `.godot/`, `build/`, `reports/`, `*.tmp`, `android/` (gradle build dir, except `android/plugins/` if the ad plugin is vendored `[HUMAN]`), `.import/` (Godot 3 leftovers), `*.keystore`, `*.jks`, `.env`; `.gitattributes`: `* text=auto eol=lf`, `*.png binary`, `*.wav binary`, `*.ogg binary`, `*.ttf binary`, `*.tres text`, `*.tscn text`, `*.gd text`

### D5.2 GitHub Actions workflow outline (`.github/workflows/ci.yml`, CAD-FP-005 / CAD-FP-065)

```yaml
name: ci
on: [push, pull_request]
env:
  GODOT_VERSION: "4.7.2"
  GDTOOLKIT_VERSION: "4.5.0"
# Official builds live in godotengine/godot-builds, and each release publishes SHA512-SUMS.txt
# (there is no SHA256 sums file) — both verified 2026-09-08 at CAD-FP-005. The workflow downloads
# that file, greps the line for the asset it fetched, and runs `sha512sum -c` on that one line.
jobs:
  lint:            # ubuntu-latest, python 3.12
    - actions/checkout@v4 ; actions/setup-python@v5
    - pip install gdtoolkit==4.5.0
    - gdlint src test tools
    - gdformat --check src test tools
  engine:          # jobs are added as their tools land: import + typing probe now (CAD-FP-005),
                   # gdUnit4 (CAD-FP-003), typecheck/purity (CAD-FP-004), content (CAD-FP-023),
                   # bench (CAD-FP-041), android-debug (CAD-FP-065)
    - actions/cache@v4  key: godot-${{ env.GODOT_VERSION }}  path: ~/.godot-bin
    - curl -fsSL -O https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip and .../SHA512-SUMS.txt ; grep the asset's line ; sha512sum -c ; unzip → ~/.godot-bin/godot
    - $GODOT_BIN --headless --path . --import
    - $GODOT_BIN --headless --path . -s res://tools/check_scripts.gd            # loads every .gd, fails on any error (warnings are errors per A-10)
    - $GODOT_BIN --headless --path . -s res://tools/check_sim_purity.gd
    - $GODOT_BIN --headless --path . -d -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -rd reports/gdunit -c
    - $GODOT_BIN --headless --path . -s res://tools/validate_content.gd
    - $GODOT_BIN --headless --path . -s res://tools/bench_runner.gd -- --compare bench/baseline.json --max-ratio 1.25
    - actions/upload-artifact@v4 reports/
  android-debug:   # needs: test ; only on push to main and PRs labelled 'apk'
    - actions/setup-java@v4 (temurin 17)
    - cache + download export templates → ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable/   # [VERIFY dir name]
    - write ~/.config/godot/editor_settings-4.7.tres (D1.3) using $ANDROID_HOME (preinstalled on ubuntu-latest [VERIFY]) and $JAVA_HOME
    - keytool debug keystore (D1.3) if missing
    - $GODOT_BIN --headless --path . --export-debug "Android Debug" build/cad-debug.apk
    - test $(stat -c %s build/cad-debug.apk) -le 94371840        # 90 MB proxy for the 80 MB install budget
    - actions/upload-artifact@v4 build/cad-debug.apk
```
Runtime budget: lint 1 min, test ≤ 6 min, android-debug ≤ 8 min; free-tier minutes ≈ 2,000/month → ≤ 130 full runs/month, so `android-debug` runs only on `main` and labelled PRs.

### D5.3 Local commands (wrapped in `tools/*.sh` and `tools/*.cmd`; `GODOT_BIN` = path to the console binary, e.g. `Godot_v4.7.2-stable_win64_console.exe`)

| command | script |
|---------|--------|
| lint + format check | `tools/lint.sh` |
| typecheck | `tools/typecheck.sh` → `$GODOT_BIN --headless --path . -s res://tools/check_scripts.gd` |
| all tests | `tools/test.sh` → `$GODOT_BIN --headless --path . -d -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -rd reports/gdunit -c` |
| one test file | `tools/test.sh res://test/unit/sim/test_cad_threat_store.gd` |
| content validation | `tools/validate.sh` |
| debug APK | `tools/export_debug.sh` → `$GODOT_BIN --headless --path . --export-debug "Android Debug" build/cad-debug.apk` |
| install + run + logs | `tools/device_run.sh` → `adb install -r build/cad-debug.apk && adb shell am start -n com.djdanou.cad/com.godot.game.GodotApp && adb logcat -s godot` `[VERIFY activity name]` |
| sim bench | `tools/bench.sh` → `$GODOT_BIN --headless --path . -s res://tools/bench_runner.gd -- --threats 250 --interceptors 300 --emplacements 60 --ticks 1800` |

### D5.4 Android release export and signing procedure (human-only steps marked)

1. `[HUMAN]` Generate the **upload key** once (CAD-FP-007): `keytool -genkeypair -v -keystore cad-upload.jks -alias cad-upload -keyalg RSA -keysize 2048 -validity 10000`; store the file and passwords in the password manager and on one offline copy; never in the repo, CI secrets, or any agent context.
2. `[HUMAN]` Enrol in **Play App Signing** at first upload (Google holds the app signing key; we hold only the upload key).
3. `[HUMAN]` On the human machine: install JDK 17 + Android SDK per D1.3; run once `$GODOT_BIN --headless --path . --install-android-build-template` (creates `android/build/`; ignored by git except `android/plugins/`).
4. `[HUMAN]` Bump `version/code` (monotonic integer) and `version/name` in preset 1 via the card that prepares the release; commit.
5. `[HUMAN]` In a fresh shell: `export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/secure/cad-upload.jks GODOT_ANDROID_KEYSTORE_RELEASE_USER=cad-upload GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=<from password manager>` then `$GODOT_BIN --headless --path . --export-release "Android Release" build/cad-release.aab`.
6. `[HUMAN]` Verify: `bundletool validate --bundle build/cad-release.aab` (bundletool is Apache-2.0, `[VERIFY current jar URL]`); 16 KB check `tools/check_16kb.sh build/cad-release.aab`; size check.
7. `[HUMAN]` Upload to Play Console → **Internal testing** → smoke on both devices → promote to **Closed testing** (Alpha onward) → **Production** staged (Launch).
8. Automation (Beta or later, only if still free): `r0adkll/upload-google-play` with a Play service-account JSON in CI secrets is permitted (it is not the keystore); the AAB is still built and signed on the human machine and uploaded as a workflow input — CI never signs.

### D5.5 Play track promotion

| track | who installs | gate to promote |
|-------|--------------|-----------------|
| Internal testing (≤ 100) | human devices | installs, launches, no crash in 10 min |
| Closed testing (12+ testers) | recruited testers | 14 days, vitals < thresholds, feedback form |
| Open testing | skipped at 1.0 | — |
| Production staged 10/25/50/100 % | public | C.2 Gold rules |

## D6 Performance targets and benchmarks

| metric | mid device target | low device target | measured by | CI / merge threshold |
|--------|-------------------|-------------------|-------------|----------------------|
| frame time p95 during WAVE (200 threats) | ≤ 16.6 ms | ≤ 33.3 ms | `CadFrameStats` (view; `Time.get_ticks_usec()` per frame) log to `user://perf/*.json` during `cad_bench_render.tscn` and during a scripted wave-12 replay | Gate 3 blocks merge |
| sim tick p95 at ceilings | ≤ 2.5 ms (400/600/60) | ≤ 3.3 ms (250/300/60) | `tools/bench_runner.gd` (headless, `-- --threats N …`), also runnable on device from the debug build's bench scene | CI: fail if x86 p95 > `bench/baseline.json` × 1.25; device: Gate 3 |
| render ms | ≤ 7 ms | ≤ 14 ms | custom monitor `cad/render_ms` = `Performance.TIME_PROCESS` − `cad/sim_ms` − `cad/ui_ms` | Gate 3 |
| UI ms | ≤ 2 ms | ≤ 4 ms | custom monitor `cad/ui_ms` (HUD/inspector update time) | Gate 3 |
| draw calls in WAVE | ≤ 120 | ≤ 120 | `Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME` | Gate 3; `cad_bench_render` prints it |
| hitches > 50 ms during WAVE | 0 | 0 | `CadFrameStats.hitch_count` | Gate 3 |
| RSS (TOTAL PSS) | ≤ 350 MB | ≤ 300 MB | `adb shell dumpsys meminfo com.djdanou.cad` | Gate 3 |
| static memory growth over 20-min soak | ≤ 5 % | ≤ 5 % | `Performance.MEMORY_STATIC` sampled every 60 s by `CadFrameStats` | Gate 3 (allocation-creep detector) |
| orphan nodes after TITLE→BUILD→WAVE→DEBRIEF→TITLE | 0 | 0 | `Performance.OBJECT_ORPHAN_NODE_COUNT` in `test/smoke/test_scene_flow.gd`; gdUnit4 orphan report | CI |
| install size | ≤ 80 MB | — | CI debug APK ≤ 90 MB proxy; Play Console app size report | CI |
| cold start | ≤ 4 s | ≤ 4 s | `adb shell am start -W -n com.djdanou.cad/com.godot.game.GodotApp` → `TotalTime` `[VERIFY]` | Gate 3 |
| thermal 20-min soak | minute-20 p95 ≤ 1.10 × minute-1 p95 | same | `CadFrameStats` per-minute p95 + `adb shell dumpsys thermalservice` + `adb shell dumpsys battery` (temperature) | Gate 3 |
| battery drain (20 min, 50 % brightness) | ≤ 12 % | ≤ 15 % | battery % before/after | Gate 3 informational until Beta, blocking from RC |

Benchmark assets: `scenes/bench/cad_bench_render.tscn` (CAD-FP-066), `tools/bench_runner.gd` (CAD-FP-041), `bench/baseline.json` (`{"godot":"4.7.2","runner":"ubuntu-latest","tick_p95_ms":…,"tick_mean_ms":…}` — updated only by a human commit after an accepted change), `test/fixtures/replays/wave12_seed42.json` (command log for the replay).

## D7 Repository directory tree

```
uavgamedev/
├── AGENTS.md                      # H1 — first file every agent reads
├── CLAUDE.md                      # byte-identical copy of AGENTS.md
├── project.godot                  # D1.1
├── export_presets.cfg             # D1.2 (no keystore fields)
├── .github/workflows/ci.yml       # D5.2
├── .gdlintrc  .editorconfig  .gitignore  .gitattributes
├── addons/gdUnit4/                # test framework, pinned (human-approved addon exception)
├── src/
│   ├── sim/                       # pure GDScript simulation (RefCounted only)
│   │   ├── cad_const.gd  cad_enums.gd  cad_rng.gd  cad_event_log.gd  cad_sim.gd
│   │   ├── store/                 # cad_threat_store.gd  cad_interceptor_store.gd  cad_emplacement.gd  cad_emplacement_store.gd  cad_district_state.gd  cad_doctrine.gd
│   │   ├── spatial/               # cad_spatial_hash.gd
│   │   ├── systems/               # cad_sensor_system.gd  cad_track_system.gd  cad_targeting.gd  cad_fire_control.gd  cad_interceptor_system.gd  cad_threat_motion.gd  cad_impact_system.gd  cad_ew_system.gd
│   │   ├── economy/               # cad_economy.gd  cad_income_report.gd
│   │   ├── waves/                 # cad_wave_generator.gd  cad_wave_plan.gd  cad_wave_director.gd
│   │   └── cmd/                   # cad_command.gd  cad_command_queue.gd
│   ├── data/                      # Resource schemas (D3.1)
│   ├── defs/                      # cad_defs.gd — loads .tres into typed registries, precomputes det_range tables
│   ├── save/                      # cad_save.gd  cad_save_migrations.gd
│   └── view/
│       ├── autoload/              # cad_events.gd  cad_app.gd
│       ├── driver/                # cad_sim_driver.gd  cad_frame_stats.gd
│       ├── world/                 # cad_camera.gd  cad_threat_view.gd  cad_interceptor_view.gd  cad_tracer_view.gd  cad_emplacement_view.gd  cad_radar_sweep_view.gd  cad_map_view.gd
│       ├── ui/                    # cad_hud.gd  cad_build_bar.gd  cad_placement_controller.gd  cad_inspector.gd  cad_build_phase.gd  cad_debrief.gd  cad_run_end.gd  cad_title.gd  cad_pause_menu.gd  cad_ui_scale.gd  cad_safe_area.gd  cad_strings.gd
│       ├── platform/              # cad_lifecycle.gd  (later: cad_ads.gd)
│       ├── audio/                 # cad_audio.gd  cad_music.gd
│       └── shaders/               # cad_icon.gdshader  cad_radar_sweep.gdshader  cad_range_ring.gdshader
├── scenes/
│   ├── app/                       # cad_boot.tscn  cad_app_root.tscn
│   ├── world/                     # cad_world.tscn  cad_emplacement_view.tscn
│   ├── ui/                        # cad_title.tscn  cad_campaign.tscn  cad_tech.tscn  cad_build_ui.tscn  cad_wave_ui.tscn  cad_debrief.tscn  cad_run_end.tscn  cad_pause_menu.tscn  cad_settings.tscn
│   └── bench/                     # cad_bench_render.tscn
├── data/
│   ├── csv/                       # balance source of truth (threats, emplacements, pk_table, packages, wave_phases_map_0N, tech, upgrades)
│   └── defs/                      # generated + committed .tres by kind: threats/ emplacements/ pk/ balance/ waves/ maps/ tech/ upgrades/ doctrine/ hints/
├── art/
│   ├── svg/                       # agent-authored sprites (source)
│   ├── atlas/                     # cad_atlas.png  cad_atlas_map.tres (generated, committed)
│   ├── icons/                     # app icon SVG + PNG exports
│   ├── fonts/                     # OFL font + licence
│   ├── AUTHORED.txt  LICENSES.md  # in-repo authorship list; third-party licence register
├── audio/                         # sfx/  music/  cad_bus_layout.tres
├── ui/
│   ├── theme/                     # cad_theme.tres  cad_palette.tres
│   └── strings/                   # cad_strings_en.csv
├── test/
│   ├── unit/                      # mirrors src/: unit/sim, unit/data, unit/view, unit/save
│   ├── scenario/                  # multi-system sim scenarios (determinism, cost exchange, economy examples, EW rates)
│   ├── smoke/                     # scene-load and scene-flow smoke tests (headless-safe)
│   ├── fixtures/                  # csv/, saves/, replays/, svg/
│   └── bench/                     # bench assertions (baseline comparison test)
├── tools/                         # csv_import/  validate_content.gd  check_scripts.gd  check_sim_purity.gd  atlas_build.gd  bench_runner.gd  balance/ (policies + runner)  *.sh *.cmd wrappers  check_16kb.sh
├── bench/baseline.json            # CI regression baseline (human-committed)
├── ai/                            # prompts/  handoffs/  logs/  metrics/  (H2–H4)
├── docs/
│   ├── production/                # this plan
│   ├── decisions/                 # ADR-nnn.md for human decisions (realism/fun, kill criteria outcomes)
│   ├── qa/                        # manual device scripts per milestone
│   ├── release/                   # closed-test log, store listing text, data-safety answers, privacy policy source
│   ├── store/                     # icon, feature graphic, screenshots
│   ├── devices.md  perf-log.md    # reference devices; every Gate-3 measurement
├── build/  reports/               # gitignored outputs
└── README.md
```
