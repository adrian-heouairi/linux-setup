#!/bin/bash

# $1 is source file, $2 is destination which must end by .mp3 and can be equal to $1

[[ $2 =~ '.'mp3$ ]] || exit 1

ffmpeg -y -i "$1" -vcodec copy -- "$2"TMP.mp3 && mv -f -- "$2"TMP.mp3 "$2"
