#!/usr/bin/env sh
# Load every project script; A-10 turns warnings into parse errors, so this is the typing gate.
set -eu
: "${GODOT_BIN:?set GODOT_BIN to the Godot 4.7.2 console binary (docs/toolchain.md)}"
exec "$GODOT_BIN" --headless --path . -s res://tools/check_scripts.gd
