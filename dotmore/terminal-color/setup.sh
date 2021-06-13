#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

/usr/bin/tic -x -o ~/.terminfo "${SCRIPT_DIR}/xterm-24bit.terminfo"
