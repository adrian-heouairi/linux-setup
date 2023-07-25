#!/bin/bash

path=$1

[[ $path =~ ^file:// ]] && path=$(python3 -c "import sys; import urllib.parse; print(urllib.parse.unquote(sys.argv[1]), end=\"\")" "$path")

path=${path#'file://'}

basename=$(basename -- "$path")

[[ $basename =~ ' @ ' ]] || exit 1

source_filename=$(sed -E 's/(.+) @ .+/\1/' <<< "$basename")
source_filename_glob_escaped=$(sed 's/[*?[]/\\\0/g' <<< "$source_filename")
source_filename_for_plocate=$(sed 's/[A-Za-z]/?/' <<< "$source_filename_glob_escaped") # Escaping a character with a backslash doesn't make plocate remove the asterisks around the pattern and it's not even sure that we're going to do that because the filename might not contain any of "*?[". So we replace the first letter of the filename with "?".

source_file_located=$(locate --literal --basename --existing --limit 1 -- "$source_filename_for_plocate") || exit

timestamps=$(sed -E 's/.+ @ ([0-9]+-[0-9]+\.[0-9]+)( - )?([0-9]+-[0-9]+\.[0-9]+)?.+/\1 \3/' <<< "$basename")
timestamps=${timestamps//-/:}
IFS=' ' read -r timestamp_a timestamp_b <<< "$timestamps"

printf '%s\n' "$source_file_located"

cd -- "$(dirname -- "$source_file_located")"
ifs_old=$IFS; IFS=
mpv --start="$timestamp_a" --pause --force-window --ab-loop-a="$timestamp_a" $([ "$timestamp_b" ] && echo --ab-loop-b=$timestamp_b) -- "$source_file_located"
IFS=$ifs_old
