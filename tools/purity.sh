#!/usr/bin/env sh
# Fail when the simulation layer uses a forbidden construct. Optional argument: a res:// root.
set -eu
: "${GODOT_BIN:?set GODOT_BIN to the Godot 4.7.2 console binary (docs/toolchain.md)}"
exec "$GODOT_BIN" --headless --path . -s res://tools/check_sim_purity.gd -- "$@"
