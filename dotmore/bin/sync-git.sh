#!/usr/bin/env bash

set -eu

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SCRIPT_DIR

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
DARK_GREY='\033[1;37m'
NC='\033[0m' # No Color

function error {
    echo -e "${RED}${1}${NC}"
}

function success {
    echo -e "${GREEN}${1}${NC}"
}

function info { # aka info log
    echo -e "${BLUE}${1}${NC}"
}

function debug {
    # echo -e "${DARK_GREY}${1}${NC}"
    true
}

function sync_git_dir {
    DIR="$1"

    debug "Checking current branch of $DIR repo"
    RESET_TO_LATEST_ON_ORIGIN="false"
    BRANCH="$(git -C "$DIR" branch --show-current)"
    if [[ "$BRANCH" == "master" || "$BRANCH" == "main" || "$BRANCH" == "develop" ]]; then
        debug "Repo $DIR is on a master-like branch so will try to update working tree"
        RESET_TO_LATEST_ON_ORIGIN="true"
    fi

    debug "Finding upstream branch of $DIR repo"
    TRACKED_BRANCH="$(git -C "$DIR" rev-parse --abbrev-ref --symbolic-full-name @{u})"
    info "Git-fetching $DIR"
    TRACKED_BRANCH_BEFORE="$(git -C "$DIR" rev-parse "$TRACKED_BRANCH")"
    git -C "$DIR" fetch --prune
    TRACKED_BRANCH_AFTER="$(git -C "$DIR" rev-parse "$TRACKED_BRANCH")"
    if [[ "$TRACKED_BRANCH_BEFORE" == "$TRACKED_BRANCH_AFTER" ]]; then
        debug "Repo $DIR has not fetched changes on $TRACKED_BRANCH, so working tree does not need to be updated"
        RESET_TO_LATEST_ON_ORIGIN="false"
    fi

    if [[ $RESET_TO_LATEST_ON_ORIGIN == "true" ]]; then
        info "Resetting $DIR working tree to that of $TRACKED_BRANCH to keep it up to date"
        git -C "$DIR" reset --keep $TRACKED_BRANCH
    fi

    success "Done with syncing git repo in $DIR"
}

function fetch_repos_in_dir {
    WORK_DIR="$(realpath $1)"

    for DIR in "$WORK_DIR"/*/ ; do
        if [[ -f "$DIR.git/config" ]]; then
            sync_git_dir "$DIR"
        else
            debug "Skipping non-git repo $DIR"
        fi
    done
}

if [[ $# -ne 0 ]]; then
    info "Looking for git repos to sync in command line args: $@"
    for ARG in "$@"; do
        if [[ -f "$ARG/.git/config" ]]; then
            sync_git_dir "$ARG"
        elif [[ -d "$ARG" ]]; then
            info "Now syncing git repos in $ARG"
            fetch_repos_in_dir "$ARG"
        else
            error "Skipping bad argument $ARG - this doesn't seem to be a directory"
        fi
    done
else
    log "No arg passed; defaulting to syncing all git dirs in script dir of $SCRIPT_DIR"
    fetch_repos_in_dir "$SCRIPT_DIR"
fi

