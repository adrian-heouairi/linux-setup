#!/bin/bash

path=$1

[[ $path =~ ^file:// ]] && path=$(python3 -c "import sys; import urllib.parse; print(urllib.parse.unquote(sys.argv[1]), end=\"\")" "$path")

path=${path#'file://'}

basename=$(basename -- "$path")

if [[ $basename =~ '.'.{3,4}'.'.{3,4}$ ]]; then
    source_filename=${basename%.*}
elif [[ $basename =~ @ ]]; then
    source_filename=$(sed -E 's/(.+) @ .+/\1/' <<< "$basename")
else
    exit 1
fi

source_filename=$(sed 's/./a/' <<< "$source_filename")
source_filename=$(sed 's/[*?[]/\\\0/g' <<< "$source_filename")
source_filename=$(sed 's/a/?/' <<< "$source_filename") # Escaping a character with a backslash doesn't make plocate remove the asterisks around the pattern so we replace the first letter of the filename with "?".

source_file_located=$(locate --literal --basename --existing --limit 1 -- "$source_filename") || exit
printf '%s\n' "$source_file_located"

timestamp_a=
timestamp_b=
if [[ $basename =~ ' @ ' ]] && ! [[ $basename =~ '.'.{3,4}'.'.{3,4}$ ]]; then
    timestamps=$(sed -E 's/.+ @ ([0-9]+-[0-9]+\.[0-9]+)( - )?([0-9]+-[0-9]+\.[0-9]+)?.+/\1 \3/' <<< "$basename")
    timestamps=${timestamps//-/:}
    IFS=' ' read -r timestamp_a timestamp_b <<< "$timestamps"
fi

cd -- "$(dirname -- "$source_file_located")"
mpv --pause --force-window "$([ "$timestamp_a" ] && echo --start="$timestamp_a")" "$([ "$timestamp_a" ] && echo --ab-loop-a="$timestamp_a")" "$([ "$timestamp_b" ] && echo --ab-loop-b="$timestamp_b")" -- "$source_file_located"
