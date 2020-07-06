#!/usr/bin/env bash

set -e

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly SRC="$SCRIPT_DIR/settings.json"

echo "finding windows terminal package config..."
readonly SETTINGS_DIRS="$(find "$(wslpath 'C:\\Users\\Admin\\AppData\\Local\\Packages\\')" -name 'Microsoft.WindowsTerminal*' 2> /dev/null)"
echo "found dir(s) of: $SETTINGS_DIRS"

for SETTINGS_DIR in $SETTINGS_DIRS; do
    DEST="$SETTINGS_DIR/LocalState/settings.json"
    echo "Copying $SRC to $DEST"
    cp "$SRC" "$DEST"
done

echo "Done!"
