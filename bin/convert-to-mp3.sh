#!/bin/bash

# $1 is source file, $2 is destination which must end by .mp3 and can be equal to $1

[[ $2 =~ '.'mp3$ ]] || exit 1

tmp=$(dirname -- "$2")/convert-to-mp3_$$.mp3

ffmpeg -y -i "$1" -vcodec copy -- "$tmp" && mv -f -- "$tmp" "$2" || rm -f -- "$tmp"
