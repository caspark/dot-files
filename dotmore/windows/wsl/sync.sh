#!/usr/bin/env bash

set -e

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly SRC="$SCRIPT_DIR/.wslconfig"

readonly DEST_DIR="/mnt/c/Users/Admin"
if [[ -d "$DEST_DIR" ]]; then
    # source for this destination directory
    # https://docs.microsoft.com/en-us/windows/wsl/release-notes#build-18945
    readonly DEST="$DEST_DIR/.wslconfig"
    echo "Copying $SRC to $DEST"
    cp "$SRC" "$DEST"
    echo "Done!"
else
    echo "Destination directory $DEST_DIR does not exist, aborting!"
fi
