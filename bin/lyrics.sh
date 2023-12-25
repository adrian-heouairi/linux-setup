#!/bin/bash

# Compatible with other than mp3 e.g. webm, mkv

lyrics_dir=~/D/Shared-ST-apho/Music/Lyrics

song_fullpath=$(qdbus py.mpris /py/mpris py.mpris.GetFullpath)
[ -f "$song_fullpath" ] || exit 1

song_filename=${song_fullpath##*/} # song_filename_no_ext=${song_filename%.*}

find=$(find "$lyrics_dir"/ -xtype f)

lyrics_file=$(grep -m1 -F -e /"$song_filename".txt -e /"$song_filename".jp <<< "$find")

if [ -f "$lyrics_file" ]; then
    position=$(qdbus py.mpris /py/mpris py.mpris.GetProperty Position)
    length=$(qdbus py.mpris /py/mpris py.mpris.GetMetadataField mpris:length)
    if [[ $position =~ ^[0-9]+$ ]] && [[ $length =~ ^[0-9]+$ ]] && ((position <= length)); then
        number_of_lines_in_file=$(grep -c -- '' "$lyrics_file")
        line_to_open_at=$((number_of_lines_in_file * position / length))
        ((line_to_open_at < 1)) && line_to_open_at=1
        ((line_to_open_at > number_of_lines_in_file)) && line_to_open_at=$number_of_lines_in_file
        text-editor --line "$line_to_open_at" -- "$lyrics_file" & disown
    else
        text-editor -- "$lyrics_file" & disown
    fi
else
    clyrics.sh
fi
