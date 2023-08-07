#!/usr/bin/env bash

set -eux

function get_url_title {
    # thanks https://unix.stackexchange.com/questions/103252/how-do-i-get-a-websites-title-using-command-line
    wget -qO- "$1" | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | recode html..
}

function gen_name {
    local title
    title="$1"
    echo "$DEST_DIR/$PREFIX - $title.txt"
}

readonly TO_PASTE="$(xclip -sel clip -o)"
readonly PREFIX="$(date +%F)"

if [[ $# -gt 0 ]]; then
    readonly DEST_DIR="$1"
else
    readonly DEST_DIR="$(pwd)"
fi

OG_FILENAME=$(gen_name '')
echo "$TO_PASTE" >> "$OG_FILENAME"

if [[ $TO_PASTE =~ ^https?:// ]]; then
    TEMP_FILENAME=$(gen_name 'link')
    mv "$OG_FILENAME" "$TEMP_FILENAME"
    TITLE="$(get_url_title "$TO_PASTE" || "link")"
    TITLE="${TITLE//[^a-zA-Z -]/}"
    mv "$TEMP_FILENAME" "$(gen_name "$TITLE")"
fi
