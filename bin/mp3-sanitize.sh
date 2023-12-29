#!/bin/bash

# This is recursive, takes a directory or file

has-front-cover() {
    mid3v2 -- "$1" | grep '^APIC=cover front' &>/dev/null
}

has-image() {
    mid3v2 -- "$1" | grep '^APIC=' &>/dev/null
}

error() {
    #echo "Error '$1' while processing $i, press Enter to skip it and proceed anyway or Ctrl+C to exit"
    echo "Error '$1' while processing '$i'"
    #read
    continue
}

dir_or_file=$1
[[ $dir_or_file =~ ^- ]] && dir_or_file=./$dir_or_file
[ -e "$dir_or_file" ] || exit
dir_or_file=${dir_or_file%/}

#eyeD3 --recursive --to-v2.4 -- "$dir_or_file"
#eyeD3 --recursive --remove-v1 -- "$dir_or_file"

IFS=$'\n'

find=$(find "$dir_or_file" -type f -name '*.mp3' | LC_ALL=C sort)

for i in $find; do
    if [ -e "$(dirname -- "$i")"/.sanitize-done ]; then
        echo "Skipping already sanitized mp3 '$i'"
        continue
    fi

    md5=$(md5sum -- "$i")
    
    mid3v2 --convert -- "$i" || error
    mid3v2 --delete-v1 -- "$i" || error

    filename_no_ext=$(basename -- "$i" .mp3)
    title=$(mp3-get-id3-frame.sh "$i" TIT2)
    [ $? = 2 ] && error "mutagen deems this file invalid"
    artist=$(mp3-get-id3-frame.sh "$i" TPE1)
    album=$(mp3-get-id3-frame.sh "$i" TALB)
    if ! [ "$title" -a "$artist" -a "$album" ]; then
        default=$filename_no_ext
        [ "$title" ] || mid3v2 -t "$default" -- "$i" || error
        [ "$artist" ] || mid3v2 --artist="$default" -- "$i" || error
        [ "$album" ] || mid3v2 --album="$default" -- "$i" || error
    fi
    
    if (! has-front-cover "$i") && has-image "$i"; then
        python3 -c 'import sys; from mutagen.id3 import ID3; id3 = ID3(sys.argv[1]); id3.getall("APIC")[0].type = 3; id3.save()' "$i" || error
    fi
    
    # This mp3gain part makes this script non-deterministic e.g. every time you get a different MD5 sum for the mp3s
    if ! (yes | mp3gain -r -s i "$i"); then
        mp3-convert-to.sh "$i" "$i" || error "ffmpeg reencoding didn't work"
        (yes | mp3gain -r -s i "$i") || error "mp3gain doesn't work even after reencoding with ffmpeg"
    fi
    
    [ "$(md5sum -- "$i")" != "$md5" ] && echo "Successfully modified $i" || echo "Didn't modify $i"
done

if [ -d "$dir_or_file" ]; then
    for i in $(find "$dir_or_file" -type d); do
        touch -- "$i"/.sanitize-done
    done
fi
