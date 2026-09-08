# Handoff — CAD-FP-002 — Repository scaffold and project.godot

## 1. Status
- status: BLOCKED
- last_updated_utc: 2026-09-08T00:00:00Z
- agent: Claude Opus 5 (Claude Code)  session: 1  takeover_from: none
- time_spent_min: 55
- blocker: the card's four verification commands need Godot 4.7.2 and gdtoolkit; neither is installed
  on this machine (CAD-FP-001 is not done). All files the card asks for are written; nothing engine-side
  is verified. See item 7.

## 2. Branch and checkpoint
- branch: card/CAD-FP-002-scaffold
- last_pushed_commit: (this commit) — `CAD-FP-002: repository scaffold and project settings`
- last_green_commit: n/a (no engine test suite exists yet; the Python checks below are green)

## 3. Files (planned → touched)
| path | intent | state |
|------|--------|-------|
| `project.godot` | D1.1 settings: Compatibility renderer, 1920×1080 canvas_items/expand, sensor_landscape, 30 Hz physics, warnings-as-errors, importer defaults, Android gesture keys | done, **unverified by the engine** |
| `.gitignore` | Godot 4 outputs, `android/` (keeping `android/plugins/`), build/reports, secrets (`*.jks`, `*.keystore`, `.env`) | done |
| `.gitattributes` | `* text=auto eol=lf`; binary list for png/wav/ogg/ttf/apk/aab; `*.cmd` crlf | done |
| `.editorconfig` | tabs for `.gd`, 4-space for py/yml/md, lf, final newline | done |
| `.gdlintrc` | A-09 values: max-line-length 100, max-file-lines 400, `Cad*` class names, snake_case functions, excluded `addons`/`.godot` | done, **option names unverified** (see item 8) |
| `art/icons/cad_icon.svg` | app icon: friendly-cyan radar fan + hostile chevron on `bg`; palette-only colours | done, verified (XML + palette test) |
| `tools/loc.py` | `python tools/loc.py <range> [--by-file]` → `impl=<n> test=<n>`; counts added non-blank non-comment `.gd`/`.gdshader` lines; impl = src/ scenes/ tools/, test = test/ | done, verified |
| `README.md` | replaces the stub: what the game is, engine/platform, entry points per reader | done |
| 63 × `.gdkeep` | the D7 directory tree | done |

Not created on purpose (owned by later cards, noted in the file headers): `[autoload]` (CAD-FP-042),
`gui/theme/custom` (CAD-FP-047), `[input]` actions (see item 8).

## 4. Tests
- command (Python-side, runnable today): `python <scratch>/test_loc.py`
- last_exit_code: 0
- failing_tests: none
- covered: `parse_diff` blank/comment filtering, non-GDScript exclusion, impl/test split (4/2 on a
  synthetic diff), CLI happy path (`impl=0 test=0` on `HEAD~1..HEAD`, correct — no `.gd` in that range),
  CLI bad-range exit code 1, icon SVG well-formed + `viewBox 0 0 64 64` + palette-only colours,
  `project.godot` structure (8 sections, 36 keys, 0 unparsed lines).
- one defect found and fixed during testing: `subprocess.run(..., text=True)` used the Windows locale
  codec (cp1252) and crashed on UTF-8 diff bytes; `loc.py` now passes `encoding="utf-8", errors="replace"`.
- also green: `git check-attr -a project.godot art/icons/cad_icon.svg` -> `text: set`, `eol: lf`
  (1 of the card's 4 verification commands; the other 3 need the engine).
- NOT run (blocked): `"$GODOT_BIN" --headless --path . --import`, `gdlint tools`, `gdformat --check tools`.

## 5. Hypotheses
- none open. The two unverified areas are configuration names, not logic: `debug/gdscript/warnings/*`
  (A-10) and the `.gdlintrc` option names (A-09). Godot silently keeps unknown project settings, so a
  wrong warning name would **disable the typing gate without any error** — this is why item 8 requires
  a visual check in Project Settings, not just a green `--import`.

## 6. Exact next step
1. Human: complete CAD-FP-001 using `docs/toolchain.md` §2 (four winget/pip commands, then `GODOT_BIN`).
2. Then run the five commands in `docs/toolchain.md` §4 and paste the output into item 4 here.
3. Then confirm the eight warning rows read **Error** in Project Settings > Debug > GDScript.
4. Correct `project.godot` / `.gdlintrc` for any name the tools reject, record the actual names in
   `docs/production/00-assumptions-register.md` §A.0, set this handoff to READY_FOR_REVIEW.
5. Then CAD-FP-003 (gdUnit4) may start.

## 7. Blockers / questions for the human
- **Blocker:** no Godot, no JDK, no Android SDK, no gdtoolkit on this machine (probe in
  `docs/toolchain.md` §1). Install commands are prepared; an agent must not install software.
- **Question:** confirm the Godot console binary path you end up with, so `GODOT_BIN` and the
  `tools/*.cmd` wrappers (CAD-FP-003) match.

## 8. Resume instructions for a successor
- read in this order: this file → `docs/toolchain.md` → the CAD-FP-002 card in
  `docs/production/09-execution-backlog.md` → `docs/production/03-architecture.md` §D1.1 and §D7.
- do NOT redo: the directory tree, `.gitignore`/`.gitattributes`/`.editorconfig`, `tools/loc.py`
  (tested), the icon, `README.md`.
- open `[VERIFY]` items carried by this card:
  - `debug/gdscript/warnings/*` names and the 0/1/2 severity encoding (A-10).
  - `[importer_defaults] texture={...}` key name and payload shape.
  - `display/window/handheld/orientation=4` = sensor_landscape.
  - `input_devices/pointing/android/enable_pan_and_scale_gestures` and `..._long_press_as_right_click`.
  - `.gdlintrc` option names — verify with `gdlint --dump-default-config` and reconcile names, keep values.
  - `[input]` actions were **not** hand-written: `InputEventKey` serialisation is version-specific.
    Add the six actions (`cad_pause`, `cad_speed_1..3`, `cad_cancel`, `cad_confirm`, `cad_debug_overlay`)
    from the editor's Input Map and commit the generated text.
  - `run/main_scene` points at `res://scenes/app/cad_boot.tscn`, which arrives in CAD-FP-063. Harmless for
    `--import`; running the project fails until then. Expected.

## 9. Self-review checklist
- [x] contract implemented exactly (files, `loc.py` CLI shape, `.gdlintrc` values, D1.1 keys)
- [x] tests first where they could exist (Python: written before the fix that made them pass; the engine
      batch is deferred with an explicit blocker, not skipped silently)
- [x] STD-TOOL for `loc.py` (stdlib only, exit codes 0/1, prints one summary line, writes nothing)
- [x] no allocation-sensitive code in this card
- [x] no new dependency; no addon; no asset without provenance (icon is code-authored)
- [x] diff within Scope; `loc.py` 62 lines ≤ 60-line ceiling +2 (see note)
- [ ] lint, typecheck, import green — **blocked on CAD-FP-001**
- [x] handoff written; log closed
- [ ] every `[VERIFY]` resolved — **blocked**, listed in item 8

Note on the LOC ceiling: `tools/loc.py` is 62 lines including the module docstring and the
`encoding="utf-8"` fix comment; the card's ceiling was 60. Two lines over, both non-logic. Flagged here
rather than compressing the docstring; the human may wave it through or ask for a trim at review.
