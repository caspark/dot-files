#!/usr/bin/env bash

set -eux

function get_url_title {
    # thanks https://unix.stackexchange.com/questions/103252/how-do-i-get-a-websites-title-using-command-line
    wget -qO- "$1" | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | recode html..
}

function gen_name {
    local title="$1"
    local ext="$2"
    echo "$(find_available_filename "$PREFIX - $title.$ext")"
}

function find_available_filename {
    local candidate_name="$1"

    if [ ! -f "$candidate_name" ]; then
        echo "$candidate_name"
        return
    fi

    local counter=2

    local filename
    while true; do
        filename="${candidate_name%.*}${counter}.${candidate_name##*.}"
        if [ ! -f "$filename" ]; then
            break
        fi
        counter=$((counter + 1))
    done

    echo "$filename"
}

function get_first_url {
    local url=$(echo "$1" | sed -n 's/.*\(https\{0,1\}:\/\/[^ ]*\).*/\1/p')
    echo "$url"
}

readonly PREFIX="$(date +%F)"

if [[ $# -gt 0 ]]; then
    cd "$1"
fi

# Check if image/png or image/gif is available in clipboard targets
if xclip -selection clipboard -t TARGETS -o | grep -q -e "image/png" -e "image/gif"; then
    # Save clipboard contents to file based on format
    if xclip -selection clipboard -t image/png -o > "$(gen_name 'img' 'png')"; then
        echo "Image saved as png"
    elif xclip -selection clipboard -t image/gif -o > $(gen_name 'img' 'gif'); then
        echo "Image saved as gif"
    else
        echo "Error saving image"
    fi
else
    OG_FILENAME=$(gen_name 'clip' 'txt')
    readonly TO_PASTE="$(xclip -sel clip -o)"
    echo "$TO_PASTE" >> "$OG_FILENAME"

    readonly FIRST_URL="$(get_first_url "$TO_PASTE")"
    if [[ -n "$FIRST_URL" ]]; then
        TEMP_FILENAME=$(gen_name 'reading-link' 'txt')
        mv "$OG_FILENAME" "$TEMP_FILENAME"
        TITLE="$(get_url_title "$FIRST_URL" || "link")"
        TITLE="${TITLE//[^a-zA-Z -]/}"
        mv "$TEMP_FILENAME" "$(gen_name "$TITLE" 'txt')"
    fi
fi

