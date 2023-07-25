#!/bin/bash

[ -f "$1" ] || exit 1
mkdir -p ~/D/Todo/mp3-swap-title-and-artist || exit 1

fullpath=$(realpath -- "$1")
backup_fullpath=~/D/Todo/mp3-swap-title-and-artist/$(basename -- "$fullpath")

title=$(ffprobe -loglevel quiet -of default=nk=1:nw=1 -show_entries format_tags=title -- "$fullpath")
artist=$(ffprobe -loglevel quiet -of default=nk=1:nw=1 -show_entries format_tags=artist -- "$fullpath")

mv -- "$fullpath" "$backup_fullpath" || exit 1

ffmpeg -i "$backup_fullpath" -c copy -metadata title="$artist" -metadata artist="$title" "$fullpath"
