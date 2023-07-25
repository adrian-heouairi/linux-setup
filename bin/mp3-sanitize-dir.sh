#!/bin/bash

has-front-cover() {
    mid3v2 -- "$1" | grep '^APIC=cover front' &>/dev/null
}

has-image() {
    mid3v2 -- "$1" | grep '^APIC=' &>/dev/null
}

error() {
    echo "Error '$1' while processing $i, press Enter to skip it and proceed anyway or Ctrl+C to exit"
    read
    continue
}

[ "$1" ] && dir=$1
[[ $dir =~ ^- ]] && dir=./$dir
[ -d "$dir" ] || exit
dir=${dir%/}

#eyeD3 --recursive --to-v2.4 -- "$dir"
#eyeD3 --recursive --remove-v1 -- "$dir"

IFS=$'\n'

find=$(find "$dir"/ -type f -name '*.mp3' | LC_ALL=C sort)

for i in $find; do
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
    
    if ! (yes | mp3gain -r -s i "$i"); then
        convert-to-mp3.sh "$i" "$i" || error "ffmpeg reencoding didn't work"
        (yes | mp3gain -r -s i "$i") || error "mp3gain doesn't work even after reencoding with ffmpeg"
    fi
    
    [ "$(md5sum -- "$i")" != "$md5" ] && echo "Successfully modified $i" || echo "Didn't modify $i"
done
