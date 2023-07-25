#!/bin/bash

# mid3v2 --delete-frames=TXXX:nocover a.mp3

has-front-cover() {
    mid3v2 -- "$1" | grep '^APIC=cover front' &>/dev/null
}

has-image() {
    mid3v2 -- "$1" | grep '^APIC=' &>/dev/null
}

set-cover() {
    pic=

    echo -n "Press Enter to skip, type 'n' to mark as needing no cover and skip, or give the path/URL for '$i': "
    read -r ans
    
    [ ! "$ans" ] && return 0
    
    if [ "$ans" = n ]; then
        mid3v2 --TXXX nocover:nocover -- "$i"
        return 0
    fi
    
    [[ $ans =~ ^file:// ]] && ans=$(file-url-to-fullpath.sh "$ans")
    if [[ $ans =~ ^/ ]]; then
        if grep -i '\.mp3$' <<< "$ans" > /dev/null; then
            rm -f /tmp/mp3-cover &>/dev/null
            python3 -c 'import sys; from mutagen.id3 import ID3; id3 = ID3(sys.argv[1]); with open("/tmp/mp3-cover", "wb") as f: f.write(id3.getall("APIC")[0].data)' "$ans"
            pic=/tmp/mp3-cover
        else
            pic=$ans
        fi
    fi
    
    if [[ $ans =~ ^https?://.*(youtu\.be|youtube\.com|soundcloud\.com)/.+ ]]; then
        rm -rf /tmp/yt-dlp-cover
        mkdir -p /tmp/yt-dlp-cover
        yt-dlp --write-thumbnail --skip-download --output=/tmp/yt-dlp-cover/cover -- "$ans" || return 1
        mogrify -format jpg /tmp/yt-dlp-cover/*
        pic=/tmp/yt-dlp-cover/cover.jpg
    fi
    
    if [[ $ans =~ ^https?://.+ ]]; then
        rm -f /tmp/mp3-cover &>/dev/null
        wget -O /tmp/mp3-cover -- "$ans"
        pic=/tmp/mp3-cover
    fi
    
    [ "$pic" ] || return 1
    mime_type=$(file --brief --mime-type -- "$pic" 2>/dev/null)
    [ "$mime_type" = image/png -o "$mime_type" = image/jpeg ] || return 1
    [[ $pic =~ : ]] && return 1
    mid3v2 --picture="$pic" -- "$i"
}

[ "$1" ] && dir=$1
[ -d "$dir" ] || exit
dir=${dir%/}

IFS=$'\n'

find=$(find "$dir"/ -type f -name '*.mp3' | LC_ALL=C sort)

for i in $find; do
    if has-image "$i" || mp3-get-id3-frame.sh "$i" TXXX:nocover > /dev/null; then continue; fi

    filename_no_ext=$(basename -- "$i" .mp3 | sed 's/[&/?]//g')
    title=$(mp3-get-id3-frame.sh "$i" TIT2 | sed 's/[&/?]//g')
    artist=$(mp3-get-id3-frame.sh "$i" TPE1 | sed 's/[&/?]//g')
    album=$(mp3-get-id3-frame.sh "$i" TALB | sed 's/[&/?]//g')
    urls=$(mid3v2 -- "$i" | grep -oE 'https?://[^[:blank:]]+' | sort -u)
    
    echo "Filename: https://www.google.com/search?tbm=isch&q=$filename_no_ext"
    [ "$title" ] && echo "Title: https://www.google.com/search?tbm=isch&q=$title"
    [ "$album" ] && echo "Album: https://www.google.com/search?tbm=isch&q=$album"
    [ "$artist" ] && echo "Artist: https://www.google.com/search?tbm=isch&q=$artist"
    [ "$artist" -a "$title" -a "$artist" != "$title" ] && echo "Artist & title: https://www.google.com/search?tbm=isch&q=$artist $title"
    [ "$artist" -a "$album" -a "$artist" != "$album" ] && echo "Artist & album: https://www.google.com/search?tbm=isch&q=$artist $album"
    #[ "$artist" -a "$album" -a "$title" ] && echo "Artist, album & title: https://www.google.com/search?tbm=isch&q=$artist $album $title"
    [ "$urls" ] && printf '%s\n' "$urls"
    
    while ! set-cover; do :; done
    echo
done
