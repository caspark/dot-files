#!/usr/bin/env bash
#
# Opens the given file in emacs, using an existing editor where available.
#
# If no existing emacs server is available, start a new one in a separate
# process, then connect to it.
#
# If -nw is passed as an argument and no existing server is available, instead
# start a new terminal instance of emacs in the terminal.

function element_is_in () {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

readonly SERVER_FILE="$(find "$HOME/.emacs.d/server" -type f)"

if [[ ! -f "$SERVER_FILE" ]]; then
    element_is_in "-nw" "$@"
    if [[ $? -eq 0 ]]; then
        echo "No emacs server file found; -nw flag passed so starting new emacs in terminal..."
        exec emacs "$@"
    else
        echo "No emacs server file found; starting new emacs server and connecting to it..."
        exec emacs-start-server-then-connect.sh "$@"
    fi
fi

# check that we do not have multiple server files available
readonly SERVER_FILE_COUNT="$(grep -c '^' <<< "$SERVER_FILE")"
if [[ "$SERVER_FILE_COUNT" -gt 1 ]]; then
    echo "Multiple emacs server files are available so not sure which to connect to:"
    echo "$SERVER_FILE"
    echo "You should delete one or more of these, but do 'M-X server-mode' to turn off server-mode in emacs first"
    echo "Starting a new emacs instance as a workaround..."
    exec emacs "$@"
fi

readonly EMACS_ADDR="$(head -n1 "$SERVER_FILE" | cut -d' ' -f1)"
readonly EMACS_PID="$(head -n1 "$SERVER_FILE" | cut -d' ' -f2)"
echo "Found emacs server file: $SERVER_FILE; connecting to $EMACS_ADDR (PID $EMACS_PID)"

# confirm that emacs is actually listening at that port
readonly LIVE_EMACS="$(netstat -lntup 2> /dev/null | grep -E "$EMACS_ADDR.*${EMACS_PID}/emacs\s*$")"
if [[ -z "$LIVE_EMACS" ]]; then
    echo "No matching emacs found at $EMACS_ADDR with PID of $EMACS_PID; netstat output follows:"
    netstat -lntup 2> /dev/null

    echo -n "Assuming that server file at $SERVER_FILE is stale so deleting it..."
    rm "$SERVER_FILE"
    echo " done!"

    echo "Starting a new emacs instance as a workaround..."
    exec emacs-start-server-then-connect.sh "$@"
fi

echo "Found matching emacs: $LIVE_EMACS"

# TODO - would be nice to actually raise emacs to the forefront here if it's not
# a -nw invocation. Might be able to do this by running some elisp using
# emacsclient to execute x-focus-frame?
# https://www.gnu.org/software/emacs/manual/html_node/elisp/Input-Focus.html
#
# Or alternatively, could do some hacky thing where we detect if we're on WSL
# and use some Windows util function.
exec emacsclient --alternate-editor='emacs-start-server-then-connect.sh' --server-file="$SERVER_FILE" "$@"
