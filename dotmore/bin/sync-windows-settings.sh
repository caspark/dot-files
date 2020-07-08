#!/usr/bin/env bash
#
# Syncs settings from this repository to Windows, if running inside Windows Subsystem for Linux.

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_NONE='\033[0m'

function user_echo {
    echo -e "${COLOR_GREEN}*** ${1}${COLOR_NONE}"
}

function user_error {
    echo -e "${COLOR_RED}*** Error: ${1}${COLOR_NONE}"
}

readonly USER_DIR="/mnt/c/Users/Admin"
if [ -d "$USER_DIR" ]; then
    user_echo "$USER_DIR exists so assuming we're on WSL and continuing"
else
    user_error "$USER_DIR does not exist -> script does not seem to be running inside WSL so aborting!"
    exit 1
fi

set -euo pipefail

readonly DOTMORE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "$DOTMORE_DIR/windows"



for d in $(ls -1); do
    user_echo "Configuring $d..."
    "$d/sync.sh"
done

user_echo "All done!"
