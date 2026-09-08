# Toolchain (CAD-FP-001)

Machine of record: `DaduAsus`, Windows 11 Home 10.0.26200, shells: PowerShell + Git Bash.

## 1. State (2026-09-08)

| tool | required (A.0 / A-01) | state | needed from |
|------|------------------------|-------|-------------|
| Godot | 4.7.2 stable console binary, `GODOT_BIN` set | **installed** ✔ | now |
| gdtoolkit | 4.5.0 (`gdlint`, `gdformat`) | **installed** ✔ (see PATH note) | CAD-FP-004 |
| Python | 3.x | 3.14.0rc2 ✔ | now |
| Godot export templates | 4.7.2.stable | missing | CAD-FP-065 |
| JDK | OpenJDK 17 (`JAVA_HOME`) | missing | CAD-FP-065 |
| Android SDK | platform-tools ≥35.0.0, build-tools 35.0.1, platforms 35 + 36, cmdline-tools latest, NDK r28b (28.1.13356709), CMake 3.10.2.4988404 | missing (`ANDROID_HOME` unset) | CAD-FP-065 |
| adb | any recent | missing | CAD-FP-008 |

Cards CAD-FP-002 … CAD-FP-064 are unblocked. The Android half of this card stays open until CAD-FP-065.

## 2. Install commands (`[HUMAN]` — an agent must not run these)

Done on 2026-09-08:

```powershell
winget install --source winget --id GodotEngine.GodotEngine --version 4.7.2
pip install gdtoolkit==4.5.0
```

Still to run, before CAD-FP-065:

```powershell
winget install --source winget --id EclipseAdoptium.Temurin.17.JDK
winget install --source winget --id Google.PlatformTools
```

Then: export templates (editor → *Manage Export Templates*), and the Android SDK — no winget package for
cmdline-tools, so download *Command line tools only*, unzip to `C:\Android\sdk\cmdline-tools\latest\`,
set `ANDROID_HOME=C:\Android\sdk`, and:

```powershell
sdkmanager "platform-tools" "build-tools;35.0.1" "platforms;android-35" "platforms;android-36" "cmdline-tools;latest" "ndk;28.1.13356709" "cmake;3.10.2.4988404"
sdkmanager --licenses
```

`[VERIFY]` that list against the Godot 4.7 "Exporting for Android" page on the day it is run.

## 3. Paths and environment

| name | value |
|------|-------|
| `GODOT_BIN` | `C:\Users\djdan\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe` (set with `setx`, so **new shells only**) |
| Git Bash form | `/c/Users/djdan/AppData/Local/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.7.2-stable_win64_console.exe` |
| gdtoolkit scripts | `C:\Users\djdan\AppData\Local\Python\pythoncore-3.14-64\Scripts\` — **not on PATH**; call `gdlint`/`gdformat` by full path, or add that directory to PATH once |
| winget also installed | `Godot_v4.7.2-stable_win64.exe` (GUI) in the same folder — use it for the editor, the `_console` one for scripts |

## 4. Verification (real output, 2026-09-08)

```text
$ "$GODOT_BIN" --version
4.7.2.stable.official.ed1daf0bf

$ gdlint --version
gdlint 4.5.0

$ gdformat --version
gdformat 4.5.0

$ "$GODOT_BIN" --headless --path . --import   # after the .gdignore and main_scene fixes
(no ERROR, WARNING or SCRIPT ERROR lines)

$ git check-attr -a project.godot
project.godot: text: set
project.godot: eol: lf

$ python tools/tests/test_scaffold.py
scaffold checks: PASS
```

Deferred to CAD-FP-065/008: `java -version`, `sdkmanager --list_installed`, `adb version`.

## 5. What the first engine session established (evidence for A.0)

1. **The strict-typing gate is real.** `--check-only -s <script>` exits 1 and prints
   `Parse Error: … (Warning treated as error.)` for an untyped `var`, a discarded return value, and a
   method call on a `Variant`. CI asserts all three as an inverted test.
2. **`exclude_addons` does not exist in Godot 4.** Dumping `ProjectSettings.get_property_list()` shows 52
   `debug/gdscript/*` settings; our seven warning names are all engine-declared with hint
   `Ignore,Warn,Error`, but `exclude_addons` behaves exactly like a made-up control name. Its replacement
   is `debug/gdscript/warnings/directory_rules`, a Dictionary defaulting to `{"res://addons": 0}`
   (0 = Exclude, 1 = Include). `project.godot` now writes it explicitly.
3. **Godot imports every `.csv` as a CSV Translation**, logging `WARNING: Locale '<column>' does not
   contain any translation` for each header column. `ai/`, `docs/`, `data/csv/` and `test/fixtures/csv/`
   carry a `.gdignore`. A CSV that must ship at runtime (`ui/strings/`, CAD-FP-047) will need an
   `.import` with `importer="keep"` or a different extension.
4. **`run/main_scene` cannot point at a scene that does not exist yet** — `--import` logs
   `ERROR: Cannot open file`, which the CI gate treats as failure. CAD-FP-063 sets it.

## 6. CI parity

GitHub Actions installs the same versions (`docs/production/03-architecture.md` §D5.2): Godot 4.7.2 from
`godotengine/godot-builds` verified against the release's `SHA512-SUMS.txt`, `gdtoolkit==4.5.0`,
Temurin 17 (from CAD-FP-065). When a version changes here it changes there in the same commit.
