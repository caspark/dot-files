#!/usr/bin/env bash
#
# Installs nix packages from $HOME/dotmore/nix/default.nix

exec nix-env -f "$HOME/dotmore/nix" -iA ckrieger-devtools
