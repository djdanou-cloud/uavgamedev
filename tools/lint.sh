#!/usr/bin/env sh
# gdlint + gdformat over every project .gd file. Override GDLINT/GDFORMAT when they are not on PATH.
set -eu
GDLINT="${GDLINT:-gdlint}"
GDFORMAT="${GDFORMAT:-gdformat}"
files=$(find src scenes tools test -name '*.gd' | sort)
if [ -z "$files" ]; then
    echo "no .gd files yet"
    exit 0
fi
echo "$files" | xargs "$GDLINT"
echo "$files" | xargs "$GDFORMAT" --check
