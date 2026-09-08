# Toolchain (CAD-FP-001)

Machine of record: `DaduAsus`, Windows 11 Home 10.0.26200, shells: PowerShell + Git Bash.
This file is the evidence for CAD-FP-001. The **Verification** section must hold the pasted
output of all seven commands before the card is done; everything below it is preparation.

## 1. Current state (probed 2026-09-08 by the CAD-FP-002 session)

| tool | required (A.0 / A-01) | found | blocks |
|------|------------------------|-------|--------|
| Godot | 4.7.2 stable, console binary, `GODOT_BIN` set | **missing** (not on PATH, no install found) | every `.gd`/`.tres` card from CAD-FP-003 on; the CAD-FP-002 import check |
| Godot export templates | 4.7.2.stable | **missing** | CAD-FP-065 (debug APK) |
| JDK | OpenJDK 17 (`JAVA_HOME`) | **missing** | CAD-FP-065 |
| Android SDK | platform-tools ≥35.0.0, build-tools 35.0.1, platform 35 + 36, cmdline-tools latest, NDK r28b (28.1.13356709), CMake 3.10.2.4988404 | **missing** (`ANDROID_HOME` unset) | CAD-FP-065, CAD-FP-068 |
| adb | any recent | **missing** | CAD-FP-008, device work |
| Python | 3.x | **3.14.0rc2** ✔ | — |
| gdtoolkit | 4.5.0 (`gdlint`, `gdformat`) | **missing** | CAD-FP-004 lint gate, CI parity |
| winget | any | **present** ✔ | — |

## 2. Install commands (run in PowerShell; `[HUMAN]` — an agent must not run these)

```powershell
winget install --source winget --id GodotEngine.GodotEngine --version 4.7.2
winget install --source winget --id EclipseAdoptium.Temurin.17.JDK
winget install --source winget --id Google.PlatformTools
pip install gdtoolkit==4.5.0
```

Package ids verified against the winget source on 2026-09-08 (`GodotEngine.GodotEngine` 4.7.2,
`EclipseAdoptium.Temurin.17.JDK` 17.0.20.101, `Google.PlatformTools` 37.0.1).

Then, in order:

1. **Console binary.** The build we drive from scripts must be the *console* executable
   (`Godot_v4.7.2-stable_win64_console.exe`). If the winget install does not provide it, download
   the Windows zip from the official 4.7.2 release page, unzip to `C:\tools\godot\`, and use that.
2. **`GODOT_BIN`** (permanent, user scope):
   `setx GODOT_BIN "C:\tools\godot\Godot_v4.7.2-stable_win64_console.exe"` — open a new shell afterwards.
3. **Export templates:** launch the editor once → *Editor > Manage Export Templates > Download and Install*
   (or place `Godot_v4.7.2-stable_export_templates.tpz` contents in the templates folder).
4. **Android SDK** (needed only from CAD-FP-065; no winget package for cmdline-tools):
   download *Command line tools only* from the Android developer site, unzip to
   `C:\Android\sdk\cmdline-tools\latest\`, set `ANDROID_HOME=C:\Android\sdk`, then:
   ```powershell
   sdkmanager "platform-tools" "build-tools;35.0.1" "platforms;android-35" "platforms;android-36" "cmdline-tools;latest" "ndk;28.1.13356709" "cmake;3.10.2.4988404"
   sdkmanager --licenses
   ```
   `[VERIFY]` the exact version list against the Godot 4.7 "Exporting for Android" page on the day.
5. **Editor settings for export** (D1.3): `export/android/android_sdk_path`, `export/android/java_sdk_path`,
   and the debug keystore. Set from *Editor > Editor Settings > Export > Android*.

## 3. Verification (paste real output here; the card is not done until all seven are present)

```text
$ "$GODOT_BIN" --version
<paste>

$ java -version
<paste>

$ sdkmanager --list_installed
<paste>

$ gdlint --version
<paste>

$ gdformat --version
<paste>

$ adb version
<paste>

$ "$GODOT_BIN" --headless --quit ; echo $?
<paste — expect exit 0>
```

## 4. First checks to run once Godot exists (carried over from CAD-FP-002)

These were written but could not be executed without the engine; run them before starting CAD-FP-003
and record the results in `/ai/handoffs/CAD-FP-002.md`:

```bash
"$GODOT_BIN" --headless --path . --import      # expect exit 0 and no WARNING/ERROR lines
gdlint tools                                    # expect exit 0
gdformat --check tools                          # expect exit 0
python tools/loc.py HEAD~1..HEAD                # expect "impl=<n> test=<n>"
git check-attr -a project.godot                 # expect text / eol: lf
```

Then confirm in the editor (*Project > Project Settings > General > Debug > GDScript*) that the
eight `debug/gdscript/warnings/*` rows from `project.godot` exist and read **Error** (A-10). Any name
the engine does not know must be corrected in `project.godot` and in
`docs/production/00-assumptions-register.md` A.0 — never silently dropped.

## 4b. Windows/PowerShell equivalents

`$GODOT_BIN` in Git Bash is `$env:GODOT_BIN` in PowerShell; the `tools/*.sh` scripts have `.cmd` twins
(added by CAD-FP-003). Run the plan's commands from Git Bash unless a card says otherwise.

## 5. CI parity

GitHub Actions installs the same versions from pinned URLs (`docs/production/03-architecture.md` §D5.2):
Godot 4.7.2 Linux binary + templates by SHA-256, `gdtoolkit==4.5.0`, Temurin 17. When a version changes
here, it changes there in the same commit.
