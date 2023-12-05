#!/bin/bash

# A clyrics query on Google looks like this: <arguments> site:lyrics.com OR site:lyrics2.com OR ...

lyrics_save_directory=~/D/Lyrics

mkdir -p -- "$lyrics_save_directory" || exit 1

song_fullpath=$(qdbus py.mpris /py/mpris py.mpris.GetFullpath)
[ -f "$song_fullpath" ] || exit 1

song_filename=${song_fullpath##*/} song_filename_no_ext=${song_filename%.*}

#song_title=$(exiftool -b -title "$song_fullpath")
#song_artist=$(exiftool -b -artist "$song_fullpath")
title=$(ffprobe -loglevel quiet -of default=nk=1:nw=1 -show_entries format_tags=title -- "$song_fullpath")
artist=$(ffprobe -loglevel quiet -of default=nk=1:nw=1 -show_entries format_tags=artist -- "$song_fullpath")

array=()
add_to_array() { array+=("$1" "$1" off); }

add_to_array "jp $song_filename_no_ext"
[ "$artist" -a "$title" ] && add_to_array "jp $artist - $title"
[ "$title" ] && add_to_array "jp $title"
add_to_array "$song_filename_no_ext"
[ "$artist" -a "$title" ] && add_to_array "$artist - $title"
[ "$title" ] && add_to_array "$title"

choice=$(kdialog --title "${0##*/}" --radiolist "$song_fullpath"$'\n\n'"Choose 'jp ' prefix for Japanese websites" -- "${array[@]}")
[ "$choice" ] || exit 1

text=$(kdialog --title "${0##*/}" --inputbox "$(printf ' %.s' {1..50})$choice$(printf ' %.s' {1..50})" "$choice")
[ "$text" ] || exit 1

query_terms=${text#'jp '}

if [[ $text =~ ^'jp ' ]]; then
    lyrics=$(clyrics -P "$(linux-setup-get-resources-path.sh)/clyrics-plugins-jp" -- "$query_terms" 2>&1) || notify-send 'clyrics returned non-zero'
else
    lyrics=$(clyrics -- "$query_terms" 2>&1) || notify-send 'clyrics returned non-zero'
fi

if [ "$lyrics" ]; then
    fullpath_to_write=$lyrics_save_directory/$song_filename

    if [[ $text =~ ^'jp ' ]] && grep -P '[\p{Han}\p{Hiragana}\p{Katakana}]' <<< "$lyrics"; then
        rm -f -- "$fullpath_to_write".txt
        fullpath_to_write=$fullpath_to_write.jp
    else
        rm -f -- "$fullpath_to_write".jp
        fullpath_to_write=$fullpath_to_write.txt
    fi
    
    printf '%s\n' "$lyrics" > "$fullpath_to_write"
    text-editor -- "$fullpath_to_write" & disown
else
    notify-send -i download -- "${0##*/}" "No lyrics found on Google for the query: $query_terms"
fi
