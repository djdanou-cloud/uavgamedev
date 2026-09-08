#!/usr/bin/env sh
# Run the gdUnit4 suite headless. Usage: tools/test.sh [res://path/to/suite_or_dir]
# Exit codes come straight from gdUnit4: 0 = all passed, 100 = failures, 101 = warnings.
set -eu
: "${GODOT_BIN:?set GODOT_BIN to the Godot 4.7.2 console binary (docs/toolchain.md)}"
SUITE="${1:-res://test}"
exec "$GODOT_BIN" --headless --path . -d -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
    --ignoreHeadlessMode -a "$SUITE" -rd reports/gdunit -c
