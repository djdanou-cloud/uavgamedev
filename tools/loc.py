#!/usr/bin/env python3
"""Count added GDScript lines in a git range, split into implementation and tests.

Usage:  python tools/loc.py main..HEAD [--by-file]
Prints: impl=<n> test=<n>
Implementation = src/ scenes/ tools/ ; tests = test/ ; only *.gd and *.gdshader ;
blank lines and whole-line comments are not counted (CAD-FP-002 contract).
"""

import argparse
import subprocess
import sys

EXTS = (".gd", ".gdshader")
IMPL_DIRS = ("src/", "scenes/", "tools/")
TEST_DIRS = ("test/",)


def parse_diff(text: str) -> dict:
    """Map path -> counted added lines, from `git diff --unified=0` output."""
    counts: dict = {}
    path = ""
    for line in text.splitlines():
        if line.startswith("+++ b/"):
            path = line[6:]
        elif line.startswith("+++") or line.startswith("---"):
            continue
        elif line.startswith("+") and path.endswith(EXTS):
            body = line[1:].strip()
            if body and not body.startswith("#"):
                counts[path] = counts.get(path, 0) + 1
    return counts


def totals(counts: dict) -> tuple:
    impl = sum(n for p, n in counts.items() if p.startswith(IMPL_DIRS))
    test = sum(n for p, n in counts.items() if p.startswith(TEST_DIRS))
    return impl, test


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("range", help="git range, e.g. main..HEAD")
    ap.add_argument("--by-file", action="store_true")
    args = ap.parse_args()
    cmd = ["git", "diff", "--unified=0", "--no-color", args.range]
    # Explicit utf-8: the Windows locale codec (cp1252) fails on multi-byte diff content.
    proc = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr)
        return 1
    counts = parse_diff(proc.stdout)
    if args.by_file:
        for path in sorted(counts):
            print(f"{counts[path]:5d}  {path}")
    impl, test = totals(counts)
    print(f"impl={impl} test={test}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
