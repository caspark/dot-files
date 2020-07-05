#!/usr/bin/env bash

set -e

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly SRC="$SCRIPT_DIR/workspacer.config.csx"

readonly DEST_DIR_PARENT="/mnt/c/Users/Admin/"
if [[ -d "$DEST_DIR_PARENT" ]]; then
    readonly DEST_DIR="/mnt/c/Users/Admin/.workspacer"
    mkdir -p "$DEST_DIR"
    readonly DEST="$DEST_DIR/workspacer.config.csx"
    echo "Copying $SRC to $DEST"
    cp "$SRC" "$DEST"
    echo "Done!"
else
    echo "Destination directory parent of $DEST_DIR_PARENT does not exist, aborting!"
fi
