#!/usr/bin/env bash
#
# Opens emacs in the current terminal. Useful to avoid having to alt-tab out.

exec emacs-launcher.sh -nw "$@"
