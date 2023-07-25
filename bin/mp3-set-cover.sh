#!/bin/bash

get-cover() {
    pic=

    read -r -e -p "Give the path/URL for the new cover of the file(s), or 'r' to remove the cover: " ans
    
    if [ "$ans" = r ]; then
        pic=r
        return 0
    fi
    
    [[ $ans =~ ^file:// ]] && ans=$(file-url-to-fullpath.sh "$ans")
    if [[ $ans =~ ^/ ]]; then
        if grep -i '\.mp3$' <<< "$ans" > /dev/null; then
            rm -f /tmp/mp3-cover &>/dev/null
            python3 -c $'import sys; from mutagen.id3 import ID3; id3 = ID3(sys.argv[1])\nwith open("/tmp/mp3-cover", "wb") as f: f.write(id3.getall("APIC")[0].data)' "$ans"
            pic=/tmp/mp3-cover
        else
            pic=$ans
        fi
    fi
    
    if [[ $ans =~ ^https?://.*(youtu\.be|youtube\.com|soundcloud\.com)/.+ ]]; then
        rm -rf /tmp/yt-dlp-cover
        mkdir -p /tmp/yt-dlp-cover
        yt-dlp --write-thumbnail --skip-download --output=/tmp/yt-dlp-cover/cover -- "$ans"
        mogrify -format jpg /tmp/yt-dlp-cover/*
        pic=/tmp/yt-dlp-cover/cover.jpg
    elif [[ $ans =~ ^https?://.+ ]]; then
        rm -f /tmp/mp3-cover &>/dev/null
        wget -O /tmp/mp3-cover -- "$ans"
        pic=/tmp/mp3-cover
    fi
    
    [ "$pic" ] || return 1
    mime_type=$(file --brief --mime-type -- "$pic" 2>/dev/null)
    [ "$mime_type" = image/png -o "$mime_type" = image/jpeg ] || return 1
    [[ $pic =~ : ]] && return 1
    return 0
}

for i; do
    filename_no_ext=$(basename -- "$i" .mp3 | sed 's/[&/?]//g; s/ /+/g')
    title=$(mp3-get-id3-frame.sh "$i" TIT2 | sed 's/[&/?]//g; s/ /+/g')
    artist=$(mp3-get-id3-frame.sh "$i" TPE1 | sed 's/[&/?]//g; s/ /+/g')
    album=$(mp3-get-id3-frame.sh "$i" TALB | sed 's/[&/?]//g; s/ /+/g')
    urls=$(mid3v2 -- "$i" | grep -oE 'https?://[^[:blank:]]+' | sort -u)

    echo "Filename: https://www.google.com/search?tbm=isch&q=$filename_no_ext"
    [ "$title" ] && echo "Title: https://www.google.com/search?tbm=isch&q=$title"
    [ "$album" ] && echo "Album: https://www.google.com/search?tbm=isch&q=$album"
    [ "$artist" ] && echo "Artist: https://www.google.com/search?tbm=isch&q=$artist"
    [ "$artist" -a "$title" -a "$artist" != "$title" ] && echo "Artist & title: https://www.google.com/search?tbm=isch&q=$artist+$title"
    [ "$artist" -a "$album" -a "$artist" != "$album" ] && echo "Artist & album: https://www.google.com/search?tbm=isch&q=$artist+$album"
    #[ "$artist" -a "$album" -a "$title" ] && echo "Artist, album & title: https://www.google.com/search?tbm=isch&q=$artist $album $title"
    [ "$urls" ] && printf '%s\n' "$urls"
    echo
done

while ! get-cover; do :; done

if [ "$pic" = r ]; then
    for i; do
        mid3v2 --delete-frames=APIC -- "$i" && echo "Successfully removed cover in $i"
    done
else
    for i; do
        mid3v2 --picture="$pic" -- "$i" && echo "Successfully embedded cover in $i"
    done
fi

echo "Script finished"
