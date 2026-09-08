#!/usr/bin/env python3
"""Repeatable checks for the CAD-FP-002 scaffold: tools/loc.py, the app icon, project.godot.

Run: python tools/tests/test_scaffold.py     (exit 0 = all pass, 1 = failures listed)
Stdlib only; runs from the repository root; needs git on PATH.
"""

import importlib.util
import pathlib
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[2]
PALETTE = {"#0B1220", "#35D0FF", "#FF5A3C", "none", None}

SYNTHETIC_DIFF = """diff --git a/src/sim/cad_rng.gd b/src/sim/cad_rng.gd
--- /dev/null
+++ b/src/sim/cad_rng.gd
@@ -0,0 +1,5 @@
+class_name CadRng
+extends RefCounted
+
+# a comment line that must not count
+var seed_value: int
diff --git a/test/unit/sim/test_cad_rng.gd b/test/unit/sim/test_cad_rng.gd
--- /dev/null
+++ b/test/unit/sim/test_cad_rng.gd
@@ -0,0 +1,2 @@
+extends GdUnitTestSuite
+func test_x() -> void:
diff --git a/docs/notes.md b/docs/notes.md
--- /dev/null
+++ b/docs/notes.md
@@ -0,0 +1,1 @@
+not gdscript, must be ignored
diff --git a/src/view/shaders/cad_icon.gdshader b/src/view/shaders/cad_icon.gdshader
--- /dev/null
+++ b/src/view/shaders/cad_icon.gdshader
@@ -0,0 +1,1 @@
+shader_type canvas_item;
"""


def load_loc():
    spec = importlib.util.spec_from_file_location("loc", ROOT / "tools" / "loc.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def check_loc(fails: list) -> None:
    loc = load_loc()
    counts = loc.parse_diff(SYNTHETIC_DIFF)
    if counts.get("src/sim/cad_rng.gd") != 3:
        fails.append(f"loc: blank/comment lines counted: {counts}")
    if "docs/notes.md" in counts:
        fails.append("loc: non-GDScript file counted")
    if loc.totals(counts) != (4, 2):
        fails.append(f"loc: impl/test split is {loc.totals(counts)}, expected (4, 2)")
    ok = subprocess.run([sys.executable, "tools/loc.py", "HEAD..HEAD"],
                        cwd=ROOT, capture_output=True, text=True)
    if ok.returncode != 0 or ok.stdout.strip() != "impl=0 test=0":
        fails.append(f"loc cli: rc={ok.returncode} out={ok.stdout!r}")
    bad = subprocess.run([sys.executable, "tools/loc.py", "no-such-ref..HEAD"],
                         cwd=ROOT, capture_output=True, text=True)
    if bad.returncode != 1:
        fails.append(f"loc cli: bad range should exit 1, got {bad.returncode}")


def check_icon(fails: list) -> None:
    root = ET.parse(ROOT / "art" / "icons" / "cad_icon.svg").getroot()
    if root.get("viewBox") != "0 0 64 64":
        fails.append(f"icon: viewBox is {root.get('viewBox')!r}")
    for el in root.iter():
        for attr in ("fill", "stroke"):
            if el.get(attr) not in PALETTE:
                fails.append(f"icon: off-palette {attr}={el.get(attr)!r}")


def check_project_godot(fails: list) -> None:
    sections, keys, unparsed, in_block = [], 0, [], False
    for n, raw in enumerate((ROOT / "project.godot").read_text(encoding="utf-8").splitlines(), 1):
        line = raw.rstrip()
        if not line or line.startswith(";"):
            continue
        if line.startswith("[") and line.endswith("]"):
            sections.append(line[1:-1])
        elif in_block:
            in_block = not line.startswith("}")
        elif "=" in line:
            keys += 1
            in_block = line.endswith("{")
        else:
            unparsed.append(f"{n}: {line}")
    if unparsed:
        fails.append(f"project.godot: unparsed lines {unparsed}")
    for required in ("application", "debug", "display", "rendering", "physics"):
        if required not in sections:
            fails.append(f"project.godot: missing section [{required}]")
    text = (ROOT / "project.godot").read_text(encoding="utf-8")
    for setting in ('renderer/rendering_method="gl_compatibility"',
                    "common/physics_ticks_per_second=30",
                    "gdscript/warnings/untyped_declaration=2",
                    "config/quit_on_go_back=false"):
        if setting not in text:
            fails.append(f"project.godot: missing {setting}")


def main() -> int:
    fails: list = []
    check_loc(fails)
    check_icon(fails)
    check_project_godot(fails)
    for failure in fails:
        print("FAIL", failure)
    print("scaffold checks:", "PASS" if not fails else f"{len(fails)} FAILED")
    return 1 if fails else 0


if __name__ == "__main__":
    raise SystemExit(main())
