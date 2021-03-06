#!/usr/bin/env bash

echo "Starting new emacs..."
setsid emacs &
sleep 2 # wait for emacs to start
disown

echo "Attempting to connect to newly created emacs..."
exec emacsclient --server-file="$HOME/.emacs.d/server/server" $@
