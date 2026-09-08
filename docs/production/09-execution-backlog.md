# I. Execution Backlog

## I1 First Playable task cards (CAD-FP-001 … CAD-FP-069), ordered by dependency

Conventions used by every card:
- `tools/test.sh <path>` (CAD-FP-003) expands to `$GODOT_BIN --headless --path . -d -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a <path> -rd reports/gdunit`; exit 0 = green, 100 = failures, 101 = warnings.
- `STD-*` sets are defined in [07-task-card-template.md §7.2](07-task-card-template.md). LOC ceilings count implementation lines; each test file ≤ 150 LOC.
- Handoff path for every card is `/ai/handoffs/<ID>.md`, created from `/ai/handoffs/_TEMPLATE.md`; the state checklist is STD-HANDOFF plus the card's extra items.
- Data ids, numbers and pseudocode come from [01-design-bible.md](01-design-bible.md); class layout from [03-architecture.md](03-architecture.md). A card never restates a number that a table holds; it cites the table.
- All ids referenced in Dependencies exist in this file. Human cards keep every field.

---

### CAD-FP-001 — Install and verify the toolchain
- **ID:** CAD-FP-001 **Title:** Install and verify the toolchain
- **Milestone:** FP **Workstream:** ENG-PLAT **Owner:** human
- **Goal:** The human machine runs Godot 4.7.2 headless, exports Android debug APKs, runs gdtoolkit and adb, and documents it.
- **Scope:** local machine; `docs/toolchain.md` (new, ≤ 60 lines); no code.
- **Interface contract:** environment variable `GODOT_BIN` = absolute path to `Godot_v4.7.2-stable_win64_console.exe` (Windows) / `godot` (Linux); export templates installed for `4.7.2.stable`; JDK 17 at `JAVA_HOME`; Android SDK at `ANDROID_HOME` with `platform-tools`, `build-tools;35.0.1`, `platforms;android-35`, `platforms;android-36`, `cmdline-tools;latest` `[VERIFY versions against the 4.7 docs page on the day]`; `pip install gdtoolkit==4.5.0`.
- **Test-first:** `docs/toolchain.md` records the outputs of: `"$GODOT_BIN" --version` (contains `4.7.2.stable`), `java -version` (17.x), `sdkmanager --list_installed` (lists the packages above), `gdlint --version` (4.5.0), `gdformat --version`, `adb version`, `"$GODOT_BIN" --headless --quit` (exit 0). Each command's output is pasted verbatim.
- **Constraints:** no paid tools; no Android Studio required (SDK via cmdline-tools is enough); nothing from this card enters the repo except `docs/toolchain.md`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-001.md`; STD-HANDOFF items 1, 3, 4, 6 (human fills status, files, command outputs, next step).
- **Definition of Done:** STD-DOD not applicable (no code); `docs/toolchain.md` committed with all seven outputs; `GODOT_BIN` persisted in the user environment.
- **Verification gates:** none beyond the recorded outputs.
- **Dependencies:** none.
- **Effort:** 0 agent sessions × 120 human minutes.
- **Abandon criteria:** STD-ABANDON not applicable; if the Android SDK install exceeds 60 min, stop and install only JDK + Godot now (SDK is first needed by CAD-FP-065).
- **Prompt template:** none — human card.

---

### CAD-FP-002 — Repository scaffold and project.godot
- **ID:** CAD-FP-002 **Title:** Repository scaffold and project.godot
- **Milestone:** FP **Workstream:** ENG-PLAT **Owner:** agent
- **Goal:** The repo opens in Godot 4.7.2 headless without warnings, has the D7 directory tree, lint config, git hygiene files and a LOC counter.
- **Scope:** create `project.godot` (D1.1 without the `[autoload]` section and without `gui/theme/custom` — added by CAD-FP-042/047), `.gitignore`, `.gitattributes`, `.editorconfig`, `.gdlintrc`, `art/icons/cad_icon.svg` (64×64 friendly-cyan fan glyph, code-authored), every D7 directory with a `.gdkeep` file, `tools/loc.py` (≤ 60 LOC, stdlib only), `README.md` (replace the one-line stub with title, pointer to `AGENTS.md` and `docs/production/README.md`); LOC ≤ 60 (loc.py).
- **Interface contract:** `tools/loc.py <git-range> [--paths src tools scenes]` prints `impl=<n> test=<n>` counting added non-blank, non-comment lines of `.gd`/`.gdshader` under `src/ scenes/ tools/` as impl and under `test/` as test; exit 0. `.gdlintrc` values: `max-line-length: 100`, `max-file-lines: 400`, `function-name: ^_?[a-z][a-z0-9]*(_[a-z0-9]+)*$`, `class-name: ^Cad[A-Z][A-Za-z0-9]*$`, `disable: [no-elif-return, no-else-return]`, `excluded_directories: [addons, .godot]` `[VERIFY option names in gdtoolkit 4.5.0]`.
- **Test-first:** verification commands (no gdUnit4 yet). Run: `"$GODOT_BIN" --headless --path . --import` exits 0 and prints no line containing `WARNING` or `ERROR`; `gdlint tools` exits 0 on an empty tree; `python tools/loc.py HEAD~1..HEAD` prints `impl=` and `test=`; `git check-attr -a project.godot` shows `text` and `eol: lf`. Outputs pasted into the handoff.
- **Constraints:** STD-TOOL for loc.py; project settings exactly as D1.1 (any `[VERIFY]` key that Godot rejects on import is removed and reported in the handoff with the editor message, never replaced by a guess).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-002.md`; STD-HANDOFF + list of `[VERIFY]` keys confirmed/rejected.
- **Definition of Done:** STD-DOD (tests = the four verification commands); `--import` output attached.
- **Verification gates:** human opens the project in the editor once: Project Settings show Compatibility renderer, warnings set per A-10, viewport 1920×1080, orientation sensor landscape; no warning dialog.
- **Dependencies:** CAD-FP-001.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: agent adds any addon or changes the renderer; fallback: human writes `project.godot` from D1.1 by hand.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-003 — Install gdUnit4 and the test wrappers
- **ID:** CAD-FP-003 **Title:** Install gdUnit4 and the test wrappers
- **Milestone:** FP **Workstream:** ENG-PLAT **Owner:** agent
- **Goal:** `tools/test.sh <suite>` runs gdUnit4 headless and returns its exit code; a smoke suite proves it.
- **Scope:** vendor `addons/gdUnit4/` from the pinned release archive (version recorded in `addons/gdUnit4/VERSION.txt` and A-08 `[VERIFY latest 4.7-compatible tag]`; **explicit human permission for this addon is granted by this card**); create `tools/test.sh`, `tools/test.cmd`, `test/unit/test_cad_smoke.gd`, `reports/` in `.gitignore`; LOC ≤ 30 (wrappers + smoke).
- **Interface contract:** `tools/test.sh [suite_path]` → runs `"$GODOT_BIN" --headless --path . -d -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a ${1:-res://test} -rd reports/gdunit -c` and exits with gdUnit4's code; `tools/test.cmd` identical for `cmd.exe` using `%GODOT_BIN%`. `test/unit/test_cad_smoke.gd`: `extends GdUnitTestSuite`, `func test_smoke_true() -> void: assert_bool(true).is_true()`.
- **Test-first:** `tools/test.sh res://test/unit/test_cad_smoke.gd` exits 0 and `reports/gdunit/results.xml` exists; a temporary second test asserting `false` makes the exit code 100 (run once, output pasted, test removed before the PR).
- **Constraints:** addon files untouched (no local patches); `debug/gdscript/warnings/exclude_addons=true` must already be in `project.godot`; wrappers are POSIX sh / cmd only.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-003.md`; STD-HANDOFF + the gdUnit4 tag and archive SHA-256.
- **Definition of Done:** STD-DOD; both exit codes demonstrated in the handoff log.
- **Verification gates:** human confirms the addon version matches A-08 and that `git diff --stat` shows only `addons/gdUnit4/**`, the two wrappers, the smoke test and `.gitignore`.
- **Dependencies:** CAD-FP-002.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: headless run needs any flag beyond `--ignoreHeadlessMode` → record in A.0 and stop for a human check; fallback: human installs the addon from the editor's AssetLib.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-004 — Script typecheck and sim-purity gates
- **ID:** CAD-FP-004 **Title:** Script typecheck and sim-purity gates
- **Milestone:** FP **Workstream:** ENG-PLAT **Owner:** agent
- **Goal:** Two headless tools fail the build when any script has an error (including warnings-as-errors) or when `src/sim/` violates STD-SIM.
- **Scope:** `tools/check_scripts.gd`, `tools/lib/cad_purity_check.gd`, `tools/check_sim_purity.gd`, `tools/typecheck.sh/.cmd`, `tools/lint.sh/.cmd`, `test/unit/tools/test_cad_purity_check.gd`, fixtures `test/fixtures/purity/bad_sim.txt`, `good_sim.txt`; LOC ≤ 110.
- **Interface contract:**
  ```gdscript
  # tools/lib/cad_purity_check.gd
  class_name CadPurityCheck
  extends RefCounted
  const FORBIDDEN: PackedStringArray = ["extends Node", "get_tree(", "Timer", "await ", "signal ", "Engine.", "Time.", "OS.", "Input.", "randf(", "randi(", "preload(", "load(", "print("]
  static func scan_text(text: String) -> PackedStringArray   # returns "<line>:<token>" per violation, ascending line
  static func scan_dir(root: String) -> PackedStringArray    # "<path>:<line>:<token>", recursive over *.gd
  # tools/check_scripts.gd — extends SceneTree; loads every *.gd under res://src res://test res://tools res://scenes with ResourceLoader.load(); a null result or a script whose reload() != OK is a failure; prints "FAIL <path>" per failure and "OK <n> scripts" on success; quit(1|0)
  # tools/check_sim_purity.gd — extends SceneTree; root from user args (default res://src/sim); prints violations; quit(1 if any else 0)
  ```
- **Test-first:** `test/unit/tools/test_cad_purity_check.gd`: Given `bad_sim.txt` containing one line per forbidden token When `scan_text` Then 14 violations with correct line numbers; Given `good_sim.txt` (a valid RefCounted class using `RandomNumberGenerator` and Packed arrays) Then 0 violations; Given a token inside a comment line Then still reported (rule is textual, comments are not exempt). Run: `tools/test.sh res://test/unit/tools/test_cad_purity_check.gd`. Manual: `tools/typecheck.sh` exit 0 on the current repo; with a deliberately untyped `var x = 1` in a scratch script → exit 1 (pasted, then removed).
- **Constraints:** STD-TOOL; STD-TYPING; `check_scripts.gd` must not instantiate scenes; skip `addons/`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-004.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD; both negative demonstrations recorded.
- **Verification gates:** human runs `tools/typecheck.sh` and `"$GODOT_BIN" --headless --path . -s res://tools/check_sim_purity.gd`; reviews the FORBIDDEN list against STD-SIM.
- **Dependencies:** CAD-FP-003.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: `ResourceLoader.load` of a script with an error does not return null in 4.7 → agent records the actual behaviour and stops (human decides on `GDScript.new()` + `set_source_code` + `reload()` alternative).
- **Delivery note (2026-09-08):** the abandon clause above triggered and was resolved in-card rather than stopped, because the fix was one line: `load()` does return non-null for broken scripts, so the checker uses `script.reload() != OK`. Two further contract refinements were forced and are recorded in the handoff: `FORBIDDEN` is split into plain-substring tokens and global-form tokens (otherwise the legitimate `rng.randf(` and `preload(`/`load(` overlap produce false positives), and `scan_dir` takes an `extension` parameter so the fixtures can be scanned as `.txt`. `check_scripts.gd` skips its own path: self-loading with `CACHE_MODE_IGNORE` segfaults the engine.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-005 — GitHub Actions CI (lint, typecheck, import, tests)
- **ID:** CAD-FP-005 **Title:** GitHub Actions CI (lint, typecheck, import, tests)
- **Milestone:** FP **Workstream:** ENG-PLAT **Owner:** agent
- **Goal:** Every push and PR runs lint → format → typecheck → purity → import → gdUnit4 on GitHub's free tier with the Godot binary cached.
- **Scope:** `.github/workflows/ci.yml` (jobs `lint`, `test` per D5.2; `content`, `bench`, `android-debug` steps are added by CAD-FP-023/041/065); `docs/toolchain.md` section "CI"; no GDScript.
- **Delivery note (2026-09-08):** executed in two stages because the developer machine has no local Godot yet. **Stage 1 (done):** `lint` (gdlint/gdformat over existing `.gd` files, Python tool tests) and `engine` (pinned Godot download + `--import` must be warning-free + a report-only typing-gate probe). CI is therefore the verification environment for CAD-FP-002's blocked checks. **Stage 2 (after CAD-FP-003/004):** rename `engine` steps into the `test` job of D5.2 and add gdUnit4, typecheck and purity. The env var is `GDTOOLKIT_VERSION`/`GODOT_VERSION`; checksum pinning uses SHA-512 (see A.0).
- **Interface contract:** workflow env `GODOT_VERSION=4.7.2`, `GODOT_SHA256=<value>` (agent computes from the downloaded zip and records it; the human confirms against the release page), `GODOT_BIN=$HOME/.godot-bin/godot`; steps exactly as D5.2 `lint` and `test` (minus content/bench); artifacts `reports/`; concurrency group per branch with cancel-in-progress.
- **Test-first:** Run: push the branch — the PR's own workflow run is the test: `lint` and `test` jobs green; a temporary failing test on the branch turns `test` red (screenshot or log link pasted into the handoff, then removed); total runtime ≤ 7 min recorded.
- **Constraints:** only `actions/checkout@v4`, `actions/cache@v4`, `actions/setup-python@v5`, `actions/upload-artifact@v4` (A-32); pinned `gdtoolkit==4.5.0`; no secrets.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-005.md`; STD-HANDOFF + workflow run URLs (green and red).
- **Definition of Done:** STD-DOD; branch protection can require the `test` job (CAD-FP-006).
- **Verification gates:** human checks the SHA-256 against the release page and that no third-party action is used.
- **Dependencies:** CAD-FP-004.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: Godot download URL pattern differs → agent stops and reports the actual asset names from the release page.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-006 — GitHub protection and Play Console account
- **ID:** CAD-FP-006 **Title:** GitHub protection and Play Console account
- **Milestone:** FP **Workstream:** PROD **Owner:** human
- **Goal:** `main` cannot receive unreviewed code, and the Play developer account (with identity verification) exists early because its lead time is unknown.
- **Scope:** GitHub repo settings; Play Console; `docs/release/play-console.md` (account type, creation date, whether the 12-tester rule applies, developer name, contact email — no secrets).
- **Interface contract:** branch protection on `main`: require PR, require status check `test`, dismiss stale approvals, no force-push; Play Console: personal account under the developer's legal name, identity verification completed, app entry created with package name `com.djdanou.cad` (A-13, immutable — confirm the name before creating the app).
- **Test-first:** `git push origin main` from a local clone is rejected (output pasted); Play Console shows "verified" status; `docs/release/play-console.md` states the account creation date and the resulting closed-test obligation (A.0).
- **Constraints:** no credentials or account ids in the repo; the human enters payment details personally (never an agent).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-006.md`; STD-HANDOFF items 1, 3, 4, 6.
- **Definition of Done:** protection active; account verified or verification pending with the date logged; app entry created.
- **Verification gates:** none (human card).
- **Dependencies:** CAD-FP-005 (status check name must exist).
- **Effort:** 0 agent sessions × 90 human minutes (+ waiting time).
- **Abandon criteria:** not applicable; if verification is pending > 4 weeks, escalate via Play support and note the risk R-18.
- **Prompt template:** none — human card.

---

### CAD-FP-007 — Upload keystore generation and backup
- **ID:** CAD-FP-007 **Title:** Upload keystore generation and backup
- **Milestone:** FP **Workstream:** PROD **Owner:** human
- **Goal:** A release upload key exists in two safe places and nowhere near the repo or any agent.
- **Scope:** local secure folder; password manager; `docs/release/signing.md` (procedure only: alias, validity, backup locations by label, rotation note — no paths to secrets, no passwords).
- **Interface contract:** `keytool -genkeypair -v -keystore cad-upload.jks -alias cad-upload -keyalg RSA -keysize 2048 -validity 10000` with a ≥ 20-char password stored in the password manager; SHA-256 fingerprint (`keytool -list -v -keystore cad-upload.jks`) recorded in `docs/release/signing.md` (fingerprints are not secrets).
- **Test-first:** `keytool -list -v -keystore cad-upload.jks` prints the alias and fingerprint; the fingerprint matches the one in `docs/release/signing.md`; `git status` shows no `.jks`; `.gitignore` contains `*.jks` and `*.keystore` (from CAD-FP-002).
- **Constraints:** never in the repo, CI secrets, agent prompts, handoffs or logs (STD-HANDOFF item 3 must never list this file).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-007.md`; STD-HANDOFF items 1, 4, 6 (fingerprint only).
- **Definition of Done:** two backups verified by listing the keystore from each copy.
- **Verification gates:** none.
- **Dependencies:** CAD-FP-001.
- **Effort:** 0 agent sessions × 30 human minutes.
- **Abandon criteria:** not applicable.
- **Prompt template:** none — human card.

---

### CAD-FP-008 — Reference device setup and record
- **ID:** CAD-FP-008 **Title:** Reference device setup and record
- **Milestone:** FP **Workstream:** PROD **Owner:** human
- **Goal:** Both reference devices accept `adb install`, and their specs are on record for every later measurement.
- **Scope:** two phones; `docs/devices.md`.
- **Interface contract:** `docs/devices.md` table columns: label (low/mid), model, SoC, GPU, RAM, resolution, density (`adb shell wm density`), Android version (`adb shell getprop ro.build.version.release`), API level, serial (last 4 chars), notes; developer options + USB debugging enabled; `adb shell dumpsys thermalservice` returns data; screen timeout set to 10 min for soaks.
- **Test-first:** `adb devices` lists both serials as `device`; `adb shell wm size` and `wm density` outputs pasted for each.
- **Constraints:** devices match A-11 tiers; if not, record the deviation in A-11.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-008.md`; STD-HANDOFF items 1, 3, 4.
- **Definition of Done:** `docs/devices.md` committed; both devices connect.
- **Verification gates:** none.
- **Dependencies:** CAD-FP-001.
- **Effort:** 0 agent sessions × 45 human minutes.
- **Abandon criteria:** not applicable; missing device → procure per brief ("expandable") and log the date.
- **Prompt template:** none — human card.

---

### CAD-FP-009 — CadConst and CadEnums (sim contracts)
- **ID:** CAD-FP-009 **Title:** CadConst and CadEnums (sim contracts)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** All sim constants, capacities and enums exist in two files that every other sim card imports.
- **Scope:** `src/sim/cad_const.gd`, `src/sim/cad_enums.gd`, `test/unit/sim/test_cad_enums.gd`; LOC ≤ 110.
- **Interface contract:**
  ```gdscript
  class_name CadConst
  extends RefCounted
  const TICK_HZ: int = 30
  const TICK_DT: float = 1.0 / 30.0
  const MAX_TICKS_PER_FRAME: int = 6
  const MAX_THREATS: int = 512
  const MAX_INTERCEPTORS: int = 1024
  const MAX_EMPLACEMENTS: int = 64
  const MAX_DISTRICTS: int = 16
  const MAX_SENSORS: int = 32
  const EVENT_CAPACITY: int = 4096
  const SPATIAL_CELL_M: float = 500.0
  const QUERY_BUFFER: int = 512
  const INVALID: int = -1
  static func seconds_to_ticks(seconds: float) -> int   # ceil(seconds * TICK_HZ), 0 for <= 0

  class_name CadEnums
  extends RefCounted
  enum ThreatClass { RECON, FPV, OWA, CRUISE, SRBM, DECOY, JAMMER, SEAD, GLIDE }
  enum AltBand { LOW, MED, HIGH, BALLISTIC }                       # bit = 1 << value
  enum Guidance { SATNAV, DATALINK, INS, TERCOM, BALLISTIC, ANTI_RADIATION }
  enum TargetPref { DISTRICT_VALUE, DISTRICT_NEAREST, EMPLACEMENT_NEAREST, EMITTER_NEAREST, EMITTER_REVEALED, REVEAL_ORBIT, JAM_ORBIT, PASS_THROUGH }
  enum ThreatState { SPAWNED, INGRESS, TERMINAL, ORBIT, WANDER, CRASHED, KILLED, IMPACTED, EXITED }
  enum ThreatFlag { CLASSIFIED = 1, JAMMED = 2, REVEALER = 4 }
  enum EmpKind { SENSOR_SEARCH, SENSOR_FCR, SENSOR_PASSIVE, GUN_AAA, GUN_CIWS, LAUNCHER_SHORAD, LAUNCHER_MRSAM, LAUNCHER_LRSAM, LAUNCHER_UAV, EW_JAMMER, DECOY_EMITTER, C2_NODE, LOGISTICS, REPAIR, HARDENING }
  enum EmpState { PLACING, ACTIVE, RELOADING, RELOCATING, DESTROYED }
  enum Roe { HOLD, TIGHT, FREE }
  enum Priority { NEAREST_IMPACT, HIGHEST_VALUE, FASTEST, BEST_EXCHANGE }
  enum EngageMode { NONE, ORGANIC, CUED, TRACKED }
  enum InterceptorState { FLYING, RESOLVED }
  enum WaveState { IDLE, SPAWNING, ACTIVE, CLEARED, FAILED }
  enum GameState { BOOT, TITLE, CAMPAIGN, TECH, BUILD, WAVE, DEBRIEF, RUN_END, PAUSED }
  enum CommandType { PLACE, SELL, RELOCATE, UPGRADE, SET_DOCTRINE, RESTOCK, REPAIR_DISTRICT, REPAIR_EMPLACEMENT, MANUAL_FIRE, HARDEN_DISTRICT }
  enum CommandResult { OK, REJECTED_FUNDS, REJECTED_ZONE, REJECTED_OVERLAP, REJECTED_CAPACITY, REJECTED_STATE, REJECTED_TARGET, REJECTED_LOCKED }
  enum EventType { THREAT_SPAWNED, THREAT_DETECTED, THREAT_LOST, TRACK_ASSIGNED, TRACK_DROPPED, SHOT_FIRED, BURST_FIRED, INTERCEPT_HIT, INTERCEPT_MISS, THREAT_KILLED, THREAT_IMPACT, THREAT_CRASHED, THREAT_EXITED, DISTRICT_DAMAGED, EMPLACEMENT_DAMAGED, EMPLACEMENT_DESTROYED, LINK_LOST, LINK_REGAINED, WAVE_STARTED, WAVE_CLEARED, RUN_ENDED, FUNDS_CHANGED, COMMAND_RESULT, RELOAD_STARTED, RELOAD_DONE }
  enum TechEffect { UNLOCK_EMPLACEMENT, STAT_MULT, STAT_ADD, PK_ADD, CONFIG_ADD, CONFIG_MULT, DOCTRINE_UNLOCK }
  enum RngStream { WAVEGEN, COMBAT, MOTION }
  enum TargetKind { NONE, DISTRICT, EMPLACEMENT, POINT }
  static func band_bit(band: int) -> int
  ```
- **Test-first:** `test/unit/sim/test_cad_enums.gd`: `test_enum_sizes_match_design` (ThreatClass 9, EmpKind 15, EventType 25, GameState 9, CommandType 10); `test_band_bit` (LOW→1, BALLISTIC→8); `test_seconds_to_ticks` (2.0→60, 0.033→1, 0→0, −1→0); `test_tick_dt` (TICK_DT × TICK_HZ == 1.0 within 1e-9); `test_capacities_positive`. Run: `tools/test.sh res://test/unit/sim/test_cad_enums.gd`.
- **Constraints:** STD-TYPING, STD-SIM; enum member order is a contract (saved as ints) — appending only, never reordering, from this card on.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-009.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human diffs the enums against B.12/D2.7/B.2 names; confirms `AGENTS.md §3` enum digest is updated in the same PR.
- **Dependencies:** CAD-FP-003.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON; fallback: human pastes the contract as the file (it is the file).
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-010 — CadRng seeded multi-stream RNG
- **ID:** CAD-FP-010 **Title:** CadRng seeded multi-stream RNG
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** The sim draws all randomness from three independently seeded, save/restorable streams.
- **Scope:** `src/sim/cad_rng.gd`, `test/unit/sim/test_cad_rng.gd`; LOC ≤ 60.
- **Interface contract:**
  ```gdscript
  class_name CadRng
  extends RefCounted
  var seed_value: int
  var _streams: Array[RandomNumberGenerator]    # size CadEnums.RngStream.size(); stream s seeded seed_value + s
  func _init(seed: int) -> void
  func randf(stream: int) -> float                              # [0, 1)
  func randf_range(stream: int, from: float, to: float) -> float
  func randi_range(stream: int, from: int, to: int) -> int      # inclusive
  func chance(stream: int, p: float) -> bool                    # p <= 0.0 → false without drawing; p >= 1.0 → true without drawing
  func get_state(stream: int) -> int
  func set_state(stream: int, state: int) -> void
  func get_states() -> PackedInt64Array
  func set_states(states: PackedInt64Array) -> void
  ```
- **Test-first:** `test_same_seed_same_sequence` (1,000 draws per stream equal across two instances), `test_streams_independent` (100 draws on WAVEGEN do not change the next COMBAT value), `test_state_roundtrip` (get/set state reproduces the next 50 values), `test_chance_extremes` (p=0 never true and consumes no state; p=1 always true and consumes no state), `test_randi_range_inclusive_bounds` (10,000 draws in [3, 5] hit both 3 and 5, never outside), `test_states_array_size` (3). Run: `tools/test.sh res://test/unit/sim/test_cad_rng.gd`.
- **Constraints:** STD-TYPING, STD-SIM; no global `randomize()`; `RandomNumberGenerator.seed` and `.state` only.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-010.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks `chance()` consumes no draw at the extremes (determinism of downstream streams).
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 6 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-011 — CadEventLog ring buffer
- **ID:** CAD-FP-011 **Title:** CadEventLog ring buffer
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Sim events are recorded allocation-free in fixed Packed arrays and hashed for golden tests.
- **Scope:** `src/sim/cad_event_log.gd`, `test/unit/sim/test_cad_event_log.gd`; LOC ≤ 70.
- **Interface contract:**
  ```gdscript
  class_name CadEventLog
  extends RefCounted
  var capacity: int
  var count: int
  var dropped: int
  var _type: PackedInt32Array
  var _a: PackedInt32Array
  var _b: PackedInt32Array
  var _c: PackedInt32Array
  var _x: PackedFloat32Array
  var _y: PackedFloat32Array
  func _init(capacity: int = CadConst.EVENT_CAPACITY) -> void
  func push(type: int, a: int, b: int, c: int, x: float, y: float) -> void   # full → dropped += 1, nothing stored
  func type_at(i: int) -> int
  func a_at(i: int) -> int
  func b_at(i: int) -> int
  func c_at(i: int) -> int
  func x_at(i: int) -> float
  func y_at(i: int) -> float
  func count_of_type(type: int) -> int
  func clear() -> void                 # count = 0, dropped = 0; arrays keep their size
  func hash_contents() -> int          # hash over the used range of all six arrays
  ```
- **Test-first:** `test_push_and_read`, `test_capacity_and_dropped` (capacity 4, push 6 → count 4, dropped 2), `test_clear_keeps_capacity` (`_type.size()` unchanged), `test_hash_equal_for_same_sequence`, `test_hash_differs_for_different_sequence`, `test_count_of_type`, `test_arrays_never_resize` (size before == size after 2 × capacity pushes). Run: `tools/test.sh res://test/unit/sim/test_cad_event_log.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `push` is a tick-path function (no allocation, no branching on strings).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-011.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks `hash_contents()` uses only the used range (0..count).
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 6 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-012 — CadThreatStore (struct-of-arrays)
- **ID:** CAD-FP-012 **Title:** CadThreatStore (struct-of-arrays)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Threat entities live in preallocated Packed arrays with a free list and a deterministic alive index list.
- **Scope:** `src/sim/store/cad_threat_store.gd`, `test/unit/sim/test_cad_threat_store.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadThreatStore
  extends RefCounted
  var capacity: int
  var alive: PackedInt32Array          # ascending alive indices after rebuild_alive()
  var alive_count: int
  var def_index: PackedInt32Array
  var state: PackedInt32Array          # CadEnums.ThreatState
  var pos_x: PackedFloat32Array
  var pos_y: PackedFloat32Array
  var prev_x: PackedFloat32Array
  var prev_y: PackedFloat32Array
  var vel_x: PackedFloat32Array
  var vel_y: PackedFloat32Array
  var alt_m: PackedFloat32Array
  var hp: PackedFloat32Array
  var value: PackedInt32Array          # CR value for doctrine
  var target_kind: PackedInt32Array    # CadEnums.TargetKind
  var target_id: PackedInt32Array
  var target_x: PackedFloat32Array
  var target_y: PackedFloat32Array
  var detect_ticks_left: PackedInt32Array
  var track_owner: PackedInt32Array    # emplacement index or -1
  var track_age: PackedInt32Array
  var engaged_by: PackedInt32Array
  var flags: PackedInt32Array          # CadEnums.ThreatFlag bits
  var state_ticks: PackedInt32Array
  var spawn_tick: PackedInt32Array
  var eccm_level: PackedInt32Array
  var package_id: PackedInt32Array
  var _free: PackedInt32Array
  var _free_count: int
  var _alive_flag: PackedByteArray
  func _init(capacity: int = CadConst.MAX_THREATS) -> void
  func alloc(def_idx: int, x: float, y: float, alt: float, hp0: float, value0: int, tick: int) -> int   # lowest free index; -1 when full; resets every field of the slot (state SPAWNED, track_owner -1, target_kind NONE, flags 0)
  func release(i: int) -> void
  func is_alive(i: int) -> bool
  func rebuild_alive() -> void
  func snapshot_prev() -> void        # prev ← pos for alive slots
  func clear_all() -> void
  ```
- **Test-first:** `test_alloc_lowest_free_index` (0, 1, 2), `test_release_and_reuse` (release 1 → next alloc returns 1), `test_full_returns_minus_one` (capacity 3), `test_alloc_resets_fields` (dirty a released slot's hp/track_owner/flags then alloc → hp0, −1, 0), `test_rebuild_alive_ascending_after_random_pattern` (seeded pattern of 200 allocs/100 releases → `alive` strictly ascending and `alive_count` equals live slots), `test_snapshot_prev_copies_alive_only`, `test_arrays_never_resize`. Run: `tools/test.sh res://test/unit/sim/test_cad_threat_store.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `alloc`/`release`/`rebuild_alive`/`snapshot_prev` are tick-path (no allocation); the free list is a stack in a Packed array, but `alloc` must return the **lowest** free index — implement by scanning `_alive_flag` from a cached `_lowest_free_hint` (amortised O(1)).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-012.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks no `Array` or `Dictionary` appears in the file; `rebuild_alive` is O(capacity).
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: agent proposes an `Array[CadThreat]` object layout → stop (A-04); fallback: human writes the store from the contract.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-013 — CadInterceptorStore (struct-of-arrays)
- **ID:** CAD-FP-013 **Title:** CadInterceptorStore (struct-of-arrays)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** In-flight guided interceptors are stored like threats, with launch and resolution metadata.
- **Scope:** `src/sim/store/cad_interceptor_store.gd`, `test/unit/sim/test_cad_interceptor_store.gd`; LOC ≤ 90.
- **Interface contract:**
  ```gdscript
  class_name CadInterceptorStore
  extends RefCounted
  var capacity: int
  var alive: PackedInt32Array
  var alive_count: int
  var launcher_index: PackedInt32Array
  var target_threat: PackedInt32Array
  var weapon_def: PackedInt32Array      # emplacement def index
  var state: PackedInt32Array           # CadEnums.InterceptorState
  var pos_x: PackedFloat32Array
  var pos_y: PackedFloat32Array
  var prev_x: PackedFloat32Array
  var prev_y: PackedFloat32Array
  var speed_mps: PackedFloat32Array
  var pk: PackedFloat32Array
  var launch_tick: PackedInt32Array
  var resolve_tick: PackedInt32Array
  func _init(capacity: int = CadConst.MAX_INTERCEPTORS) -> void
  func alloc(launcher: int, target: int, weapon: int, x: float, y: float, speed: float, pk0: float, tick: int, resolve: int) -> int
  func release(i: int) -> void
  func is_alive(i: int) -> bool
  func rebuild_alive() -> void
  func snapshot_prev() -> void
  func clear_all() -> void
  func count_for_launcher(launcher: int) -> int     # over alive
  ```
- **Test-first:** same five structural tests as CAD-FP-012 adapted, plus `test_count_for_launcher` (3 allocs for launcher 2, 1 for launcher 5 → 3 and 1). Run: `tools/test.sh res://test/unit/sim/test_cad_interceptor_store.gd`.
- **Constraints:** STD-TYPING, STD-SIM; same free-list discipline as CAD-FP-012 (lowest free index).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-013.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks field parity with D2.3.
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 6 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-014 — CadSpatialHash uniform grid
- **ID:** CAD-FP-014 **Title:** CadSpatialHash uniform grid
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Circle queries over up to 512 threats run through a counting-sort grid without allocating.
- **Scope:** `src/sim/spatial/cad_spatial_hash.gd`, `test/unit/sim/test_cad_spatial_hash.gd`; LOC ≤ 110.
- **Interface contract:**
  ```gdscript
  class_name CadSpatialHash
  extends RefCounted
  var cells_x: int
  var cells_y: int
  var cell_size: float
  var origin_x: float
  var origin_y: float
  var max_items: int
  var cell_start: PackedInt32Array     # size cells_x * cells_y + 1 (prefix sums)
  var cell_items: PackedInt32Array     # size max_items
  var _cell_of_item: PackedInt32Array
  var _counts: PackedInt32Array
  var _n: int
  func _init(world_min: Vector2, world_max: Vector2, cell_m: float, max_items: int) -> void
  func cell_of(x: float, y: float) -> int                        # clamped into the grid
  func rebuild(xs: PackedFloat32Array, ys: PackedFloat32Array, indices: PackedInt32Array, n: int) -> void   # indices[0..n) are entity ids; positions read from xs/ys
  func query_circle(cx: float, cy: float, r: float, xs: PackedFloat32Array, ys: PackedFloat32Array, out: PackedInt32Array) -> int   # exact dist² ≤ r² filter; writes into out (pre-sized), returns count; visits cells in ascending index order and items in bucket order
  func item_count() -> int
  ```
- **Test-first:** `test_matches_brute_force` (seeded 500 points in a 20,000 × 12,000 world, 50 random circles r ∈ [200, 8,000] → identical sets), `test_out_of_bounds_points_clamped_and_found`, `test_zero_radius_returns_coincident_only`, `test_out_written_in_place_no_resize` (`out.size()` unchanged; values present), `test_rebuild_twice_same_order` (two identical rebuilds → identical `cell_items`), `test_empty_rebuild_query_zero`. Run: `tools/test.sh res://test/unit/sim/test_cad_spatial_hash.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `rebuild` and `query_circle` are tick-path; `out` is filled by index writes (Packed arrays are passed by reference `[VERIFY: the in-place test proves it]`); cell scan limited to the circle's bounding box.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-014.md`; STD-HANDOFF + the measured brute-force test runtime.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human reads the prefix-sum scatter for off-by-one at cell boundaries; confirms no `Vector2` temporaries inside the item loop.
- **Dependencies:** CAD-FP-009.
- **Effort:** 1–2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: brute-force test still failing after 2 attempts; fallback: human writes the counting sort (≈ 40 LOC).
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-015 — CadThreatDef resource schema
- **ID:** CAD-FP-015 **Title:** CadThreatDef resource schema
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** Threat archetypes are typed Resources with validation, matching table B.2 field for field.
- **Scope:** `src/data/cad_threat_def.gd`, `test/unit/data/test_cad_threat_def.gd`; LOC ≤ 60.
- **Interface contract:** fields exactly as D3.1 `CadThreatDef` (types, defaults, order) plus `func validate() -> PackedStringArray` returning messages for: `id` empty, `cost < 0`, `hp <= 0`, `speed_mps <= 0`, `rcs_m2 <= 0`, `intro_wave < 1`, `apparent_rcs_m2 < 0`, `jam_radius_m > 0 and jam_strength <= 0`.
- **Test-first:** `test_defaults` (schema_version 1, salvage_mult 1.0, eccm_level 0), `test_validate_flags_each_rule` (parameterised over 8 bad inputs, each yields exactly one message containing the field name), `test_tres_roundtrip` (`ResourceSaver.save` to `user://t/threat.tres`, load with `ResourceLoader.CACHE_MODE_IGNORE` → all fields equal, enums preserved). Run: `tools/test.sh res://test/unit/data/test_cad_threat_def.gd`.
- **Constraints:** STD-TYPING, STD-DATA; enum fields typed `CadEnums.ThreatClass` etc.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-015.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD; B.14 row unchanged.
- **Verification gates:** human compares field list with B.2 header (23 fields).
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 6 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-016 — CadEmplacementDef resource schema
- **ID:** CAD-FP-016 **Title:** CadEmplacementDef resource schema
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** Emplacement archetypes are typed Resources covering sensors, shooters and support kinds (B.3).
- **Scope:** `src/data/cad_emplacement_def.gd`, `test/unit/data/test_cad_emplacement_def.gd`; LOC ≤ 90.
- **Interface contract:** fields exactly as D3.1 `CadEmplacementDef`; `func covers(band: int) -> bool` (bitmask test via `CadEnums.band_bit`); `func is_sensor() -> bool` (kind in SENSOR_*), `is_shooter() -> bool` (GUN_*, LAUNCHER_*), `is_ew() -> bool`, `is_support() -> bool`; `func validate() -> PackedStringArray` for: `range_min_m >= range_max_m` when shooter, `is_gun and interceptor_speed_mps != 0`, `not is_gun and is_shooter() and interceptor_speed_mps <= 0`, `channels < 1`, `ammo_capacity <= 0` for shooters, `cost < 0`, `hp <= 0` unless kind HARDENING, `track_capacity > 0` only for SENSOR_FCR.
- **Test-first:** `test_covers_bitmask` (LOW|MED covers LOW and MED, not HIGH), `test_kind_predicates` (one per group), `test_validate_rules` (parameterised), `test_tres_roundtrip`. Run: `tools/test.sh res://test/unit/data/test_cad_emplacement_def.gd`.
- **Constraints:** STD-TYPING, STD-DATA.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-016.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human compares with B.3.1–B.3.3 columns (every column has a field).
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-017 — CadPkTable resource and matrix builder
- **ID:** CAD-FP-017 **Title:** CadPkTable resource and matrix builder
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** The Pk matrix is a Resource keyed by ids and can be re-indexed into the sim's integer def space.
- **Scope:** `src/data/cad_pk_table.gd`, `test/unit/data/test_cad_pk_table.gd`; LOC ≤ 70.
- **Interface contract:**
  ```gdscript
  class_name CadPkTable
  extends Resource
  @export var schema_version: int = 1
  @export var weapon_ids: Array[StringName]
  @export var threat_ids: Array[StringName]
  @export var pk: PackedFloat32Array                 # row-major weapons × threats
  func index_of_weapon(id: StringName) -> int         # -1 if absent
  func index_of_threat(id: StringName) -> int
  func pk_for(weapon_i: int, threat_i: int) -> float  # 0.0 when out of range
  func validate() -> PackedStringArray               # size mismatch, values outside [0,1], duplicate ids
  func build_matrix(weapon_order: Array[StringName], threat_order: Array[StringName], missing: PackedStringArray) -> PackedFloat32Array   # re-indexed matrix; appends "weapon/threat" to missing for absent pairs (value 0.0)
  ```
- **Test-first:** `test_lookup_by_ids` (B.4: shorad×owa 0.75, aaa×srbm 0.0), `test_missing_pair_reported` (matrix value 0.0 and one entry in `missing`), `test_validate_size_mismatch`, `test_validate_value_range`, `test_build_matrix_reorders` (reversed orders → transposed positions). Run: `tools/test.sh res://test/unit/data/test_cad_pk_table.gd`.
- **Constraints:** STD-TYPING, STD-DATA; `build_matrix` runs at load only (allocation allowed there).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-017.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks row-major convention matches `CadDefs.pk_for` (CAD-FP-021).
- **Dependencies:** CAD-FP-015, CAD-FP-016.
- **Effort:** 1 agent session × 6 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-018 — CadMapDef and CadDistrictDef schemas
- **ID:** CAD-FP-018 **Title:** CadMapDef and CadDistrictDef schemas
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** Maps and districts are typed Resources with geometry validation.
- **Scope:** `src/data/cad_map_def.gd`, `src/data/cad_district_def.gd`, `test/unit/data/test_cad_map_def.gd`; LOC ≤ 80.
- **Interface contract:** fields exactly as D3.1 (`wave_rules: CadWaveRules` and `hint_rules: CadHintRules` typed to classes created in CAD-FP-019/020 — this card declares them as `Resource` and CAD-FP-019/020 retype them in their own diffs); `CadDistrictDef.validate() -> PackedStringArray` (polygon < 3 points, `center` outside polygon via `Geometry2D.is_point_in_polygon`, `value_per_wave <= 0`, `max_hp <= 0`); `CadMapDef.validate()` (world_min < world_max on both axes, `threat_axis` not zero and normalised within 1e-3, spawn line endpoints inside world bounds, no district ids duplicated, `districts.size() <= CadConst.MAX_DISTRICTS`, `final_wave >= 1`, `starting_funds >= 0`, `build_zones` non-empty); `func point_in_build_zone(p: Vector2) -> bool` (inside any build zone and outside every no-build zone).
- **Test-first:** `test_district_validate_rules` (parameterised), `test_map_validate_rules` (parameterised), `test_point_in_build_zone` (inside, outside, inside-but-excluded), `test_tres_roundtrip_with_inline_districts`. Run: `tools/test.sh res://test/unit/data/test_cad_map_def.gd`.
- **Constraints:** STD-TYPING, STD-DATA; `point_in_build_zone` is called at command time only (not tick-path).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-018.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks B.8 columns ↔ fields.
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-019 — Wave rules, phase and package schemas
- **ID:** CAD-FP-019 **Title:** Wave rules, phase and package schemas
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** Wave generation parameters (B.7) are typed Resources with the budget and window formulas as pure methods.
- **Scope:** `src/data/cad_wave_rules.gd`, `src/data/cad_wave_phase.gd`, `src/data/cad_package_def.gd`, retype `CadMapDef.wave_rules` to `CadWaveRules`, `test/unit/data/test_cad_wave_rules.gd`; LOC ≤ 90.
- **Interface contract:** fields exactly as D3.1; `CadWaveRules.budget(wave: int, map_mult: float, final_wave: int) -> float` = `(budget_base + budget_linear × w + budget_quad × w²) × map_mult × (final_wave_budget_mult if w == final_wave else 1.0)`; `spawn_window_s(wave: int) -> float` = `clamp(base + per_wave × w, base, max)`; `phase_for_wave(wave: int) -> CadWavePhase` (null if none); `validate() -> PackedStringArray` (phase gaps/overlaps over 1..final_wave passed as argument, weights size ≠ ids size, `fill_min > fill_max`, package `entry_min > entry_max`, empty entries).
- **Test-first:** `test_budget_values` (B.6: w1 654, w10 2,400, w20 5,100, w30 12,900 with final_wave 30), `test_spawn_window` (w1 66, w30 240, w40 240), `test_phase_lookup_and_gaps` (phases 1–3 and 5–6 → CV008-style message for wave 4), `test_package_validate`, `test_tres_roundtrip`. Run: `tools/test.sh res://test/unit/data/test_cad_wave_rules.gd`.
- **Constraints:** STD-TYPING, STD-DATA.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-019.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the budget formula against B.6 and the ×1.5 final-wave rule.
- **Dependencies:** CAD-FP-015, CAD-FP-018.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-020 — Balance config, doctrine preset and hint schemas
- **ID:** CAD-FP-020 **Title:** Balance config, doctrine preset and hint schemas
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** Global balance constants, per-kind doctrine defaults and hint rules are typed Resources with tick-converted accessors.
- **Scope:** `src/data/cad_balance_config.gd`, `src/data/cad_doctrine_preset.gd`, `src/data/cad_hint_rules.gd`, retype `CadMapDef.hint_rules`, `test/unit/data/test_cad_balance_config.gd`; LOC ≤ 90.
- **Interface contract:** fields exactly as D3.1 for the three classes; `CadBalanceConfig` adds derived tick accessors computed by `func bake() -> void`: `detection_persist_ticks: int`, `decoy_classify_ticks: int`, `manual_fire_cooldown_ticks: int`, `relocate_penalty_ticks: int` (via `CadConst.seconds_to_ticks`); `func quality(damage_this_wave: float) -> float` = `clamp(1 − damage / bonus_damage_denominator, 0, 1)`; `func wave_bonus(wave: int, damage_this_wave: float) -> int` = `int((bonus_base + bonus_per_wave × wave) × quality)`; `CadDoctrinePreset.to_values(out: PackedInt32Array) -> void` (roe, priority, min_threat_value, salvo, reengage as 0/1).
- **Test-first:** `test_defaults_match_design` (salvage 0.15, denominator 200, organic 0.6, cued 0.75), `test_bake_ticks` (2.0 s → 60, 8.0 → 240, 3.0 → 90, 20.0 → 600), `test_quality_and_bonus` (wave 1 dmg 40 → 208; wave 20 dmg 480 → 0; wave 30 dmg 40 → 1,600), `test_preset_to_values`, `test_hint_rules_roundtrip`. Run: `tools/test.sh res://test/unit/data/test_cad_balance_config.gd`.
- **Constraints:** STD-TYPING, STD-DATA (bake() is the only method with state, called once at load).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-020.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the bonus numbers reproduce B.6.
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 6 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-021 — CadDefs registry with precomputed tables
- **ID:** CAD-FP-021 **Title:** CadDefs registry with precomputed tables
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** All `.tres` definitions load once into index-addressed typed arrays with the Pk matrix, detection-range tables and tick conversions precomputed.
- **Scope:** `src/defs/cad_defs.gd`, `test/unit/data/test_cad_defs.gd`, fixtures `test/fixtures/defs/` (2 threats, 3 emplacements, 1 pk table, 1 balance config, 1 map, 3 doctrine presets); LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadDefs
  extends RefCounted
  var threats: Array[CadThreatDef]                 # sorted by id; index = def_index
  var emplacements: Array[CadEmplacementDef]       # sorted by id
  var threat_index: Dictionary[StringName, int]
  var emp_index: Dictionary[StringName, int]
  var pk: PackedFloat32Array                       # [emp_i * threats.size() + thr_i]
  var det_range_apparent: PackedFloat32Array       # [emp_i * threats.size() + thr_i], metres, 0 for non-sensors
  var det_range_true: PackedFloat32Array
  var shot_interval_ticks: PackedInt32Array        # per emplacement def
  var reload_ticks: PackedInt32Array
  var wander_ticks: PackedInt32Array               # per threat def
  var orbit_ticks: PackedInt32Array
  var balance: CadBalanceConfig
  var doctrine_presets: Array[CadDoctrinePreset]   # index = EmpKind; missing kinds → a default preset
  var maps: Dictionary[StringName, CadMapDef]
  var load_errors: PackedStringArray
  static func load_from(root: String = "res://data/defs") -> CadDefs   # never null; errors in load_errors
  func pk_for(emp_i: int, thr_i: int) -> float
  func det_range(emp_i: int, thr_i: int, classified: bool) -> float
  func precompute() -> void            # radar equation R = ref × (rcs/ref_rcs)^0.25 for apparent and true RCS
  ```
- **Test-first:** `test_sorted_indices_stable` (ids sorted; `threat_index` consistent), `test_pk_reindexed` (fixture pk table listed in a different order → `pk_for` returns the id-based values), `test_det_range_quarter_power` (ref 15,000, rcs 0.05 → 7,093 ± 1; rcs 1.0 → 15,000; non-sensor → 0), `test_tick_conversions` (shot 1.5 s → 45, reload 8 s → 240), `test_missing_dir_reports_error` (root `res://nope` → `load_errors.size() > 0`, arrays empty), `test_default_preset_for_missing_kind`. Run: `tools/test.sh res://test/unit/data/test_cad_defs.gd`.
- **Constraints:** STD-TYPING; this is the only sim-facing file allowed to call `ResourceLoader`/`DirAccess` (STD-SIM purity roots exclude `src/defs/`); all `pow()` happens here.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-021.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the ¼-power and that `det_range_true` differs from apparent only for decoys.
- **Dependencies:** CAD-FP-015, CAD-FP-016, CAD-FP-017, CAD-FP-018, CAD-FP-019, CAD-FP-020.
- **Effort:** 1–2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: agent proposes lazy loading during ticks → stop.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-022 — CSV → .tres importer (non-destructive)
- **ID:** CAD-FP-022 **Title:** CSV → .tres importer (non-destructive)
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** Balance CSVs become typed `.tres` files, writing only files whose bytes change.
- **Scope:** `tools/lib/cad_csv_import.gd`, `tools/csv_import/cad_csv_import.gd` (runner), `tools/import_csv.sh/.cmd`, `test/unit/tools/test_cad_csv_import.gd`, fixtures `test/fixtures/csv/threats_ok.csv`, `threats_bad_column.csv`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadCsvImport
  extends RefCounted
  static func parse_rows(text: String) -> Array[PackedStringArray]           # RFC-4180 subset: comma, double quotes, no embedded newlines
  static func apply_row(res: Resource, header: PackedStringArray, row: PackedStringArray) -> PackedStringArray   # errors: "CSV001 unknown column <name>", "CSV002 bad value <col>=<v>"; typed conversion by get_property_list(): int, float, bool, String, StringName, enum (name → CadEnums lookup), Array[StringName] ('a|b'), bitmask ('LOW|MED'), PackedInt32Array ('1|2'), PackedFloat32Array
  static func write_if_changed(res: Resource, path: String) -> String         # "wrote" | "unchanged" | "error <msg>": saves to user://tmp/<name>.tres, compares bytes with path, copies on difference
  # runner: -- --in <csv> --schema <ClassName> --out <dir>; one resource per row named <id>.tres; prints one line per row; quit(1) on any error
  ```
- **Test-first:** `test_parse_quoted_fields`, `test_apply_row_types` (int/float/bool/enum/list/bitmask from `threats_ok.csv`), `test_unknown_column_error` (`threats_bad_column.csv` → CSV001), `test_write_if_changed_twice` (first "wrote", second "unchanged", file mtime unchanged), `test_runner_headless_end_to_end` (runs the runner via `OS.execute($GODOT_BIN …)` on the fixture into `user://out/` → 2 files `[VERIFY OS.execute with the Godot binary works in the test environment; otherwise call the lib directly]`). Run: `tools/test.sh res://test/unit/tools/test_cad_csv_import.gd`.
- **Constraints:** STD-TOOL, STD-TYPING; the only place `set()` by string is allowed (STD-TYPING exception); never deletes.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-022.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human runs the importer twice on `data/csv/` (after CAD-FP-024) and confirms `git status` clean on the second run (non-destructive proof).
- **Dependencies:** CAD-FP-021.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: `.tres` byte comparison unstable (Godot writes non-deterministic ids) → agent reports and stops; fallback: compare after stripping `uid=` lines.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-023 — Content validator (CV rules) and CI job
- **ID:** CAD-FP-023 **Title:** Content validator (CV rules) and CI job
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** Broken or inconsistent content fails CI with a `CVnnn` line naming the file.
- **Scope:** `tools/lib/cad_content_validator.gd`, `tools/validate_content.gd` (runner), `tools/validate.sh/.cmd`, `test/unit/tools/test_cad_content_validator.gd`, fixtures `test/fixtures/defs_bad/<case>/`, `.github/workflows/ci.yml` (+ `content` step in `test` job); LOC ≤ 120.
- **Interface contract:** `class_name CadContentValidator extends RefCounted`; `static func validate(root: String) -> PackedStringArray` implementing D3.4 rules CV001, CV002, CV003, CV004, CV006, CV007, CV008, CV009, CV010, CV011, CV013 (CV005 added by CAD-FP-046, CV012 by CAD-FP-047), each line `CVnnn <res path> <detail>`; runner prints lines and `OK`/`FAIL <n>`, quit code accordingly; reserved tech id `&"locked"` is valid for `tech_required`.
- **Test-first:** one test per rule using a bad fixture directory (`test_cv001_duplicate_id`, …, `test_cv013_missing_preset`), `test_good_fixture_passes` (uses `test/fixtures/defs/`), `test_locked_tech_id_allowed`. Run: `tools/test.sh res://test/unit/tools/test_cad_content_validator.gd`.
- **Constraints:** STD-TOOL, STD-TYPING; reuses `CadDefs.load_from(root)` and the schemas' `validate()`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-023.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD; CI `content` step green on `test/fixtures/defs/` and on `data/defs/` once CAD-FP-024 lands.
- **Verification gates:** human reads each rule against D3.4.
- **Dependencies:** CAD-FP-021, CAD-FP-022.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-024 — First Playable content (CSVs, defs, map 1, waves 1–5)
- **ID:** CAD-FP-024 **Title:** First Playable content (CSVs, defs, map 1, waves 1–5)
- **Milestone:** FP **Workstream:** CON **Owner:** agent
- **Goal:** All B.2–B.8 data exists as CSV + generated `.tres`, with non-FP emplacements locked, and map 1 authored.
- **Scope:** `data/csv/threats.csv` (9 rows), `emplacements.csv` (15 rows; `tech_required=locked` for every kind except search radar, AAA, SHORAD), `pk_table.csv`, `packages.csv` (7), `wave_phases_map_01.csv` (6); generated `data/defs/{threats,emplacements,pk,doctrine}/…`, `data/defs/balance/cad_balance_config.tres`, `data/defs/waves/map_01_rules.tres`, `data/defs/maps/map_01.tres` (B.8 districts as inline sub-resources with rectangular-ish polygons ≥ 6 points each, build zones, no-build strip), `test/unit/data/test_cad_content_fp.gd`; no GDScript LOC (data only).
- **Interface contract:** ids exactly as B.2/B.3/B.7/B.8; numeric values exactly as the tables; `CadMapDef.threat_axis = (−1, 0)`, spawn line (9,800, −5,500)→(9,800, 5,500); `wave_rules` per B.7 phase table with the fill rules' constants from D3.1 defaults.
- **Test-first:** `test_validator_passes_on_data_defs`, `test_sample_values` (owa cost 100 & speed 50; shorad range_max 6,000 & ammo_cost 60; pk shorad×owa 0.75; aaa×cruise 0.08; budget(1) 654, budget(10) 2,400), `test_districts_sum_800`, `test_fp_available_emplacements_are_three` (defs with `tech_required == &""` are exactly search radar, AAA, SHORAD), `test_phases_cover_1_to_30`. Run: `tools/test.sh res://test/unit/data/test_cad_content_fp.gd` and `tools/validate.sh`.
- **Constraints:** STD-DATA; CSVs are the source of truth; the `.tres` are produced by `tools/import_csv.sh`, never hand-edited (map and wave rules are hand-authored `.tres` because they hold geometry and nested resources).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-024.md`; STD-HANDOFF + the importer's per-row output.
- **Definition of Done:** STD-DOD; second importer run leaves `git status` clean.
- **Verification gates:** human spot-checks 10 numbers against B.2–B.4 and the district polygons (open `map_01.tres` in the editor; districts do not overlap).
- **Dependencies:** CAD-FP-018, CAD-FP-019, CAD-FP-023.
- **Effort:** 1–2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: any invented number not in the tables → return.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-025 — CadCommand and CadCommandQueue
- **ID:** CAD-FP-025 **Title:** CadCommand and CadCommandQueue
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Player intents reach the sim as pooled, sequence-numbered command objects.
- **Scope:** `src/sim/cmd/cad_command.gd`, `src/sim/cmd/cad_command_queue.gd`, `test/unit/sim/test_cad_command_queue.gd`; LOC ≤ 80.
- **Interface contract:**
  ```gdscript
  class_name CadCommand
  extends RefCounted
  var type: int            # CadEnums.CommandType
  var seq: int
  var emp_index: int = -1
  var def_index: int = -1
  var x: float = 0.0
  var y: float = 0.0
  var a: int = 0           # doctrine field / district index / target threat / rounds
  var b: int = 0
  var c: int = 0
  func reset() -> void

  class_name CadCommandQueue
  extends RefCounted
  const POOL_SIZE: int = 64
  var pending_count: int
  func acquire() -> CadCommand          # from the pool; null + push_error when exhausted
  func enqueue(cmd: CadCommand) -> void  # assigns seq (monotonic), appends
  func pop() -> CadCommand               # FIFO; null when empty
  func recycle(cmd: CadCommand) -> void  # reset + return to pool
  ```
- **Test-first:** `test_fifo_order_and_seq`, `test_pool_exhaustion_returns_null`, `test_recycle_returns_to_pool` (acquire 64, recycle 1, acquire → not null), `test_reset_clears_fields`. Run: `tools/test.sh res://test/unit/sim/test_cad_command_queue.gd`.
- **Constraints:** STD-TYPING, STD-SIM; the pool is an `Array[CadCommand]` allocated in `_init` (allowed: not tick-path); `pop`/`enqueue` allocation-free (ring buffer over the pool).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-025.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human confirms no `Array.push_back` in `enqueue` (ring index only).
- **Dependencies:** CAD-FP-009.
- **Effort:** 1 agent session × 6 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-026 — CadEmplacement runtime object and CadDoctrine
- **ID:** CAD-FP-026 **Title:** CadEmplacement runtime object and CadDoctrine
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** A pooled emplacement object carries per-instance state and effective (upgrade/tech-adjusted) stats with pre-squared ranges.
- **Scope:** `src/sim/store/cad_doctrine.gd`, `src/sim/store/cad_emplacement.gd`, `test/unit/sim/test_cad_emplacement.gd`; LOC ≤ 110.
- **Interface contract:**
  ```gdscript
  class_name CadDoctrine
  extends RefCounted
  var roe: int
  var priority: int
  var min_threat_value: int
  var salvo: int = 1
  var reengage: bool = false
  func apply_preset(p: CadDoctrinePreset) -> void
  func copy_from(o: CadDoctrine) -> void

  class_name CadEmplacement
  extends RefCounted
  var active: bool
  var id: int
  var def_index: int
  var kind: int
  var state: int                 # CadEnums.EmpState
  var x: float
  var y: float
  var hp: float
  var max_hp: float
  var level: int = 1
  var ammo: int
  var stock: int
  var ready_tick: int
  var reload_end_tick: int
  var channels_busy: int
  var linked: bool
  var revealed: bool
  var last_emit_tick: int = -1
  var relocate_until_tick: int
  var manual_ready_tick: int
  var kills: int
  var shots: int
  var doctrine: CadDoctrine
  # effective stats
  var range_max_m: float
  var range_min_m: float
  var range_max2: float
  var range_min2: float
  var organic_range2: float
  var detect_ref_range_m: float
  var low_alt_horizon_m: float
  var max_alt_m: float
  var alt_coverage: int
  var track_capacity: int
  var track_range2: float
  var passive_range2: float
  var effect_radius2: float
  var effect_a: float
  var effect_b: float
  var shot_interval_ticks: int
  var reload_ticks: int
  var ammo_capacity: int
  var stock_max: int
  var ammo_cost: int
  var interceptor_speed: float
  var channels: int
  var jam_vulnerability: float
  var pk_additive: float
  var is_gun: bool
  var needs_track: bool
  var query_radius: float        # max of range_max, detect_ref × 1.2, track_range, passive, effect radius
  func reset() -> void
  func init_from(def: CadEmplacementDef, def_idx: int, new_id: int, px: float, py: float, preset: CadDoctrinePreset, defs: CadDefs) -> void
  func recompute_stats(def: CadEmplacementDef, defs: CadDefs, reload_mult: float, stock_mult: float) -> void   # FP: mults 1.0; upgrades/tech applied in VS/PA cards through the same function
  ```
- **Test-first:** `test_init_copies_and_squares` (SHORAD: range_max2 36e6, organic_range2 16e6, shot_interval_ticks 60, reload_ticks 240, ammo 4, stock 0, linked false, state ACTIVE), `test_recompute_mults` (reload_mult 0.75 → 180 ticks; stock_mult 1.5 → stock_max 24), `test_reset_clears`, `test_doctrine_preset_applied` (launcher preset per B.10: TIGHT, HIGHEST_VALUE, 50). Run: `tools/test.sh res://test/unit/sim/test_cad_emplacement.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `doctrine` allocated once in `_init` and reused across `reset()`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-026.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks `query_radius` covers every use in later systems (sensor, track, targeting, EW).
- **Dependencies:** CAD-FP-016, CAD-FP-020, CAD-FP-021.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-027 — CadEmplacementStore with placement rules and links
- **ID:** CAD-FP-027 **Title:** CadEmplacementStore with placement rules and links
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Emplacements are placed, removed and categorised deterministically, with zone/overlap/capacity rules and the C2 link rule.
- **Scope:** `src/sim/store/cad_emplacement_store.gd`, `test/unit/sim/test_cad_emplacement_store.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadEmplacementStore
  extends RefCounted
  var items: Array[CadEmplacement]        # size CadConst.MAX_EMPLACEMENTS, preallocated
  var active_count: int
  var sensors: PackedInt32Array
  var sensor_count: int
  var shooters: PackedInt32Array
  var shooter_count: int
  var ew: PackedInt32Array
  var ew_count: int
  var support: PackedInt32Array
  var support_count: int
  var lists_dirty: bool
  var _next_id: int = 1
  func _init(defs: CadDefs, map: CadMapDef) -> void
  func can_place(def_idx: int, px: float, py: float) -> int      # CommandResult: OK | REJECTED_ZONE | REJECTED_OVERLAP | REJECTED_CAPACITY
  func place(def_idx: int, px: float, py: float, tick: int) -> int   # index or -1; runs init_from with the kind's preset; marks lists dirty
  func remove(i: int) -> void
  func rebuild_lists() -> void                                     # ascending index order into the four lists; clears lists_dirty
  func recompute_links() -> void                                   # B.3.3: with no C2 on the map, linked = not needs_track; with C2 nodes: linked if within a C2's effect radius and that C2 has a sensor within its radius
  func find_at(px: float, py: float, radius: float) -> int         # nearest active within radius, -1 if none
  func upkeep_total(defs: CadDefs) -> int                          # excludes DESTROYED
  func count_of_kind(kind: int) -> int
  ```
- **Test-first:** `test_place_in_zone_ok`, `test_place_outside_zone_rejected`, `test_overlap_rejected` (two footprints 200 m apart with footprint 150 → REJECTED_OVERLAP; 310 m apart → OK), `test_capacity_rejected` (65th), `test_lists_categorised` (radar → sensors, AAA → shooters), `test_links_default_rule_without_c2` (AAA linked true, MRSAM linked false), `test_links_with_c2` (MRSAM within 8,000 m of a C2 that has a radar within 8,000 m → linked), `test_find_at_nearest`, `test_upkeep_excludes_destroyed`. Run: `tools/test.sh res://test/unit/sim/test_cad_emplacement_store.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `can_place`/`place`/`remove`/`recompute_links` run at command time (allocation-free anyway); `rebuild_lists` is O(capacity).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-027.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the link rule matches B.3.3 exactly.
- **Dependencies:** CAD-FP-026, CAD-FP-018, CAD-FP-021.
- **Effort:** 1–2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-028 — CadDistrictState
- **ID:** CAD-FP-028 **Title:** CadDistrictState
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** District hit points, hardening, income fraction, integrity and capped repair are simulated in Packed arrays.
- **Scope:** `src/sim/store/cad_district_state.gd`, `test/unit/sim/test_cad_district_state.gd`; LOC ≤ 90.
- **Interface contract:**
  ```gdscript
  class_name CadDistrictState
  extends RefCounted
  var count: int
  var hp: PackedFloat32Array
  var max_hp: PackedFloat32Array
  var value: PackedInt32Array
  var hardening_mult: PackedFloat32Array     # 1.0 default; 0.7 / 0.5 when hardened
  var damage_this_wave: PackedFloat32Array
  var repair_cap: PackedFloat32Array
  var repair_used: PackedFloat32Array
  var center_x: PackedFloat32Array
  var center_y: PackedFloat32Array
  func _init(map: CadMapDef) -> void
  func apply_damage(d: int, dmg: float) -> float     # returns applied damage after hardening; hp clamped at 0
  func integrity() -> float                           # 100 × Σhp / Σmax_hp
  func district_income() -> int                       # Σ int(value × hp / max_hp)
  func repair(d: int, amount: float) -> float         # min(amount, cap − used, max − hp); returns applied
  func reset_wave() -> void                           # damage_this_wave = 0, repair_used = 0
  func total_damage_this_wave() -> float
  func nearest(px: float, py: float) -> int
  func pick_by_value(rng: CadRng, stream: int) -> int # weight = value × (1.0 if hp > 0 else 0.2)
  ```
- **Test-first:** `test_damage_hardening_clamp` (100 hp, mult 0.7, dmg 400 → applied 280, hp 0), `test_integrity` (8 districts, one at 0 → 87.5), `test_income_wave10_example` (Port 70 %, Industrial 80 %, others full → 742), `test_repair_cap` (cap 50: repair 80 → 50, then 10 → 0), `test_pick_by_value_hits_all_nonzero` (seeded 2,000 picks cover all 8), `test_nearest`. Run: `tools/test.sh res://test/unit/sim/test_cad_district_state.gd`.
- **Constraints:** STD-TYPING, STD-SIM.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-028.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks `district_income` rounding (per-district `int()` floor) matches B.6 examples.
- **Dependencies:** CAD-FP-018, CAD-FP-010.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-029 — CadEconomy and CadIncomeReport
- **ID:** CAD-FP-029 **Title:** CadEconomy and CadIncomeReport
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Funds, salvage, wave income, restock/repair/sell pricing follow B.6 exactly.
- **Scope:** `src/sim/economy/cad_income_report.gd`, `src/sim/economy/cad_economy.gd`, `test/unit/sim/test_cad_economy.gd`; LOC ≤ 100.
- **Interface contract:**
  ```gdscript
  class_name CadIncomeReport
  extends RefCounted
  var wave: int
  var district_income: int
  var salvage: int
  var bonus: int
  var upkeep: int
  var net: int
  var quality: float
  var damage: float
  var kills_value: int
  func reset() -> void

  class_name CadEconomy
  extends RefCounted
  var funds: int
  var salvage_accum: float
  var kills_value_accum: int
  var cfg: CadBalanceConfig
  func _init(cfg: CadBalanceConfig, starting_funds: int) -> void
  func can_afford(cost: int) -> bool
  func spend(cost: int) -> bool                       # false and unchanged when unaffordable
  func add(amount: int) -> void
  func add_kill_salvage(cost: int, mult: float) -> void   # salvage_accum += cost × salvage_rate × mult; kills_value_accum += cost
  func compute_wave_income(wave: int, district_income: int, damage_this_wave: float, upkeep: int, report: CadIncomeReport) -> void   # salvage = floor(accum); bonus via cfg.wave_bonus; net = district + salvage + bonus − upkeep; funds += net; accumulators reset
  func restock_cost(emp: CadEmplacement, rounds: int) -> int         # rounds × ammo_cost
  func sell_refund(emp: CadEmplacement, def: CadEmplacementDef) -> int   # int(def.cost × sell_refund_rate × hp / max_hp) + int(emp.stock × ammo_cost × sell_refund_rate)
  func repair_cost_district(hp_amount: float) -> int
  func repair_cost_emplacement(hp_amount: float) -> int
  func relocate_cost(def: CadEmplacementDef) -> int
  ```
- **Test-first:** `test_wave1_example_net_980` (district 752, 5 kills × 100, dmg 40, upkeep 55), `test_wave10_example_net_1601`, `test_wave20_case_a_net_474`, `test_quality_zero_when_damage_ge_200`, `test_spend_rejects_when_short`, `test_sell_refund_with_hp_and_stock` (SHORAD full hp, stock 4 → 250 + 120 = 370), `test_salvage_floor`. Run: `tools/test.sh res://test/unit/sim/test_cad_economy.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `compute_wave_income` runs once per wave (not tick-path).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-029.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human recomputes the wave-1 and wave-10 examples by hand from B.6.
- **Dependencies:** CAD-FP-020, CAD-FP-026, CAD-FP-028.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-030 — CadSensorSystem (DETECT)
- **ID:** CAD-FP-030 **Title:** CadSensorSystem (DETECT)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Search/FCR/passive sensors detect threats per B.5.3 with RCS, altitude band, low-altitude horizon, ballistic visibility and jam factor.
- **Scope:** `src/sim/systems/cad_sensor_system.gd`, `test/unit/sim/test_cad_sensor_system.gd`; LOC ≤ 110.
- **Interface contract:**
  ```gdscript
  class_name CadSensorSystem
  extends RefCounted
  var jam_at_emp: PackedFloat32Array        # size MAX_EMPLACEMENTS; written by CadEwSystem (VS); zeros in FP
  var persist_ticks: int
  var _query: PackedInt32Array               # size CadConst.QUERY_BUFFER
  func _init(defs: CadDefs, cfg: CadBalanceConfig) -> void
  func update(tick: int, threats: CadThreatStore, emps: CadEmplacementStore, hash: CadSpatialHash, events: CadEventLog) -> void
  func detection_range(emp: CadEmplacement, thr_def: int, classified: bool, band: int, alt: float) -> float   # pure: B.5.3 rules, 0 when band not covered or ballistic above max_alt
  ```
- **Test-first:** (radar ref range 15,000 at 1 m², horizon 6,000, max_alt 30,000; threats from B.2) `test_owa_beyond_horizon_not_detected` (dist 6,100 → no), `test_owa_inside_horizon_detected` (5,900 → yes), `test_recon_high_detected_at_7000` (¼-power 7,093), `test_recon_high_not_at_7200`, `test_srbm_above_max_alt_not_detected`, `test_srbm_at_25000_alt_detected_within_12613`, `test_jam_halves_range` (jam 0.5, vulnerability 1.0 → OWA at 3,100 not detected, at 2,900 detected), `test_passive_ignores_rcs` (FPV at 2,400 from passive → detected; at 2,600 → not), `test_persistence_60_ticks_after_loss`, `test_detected_event_once_per_transition`, `test_band_not_covered` (passive vs MED → no). Run: `tools/test.sh res://test/unit/sim/test_cad_sensor_system.gd`.
- **Constraints:** STD-TYPING, STD-SIM; per-tick: for each sensor one `query_circle` with `emp.query_radius`; no `sqrt` (compare squares); ranges from `defs.det_range()`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-030.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the horizon cap applies only to LOW band and that `last_emit_tick` is set on detection (SEAD later).
- **Dependencies:** CAD-FP-021, CAD-FP-012, CAD-FP-014, CAD-FP-027.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: agent computes `pow()` per tick → return.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-031 — CadTrackSystem (TRACK and engagement mode)
- **ID:** CAD-FP-031 **Title:** CadTrackSystem (TRACK and engagement mode)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** FCRs allocate capacity-limited tracks with hysteresis, decoys get classified, and shooters learn whether a threat is TRACKED, CUED, ORGANIC or NONE.
- **Scope:** `src/sim/systems/cad_track_system.gd`, `test/unit/sim/test_cad_track_system.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadTrackSystem
  extends RefCounted
  var classify_ticks: int
  var _query: PackedInt32Array
  var _topk: PackedInt32Array            # size 32 (max track capacity)
  var _topk_key: PackedInt32Array
  func _init(defs: CadDefs, cfg: CadBalanceConfig) -> void
  func update(tick: int, threats: CadThreatStore, emps: CadEmplacementStore, hash: CadSpatialHash, events: CadEventLog) -> void
  func engage_mode(emp: CadEmplacement, threats: CadThreatStore, i: int, dist2: float, band: int) -> int   # B.5.4: NONE if out of [range_min², range_max²] or band not covered; TRACKED if track_owner ≥ 0 and linked; CUED if detect_ticks_left > 0 and linked; ORGANIC if dist2 ≤ organic_range2
  ```
- **Test-first:** `test_capacity_limits_tracks` (FCR capacity 6, 8 detected → 6 tracked, the two lowest-value untracked), `test_tracks_persist_while_detected`, `test_track_dropped_on_loss_event`, `test_decoy_classified_after_240_track_ticks` (flag set, `value` → 60), `test_engage_mode_tracked_cued_organic_none` (parameterised 6 cases incl. min range and altitude), `test_top_k_deterministic_tie_break` (equal values → lower index first). Run: `tools/test.sh res://test/unit/sim/test_cad_track_system.gd`.
- **Constraints:** STD-TYPING, STD-SIM; top-K by fixed-size insertion (no sort); `engage_mode` is called per (shooter, candidate) per tick — no allocation, ≤ 10 comparisons.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-031.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks hysteresis (kept tracks are not re-ranked) and that FCR detection (its own `detect_ref_range_m`) is handled by CAD-FP-030, not here.
- **Dependencies:** CAD-FP-030.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-032 — CadTargeting (doctrine-driven target selection)
- **ID:** CAD-FP-032 **Title:** CadTargeting (doctrine-driven target selection)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Each ready shooter picks at most one target per tick according to ROE, priority, minimum value, engagement caps and Pk modifiers (B.5.5).
- **Scope:** `src/sim/systems/cad_targeting.gd`, `test/unit/sim/test_cad_targeting.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadTargeting
  extends RefCounted
  var _query: PackedInt32Array
  var last_pk: float                     # pk of the last selected target (read by CadFireControl right after select_target)
  var last_mode: int
  func _init(defs: CadDefs, cfg: CadBalanceConfig, districts: CadDistrictState) -> void
  func select_target(tick: int, emp: CadEmplacement, threats: CadThreatStore, hash: CadSpatialHash, tracks: CadTrackSystem, jam: float) -> int   # threat index or -1
  func compute_pk(emp: CadEmplacement, thr_def: int, mode: int, jam: float) -> float   # base × mode mult × (1 − jam_pk_mult × jam × vulnerability) + pk_additive, clamped [0, 0.98]
  func ticks_to_impact(threats: CadThreatStore, i: int) -> int         # dist to target / speed, in ticks; INT32 max when no target
  func in_tight_zone(emp: CadEmplacement, threats: CadThreatStore, i: int) -> bool   # target point within defended_radius of emp, or target is emp itself
  ```
- **Test-first:** `test_hold_never_selects`, `test_min_threat_value_filters` (min 500 ignores OWA 100), `test_priority_nearest_impact`, `test_priority_highest_value`, `test_priority_best_exchange` (AAA prefers OWA over cruise), `test_max_engagements_cap` (engaged_by 2 → skipped), `test_tight_zone_rule`, `test_pk_modifiers` (organic 0.6×, cued 0.75× for needs_track weapons only, jam 0.5 with vuln 0.4 → ×0.9, additive +0.05, clamp 0.98), `test_min_pk_to_fire` (pk 0.04 → skipped), `test_tie_break_by_index`. Run: `tools/test.sh res://test/unit/sim/test_cad_targeting.gd`.
- **Constraints:** STD-TYPING, STD-SIM; one `query_circle` per shooter per tick with `emp.range_max_m`; no allocation.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-032.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks each doctrine key formula against B.5.5.
- **Dependencies:** CAD-FP-031, CAD-FP-020.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-033 — CadFireControl (ENGAGE: bursts, launches, reloads, manual fire)
- **ID:** CAD-FP-033 **Title:** CadFireControl (ENGAGE: bursts, launches, reloads, manual fire)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Ready shooters fire per doctrine: guns resolve bursts instantly, launchers spawn interceptors with a computed time-to-intercept, ammo/stock/reload cycles run, manual override works.
- **Scope:** `src/sim/systems/cad_fire_control.gd`, `test/unit/sim/test_cad_fire_control.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadFireControl
  extends RefCounted
  func _init(defs: CadDefs, cfg: CadBalanceConfig, targeting: CadTargeting) -> void
  func update(tick: int, threats: CadThreatStore, emps: CadEmplacementStore, interceptors: CadInterceptorStore, hash: CadSpatialHash, tracks: CadTrackSystem, jam_at_emp: PackedFloat32Array, rng: CadRng, events: CadEventLog) -> void
  func fire_at(tick: int, emp: CadEmplacement, target: int, pk: float, threats: CadThreatStore, interceptors: CadInterceptorStore, rng: CadRng, events: CadEventLog, salvo: int) -> int   # rounds fired
  func manual_fire(tick: int, emp: CadEmplacement, target: int, threats: CadThreatStore, interceptors: CadInterceptorStore, tracks: CadTrackSystem, jam: float, rng: CadRng, events: CadEventLog) -> int   # CommandResult; ignores doctrine, requires range/ammo/cooldown
  static func intercept_time(sx: float, sy: float, tx: float, ty: float, tvx: float, tvy: float, speed: float) -> float   # smallest positive root of |T + V t| = s t; fallback dist / speed; capped at 60 s
  ```
  Rules: readiness = `state == ACTIVE and roe != HOLD and tick >= ready_tick and ammo > 0 and channels_busy < channels`; gun: `BURST_FIRED(emp, target, hit)`, hit → `threats.state = KILLED`; launcher: `interceptors.alloc(...)` with `resolve_tick = tick + ceil(t × 30)`, `SHOT_FIRED`, `channels_busy += 1`, `engaged_by += 1`; `ammo == 0 and stock > 0` → `state = RELOADING`, `reload_end_tick`, `RELOAD_STARTED`; at `reload_end_tick`: move `min(ammo_capacity, stock)` rounds, `RELOAD_DONE`, `ACTIVE`.
- **Test-first:** `test_gun_burst_hit_and_miss_from_seed` (seeded rng, two ticks → events with the expected hit flags), `test_launcher_spawns_interceptor_with_resolve_tick` (head-on target 3,000 m, speed 600, target speed 50 toward → t ≈ 4.615 s → 139 ticks), `test_salvo_two_uses_two_rounds_and_channels`, `test_no_fire_before_ready_tick`, `test_reload_cycle` (ammo 0, stock 6, capacity 4 → RELOADING, after 240 ticks ammo 4 stock 2, events), `test_manual_fire_ignores_doctrine_but_respects_cooldown` (HOLD launcher fires once, second call within 90 ticks → REJECTED_STATE), `test_intercept_time_analytic` (three cases ±1 %). Run: `tools/test.sh res://test/unit/sim/test_cad_fire_control.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `sqrt` allowed once per launch (not per candidate); all events carry (emp, target) indices.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-033.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the pk used at launch is the one from `CadTargeting.last_pk` (snapshot semantics, B.5.5) and that guns never allocate interceptors.
- **Dependencies:** CAD-FP-032, CAD-FP-013, CAD-FP-010.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: the quadratic intercept solver fails the analytic test twice → fallback `dist / speed` with a logged simplification.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-034 — CadInterceptorSystem (ASSESS)
- **ID:** CAD-FP-034 **Title:** CadInterceptorSystem (ASSESS)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** In-flight interceptors pursue their target visually and resolve by Pk at their resolve tick, releasing channels and handling gone targets.
- **Scope:** `src/sim/systems/cad_interceptor_system.gd`, `test/unit/sim/test_cad_interceptor_system.gd`; LOC ≤ 80.
- **Interface contract:**
  ```gdscript
  class_name CadInterceptorSystem
  extends RefCounted
  func _init(defs: CadDefs) -> void
  func update(tick: int, interceptors: CadInterceptorStore, threats: CadThreatStore, emps: CadEmplacementStore, rng: CadRng, events: CadEventLog) -> void
  ```
  Rules per B.5.6: target not alive or state ∉ {INGRESS, TERMINAL, ORBIT, WANDER} → `INTERCEPT_MISS(k, target, c = 1)`; else move toward target by `speed × TICK_DT`; at `resolve_tick`: `chance(COMBAT, pk)` → `INTERCEPT_HIT` and `threats.state[target] = KILLED`, else `INTERCEPT_MISS(c = 0)`; always `launcher.channels_busy −= 1`, `threats.engaged_by[target] −= 1`, release; on miss with `doctrine.reengage` and target alive → `launcher.ready_tick = tick`.
- **Test-first:** `test_hit_kills_and_frees_channel`, `test_miss_leaves_target_alive`, `test_target_gone_resolves_as_miss_reason_1`, `test_moves_toward_target_each_tick` (distance strictly decreasing), `test_reengage_resets_ready_tick`, `test_engaged_by_decrements`. Run: `tools/test.sh res://test/unit/sim/test_cad_interceptor_system.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `sqrt` per interceptor per tick allowed (≤ 1,024).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-034.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks kills by interceptors are consumed by CAD-FP-036 (state KILLED, not released here).
- **Dependencies:** CAD-FP-033.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-035 — CadThreatMotion (OWA and cruise profiles, generic states)
- **ID:** CAD-FP-035 **Title:** CadThreatMotion (OWA and cruise profiles, generic states)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Threats acquire targets per `target_pref`, fly straight at their speed, impact when they arrive, and wander/crash after link loss; SRBM/orbit/glide profiles are added by VS/PA epics through the same state table.
- **Scope:** `src/sim/systems/cad_threat_motion.gd`, `test/unit/sim/test_cad_threat_motion.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadThreatMotion
  extends RefCounted
  func _init(defs: CadDefs, map: CadMapDef, districts: CadDistrictState) -> void
  func update(tick: int, threats: CadThreatStore, emps: CadEmplacementStore, rng: CadRng) -> void
  func assign_target(i: int, threats: CadThreatStore, emps: CadEmplacementStore, rng: CadRng) -> void
  static func step_toward(threats: CadThreatStore, i: int, tx: float, ty: float, step: float) -> bool   # moves by ≤ step; returns true when arrived (also sets vel)
  ```
  State table (D2.7): SPAWNED → INGRESS (assign_target, first tick); INGRESS: `step_toward(target)`; arrived → IMPACTED; WANDER: heading from `rng.randf_range(MOTION, −PI, PI)` chosen on entry, straight flight, `state_ticks ≥ defs.wander_ticks[def]` → CRASHED; TERMINAL/ORBIT/EXITED handled as no-ops in FP (documented as VS extension points). Target rules: DISTRICT_VALUE → `districts.pick_by_value(rng, WAVEGEN)`; DISTRICT_NEAREST → `districts.nearest`; EMPLACEMENT_NEAREST → nearest active emplacement within 3,000 m of the straight path to the city centre, else DISTRICT_NEAREST; PASS_THROUGH → point on the far edge along the axis; other prefs → DISTRICT_VALUE in FP.
- **Test-first:** `test_spawned_becomes_ingress_with_target`, `test_moves_speed_dt_per_tick` (OWA 50 m/s → 1.6667 m/tick ± 1e-4), `test_impacts_exactly_on_arrival` (no overshoot; state IMPACTED at the first tick where remaining ≤ step), `test_wander_then_crash` (wander_ticks 360 → CRASHED at tick 360), `test_target_pref_emplacement_nearest_within_path` (emplacement 2,000 m off the path chosen; 4,000 m off → district), `test_pass_through_target_on_far_edge`, `test_prev_positions_untouched` (motion never writes prev arrays). Run: `tools/test.sh res://test/unit/sim/test_cad_threat_motion.gd`.
- **Constraints:** STD-TYPING, STD-SIM; one `sqrt` per moving threat per tick; `assign_target` runs once per threat lifetime (not per tick).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-035.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the state table matches D2.7 and that `vel_x/vel_y` are written (needed by intercept prediction and view heading).
- **Dependencies:** CAD-FP-012, CAD-FP-028, CAD-FP-010, CAD-FP-021.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-036 — CadImpactSystem (IMPACT and cleanup)
- **ID:** CAD-FP-036 **Title:** CadImpactSystem (IMPACT and cleanup)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Impacts damage districts/emplacements, kills pay salvage, and every terminal threat state releases its slot in the same tick.
- **Scope:** `src/sim/systems/cad_impact_system.gd`, `test/unit/sim/test_cad_impact_system.gd`; LOC ≤ 90.
- **Interface contract:**
  ```gdscript
  class_name CadImpactSystem
  extends RefCounted
  func _init(defs: CadDefs, cfg: CadBalanceConfig) -> void
  func update(tick: int, threats: CadThreatStore, emps: CadEmplacementStore, districts: CadDistrictState, economy: CadEconomy, events: CadEventLog) -> void
  ```
  Rules per B.5.7: IMPACTED + target DISTRICT → `districts.apply_damage`, `DISTRICT_DAMAGED(d, applied)`, `THREAT_IMPACT`; IMPACTED + target EMPLACEMENT → `emp.hp −= damage`, `EMPLACEMENT_DAMAGED`; `hp ≤ 0` → `state = DESTROYED`, `EMPLACEMENT_DESTROYED`, `emps.lists_dirty = true`; KILLED → `economy.add_kill_salvage(def.cost, def.salvage_mult)`, `THREAT_KILLED(i, def, x, y)`; CRASHED → `THREAT_CRASHED`; EXITED → `THREAT_EXITED`; all four → `threats.release(i)`. Kill credit: `launcher.kills += 1` when the killing event's launcher is known (`engaged_by` bookkeeping from CAD-FP-034 passes the launcher via `threats.target_id`? No — CAD-FP-034 records `last_hit_by: PackedInt32Array` on the threat store; this card reads it).
- **Test-first:** `test_district_impact_applies_hardened_damage_and_event`, `test_emplacement_impact_and_destroyed`, `test_kill_pays_salvage_and_releases` (OWA → salvage_accum 15.0), `test_crash_no_salvage`, `test_exit_releases`, `test_alive_count_after_cleanup` (5 spawned, 2 killed, 1 impacted → 2 alive after `rebuild_alive`). Run: `tools/test.sh res://test/unit/sim/test_cad_impact_system.gd`.
- **Constraints:** STD-TYPING, STD-SIM; adds `last_hit_by: PackedInt32Array` to `CadThreatStore` (≤ 6 LOC change in CAD-FP-012's file, allowed by this card's Scope) and sets it in CAD-FP-033/034 (≤ 4 LOC each) — the only cross-file edits, listed in Scope.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-036.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human confirms no slot is released before its event is logged.
- **Dependencies:** CAD-FP-035, CAD-FP-029, CAD-FP-027, CAD-FP-034.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-037 — CadWaveGenerator and CadWavePlan
- **ID:** CAD-FP-037 **Title:** CadWaveGenerator and CadWavePlan
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** A wave's spawn plan (which threats, when, where) is generated deterministically from the budget, phase weights, package archetypes and caps of B.7.
- **Scope:** `src/sim/waves/cad_wave_plan.gd`, `src/sim/waves/cad_wave_generator.gd`, `test/unit/sim/test_cad_wave_generator.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadWavePlan
  extends RefCounted
  const MAX_ENTRIES: int = 1024
  var wave: int
  var count: int
  var budget: float
  var spent: float
  var def_index: PackedInt32Array
  var spawn_tick: PackedInt32Array
  var spawn_x: PackedFloat32Array
  var spawn_y: PackedFloat32Array
  var package_id: PackedInt32Array
  var eccm_level: int
  func clear() -> void
  func add(def_idx: int, tick: int, x: float, y: float, pkg: int) -> bool
  func sort_by_spawn_tick() -> void        # in-place insertion sort of all arrays by (spawn_tick, insertion index); once per wave
  func count_of_def(def_idx: int) -> int

  class_name CadWaveGenerator
  extends RefCounted
  func _init(defs: CadDefs, rules: CadWaveRules, map: CadMapDef) -> void
  func generate(wave: int, rng: CadRng, plan: CadWavePlan) -> void   # B.7 fill algorithm with WAVEGEN stream; final wave: all tot offsets in [0, 30] s
  func budget(wave: int) -> float
  ```
- **Test-first:** `test_budget_matches_rules` (654 / 2,400 / 5,100 / 12,900), `test_spend_within_fill_band_or_all_tried` (waves 1, 10, 20 over 20 seeds), `test_respects_min_wave` (wave 3 contains no cruise), `test_respects_caps` (wave 12: srbm ≤ 1), `test_sorted_by_spawn_tick`, `test_spawn_positions_on_spawn_line_with_lateral_spread`, `test_deterministic_for_seed` (seed 42 twice → identical arrays; seed 43 → different), `test_wave_30_synchronised` (all spawn ticks ≤ 30 s + spread). Run: `tools/test.sh res://test/unit/sim/test_cad_wave_generator.gd`.
- **Constraints:** STD-TYPING, STD-SIM; generation runs at wave start (not tick-path) but still uses only Packed arrays; package "tried" flags in a `PackedByteArray`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-037.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human runs the generator for waves 1–12 with seed 42 and reads the composition list for plausibility against B.7 phases.
- **Dependencies:** CAD-FP-019, CAD-FP-021, CAD-FP-010.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-038 — CadWaveDirector (spawning and wave state)
- **ID:** CAD-FP-038 **Title:** CadWaveDirector (spawning and wave state)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Plan entries spawn at their ticks under the concurrency cap and the wave state advances SPAWNING → ACTIVE → CLEARED.
- **Scope:** `src/sim/waves/cad_wave_director.gd`, `test/unit/sim/test_cad_wave_director.gd`; LOC ≤ 80.
- **Interface contract:**
  ```gdscript
  class_name CadWaveDirector
  extends RefCounted
  var state: int                 # CadEnums.WaveState
  var plan: CadWavePlan
  var cursor: int
  var wave_start_tick: int
  var max_concurrent: int
  func _init(defs: CadDefs, rules: CadWaveRules) -> void
  func start(wave: int, tick: int, plan: CadWavePlan) -> void      # state SPAWNING, cursor 0
  func update(tick: int, threats: CadThreatStore, events: CadEventLog) -> void   # spawn entries with spawn_tick ≤ tick − wave_start_tick while alive_count < max_concurrent; THREAT_SPAWNED per spawn; when cursor == count → ACTIVE
  func is_cleared(threats: CadThreatStore) -> bool                 # cursor == count and alive_count == 0
  func remaining() -> int
  func mark_cleared() -> void
  func mark_failed() -> void
  ```
  Spawn: `threats.alloc(def, x, y, def.altitude_m, def.hp, def.cost, tick)`; sets `eccm_level`, `package_id`.
- **Test-first:** `test_spawns_at_due_ticks`, `test_concurrency_cap_queues` (cap 3, 5 due → 3 alive, 2 later after releases), `test_state_transitions`, `test_spawned_events_equal_plan_count`, `test_is_cleared_only_when_all_spawned_and_none_alive`. Run: `tools/test.sh res://test/unit/sim/test_cad_wave_director.gd`.
- **Constraints:** STD-TYPING, STD-SIM.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-038.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks `alloc` failure (store full) is handled by retrying next tick, not by dropping the entry.
- **Dependencies:** CAD-FP-037, CAD-FP-012, CAD-FP-011.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-039 — CadSim facade (tick order, commands, wave lifecycle)
- **ID:** CAD-FP-039 **Title:** CadSim facade (tick order, commands, wave lifecycle)
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** One object owns every sim subsystem, applies commands, runs the D2.2 tick order and closes waves with an income report.
- **Scope:** `src/sim/cad_sim.gd`, `test/unit/sim/test_cad_sim.gd`; LOC ≤ 120 (constructor wiring counts; keep command handling in a `match` with one line per case that delegates).
- **Interface contract:**
  ```gdscript
  class_name CadSim
  extends RefCounted
  var tick: int
  var wave_index: int            # 0 before the first wave; the wave being played or just cleared
  var seed: int
  var defs: CadDefs
  var map: CadMapDef
  var rng: CadRng
  var events: CadEventLog
  var threats: CadThreatStore
  var interceptors: CadInterceptorStore
  var emplacements: CadEmplacementStore
  var districts: CadDistrictState
  var economy: CadEconomy
  var commands: CadCommandQueue
  var hash: CadSpatialHash
  var sensors: CadSensorSystem
  var tracks: CadTrackSystem
  var targeting: CadTargeting
  var fire: CadFireControl
  var interceptor_sys: CadInterceptorSystem
  var motion: CadThreatMotion
  var impacts: CadImpactSystem
  var generator: CadWaveGenerator
  var director: CadWaveDirector
  var plan: CadWavePlan
  var report: CadIncomeReport
  var run_over: bool
  func _init(defs: CadDefs, map_id: StringName, seed: int) -> void
  func apply_command(cmd: CadCommand) -> int          # CommandResult; PLACE (funds → can_place → place → spend), SELL, SET_DOCTRINE (a=roe, b=priority, c=min value; salvo/reengage via UPGRADE-like fields later), RESTOCK (a=rounds), REPAIR_DISTRICT (a=district, b=hp), REPAIR_EMPLACEMENT, MANUAL_FIRE (a=target); others → REJECTED_STATE in FP; emits COMMAND_RESULT(seq, result) and FUNDS_CHANGED
  func start_wave() -> void                            # wave_index += 1; generator.generate; districts.reset_wave; director.start; WAVE_STARTED
  func step() -> void                                  # D2.2 stages 1–15
  func is_wave_cleared() -> bool
  func is_run_over() -> bool                           # integrity ≤ 0
  func end_wave() -> CadIncomeReport                   # economy.compute_wave_income with upkeep_total; WAVE_CLEARED; director IDLE
  func integrity() -> float
  ```
- **Test-first:** `test_place_command_spends_funds_and_creates_emplacement`, `test_place_rejected_without_funds_emits_result`, `test_start_wave_generates_plan_and_spawns`, `test_layered_defence_clears_wave_1` (radar + AAA + SHORAD placed 2,000 m east of centre; seed 42; step until cleared or 5,400 ticks → cleared, kills ≥ 3), `test_end_wave_report_positive_net`, `test_run_over_when_integrity_zero` (script district damage to 0 → `is_run_over`), `test_tick_increments_once_per_step`, `test_step_order_snapshot_before_motion` (prev == last pos after a step). Run: `tools/test.sh res://test/unit/sim/test_cad_sim.gd`.
- **Constraints:** STD-TYPING, STD-SIM; `step()` contains only calls in D2.2 order; the FP `jam_at_emp` array stays zero (no EW system yet); no per-step allocation (`report`/`plan` allocated once).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-039.md`; STD-HANDOFF + the exact stage order as implemented.
- **Definition of Done:** STD-DOD; `tools/check_sim_purity.gd` green.
- **Verification gates:** human compares `step()` line by line with D2.2; runs the wave-1 test and reads the event log summary.
- **Dependencies:** CAD-FP-024, CAD-FP-025, CAD-FP-027, CAD-FP-028, CAD-FP-029, CAD-FP-030, CAD-FP-031, CAD-FP-032, CAD-FP-033, CAD-FP-034, CAD-FP-035, CAD-FP-036, CAD-FP-037, CAD-FP-038.
- **Effort:** 2 agent sessions × 20 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: agent reorders stages to "fix" a test → return with a note; fallback: human writes `step()` by hand (≈ 30 LOC).
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-040 — Scenario suites: determinism, cost exchange, economy examples, leakers
- **ID:** CAD-FP-040 **Title:** Scenario suites: determinism, cost exchange, economy examples, leakers
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** The sim's behaviour is pinned by multi-system scenario tests that the balance harness and every later card must keep green.
- **Scope:** `test/scenario/test_determinism.gd`, `test/scenario/test_cost_exchange.gd`, `test/scenario/test_economy_examples.gd`, `test/scenario/test_leak_to_next_layer.gd`, `test/scenario/cad_scenario_util.gd` (helpers: build sim with seed, place list, run n ticks, count events), fixture `test/fixtures/replays/fp_seed42.json`; ≤ 150 test lines per file (tests are exempt from the 120 implementation ceiling), helper ≤ 60.
- **Interface contract:** `class_name CadScenarioUtil extends RefCounted`; `static func make_sim(seed: int) -> CadSim` (map_01, `test/fixtures/defs` or `data/defs`), `static func place(sim: CadSim, id: StringName, x: float, y: float) -> int`, `static func run_ticks(sim: CadSim, n: int) -> void`, `static func run_until_cleared(sim: CadSim, max_ticks: int) -> bool`, `static func events_of(sim: CadSim, type: int) -> int` (accumulated across ticks by draining the log each tick into counters).
- **Test-first:** determinism: `test_same_seed_same_event_hash_per_wave` (waves 1–5, two sims, hash after each wave equal) and `test_different_seed_differs`; cost exchange: `test_aaa_vs_owa_cost_per_kill_20_pm20pct` (isolated AAA vs 2,000 OWA passes at 1,500 m → CR spent / kills ∈ [16, 24]), `test_shorad_vs_cruise_150_pm20pct`, `test_mrsam_vs_owa_is_bad_exchange` (≥ 250); economy: `test_wave1_income_980_from_scripted_wave` (script the 6-OWA wave with 1 leak dealing 40 to Port → report.net 980); leakers: `test_missed_threat_is_engaged_by_next_layer` (SHORAD forced miss via rng state → AAA burst events on the same threat later). Run: `tools/test.sh res://test/scenario`.
- **Constraints:** STD-TYPING; tests never edit sim internals except through documented fields (`rng.set_state`, doctrine); each test ≤ 5 s headless.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-040.md`; STD-HANDOFF + measured suite runtime.
- **Definition of Done:** STD-DOD; suite runtime ≤ 60 s in CI.
- **Verification gates:** human reads the cost-exchange bands against B.4; confirms the determinism test would catch a `Dictionary` iteration (review only).
- **Dependencies:** CAD-FP-039.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: a scenario reveals a sim defect → the agent files it in the handoff as BLOCKED with the failing test kept (marked `@warning_ignore` never; use gdUnit4 `skip` with reason) and stops.
- **Prompt template:** /ai/prompts/write-tests-from-contract.md

---

### CAD-FP-041 — Headless sim benchmark, baseline and CI regression
- **ID:** CAD-FP-041 **Title:** Headless sim benchmark, baseline and CI regression
- **Milestone:** FP **Workstream:** ENG-SIM **Owner:** agent
- **Goal:** Tick cost at the entity ceilings is measured headless, compared with a committed baseline in CI, and runnable on device.
- **Scope:** `tools/bench_runner.gd`, `tools/lib/cad_bench.gd`, `tools/bench.sh/.cmd`, `bench/baseline.json`, `test/bench/test_sim_bench_regression.gd`, `.github/workflows/ci.yml` (+ `bench` step); LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadBench
  extends RefCounted
  var threats_n: int
  var interceptors_n: int
  var emplacements_n: int
  var ticks_n: int
  var tick_ms: PackedFloat32Array          # per tick
  var object_count_delta: int
  var memory_static_delta: int
  func setup(sim: CadSim) -> void          # places emplacements_n on a grid (cycling radar/AAA/SHORAD), spawns threats_n via director plan override, fires until interceptors_n are in flight
  func run(sim: CadSim) -> void            # measures Time.get_ticks_usec() around sim.step() (view-side tool, allowed)
  func mean_ms() -> float
  func p95_ms() -> float
  func to_json() -> String                 # {"godot":…, "threats":…, "tick_mean_ms":…, "tick_p95_ms":…, "tick_max_ms":…, "object_count_delta":…, "memory_static_delta":…}
  static func compare(result: Dictionary, baseline: Dictionary, max_ratio: float) -> PackedStringArray   # failures
  # runner args: -- --threats N --interceptors N --emplacements N --ticks N [--out path] [--compare bench/baseline.json --max-ratio 1.25]
  ```
- **Test-first:** `test_bench_small_runs_and_reports` (50/50/6/120 ticks → JSON has all fields, p95 ≥ mean), `test_object_count_delta_zero` (50/50/6/300 → 0), `test_compare_fails_above_ratio`, `test_compare_passes_at_baseline`. Run: `tools/test.sh res://test/bench/test_sim_bench_regression.gd`; manual: `tools/bench.sh` prints p95 for 250/300/60/1,800.
- **Constraints:** STD-TOOL, STD-TYPING; `Performance.get_monitor(Performance.OBJECT_COUNT)` and `MEMORY_STATIC` sampled before/after; the baseline JSON is written by the agent once, committed, and thereafter changed only by a human commit.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-041.md`; STD-HANDOFF + first x86 numbers.
- **Definition of Done:** STD-DOD; CI `bench` step green with `--max-ratio 1.25`.
- **Verification gates:** human runs `tools/bench.sh` locally and records numbers in `docs/perf-log.md`; if p95 on the dev PC > 1.0 ms at 250/300/60, opens an optimisation card before any view work (SPOF-1).
- **Dependencies:** CAD-FP-039, CAD-FP-005.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-042 — CadEvents and CadApp autoloads
- **ID:** CAD-FP-042 **Title:** CadEvents and CadApp autoloads
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** Sim events become typed signals, and the game-state machine (B.12) owns scene switching and the current run.
- **Scope:** `src/view/autoload/cad_events.gd`, `src/view/autoload/cad_app.gd`, `project.godot` (`[autoload]` section), `test/unit/view/test_cad_events.gd`, `test/unit/view/test_cad_app.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadEvents
  extends Node
  signal sim_threat_spawned(index: int, def_index: int)
  signal sim_threat_detected(index: int, sensor: int)
  signal sim_threat_lost(index: int)
  signal sim_track_assigned(index: int, fcr: int)
  signal sim_track_dropped(index: int)
  signal sim_shot_fired(emp: int, target: int)
  signal sim_burst_fired(emp: int, target: int, hit: bool)
  signal sim_intercept_hit(interceptor: int, target: int, x: float, y: float)
  signal sim_intercept_miss(interceptor: int, target: int, reason: int)
  signal sim_threat_killed(index: int, def_index: int, x: float, y: float)
  signal sim_threat_impact(index: int, target_kind: int, target_id: int, x: float, y: float)
  signal sim_threat_crashed(index: int, x: float, y: float)
  signal sim_threat_exited(index: int)
  signal sim_district_damaged(district: int, damage: float)
  signal sim_emplacement_damaged(emp: int, hp: float)
  signal sim_emplacement_destroyed(emp: int)
  signal sim_link_lost(index: int)
  signal sim_link_regained(index: int)
  signal sim_wave_started(wave: int)
  signal sim_wave_cleared(wave: int)
  signal sim_run_ended(victory: bool)
  signal sim_funds_changed(funds: int)
  signal sim_command_result(seq: int, result: int)
  signal sim_reload_started(emp: int)
  signal sim_reload_done(emp: int)
  signal ui_state_changed(from: int, to: int)
  signal ui_emplacement_selected(index: int)          # -1 = deselect
  signal ui_build_item_selected(def_index: int)       # -1 = cancel
  signal ui_speed_changed(speed: int)
  func emit_from_log(log: CadEventLog) -> void         # one match over EventType; a, b, c, x, y mapped as above

  class_name CadApp
  extends Node
  const TRANSITIONS: Dictionary[int, PackedInt32Array]   # B.12 table, keyed by GameState
  var state: int = CadEnums.GameState.BOOT
  var previous_state: int
  var run_map_id: StringName
  var run_seed: int
  var sim: CadSim
  var defs: CadDefs
  var scenes: Dictionary[int, PackedScene]               # preloaded at boot for TITLE, BUILD/WAVE (world), DEBRIEF, RUN_END; PAUSED is an overlay
  func can_goto(next: int) -> bool
  func goto(next: int) -> bool                           # false + push_error on illegal; emits ui_state_changed; switches scene when the target state has a scene different from the current; PAUSED sets get_tree().paused = true and shows the overlay; leaving PAUSED unpauses
  func new_run(map_id: StringName, seed: int) -> void    # creates CadSim
  func end_run() -> void                                 # frees sim reference
  ```
- **Test-first:** `test_transition_table_matches_design` (every ✓ in B.12 allowed; sampled ✗ rejected: TITLE→WAVE, DEBRIEF→WAVE, TECH→BUILD), `test_illegal_goto_returns_false_and_keeps_state`, `test_goto_emits_ui_state_changed`, `test_paused_sets_tree_paused_and_restores_previous`, `test_emit_from_log_maps_each_event_type` (parameterised over 25 types using `assert_signal(...).is_emitted(...)`), `test_new_run_creates_sim_with_seed`. Run: `tools/test.sh res://test/unit/view`.
- **Constraints:** STD-TYPING, STD-VIEW; `process_mode = PROCESS_MODE_ALWAYS` for both autoloads; scene switching via `get_tree().change_scene_to_packed()`; no scene loading during WAVE (all preloaded at BOOT).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-042.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the transition table against B.12 cell by cell and that `PAUSED` returns to `previous_state`.
- **Dependencies:** CAD-FP-009, CAD-FP-011.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-043 — CadSimDriver (fixed-step accumulator, speed, interpolation alpha)
- **ID:** CAD-FP-043 **Title:** CadSimDriver (fixed-step accumulator, speed, interpolation alpha)
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** The sim advances at exactly 30 × speed ticks per second of wall time, clamped, and views get an interpolation alpha and drained events every frame.
- **Scope:** `src/view/driver/cad_sim_driver.gd`, `test/unit/view/test_cad_sim_driver.gd`; LOC ≤ 80.
- **Interface contract:**
  ```gdscript
  class_name CadSimDriver
  extends Node
  signal ticked(tick: int)
  signal ticks_this_frame(n: int)
  var sim: CadSim
  var speed: int = 1                  # 0..3
  var alpha: float                    # accumulator / TICK_DT
  var sim_ms_last_frame: float
  var ticks_total: int
  var _acc: float
  func attach(sim: CadSim) -> void
  func set_speed(s: int) -> void      # clamps 0..3; emits CadEvents.ui_speed_changed
  func advance(delta: float) -> int   # the accumulator logic (D1.4); returns ticks run; called from _process and directly by tests
  func _process(delta: float) -> void # advance(delta); CadEvents.emit_from_log(sim.events); sim.events.clear()
  ```
- **Test-first:** `test_60_frames_at_speed_1_gives_30_ticks`, `test_speed_3_gives_90`, `test_speed_0_gives_0_and_alpha_frozen`, `test_large_delta_clamped_to_6_ticks`, `test_alpha_in_range`, `test_events_drained_and_cleared_each_frame`, `test_ticked_signal_count`. Run: `tools/test.sh res://test/unit/view/test_cad_sim_driver.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; `process_mode = PROCESS_MODE_PAUSABLE`; `delta` capped at 0.1 s before accumulation; sim time measured with `Time.get_ticks_usec()` (view side is allowed).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-043.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the accumulator never drifts (no float reset to 0 after clamping — subtract what was consumed, then clamp the remainder to one TICK_DT).
- **Dependencies:** CAD-FP-039, CAD-FP-042.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-044 — CadFrameStats (hitch logger, custom monitors, debug overlay)
- **ID:** CAD-FP-044 **Title:** CadFrameStats (hitch logger, custom monitors, debug overlay)
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** Every Gate-3 number (frame p95, hitches, sim/UI/render split, memory growth) is produced by the game itself and dumped to JSON.
- **Scope:** `src/view/driver/cad_frame_stats.gd`, `test/unit/view/test_cad_frame_stats.gd`; LOC ≤ 110.
- **Interface contract:**
  ```gdscript
  class_name CadFrameStats
  extends Node
  const RING: int = 3600
  var frame_ms: PackedFloat32Array        # ring
  var minute_p95: PackedFloat32Array      # up to 60 minutes
  var memory_samples: PackedInt64Array    # every 60 s
  var hitch_count: int
  var hitch_threshold_ms: float = 50.0
  var ui_ms: float                        # set by UI nodes around their update work
  var sim_ms: float                       # from CadSimDriver
  func record(frame_ms_value: float) -> void   # tick-path (allocation-free)
  func p95(last_n: int) -> float               # over the ring, computed with a fixed 1,000-bin histogram (no sort)
  func mean(last_n: int) -> float
  func dump_json(path: String) -> Error        # {"p95_ms","mean_ms","hitches","minute_p95":[…],"memory_static":[…],"draw_calls_last":…}
  func set_overlay_visible(v: bool) -> void    # Label child with p95/hitches/sim/ui/draw calls, updated 4× per second
  ```
  Registers custom monitors `cad/sim_ms`, `cad/ui_ms`, `cad/render_ms` via `Performance.add_custom_monitor`.
- **Test-first:** `test_p95_of_synthetic_distribution` (1,000 values 10 ms + 50 values 100 ms → p95 ≥ 99), `test_hitch_counting`, `test_ring_wraps_without_resize`, `test_dump_json_fields` (to `user://perf/test.json`), `test_overlay_toggle_by_action` (`cad_debug_overlay` via `Input.parse_input_event` of the mapped key → visible). Run: `tools/test.sh res://test/unit/view/test_cad_frame_stats.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; `record()` allocation-free; overlay text updated at ≤ 4 Hz and only when a value changed.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-044.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks p95 uses a histogram, not `sort()`.
- **Dependencies:** CAD-FP-043.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-045 — SVG sprite set v1 (FP entities and UI glyphs)
- **ID:** CAD-FP-045 **Title:** SVG sprite set v1 (FP entities and UI glyphs)
- **Milestone:** FP **Workstream:** ART **Owner:** agent
- **Goal:** Thirteen legible flat SVG glyphs exist for the FP roster, tracers and speed/build controls, in the B.13 palette.
- **Scope:** `art/svg/emp_search_radar.svg`, `emp_aaa.svg`, `emp_shorad.svg`, `thr_owa.svg`, `thr_cruise.svg`, `fx_tracer.svg`, `fx_trail.svg`, `ui_glyph_pause.svg`, `ui_glyph_play.svg`, `ui_glyph_speed2.svg`, `ui_glyph_speed3.svg`, `ui_glyph_restock.svg`, `ui_glyph_sell.svg`; `art/AUTHORED.txt` (one path per line); `test/unit/art/test_cad_svg_set.gd`; no GDScript LOC beyond the test.
- **Interface contract:** each SVG: `viewBox="0 0 64 64"`, no raster, no text, no external references, only `path/circle/rect/polygon/line`, `stroke-width="4"`, colours restricted to `#35D0FF`, `#FF5A3C`, `#FFB03C`, `#E6F0FF`, `#FFFFFF` and `none`; glyph shapes per the B.13 legend; entity glyphs point "up" (−y) as the zero heading.
- **Test-first:** `test_every_file_parses_at_scale_2` (`Image.load_svg_from_string` → 128×128, non-empty alpha), `test_only_palette_colours` (regex over `fill=`/`stroke=`), `test_viewbox_64`, `test_authored_list_covers_files`. Run: `tools/test.sh res://test/unit/art/test_cad_svg_set.gd`.
- **Constraints:** §4.4 IP rule (code-authored vectors only); each file ≤ 30 lines; no gradients or filters (Godot's SVG importer support is partial).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-045.md`; STD-HANDOFF + a contact-sheet PNG rendered via `tools/atlas_build.gd` once CAD-FP-046 exists (or the test's 128 px renders saved to `user://`).
- **Definition of Done:** STD-DOD.
- **Verification gates:** human views the glyphs at 26 dp on the low device (after CAD-FP-048) — the FP gate readability check; style unity.
- **Dependencies:** CAD-FP-002.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: any glyph resembling a real-world insignia → redraw.
- **Prompt template:** /ai/prompts/generate-svg-sprite-set.md

---

### CAD-FP-046 — CadAtlasMap and the atlas builder tool
- **ID:** CAD-FP-046 **Title:** CadAtlasMap and the atlas builder tool
- **Milestone:** FP **Workstream:** ENG-DATA **Owner:** agent
- **Goal:** All SVGs are rasterised at 2× into one lossless atlas with a typed frame map, deterministically, by a headless tool.
- **Scope:** `src/data/cad_atlas_map.gd`, `tools/lib/cad_atlas_packer.gd`, `tools/atlas_build.gd`, `tools/atlas.sh/.cmd`, generated `art/atlas/cad_atlas.png` + `art/atlas/cad_atlas_map.tres`, `tools/lib/cad_content_validator.gd` (+ CV005), `test/unit/tools/test_cad_atlas_packer.gd`; LOC ≤ 110.
- **Interface contract:**
  ```gdscript
  class_name CadAtlasMap
  extends Resource
  @export var schema_version: int = 1
  @export var atlas_texture: Texture2D
  @export var sprite_ids: Array[StringName]
  @export var frames: Array[Rect2i]
  @export var pivot: Vector2 = Vector2(0.5, 0.5)
  func frame_of(id: StringName) -> Rect2i        # Rect2i() when missing
  func uv_of(id: StringName) -> Rect2            # normalised

  class_name CadAtlasPacker
  extends RefCounted
  static func pack(ids: Array[StringName], cell: int, atlas_size: int, padding: int) -> Array[Rect2i]   # sorted ids, row-major grid, deterministic; empty array if it does not fit
  # tools/atlas_build.gd: -- --svg art/svg --out art/atlas --scale 2.0 --cell 128 --size 2048; renders each SVG with Image.load_svg_from_string, blits into an RGBA8 image, saves PNG and the .tres; prints "OK <n> sprites"
  ```
- **Test-first:** `test_pack_non_overlapping_and_sorted`, `test_pack_capacity` (256 fit in 2048/128; 257 → empty), `test_frame_of_missing_returns_empty_rect`, `test_builder_on_fixture_svgs` (3 fixture SVGs → PNG exists, map has 3 frames, frames match packer), `test_cv005_flags_unknown_sprite_id`. Run: `tools/test.sh res://test/unit/tools/test_cad_atlas_packer.gd`.
- **Constraints:** STD-TOOL, STD-TYPING, STD-DATA; import settings for the PNG via `importer_defaults` (lossless, mipmaps); CI check (added to `content` step): rebuilt atlas bytes equal the committed bytes.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-046.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD; `art/atlas/*` committed and CI byte-equality green.
- **Verification gates:** human opens the atlas PNG (glyphs crisp, 2 px padding) and checks PNG byte-determinism across two runs.
- **Dependencies:** CAD-FP-045, CAD-FP-023.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: `Image.save_png` output differs between runs → record and switch the CI check to frame-map equality only.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-047 — Theme, palette, font and CadStrings
- **ID:** CAD-FP-047 **Title:** Theme, palette, font and CadStrings
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** UI colours, sizes, font and text come from one theme, one palette resource and one strings CSV.
- **Scope:** `src/data/cad_palette.gd`, `ui/theme/cad_palette.tres` (B.13 values), `ui/theme/cad_theme.tres` (default font, sizes 14/18/24/32, Button min size 48×48, panel styles from palette), `art/fonts/Inter-Regular.ttf` + `Inter-Bold.ttf` + `art/fonts/OFL.txt` + `art/LICENSES.md` row, `ui/strings/cad_strings_en.csv` (FP keys: hud, build bar, inspector, debrief, title, pause), `src/view/ui/cad_strings.gd`, `project.godot` (`gui/theme/custom`), `tools/lib/cad_content_validator.gd` (+ CV012), `test/unit/view/test_cad_strings.gd`; LOC ≤ 70.
- **Interface contract:** `CadPalette` fields exactly as D3.1; `class_name CadStrings extends RefCounted`; `static var table: Dictionary[StringName, String]`; `static func load_csv(path: String) -> int` (rows loaded; CSV columns `key,text`); `static func get_text(key: StringName) -> String` (missing → `"!" + key`); CV012 greps `get_text(&"` keys in `src/` against the CSV.
- **Test-first:** `test_palette_loads_14_colours`, `test_theme_font_sizes_and_button_min_size`, `test_strings_load_and_lookup`, `test_missing_key_marker`, `test_cv012_detects_missing_key` (fixture script + CSV). Run: `tools/test.sh res://test/unit/view/test_cad_strings.gd`.
- **Constraints:** STD-TYPING, STD-DATA; OFL licence file shipped; no `tr()`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-047.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD; `art/LICENSES.md` row present (CI `licences` check added to the `content` step: every file under `art/` and `audio/` is in `AUTHORED.txt` or has a `LICENSES.md` row).
- **Verification gates:** human confirms the font licence and that palette hex values match B.13.
- **Dependencies:** CAD-FP-046, CAD-FP-002.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: font download blocked → use Godot's built-in default font and log the deviation in A-22.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-048 — Icon shader and CadThreatView (MultiMesh)
- **ID:** CAD-FP-048 **Title:** Icon shader and CadThreatView (MultiMesh)
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** Every alive threat is drawn as a screen-constant 26 dp atlas glyph with interpolation, in one draw call.
- **Scope:** `src/view/shaders/cad_icon.gdshader`, `src/view/world/cad_threat_view.gd`, `test/smoke/test_cad_threat_view.gd`; LOC ≤ 100 (shader ≤ 30).
- **Interface contract:**
  ```gdscript
  class_name CadThreatView
  extends MultiMeshInstance2D
  @export var atlas_map: CadAtlasMap
  @export var palette: CadPalette
  @export var icon_dp: float = 26.0
  var driver: CadSimDriver
  var defs: CadDefs
  var _frame_uv: PackedColorArray          # per threat def: (u, v, w, h) as Color
  var _tint: PackedColorArray              # per threat def
  func bind(driver: CadSimDriver, defs: CadDefs) -> void   # builds MultiMesh: instance_count = CadConst.MAX_THREATS, use_colors = true, use_custom_data = true, transform_format = TRANSFORM_2D, mesh = 1×1 QuadMesh
  func set_zoom(zoom: float) -> void       # shader uniform icon_scale = icon_dp × ui_scale / zoom
  func _process(_delta: float) -> void     # for k in 0..alive_count: i = alive[k]; x = lerp(prev, pos, alpha); set_instance_transform_2d(k, Transform2D(heading, Vector2(x, y))); set_instance_color(k, tint); set_instance_custom_data(k, frame_uv); visible_instance_count = alive_count
  ```
  Shader (`canvas_item`): vertex scales the quad by `icon_scale` uniform and rotates by the instance transform; fragment samples `atlas` at `INSTANCE_CUSTOM.xy + UV × INSTANCE_CUSTOM.zw`, multiplies by `COLOR`.
- **Test-first:** (headless smoke) `test_bind_creates_multimesh_with_capacity`, `test_visible_count_tracks_alive` (spawn 5 threats through a CadSim, one `_process` → 5; kill 2 + cleanup → 3), `test_instance_positions_lerped` (alpha 0.5 → midpoint), `test_no_multimesh_reallocation_between_frames` (same `multimesh.get_rid()` after 60 frames, `instance_count` constant). Run: `tools/test.sh res://test/smoke/test_cad_threat_view.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; `_process` allocation-free (Transform2D/Vector2/Color are value types — allowed); classified decoys tint `text_dim`; SRBM tint `hostile_high`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-048.md`; STD-HANDOFF + a screenshot from the desktop run.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on device: 200 glyphs at 26 dp, one draw call for threats (`RENDER_TOTAL_DRAW_CALLS_IN_FRAME` in the overlay), no shimmer at 2× zoom.
- **Dependencies:** CAD-FP-043, CAD-FP-046, CAD-FP-047.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: `INSTANCE_CUSTOM` unavailable in the Compatibility canvas shader `[VERIFY]` → fall back to `set_instance_color` alpha-encoded frame index and report.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-049 — CadInterceptorView (MultiMesh)
- **ID:** CAD-FP-049 **Title:** CadInterceptorView (MultiMesh)
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** In-flight interceptors are drawn as heading-aligned friendly glyphs in one draw call.
- **Scope:** `src/view/world/cad_interceptor_view.gd`, `test/smoke/test_cad_interceptor_view.gd`; LOC ≤ 60.
- **Interface contract:** same as `CadThreatView` with `instance_count = CadConst.MAX_INTERCEPTORS`, reading `CadInterceptorStore` (heading from (pos − prev)), tint `palette.friendly`, frame `fx_trail` glyph scaled to 12 dp; `bind(driver, defs)`, `set_zoom(zoom)`.
- **Test-first:** `test_visible_count_tracks_alive`, `test_heading_from_motion`, `test_no_reallocation`. Run: `tools/test.sh res://test/smoke/test_cad_interceptor_view.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; shares `cad_icon.gdshader` (one material per view).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-049.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks draw-call count stays +1.
- **Dependencies:** CAD-FP-048.
- **Effort:** 1 agent session × 6 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-050 — CadTracerView (view-only tracers and hit flashes)
- **ID:** CAD-FP-050 **Title:** CadTracerView (view-only tracers and hit flashes)
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** Gun bursts and intercept hits produce short-lived tracers/flashes from a fixed pool of 3,000 MultiMesh instances without touching the sim.
- **Scope:** `src/view/world/cad_tracer_view.gd`, `test/smoke/test_cad_tracer_view.gd`; LOC ≤ 100.
- **Interface contract:**
  ```gdscript
  class_name CadTracerView
  extends MultiMeshInstance2D
  const POOL: int = 3000
  var ttl: PackedFloat32Array
  var from_x: PackedFloat32Array
  var from_y: PackedFloat32Array
  var to_x: PackedFloat32Array
  var to_y: PackedFloat32Array
  var kind: PackedInt32Array        # 0 tracer, 1 flash
  var live: int
  func bind(driver: CadSimDriver, world: CadWorldRefs) -> void   # connects CadEvents.sim_burst_fired → spawn tracer from emp pos to target pos (TTL 0.4 s); sim_intercept_hit → flash at (x, y) TTL 0.25 s; CadWorldRefs is a tiny RefCounted holding the sim reference for position lookups (declared in this card, ≤ 10 LOC)
  func spawn(k: int, fx: float, fy: float, tx: float, ty: float, ttl_s: float) -> void   # if live == POOL: overwrite the oldest (ring)
  func _process(delta: float) -> void   # decrement ttl; compact by swap-with-last; write transforms/colors; visible_instance_count = live
  ```
- **Test-first:** `test_spawn_ten_visible_ten`, `test_expire_after_ttl` (delta steps → 0 visible), `test_pool_never_exceeds_3000` (3,200 spawns → live 3,000), `test_burst_event_spawns_tracer` (emit `sim_burst_fired` → live 1). Run: `tools/test.sh res://test/smoke/test_cad_tracer_view.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; `_process` allocation-free; VFX randomness (tracer jitter ±1.5 dp) from a view-local `RandomNumberGenerator`, never the sim's.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-050.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on device: AAA bursts visible as streaks; `render_ms` delta ≤ 1 ms with 1,000 live tracers (bench scene).
- **Dependencies:** CAD-FP-048.
- **Effort:** 1–2 agent sessions × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-051 — CadEmplacementView pool with range rings
- **ID:** CAD-FP-051 **Title:** CadEmplacementView pool with range rings
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** Each placed emplacement has a pooled Node2D view (glyph, range ring, ammo bar, state tint) updated only on events.
- **Scope:** `scenes/world/cad_emplacement_view.tscn`, `src/view/world/cad_emplacement_view.gd`, `src/view/world/cad_emplacement_views.gd` (pool manager), `test/smoke/test_cad_emplacement_views.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadEmplacementView
  extends Node2D
  @export var icon: Sprite2D              # region from CadAtlasMap
  @export var ring: Node2D                # _draw: draw_arc radius range_max_m (or detect_ref × 0.5 for radars), width 1.5 dp / zoom, colour by kind (B.13 ring styles), fill alpha 0.06
  @export var ammo_bar: Node2D            # _draw: bar 24×3 dp under the icon
  var emp_index: int = -1
  func show_for(index: int, emp: CadEmplacement, def: CadEmplacementDef, atlas: CadAtlasMap, palette: CadPalette) -> void
  func refresh(emp: CadEmplacement) -> void        # tint by state (ACTIVE friendly, RELOADING warning, DESTROYED danger), ammo bar, selection ring
  func set_selected(v: bool) -> void
  func hide_view() -> void

  class_name CadEmplacementViews
  extends Node2D
  const POOL: int = CadConst.MAX_EMPLACEMENTS
  var views: Array[CadEmplacementView]      # instantiated once at _ready
  func bind(driver: CadSimDriver, defs: CadDefs, atlas: CadAtlasMap, palette: CadPalette) -> void   # connects sim_command_result (PLACE/SELL ok), sim_emplacement_damaged/destroyed, sim_reload_started/done, sim_shot_fired, sim_burst_fired, ui_emplacement_selected
  func view_for(index: int) -> CadEmplacementView
  func set_zoom(zoom: float) -> void        # rings queue_redraw
  ```
- **Test-first:** `test_pool_created_at_ready_64_hidden`, `test_place_shows_view_with_ring_radius` (SHORAD → 6,000), `test_sell_hides_and_returns_to_pool`, `test_no_nodes_created_after_ready` (node count constant across place/sell), `test_reload_event_tints_warning`, `test_selection_ring_toggle`. Run: `tools/test.sh res://test/smoke/test_cad_emplacement_views.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; no `_process` in these nodes; `queue_redraw` only on events or zoom change; all 64 views instantiated at `_ready`, never freed.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-051.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on device: rings legible at full-map zoom; 60 emplacements ≤ 60 draw calls (rings are `_draw` per node — if > 60, the VS optimisation epic moves rings to one MultiMesh/shader).
- **Dependencies:** CAD-FP-043, CAD-FP-046, CAD-FP-047.
- **Effort:** 2 agent sessions × 15 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-052 — Radar sweep shader and CadRadarSweepView
- **ID:** CAD-FP-052 **Title:** Radar sweep shader and CadRadarSweepView
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** Search radars show a rotating 30° sweep wedge inside their detection ring, pausing with the game.
- **Scope:** `src/view/shaders/cad_radar_sweep.gdshader`, `src/view/world/cad_radar_sweep_view.gd`, `test/smoke/test_cad_radar_sweep_view.gd`; LOC ≤ 70 (shader ≤ 25).
- **Interface contract:** `class_name CadRadarSweepView extends Node2D`; pool of 32 `Sprite2D` children (1×1 white texture scaled to ring diameter) sharing one `ShaderMaterial` per instance with uniforms `angle` (radians), `wedge` (0.5236), `color`; `bind(driver, defs, palette)`; on PLACE/SELL/DESTROY of a sensor kind: assign/free a sprite; `_process(delta)`: `angle += delta × TAU / 4.0` on all live sprites (`process_mode = PROCESS_MODE_PAUSABLE`; also frozen when driver speed is 0 — the sweep is cosmetic and follows game speed: `angle += delta × speed`).
- **Test-first:** `test_sprite_assigned_per_search_radar`, `test_angle_advances_with_speed_and_freezes_at_0`, `test_free_on_sell`. Run: `tools/test.sh res://test/smoke/test_cad_radar_sweep_view.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; fragment shader: alpha = smoothstep over angular distance behind `angle`, 0 outside the unit circle.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-052.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on device: sweep visible, no banding, ≤ 1 draw call per radar.
- **Dependencies:** CAD-FP-051.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-053 — CadMapView (grid, districts, build zones, axis)
- **ID:** CAD-FP-053 **Title:** CadMapView (grid, districts, build zones, axis)
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** The tactical map background — grid, district polygons tinted by health, build zones in BUILD state, threat-axis marker — draws once and redraws only on events.
- **Scope:** `src/view/world/cad_map_view.gd`, `test/smoke/test_cad_map_view.gd`; LOC ≤ 100.
- **Interface contract:** `class_name CadMapView extends Node2D`; `bind(driver, map: CadMapDef, palette)`; `_draw()`: background rect `palette.bg`, 1,000 m grid `palette.grid`, each district `draw_colored_polygon` lerp(`district_hit`, `district_ok`, hp/max) + outline, district labels (`draw_string` with theme font, 14 dp / zoom) only when zoom > threshold, build zones outline (`friendly_dim`) when `CadApp.state == BUILD`, spawn line + axis chevrons (`hostile` at alpha 0.5); `redraw_on(district_damaged, ui_state_changed)`; `set_zoom(zoom)`; `set_processing(false)` (no `_process`).
- **Test-first:** `test_redraw_requested_on_district_damage` (subclass counter on `queue_redraw`), `test_no_processing`, `test_draw_runs_without_error_headless` (call `_draw` via `queue_redraw` + one frame — headless `_draw` executes `[VERIFY]`; otherwise assert the polygon cache built by `bind`). Run: `tools/test.sh res://test/smoke/test_cad_map_view.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; polygons cached at bind (no per-draw allocation of arrays; `draw_colored_polygon` takes the cached `PackedVector2Array`).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-053.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on device: districts readable, grid not dominant, ≤ 3 draw calls for the map.
- **Dependencies:** CAD-FP-043, CAD-FP-047, CAD-FP-018.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-054 — CadCamera (pinch zoom, pan, bounds)
- **ID:** CAD-FP-054 **Title:** CadCamera (pinch zoom, pan, bounds)
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** One-finger pan, two-finger pinch zoom (Android gestures) and mouse-wheel zoom move a bounded camera and broadcast zoom to views.
- **Scope:** `src/view/world/cad_camera.gd`, `test/unit/view/test_cad_camera.gd`; LOC ≤ 100.
- **Interface contract:**
  ```gdscript
  class_name CadCamera
  extends Camera2D
  signal zoom_changed(zoom: float)
  @export var min_zoom: float = 0.096     # full map on 1920 px
  @export var max_zoom: float = 0.5
  var world_min: Vector2
  var world_max: Vector2
  var pan_enabled: bool = true            # false while placing
  func bind(map: CadMapDef) -> void
  func _unhandled_input(event: InputEvent) -> void   # InputEventMagnifyGesture → zoom × factor about the gesture position; InputEventPanGesture → pan by delta / zoom; InputEventScreenDrag (single finger) → pan; InputEventMouseButton wheel up/down → zoom × 1.1 / 0.9 about the cursor
  func apply_zoom(z: float, about_screen: Vector2) -> void   # clamps; keeps the world point under `about_screen` fixed; emits zoom_changed
  func clamp_position() -> void
  ```
- **Test-first:** `test_zoom_clamped`, `test_zoom_about_point_keeps_world_point`, `test_pan_moves_by_delta_over_zoom`, `test_position_clamped_to_bounds`, `test_pan_disabled_ignores_drag`, `test_wheel_zoom`. Run: `tools/test.sh res://test/unit/view/test_cad_camera.gd` (events constructed in code and passed to `_unhandled_input`).
- **Constraints:** STD-TYPING, STD-VIEW; requires `input_devices/pointing/android/enable_pan_and_scale_gestures=true` (D1.1) `[VERIFY the events arrive on Android; fallback: two-finger distance tracking from InputEventScreenTouch/Drag, ≤ 30 LOC, documented]`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-054.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on device: pinch/pan feel, no jump on the second finger down, zoom limits sensible.
- **Dependencies:** CAD-FP-043.
- **Effort:** 1–2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-055 — CadUiScale and CadSafeArea
- **ID:** CAD-FP-055 **Title:** CadUiScale and CadSafeArea
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** UI sizes track physical dp on every phone and never sit under cutouts.
- **Scope:** `src/view/ui/cad_ui_scale.gd`, `src/view/ui/cad_safe_area.gd`, `test/unit/view/test_cad_ui_scale.gd`; LOC ≤ 60.
- **Interface contract:** `class_name CadUiScale extends Node`; `static func factor_for(dpi: float, window_width_px: int) -> float` = `clamp(dpi / 160.0 × 0.5, 0.75, 1.5)` further limited so that 1920 × factor ≤ window width × 1.25 `[HUMAN may retune at Gate 3]`; `_ready`: applies to `get_tree().root.content_scale_factor` using `DisplayServer.screen_get_dpi()` and `get_window().size`; reapplies on `size_changed`. `class_name CadSafeArea extends MarginContainer`; `static func margins_for(safe: Rect2i, window: Rect2i) -> PackedInt32Array` (left, top, right, bottom); `_ready` and `size_changed` apply `DisplayServer.get_display_safe_area()`.
- **Test-first:** `test_factor_examples` (160 → 0.75; 420 → 1.3125; 640 → 1.5), `test_factor_limited_by_window_width` (720 px wide → ≤ 0.469? no: rule yields max(0.75, …) — assert the documented formula), `test_margins_from_rects` (safe inset 80 px at top → top 80, others 0), `test_nodes_apply_without_error_headless`. Run: `tools/test.sh res://test/unit/view/test_cad_ui_scale.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; both nodes `PROCESS_MODE_ALWAYS`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-055.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on both devices: a 48 dp button measures ≈ 8 mm with a ruler; HUD clear of the cutout.
- **Dependencies:** CAD-FP-047.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-056 — CadHud (funds, integrity, wave, speed controls)
- **ID:** CAD-FP-056 **Title:** CadHud (funds, integrity, wave, speed controls)
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** The top bar shows funds, city integrity and wave; the bottom-right cluster switches pause/1×/2×/3×.
- **Scope:** `scenes/ui/cad_hud.tscn`, `src/view/ui/cad_hud.gd`, `test/smoke/test_cad_hud.gd`; LOC ≤ 80.
- **Interface contract:** `class_name CadHud extends Control`; `%FundsLabel`, `%IntegrityLabel`, `%WaveLabel`, `%SpeedButtons` (4 `Button`s 48 dp with `ui_glyph_*` icons; `ButtonGroup`); `bind(driver)`; updates labels only on `sim_funds_changed`, `sim_district_damaged`, `sim_wave_started`, `sim_wave_cleared` (integrity read from `driver.sim.integrity()`); speed buttons → `driver.set_speed(n)`; reflects `ui_speed_changed` (pressed state); speed cluster hidden in BUILD (only ‖ shown as disabled).
- **Test-first:** `test_labels_update_on_signals`, `test_speed_button_sets_driver_speed`, `test_no_process_callback`, `test_speed_cluster_visibility_by_state`. Run: `tools/test.sh res://test/smoke/test_cad_hud.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; string formatting only when the value changed (cache ints).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-056.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human: speed buttons reachable with the right thumb on the mid device; text 18/24 dp.
- **Dependencies:** CAD-FP-043, CAD-FP-047, CAD-FP-055.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-057 — CadBuildBar
- **ID:** CAD-FP-057 **Title:** CadBuildBar
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** A one-thumb bottom bar lists purchasable emplacements with cost and affordability and starts placement.
- **Scope:** `scenes/ui/cad_build_bar.tscn`, `src/view/ui/cad_build_bar.gd`, `test/smoke/test_cad_build_bar.gd`; LOC ≤ 80.
- **Interface contract:** `class_name CadBuildBar extends Control`; `bind(driver, defs, atlas)`; builds one 64 dp `Button` per def with `tech_required == &""` (VS adds unlocked-tech filtering through the same function `is_available(def) -> bool`), icon from atlas, cost label 14 dp; `sim_funds_changed` → `disabled = cost > funds`; press → `CadEvents.ui_build_item_selected(def_index)` and toggles the pressed state; `ui_build_item_selected(-1)` clears; hidden in WAVE state; `HScrollContainer` when > 7 items.
- **Test-first:** `test_three_buttons_in_fp_data`, `test_disabled_when_unaffordable`, `test_press_emits_def_index`, `test_hidden_in_wave_state`. Run: `tools/test.sh res://test/smoke/test_cad_build_bar.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; buttons created once at bind.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-057.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human: bar within the bottom 25 % and right 40 % reach zone; cost readable at 14 dp.
- **Dependencies:** CAD-FP-056, CAD-FP-021.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-058 — CadPlacementController (drag-to-place ghost, tap-to-select)
- **ID:** CAD-FP-058 **Title:** CadPlacementController (drag-to-place ghost, tap-to-select)
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** After picking a build item, a ghost follows the finger, shows validity, and a confirm tap enqueues PLACE; tapping an emplacement selects it.
- **Scope:** `src/view/ui/cad_placement_controller.gd`, `scenes/ui/cad_placement_confirm.tscn` (Confirm/Cancel 48 dp buttons anchored above the ghost), `test/unit/view/test_cad_placement_controller.gd`; LOC ≤ 110.
- **Interface contract:**
  ```gdscript
  class_name CadPlacementController
  extends Node2D
  enum Mode { IDLE, PLACING }
  var mode: int
  var def_index: int = -1
  var ghost_pos: Vector2
  var valid: bool
  @export var ghost: Sprite2D
  @export var ring: Node2D
  func bind(driver: CadSimDriver, camera: CadCamera, defs: CadDefs, atlas: CadAtlasMap, palette: CadPalette) -> void   # listens to ui_build_item_selected
  func _unhandled_input(event: InputEvent) -> void   # PLACING: ScreenDrag/MouseMotion moves ghost (world coords via camera); validity = sim.emplacements.can_place(...) == OK and funds ≥ cost; IDLE: ScreenTouch release without drag → find_at(world, 60 dp / zoom) → ui_emplacement_selected(index or -1)
  func confirm() -> void     # if valid: cmd = queue.acquire(); type PLACE; def_index; x, y; enqueue; mode IDLE; ui_build_item_selected(-1)
  func cancel() -> void
  ```
- **Test-first:** `test_select_item_enters_placing`, `test_drag_moves_ghost_and_validity` (inside zone + affordable → valid; outside → invalid), `test_confirm_enqueues_place_command_with_coords`, `test_confirm_invalid_does_nothing`, `test_tap_selects_nearest_emplacement`, `test_cancel_returns_idle`, `test_pan_disabled_while_placing`. Run: `tools/test.sh res://test/unit/view/test_cad_placement_controller.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; `can_place` is a read-only sim query (allowed); all placement happens through the command queue.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-058.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on device: placement precise under the finger (ghost offset 40 dp above the fingertip), no accidental placement on pan.
- **Dependencies:** CAD-FP-057, CAD-FP-054, CAD-FP-051.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-059 — CadInspector (stats, ROE, restock, sell)
- **ID:** CAD-FP-059 **Title:** CadInspector (stats, ROE, restock, sell)
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** A slide-in panel shows the selected emplacement and issues doctrine, restock and sell commands.
- **Scope:** `scenes/ui/cad_inspector.tscn`, `src/view/ui/cad_inspector.gd`, `test/smoke/test_cad_inspector.gd`; LOC ≤ 110.
- **Interface contract:** `class_name CadInspector extends PanelContainer`; `bind(driver, defs)`; on `ui_emplacement_selected(i)`: show name, hp/max, ammo/capacity, stock/stock_max, upkeep, kills; ROE `OptionButton` (HOLD/TIGHT/FREE) and priority `OptionButton` (4 values) → SET_DOCTRINE (a = roe, b = priority, c = min value); `Restock` button → RESTOCK (a = rounds to fill stock to max, cost shown, disabled if unaffordable or full); `Sell` button (confirm dialog) → SELL; `Close`; refresh on `sim_command_result`, `sim_reload_done`, `sim_shot_fired`, `sim_burst_fired` for the selected index only; in WAVE state only doctrine controls are enabled.
- **Test-first:** `test_shows_selected_values`, `test_roe_change_enqueues_set_doctrine`, `test_restock_enqueues_rounds_and_disabled_when_unaffordable`, `test_sell_enqueues_after_confirm`, `test_wave_state_locks_purchase_buttons`, `test_deselect_hides`. Run: `tools/test.sh res://test/smoke/test_cad_inspector.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; labels updated only for the selected index; strings from `CadStrings`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-059.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human on device: panel does not cover the selected emplacement; controls ≥ 48 dp.
- **Dependencies:** CAD-FP-058, CAD-FP-029.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-060 — CadBuildPhase (BUILD ↔ WAVE ↔ DEBRIEF flow, intel v0, auto-restock)
- **ID:** CAD-FP-060 **Title:** CadBuildPhase (BUILD ↔ WAVE ↔ DEBRIEF flow, intel v0, auto-restock)
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** The core loop's phase transitions, the Start Wave button, next-wave intel and auto-restock are wired through CadApp and the command queue.
- **Scope:** `src/view/ui/cad_build_phase.gd`, `scenes/ui/cad_build_ui.tscn` (Start Wave 64 dp bottom-right, auto-restock `CheckButton`, intel panel top-left), `test/smoke/test_cad_build_phase.gd`; LOC ≤ 100.
- **Interface contract:** `class_name CadBuildPhase extends Node`; `bind(driver, defs)`; on entering BUILD: if `auto_restock` → enqueue RESTOCK for each launcher, cheapest `ammo_cost` first, while `funds ≥ 2 × cost` (B.6); intel v0: generate the next wave's plan into a scratch `CadWavePlan` with a copy of the WAVEGEN state (peek without consuming: save state, generate, restore state) and show counts per class (quality 1.0 in FP); Start Wave → `sim.start_wave()`, `CadApp.goto(WAVE)`; on `sim_wave_cleared` → `sim.end_wave()` → `CadApp.goto(DEBRIEF)`; on `sim_run_ended` → `CadApp.goto(RUN_END)`; on integrity 0 detected via `driver.ticked` → `sim.run_over` path.
- **Test-first:** `test_start_wave_transitions_and_generates`, `test_wave_cleared_goes_to_debrief_with_report`, `test_run_over_goes_to_run_end`, `test_auto_restock_order_and_funds_rule`, `test_intel_peek_does_not_consume_rng` (plan after peek equals plan without peek). Run: `tools/test.sh res://test/smoke/test_cad_build_phase.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; intel peek uses `rng.get_states/set_states` (sim API), never a second RNG.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-060.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human: the loop BUILD → WAVE → DEBRIEF → BUILD runs 5 times on desktop without manual intervention beyond Start/Continue.
- **Dependencies:** CAD-FP-059, CAD-FP-042, CAD-FP-038.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-061 — CadDebrief screen and CadWaveStats
- **ID:** CAD-FP-061 **Title:** CadDebrief screen and CadWaveStats
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** After each wave the player sees the income table, kills/leaks by class and the exchange ratio, then continues to BUILD.
- **Scope:** `src/view/ui/cad_wave_stats.gd`, `scenes/ui/cad_debrief.tscn`, `src/view/ui/cad_debrief.gd`, `test/smoke/test_cad_debrief.gd`; LOC ≤ 100.
- **Interface contract:** `class_name CadWaveStats extends Node` — counters per threat def (`kills`, `leaks`, `crashes`: `PackedInt32Array`), `shots`, `bursts`, `cr_spent` (from SHOT/BURST events × ammo_cost), `reset()`; `exchange_ratio() -> float` = cr_spent / max(1, killed enemy CR); `class_name CadDebrief extends Control`; `show_report(report: CadIncomeReport, stats: CadWaveStats, defs)`: rows District income / Salvage / Wave bonus (with quality %) / Upkeep / Net; per-class kills–leaks table; exchange ratio; `Continue` → `CadApp.goto(BUILD)`.
- **Test-first:** `test_stats_count_events`, `test_exchange_ratio`, `test_debrief_shows_report_values` (labels contain "980"), `test_continue_goes_to_build`. Run: `tools/test.sh res://test/smoke/test_cad_debrief.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; the stats node counts from `CadEvents` signals (no sim access).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-061.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human checks the table reads top-down in ≤ 5 s on the low device.
- **Dependencies:** CAD-FP-060, CAD-FP-047.
- **Effort:** 1 agent session × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-062 — Title, run-end and pause-menu screens
- **ID:** CAD-FP-062 **Title:** Title, run-end and pause-menu screens
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** The app can start a run from a title screen, end it with a result screen, and pause/resume/quit from an overlay.
- **Scope:** `scenes/ui/cad_title.tscn` + `src/view/ui/cad_title.gd`, `scenes/ui/cad_run_end.tscn` + `src/view/ui/cad_run_end.gd`, `scenes/ui/cad_pause_menu.tscn` + `src/view/ui/cad_pause_menu.gd`, `test/smoke/test_cad_screens.gd`; LOC ≤ 90.
- **Interface contract:** `CadTitle`: `New run` → `CadApp.new_run(&"map_01", int(Time.get_unix_time_from_system()))` then `goto(BUILD)`; `Quit` → `get_tree().quit()`; version label from `ProjectSettings.get_setting("application/config/version")`. `CadRunEnd`: `show_result(victory: bool, waves: int)`; `Back to title` → `CadApp.end_run()`, `goto(TITLE)`. `CadPauseMenu` (CanvasLayer overlay, `PROCESS_MODE_WHEN_PAUSED`): `Resume` → `goto(previous)`, `Quit to title` (confirm) → `end_run`, `goto(TITLE)`.
- **Test-first:** `test_new_run_creates_sim_and_goes_to_build`, `test_run_end_shows_waves_and_returns_to_title`, `test_pause_menu_resume_restores_state`, `test_scenes_instantiate_headless_without_errors`. Run: `tools/test.sh res://test/smoke/test_cad_screens.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; all buttons ≥ 48 dp; strings from `CadStrings`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-062.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human: pause overlay blocks map input; Quit confirm prevents accidental loss.
- **Dependencies:** CAD-FP-060, CAD-FP-047.
- **Effort:** 1 agent session × 8 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-063 — Scene assembly: boot and world scenes, scene-flow smoke test
- **ID:** CAD-FP-063 **Title:** Scene assembly: boot and world scenes, scene-flow smoke test
- **Milestone:** FP **Workstream:** ENG-UI **Owner:** agent
- **Goal:** All views, UI and the driver are wired in one world scene; the app boots, loads defs, and runs the full state loop headless with zero orphans.
- **Scope:** `scenes/app/cad_boot.tscn` + `src/view/ui/cad_boot.gd`, `scenes/world/cad_world.tscn` + `src/view/world/cad_world.gd`, `test/smoke/test_scene_flow.gd`; LOC ≤ 100.
- **Interface contract:** `CadBoot`: `CadApp.defs = CadDefs.load_from()`; `CadStrings.load_csv`; preload scenes into `CadApp.scenes`; `goto(TITLE)` after one frame. `CadWorld` (root Node2D of `cad_world.tscn`): children in order `CadMapView`, `CadEmplacementViews`, `CadRadarSweepView`, `CadThreatView`, `CadInterceptorView`, `CadTracerView`, `CadPlacementController`, `CadCamera`, `CadSimDriver`, `CadFrameStats`, `CanvasLayer/CadSafeArea/{CadHud, CadBuildBar, CadInspector, CadBuildPhase UI}`, `CadWaveStats`, `CadBuildPhase`; `_ready`: `driver.attach(CadApp.sim)`; bind every view; `camera.zoom_changed` → every `set_zoom`.
- **Test-first:** `test_boot_loads_defs_and_goes_to_title`, `test_full_loop_headless` (TITLE → new run → BUILD → place 3 → start wave → run 600 frames of `_process` at speed 3 → threat view visible > 0 at some frame → DEBRIEF reached or 5,400 ticks), `test_zero_orphans_after_return_to_title` (`Performance.OBJECT_ORPHAN_NODE_COUNT == 0`), `test_no_scene_load_during_wave` (`ResourceLoader` not called: spy via `CadApp.scenes` preloaded check — all scenes present before WAVE). Run: `tools/test.sh res://test/smoke/test_scene_flow.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; `run/main_scene` = `res://scenes/app/cad_boot.tscn` (already in D1.1).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-063.md`; STD-HANDOFF.
- **Definition of Done:** STD-DOD; desktop run (`"$GODOT_BIN" --path .`) plays 5 waves.
- **Verification gates:** human plays 5 waves on desktop with the debug overlay on; no editor warnings; orphan count 0 in the overlay after returning to title.
- **Dependencies:** CAD-FP-044, CAD-FP-048, CAD-FP-049, CAD-FP-050, CAD-FP-051, CAD-FP-052, CAD-FP-053, CAD-FP-054, CAD-FP-055, CAD-FP-056, CAD-FP-057, CAD-FP-058, CAD-FP-059, CAD-FP-060, CAD-FP-061, CAD-FP-062.
- **Effort:** 2 agent sessions × 20 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: orphan nodes after 2 attempts → human debugs with the remote scene tree (Gate 2 allocation & lifetime audit).
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-064 — CadLifecycle (Android pause/resume, back gesture)
- **ID:** CAD-FP-064 **Title:** CadLifecycle (Android pause/resume, back gesture)
- **Milestone:** FP **Workstream:** ENG-PLAT **Owner:** agent
- **Goal:** Backgrounding the app pauses the game; the back gesture opens/closes the pause menu and never hard-exits mid-run.
- **Scope:** `src/view/platform/cad_lifecycle.gd` (child of the boot/app root, `PROCESS_MODE_ALWAYS`), `test/unit/view/test_cad_lifecycle.gd`; LOC ≤ 50.
- **Interface contract:** `class_name CadLifecycle extends Node`; `_notification(what)`: `NOTIFICATION_APPLICATION_PAUSED` → if state ∈ {BUILD, WAVE} → `CadApp.goto(PAUSED)`; `NOTIFICATION_APPLICATION_RESUMED` → no state change (user taps Resume); `NOTIFICATION_APPLICATION_FOCUS_OUT` → same as PAUSED during WAVE only; `NOTIFICATION_WM_GO_BACK_REQUEST` → PAUSED → `goto(previous)`; BUILD/WAVE → `goto(PAUSED)`; DEBRIEF/RUN_END → ignored; TITLE → `get_tree().quit()`; constants referenced as `Node.NOTIFICATION_APPLICATION_PAUSED` etc. `[VERIFY names on Node in 4.7; values believed 2015/2014/2017/1007]`.
- **Test-first:** `test_paused_notification_in_wave_goes_to_paused`, `test_paused_notification_in_title_ignored`, `test_back_in_wave_opens_pause_menu`, `test_back_in_paused_resumes`, `test_back_in_title_quits` (spy on a `quit_requested` signal added to the class for testability), `test_resumed_keeps_paused`. Run: `tools/test.sh res://test/unit/view/test_cad_lifecycle.gd` (notifications sent via `notification(Node.NOTIFICATION_…)`).
- **Constraints:** STD-TYPING, STD-VIEW; `application/config/quit_on_go_back=false` already set (D1.1).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-064.md`; STD-HANDOFF + the constants' actual values printed by a one-off `print` in the test (recorded in A.0).
- **Definition of Done:** STD-DOD; `docs/qa/manual_android_fp.md` steps for lifecycle (G.5) drafted by the agent in this card.
- **Verification gates:** human on both devices: Home during WAVE → paused overlay; back gesture behaviour per state; no crash on 10 rapid pause/resume cycles.
- **Dependencies:** CAD-FP-063, CAD-FP-062.
- **Effort:** 1 agent session × 12 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: a constant does not exist → agent records and stops (no guessing numeric values).
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-065 — Android debug export preset, scripts and CI APK job
- **ID:** CAD-FP-065 **Title:** Android debug export preset, scripts and CI APK job
- **Milestone:** FP **Workstream:** ENG-PLAT **Owner:** agent
- **Goal:** A debug APK is produced locally and by CI from the committed preset, installs on both devices, and stays under the size proxy.
- **Scope:** `export_presets.cfg` (preset 0 exactly as D1.2), `tools/export_debug.sh/.cmd`, `tools/device_run.sh`, `tools/icon_export.gd` (renders `art/icons/cad_icon.svg` to 192 px and 432 px PNGs), `art/icons/*.png`, `.github/workflows/ci.yml` (+ `android-debug` job per D5.2), `docs/toolchain.md` (editor settings D1.3), `docs/qa/manual_android_fp.md` (full G.5 subset for FP); no GDScript LOC beyond `icon_export.gd` ≤ 30.
- **Interface contract:** as D1.2/D5.2/D5.3; CI job runs on push to `main` and PRs labelled `apk`; artifact `cad-debug.apk`; size assertion ≤ 94,371,840 bytes.
- **Test-first:** Run: local: `tools/export_debug.sh` exits 0, `build/cad-debug.apk` exists; `adb install -r build/cad-debug.apk` succeeds on both devices (human pastes output); CI: `android-debug` green on the PR (labelled), artifact downloadable; `unzip -l build/cad-debug.apk | grep lib/` shows only `arm64-v8a`.
- **Constraints:** no keystore fields in the preset; no gradle build for the debug APK; every `[VERIFY]` in D1.2 resolved and recorded in the handoff (option names accepted by Godot 4.7).
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-065.md`; STD-HANDOFF + accepted/rejected preset keys + CI run URL.
- **Definition of Done:** STD-DOD; both devices run the APK to the title screen.
- **Verification gates:** human installs from the CI artifact (not a local build) on both devices; checks the launcher icon and landscape orientation lock.
- **Dependencies:** CAD-FP-063, CAD-FP-005, CAD-FP-006, CAD-FP-007, CAD-FP-008.
- **Effort:** 2 agent sessions × 20 human minutes.
- **Abandon criteria:** STD-ABANDON; specific: CI cannot find the Android SDK → agent records `ANDROID_HOME` findings and stops; fallback: human-local export only for FP, CI job deferred to VS (logged in R-04).
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-066 — Render benchmark scene
- **ID:** CAD-FP-066 **Title:** Render benchmark scene
- **Milestone:** FP **Workstream:** ENG-REN **Owner:** agent
- **Goal:** A scene fills every view to its ceiling and logs frame time, draw calls and memory so Gate 3 has numbers on device.
- **Scope:** `scenes/bench/cad_bench_render.tscn`, `src/view/world/cad_bench_render.gd`, `tools/bench_render.sh` (desktop run), `test/smoke/test_cad_bench_render.gd`; LOC ≤ 90.
- **Interface contract:** `class_name CadBenchRender extends Node2D`; `@export var threats_n: int = 400`, `interceptors_n = 600`, `tracers_n = 3000`, `emplacements_n = 60`, `seconds: float = 60.0`; builds a `CadSim` with a synthetic map, allocates entities directly through the stores (bench-only exception, documented), binds the real views, animates positions each frame (sinusoidal drift so interpolation and transforms run), spawns tracers at 200/s, moves the camera zoom between min and max over 10 s; `CadFrameStats.dump_json("user://perf/render_bench.json")` at the end plus `RENDER_TOTAL_DRAW_CALLS_IN_FRAME` and `RENDER_VIDEO_MEM_USED`; with user arg `--frames N` runs N frames then quits (headless smoke); launched on device via the debug overlay's "bench" button (only in debug builds: `OS.is_debug_build()`).
- **Test-first:** `test_headless_smoke_60_frames_writes_json`, `test_instance_counts_match_parameters`. Run: `tools/test.sh res://test/smoke/test_cad_bench_render.gd`.
- **Constraints:** STD-TYPING, STD-VIEW; excluded from release exports via `exclude_filter` when the release preset is created (E-AL-07) — the debug APK includes it.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-066.md`; STD-HANDOFF + desktop numbers.
- **Definition of Done:** STD-DOD.
- **Verification gates:** human runs it on both devices (CAD-FP-068).
- **Dependencies:** CAD-FP-063, CAD-FP-044.
- **Effort:** 1–2 agent sessions × 10 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-067 — Balance harness v0 (policy base, layered_basic, runner)
- **ID:** CAD-FP-067 **Title:** Balance harness v0 (policy base, layered_basic, runner)
- **Milestone:** FP **Workstream:** DES **Owner:** agent
- **Goal:** A scripted player policy plays waves 1–5 headless over many seeds and reports win rate and funds curves as JSON.
- **Scope:** `tools/balance/cad_balance_policy.gd`, `tools/balance/cad_policy_layered_basic.gd`, `tools/balance/cad_balance_run.gd`, `tools/balance.sh/.cmd`, `test/unit/tools/test_cad_balance_run.gd`; LOC ≤ 120.
- **Interface contract:**
  ```gdscript
  class_name CadBalancePolicy
  extends RefCounted
  func name() -> StringName
  func decide_build(sim: CadSim, wave_next: int, out: Array[CadCommand]) -> void   # commands acquired from sim.commands; called at each BUILD phase (allocation allowed: not tick-path)

  class_name CadPolicyLayeredBasic
  extends CadBalancePolicy               # G.2 row: radar → AAA ×2 → SHORAD → AAA → SHORAD along the axis at 2,000–4,000 m east of centre; restock all; repair cheapest first
  # runner: -- --map map_01 --policy layered_basic --seeds N --waves W --out reports/balance/
  # output <map>_<policy>.json: {"seeds":[{"seed":…, "waves_cleared":…, "funds":[…], "integrity":[…], "cr_spent":…, "cr_killed":…}], "win_rate_by_wave":[…]}; prints "OK win@W=<rate>"
  ```
- **Test-first:** `test_runner_two_seeds_two_waves_writes_json` (< 60 s), `test_layered_basic_first_build_places_radar_first`, `test_win_rate_by_wave_monotone_non_increasing`. Run: `tools/test.sh res://test/unit/tools/test_cad_balance_run.gd`.
- **Constraints:** STD-TOOL, STD-TYPING; the runner drives `CadSim` directly (no scene tree, no driver): `start_wave`, loop `step()` until cleared/run over/tick cap 10,800, `end_wave`.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-067.md`; STD-HANDOFF + the 40-seed wave-5 win rate.
- **Definition of Done:** STD-DOD; `layered_basic` wave-5 win rate ≥ 90 % over 40 seeds (G.2) — if not, the card is still done and a balance card is opened.
- **Verification gates:** human reads the JSON for one seed and the win-rate line.
- **Dependencies:** CAD-FP-040, CAD-FP-039.
- **Effort:** 2 agent sessions × 12 human minutes.
- **Abandon criteria:** STD-ABANDON.
- **Prompt template:** /ai/prompts/implement-from-card.md

---

### CAD-FP-068 — Gate 3: on-device profile of First Playable
- **ID:** CAD-FP-068 **Title:** Gate 3: on-device profile of First Playable
- **Milestone:** FP **Workstream:** PROD **Owner:** human
- **Goal:** Every D6 number is measured on both devices and written down, deciding go/no-go for the FP gate.
- **Scope:** both devices; `docs/perf-log.md` (table per device: date, build hash, metric, value, target, pass/fail); `docs/qa/manual_android_fp.md` executed.
- **Interface contract:** procedure: install the CI artifact → run `cad_bench_render` (overlay button) → copy `user://perf/render_bench.json` via `adb shell run-as com.djdanou.cad cat files/perf/render_bench.json` `[VERIFY user:// path on Android = files/]` → run `tools/bench.sh` numbers on device via the overlay "sim bench" button (CAD-FP-041 runner embedded in the debug build) → play 5 waves at 1× and 3× with the overlay on → record p95, hitches, draw calls, sim/ui/render ms → `adb shell dumpsys meminfo com.djdanou.cad` → `adb shell am start -W` cold start ×3 → execute the manual lifecycle script.
- **Test-first:** the pass/fail column of `docs/perf-log.md` against D6 targets for the low device (30 fps tier) and mid device (60 fps tier).
- **Constraints:** measurements on battery, 50 % brightness, no charger, airplane mode; the same build hash on both devices.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-068.md`; STD-HANDOFF items 1, 3, 4, 6 with the perf-log rows.
- **Definition of Done:** all rows filled; failures each mapped to an optimisation card id or a kill-criterion decision (C.2).
- **Verification gates:** this card is the gate.
- **Dependencies:** CAD-FP-065, CAD-FP-066, CAD-FP-041, CAD-FP-008.
- **Effort:** 0 agent sessions × 120 human minutes (agent assists via /ai/prompts/profile-and-report.md when a failure needs analysis).
- **Abandon criteria:** not applicable.
- **Prompt template:** none — human card (assist: /ai/prompts/profile-and-report.md).

---

### CAD-FP-069 — First Playable gate review and retune
- **ID:** CAD-FP-069 **Title:** First Playable gate review and retune
- **Milestone:** FP **Workstream:** AIOPS **Owner:** human
- **Goal:** The FP Definition of Done is checked item by item, metrics are read, the delegation matrix is retuned, and the VS epics are expanded into cards.
- **Scope:** `docs/production/02-milestones.md` (tick the FP checklist with date), `docs/decisions/ADR-001-fp-gate.md`, `ai/metrics/metrics.csv` (complete review columns), `docs/production/04-workstreams.md` E.7 (retune edits if H4 rules trip), `docs/production/09-execution-backlog.md` (VS cards appended via the appendix prompt).
- **Interface contract:** ADR-001 sections: DoD results, kill criteria evaluated (with the numbers), H4 metrics summary (`python tools/ai_metrics.py --last 69`), retune decisions (R1–R6), Godot patch decision (A-43), next milestone start date.
- **Test-first:** every FP DoD checkbox has a date and evidence link (perf-log row, CI run, test name); `tools/ai_metrics.py` output pasted.
- **Constraints:** no new feature cards until the ADR is committed.
- **Handoff & takeover artifacts:** `/ai/handoffs/CAD-FP-069.md`; STD-HANDOFF items 1, 3, 6.
- **Definition of Done:** ADR-001 committed; VS epic expansion started (E-VS-01 first).
- **Verification gates:** this card is the review.
- **Dependencies:** CAD-FP-068, CAD-FP-067, CAD-FP-064.
- **Effort:** 0 agent sessions × 90 human minutes (+ 1 agent session to expand E-VS-01 using the appendix prompt).
- **Abandon criteria:** not applicable.
- **Prompt template:** none — human card (expansion: the appendix prompt in the brief, executed with /ai/prompts/implement-from-card.md conventions).

---

## I2 Epics: Vertical Slice through Beta

Each epic is expanded into cards with the appendix prompt ("expand epic <id>"), using the §7 template, ≤ 120 LOC per card, failing-test-first, handoff artefacts, and only contracts that exist or are defined by their own card. Estimated card counts feed C.1.

### Vertical Slice (VS)

| epic | outcome | contracts to define (new cards) | tests to define | est. cards |
|------|---------|----------------------------------|-----------------|-----------|
| E-VS-01 Kill chain complete | FCR tracks, C2 links, friendly EW, decoy classification, recon reveal, jammer field, threat classes FPV/recon/decoy/jammer active; emplacements FCR, C2, EW, passive, depot, repair unlocked (CSV `tech_required` cleared) | `CadEwSystem` (compute_fields, apply), `CadThreatMotion` ORBIT/REVEAL/JAM_ORBIT/PASS_THROUGH profiles, `CadEmplacementStore.recompute_links` C2 graph (already stubbed), `CadEmplacement` depot/repair effects, `CadSensorSystem.jam_at_emp` producer | scenario: EW link-loss rate ±20 % of B.4 EW row; decoy classified by FCR after 8 s and by passive instantly; recon reveals emplacements after 10 s; jammer halves radar range at 2,500 m; C2-unlinked MRSAM fires ORGANIC only | 14 |
| E-VS-02 Waves 6–12 content and intel | phases P2–P3 live; packages strike/saturation/probe; intel quality model (B.7) | `CadWaveGenerator.intel(plan, quality, rng, out_min, out_max)`, `CadIntelReport` | generator caps and decoy ratio; intel ranges contain the truth at quality 0.5 and equal it at 1.0 | 5 |
| E-VS-03 Doctrine, manual fire, relocate, repair UI | inspector doctrine panel (priority, min value, salvo), manual fire mode (tap launcher → tap threat), relocate (drag existing), district repair from the map, sell confirm | commands RELOCATE, REPAIR_DISTRICT, MANUAL_FIRE wiring in `CadSim.apply_command`; `CadPlacementController` modes RELOCATING/TARGETING; non-engagement reason glyphs (R-23) via `CadEvents.sim_engage_denied(emp, reason)` | scenario: doctrine change mid-wave alters targets; manual fire cooldown; relocate penalty ticks | 9 |
| E-VS-04 VFX pass 1 | hit flash, miss puff, wander spiral, crash mark, impact ring, jam haze, link-lost glyph, detection blip | `CadFxView` (pooled MultiMesh, ≤ 2,000), palette-driven | pool never grows; each event type spawns one fx | 6 |
| E-VS-05 Save/load and lifecycle save | JSON save at BUILD entry and RUN_END, Continue on title, migrations v1, corrupt-file handling, save-on-`APPLICATION_PAUSED` flush | `CadSave` (write/read atomic), `CadSaveMigrations`, `CadSim.snapshot() -> Dictionary` / `CadSim.restore(d)` at wave boundary, `CadSaveCodec` for emplacements/doctrine/districts/rng | round-trip equality of snapshot → save → load → snapshot; 50-cycle kill/restore loop (manual); fixture per version | 8 |
| E-VS-06 Sprite set 2 and theme polish | all 24 entity glyphs + 12 UI glyphs, inspector/debrief layout polish, readability at 4 mm | none (art) | SVG palette/parse tests extended; atlas byte-equality | 3 |
| E-VS-07 Audio pass 1 | bus layout, `CadAudio` pooled SFX with caps, 12 SFX mapped to events, licence rows | `CadAudio.play(sfx_id, x, y)`, `CadAudioMap` resource (event → sfx ids, cap) | concurrency cap; pool size fixed; every sfx has a licence row (CI) | 5 |
| E-VS-08 Campaign/title flow | title → campaign select (map 1 only) → run; best-wave display; settings overlay (volumes, UI scale ±, rings toggle) | `CadSettings` resource + persistence in the save file | settings persist across restart | 4 |
| E-VS-09 Balance harness v1 | policies layered_optimal, sam_spam, aaa_spam, turtle, greedy_econ; Markdown summary; CI manual-dispatch job | `CadBalanceReport.write_summary_md` | G.2 expectations for waves 5 and 12 encoded as tests with tolerance | 6 |
| E-VS-10 Performance pass 1 | mid device 60 fps at 200 threats; rings to a single shader if draw calls > 120; speed governor (R-06) | `CadSimDriver.governor` (drops 3× → 2× when `sim_ms` > budget for 60 frames) | bench regression; governor unit test | 4 |
| E-VS-11 VS gate (human) | DoD C.2 VS; ADR-002 (A-30 decision, realism review); playtest with 2 testers | — | — | 2 |

### Pre-Alpha (PA)

| epic | outcome | contracts to define | tests to define | est. cards |
|------|---------|---------------------|-----------------|-----------|
| E-PA-01 SRBM and ABM loop | SRBM ballistic profile (apex spawn, descent, `max_alt` visibility), LRSAM engagement window, `t3_abm_upgrade` hook; waves 12–17 (P4) | `CadThreatMotion` BALLISTIC profile; `CadTargeting.ticks_to_impact` for ballistic; `CadWaveGenerator` even-wave rule | scenario: SRBM visible ≈ 15 s before impact; 2 ABM shots possible with reengage; leak destroys a district | 7 |
| E-PA-02 Remaining emplacements | CIWS, decoy emitter, interceptor UAV, hardening (per-district command HARDEN_DISTRICT), upgrades (B.11) with `CadUpgradeDef` + UPGRADE command | `CadUpgradeDef` schema + CSV; `CadEmplacement.recompute_stats` upgrade path; `CadEmplacementStore.decoy_attraction` for anti-radiation seekers | upgrade math; hardening multiplier; UAV Pk; CIWS burst rate | 8 |
| E-PA-03 Tech tree | `CadTechNode` schema + CSV (B.9), TP economy (A-27), tech effects applied at run start (`CadDefs.apply_tech(unlocked)` producing an effective copy), tech screen UI | `CadTechState` (unlocked set, tp), `CadTechApplier` | prereq logic; every effect kind applied to the right target; persistence in save v2 (migration) | 9 |
| E-PA-04 Waves 18–30 and endless | P5–P6 phases, wave 30 synchronised raid, endless continuation (budget curve continues, TP stops), map-1 wave script review | `CadWaveDirector.endless` flag; `CadRunEnd` endless prompt | generator caps for P5/P6; endless wave 31 budget; victory at wave 30 then endless | 5 |
| E-PA-05 Music and audio pass 2 | layered music (`AudioStreamInteractive` `[VERIFY]`), transitions BUILD/WAVE/final-30-s, ducking; remaining SFX | `CadMusic.set_layer(name)` | state → layer mapping test; no allocation in transitions | 5 |
| E-PA-06 Ad SDK spike (own gate) | plugin chosen (A-24), installed by the human, `CadAds` wrapper (init, load, show rewarded, consent), reward → `CadCommand` (RESTOCK_FREE / SALVAGE_BOOST / SECOND_CHANCE commands), test ads on device, 16 KB + API 36 checks, offline behaviour | `CadAds` (signals `reward_granted(kind)`, `unavailable`), `CadAdsConfig` resource (ids injected by the human at RC), `tools/check_16kb.sh` | wrapper state machine with a fake backend; reward commands in sim; gate checklist C.2 PA | 7 |
| E-PA-07 Settings and licences screens | full settings, licences screen (reads `art/LICENSES.md`), hint cards for waves 1–2 (`CadHintRules`) | `CadHints` view | hint triggers once; licence file parsed | 4 |
| E-PA-08 Performance pass 2 and soak | low device wave 25–30 at 30 fps; 20-min soak scene; allocation audit tool | `scenes/bench/cad_soak.tscn`; `tools/check_alloc_patterns.py` (R-02) | soak JSON fields; pattern checker catches fixtures | 5 |
| E-PA-09 PA gate (human) | C.2 PA DoD; ad go/no-go ADR-003 | — | — | 2 |

### Alpha (AL)

| epic | outcome | contracts to define | tests to define | est. cards |
|------|---------|---------------------|-----------------|-----------|
| E-AL-01 Feature completeness sweep | every B.12 screen, every command, every doctrine option, every emplacement kind reachable in play; stretch classes SEAD/glide implemented behind `tech_required=locked` (decision at Beta) | `CadThreatMotion` GLIDE profile; ANTI_RADIATION targeting with decoy attraction | scenario per stretch class | 8 |
| E-AL-02 Maps 2 and 3 blockouts | `map_02.tres`, `map_03.tres` with wave rules, terrain mask for valley horizon reduction, campaign select with 3 maps and unlock rule (clear wave 20 of the previous map) | `CadMapDef.terrain_mask` + `CadSensorSystem` horizon factor lookup | validator on both maps; horizon factor test; unlock rule | 7 |
| E-AL-03 Balance harness v2 | all 7 policies × 3 maps, no_ew policy, CI manual job, tuning loop run 1 | — | G.2 bands per map | 4 |
| E-AL-04 Strings, hints, fiction glossary | all UI text final draft, fiction glossary `docs/design/fiction.md`, no real names (CI grep against a denylist) | `tools/check_fiction.py` | denylist test | 3 |
| E-AL-05 Sprite set 3 and store art drafts | tech icons, VFX glyphs, app icon final, feature graphic SVG draft | — | atlas tests | 3 |
| E-AL-06 Android checks | cutouts, 21:9, tablet, text scale, rotation, audio focus, offline (G.5) with fixes | `CadSafeArea` tablet layout adapter | smoke on emulated sizes (`DisplayServer.window_set_size` in tests) | 5 |
| E-AL-07 Release export pipeline | preset 1 (gradle, AAB, target 36), `--install-android-build-template`, `tools/export_release.sh` (env vars), `bundletool validate`, 16 KB check, version bump card, internal track upload procedure executed once | — | AAB contains only arm64; `check_16kb.sh` green; size ≤ 80 MB | 5 (2 human) |
| E-AL-08 Play listing and closed test start | listing draft, privacy policy on GitHub Pages, Data safety draft, IARC draft, internal → closed track, tester recruitment (≥ 12, day-14 clock) | `docs/release/closed-test.md` daily count | — | 4 (3 human) |
| E-AL-09 Ads integration (if go) | production wrapper wiring on three placements, consent flow, no-ads fallback path when unavailable | `CadAdsPlacement` UI component | placement shown only when allowed (once/wave, once/run) | 5 |
| E-AL-10 Alpha gate (human) | C.2 AL DoD; ADR-004 | — | — | 2 |

### Beta (BE)

| epic | outcome | contracts to define | tests to define | est. cards |
|------|---------|---------------------|-----------------|-----------|
| E-BE-01 Balance tuning rounds 2–4 | 3 maps within G.2 bands; two human full campaigns logged; CSV changes only | — | bands as tests | 9 |
| E-BE-02 Stretch classes decision | SEAD/glide in (waves 18+/22+) or cut per A-26; ADR-005 | — | scenario tests kept or deleted with the decision | 3 |
| E-BE-03 Art and audio final | all sprites polished (human pass in Inkscape logged in `AUTHORED.txt` as modified), music stems per map, SFX final, licence register complete | — | CI licence check | 6 |
| E-BE-04 Hardening | crash-proofing (null checks at save/load boundaries, defs validation on boot with a user-facing error), corrupt-save flow, low-memory behaviour (`NOTIFICATION_OS_MEMORY_WARNING` `[VERIFY on Android]` → drop tracer pool to 1,000) | `CadMemoryGuard` | unit tests for each guard | 6 |
| E-BE-05 Performance pass 3 | both devices meet D6 on all maps; RSS and install size within budget | — | perf-log rows | 4 |
| E-BE-06 Closed-test feedback loop | tester feedback form (Google Forms, free) triage into cards; vitals watch | `docs/release/feedback.md` | — | 6 |
| E-BE-07 Localization readiness (no translation) | all strings in CSV, no hard-coded text (CI CV012 extended to scenes: `text` properties must be empty in `.tscn` files) | `tools/check_scene_text.py` | fixture test | 2 |
| E-BE-08 Beta gate (human) | C.2 BE DoD; production access requested; ADR-006 | — | — | 2 |

### Release Candidate, Launch, 1.1 (outline; expanded at Beta gate)

| epic | outcome | est. cards |
|------|---------|-----------|
| E-RC-01 Pre-release checklist G.6 | all items ticked; ad ids injected by the human; store assets final | 8 (5 human) |
| E-RC-02 Bug-fix cards | ≤ 60 LOC each; no features | 8 |
| E-RC-03 Device matrix and pre-launch report | G.4 executed; report clean | 3 (human) |
| E-GO-01 Staged rollout | G.7 steps with vitals gates | 3 (human) |
| E-GO-02 Hotfix rehearsal | one dry run on the closed track | 2 |
| E-PL-01 Vitals triage cycle | weekly triage, top-3 fixes | 8 |
| E-PL-02 Balance patch 1.1 | CSV-only patch from harness + player reports | 4 |
| E-PL-03 First content add | SEAD class (if cut) or map 4 blockout | 10 |
| E-PL-04 Godot patch adoption | 4.7.x or 4.8 evaluation at the 1.1 freeze point (A-43) | 3 |

## I3 Self-check record (run before every backlog change)

Checks applied to this file at authoring time; the appendix prompt re-runs them after every expansion:

| check | result |
|-------|--------|
| every task card ≤ 120 implementation LOC with a failing-test-first specification | 69/69 (human cards carry verification commands as their test) |
| every Dependencies entry resolves to an existing card id in I1 | verified by `tools/backlog_check.py` (to be added by the first VS expansion card; until then by manual grep) |
| every design table maps to a Resource schema (B.14) | 12/12 |
| every performance target has a measuring test or procedure (D6) | 13/13 |
| every card includes Handoff & takeover artifacts | 69/69 |
| no forbidden filler words (output rule 5 list) without a measurable criterion | grep clean |
| Assumptions Register lists every decision not fixed in the brief | A-01…A-43 |
