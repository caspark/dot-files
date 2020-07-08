#!/usr/bin/env bash
#
# Syncs settings from this repository to emacs - initialize Doom Emacs submodule and install packages

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_NONE='\033[0m'

function user_echo {
    echo -e "${COLOR_GREEN}*** ${1}${COLOR_NONE}"
}

function user_error {
    echo -e "${COLOR_RED}*** Error: ${1}${COLOR_NONE}"
}

set -euo pipefail

cd $HOME

user_echo "Initializing, syncing and updating git submodules..."
git submodule init .emacs.d/
git submodule sync .emacs.d/
git submodule update

user_echo "Running doom sync..."
doom sync

user_echo "Running doom env..."
doom env

user_echo "Running doom doctor (check output for problems!)..."
doom doctor

user_echo "All done!"
