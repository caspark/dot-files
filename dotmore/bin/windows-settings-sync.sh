#!/usr/bin/env bash
#
# Syncs settings from this repository to Windows, if running inside Windows Subsystem for Linux.

readonly USER_DIR="/mnt/c/Users/Admin"
if [ -d "$USER_DIR" ]; then
    echo "*** $USER_DIR exists so assuming we're on WSL and continuing"
else
    echo "*** Error: $USER_DIR does not exist -> script does not seem to be running inside WSL so aborting!"
    exit 1
fi

set -euo pipefail

readonly DOTMORE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
echo "$DOTMORE_DIR"

echo "*** Configuring Windows Terminal..."
"$DOTMORE_DIR/msterminal/sync.sh"
echo "*** Configuring Workspacer..."
"$DOTMORE_DIR/workspacer/sync.sh"

echo "*** All done!"
