#!/bin/bash

# Default libx265 CRF is 28
# Default libopus bitrate is 96 kbps -> 17,28 MiB for 24.0 minutes

#nb_of_audio_tracks=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 -- "$i" | wc -w)
#duration=$(ffprobe -loglevel quiet -show_entries format=duration -of default=nk=1:nw=1 -- "$i")

tmp_file=

trap 'rm -f -- "$tmp_file"; exit 0' SIGINT

#trap 'echo "Current file: $tmp_file"' SIGQUIT

db=~/Documents/reencode-dir-videos.txt

IFS=$'\n'

mkdir -p ~/Documents || exit 1

for ext in mkv mp4; do
    for i in $(find "$(realpath -- "$1")" -type f -name "*.$ext" 2>/dev/null | LC_ALL=C sort); do
        basename=$(basename -- "$i")
        
        grep -Fx -- "$basename" "$db" &>/dev/null && continue
    
        if (( $(printf %s "$basename" | wc --bytes) > 240 )); then
            tmp_file=${i%???????????????}TMP.$ext
        else
            tmp_file=${i}TMP.$ext
        fi
    
        echo "Current file: $i"
    
        if ffmpeg -y -i "$i" -map 0 -codec copy -vcodec libx265 -acodec libopus -- "$tmp_file"; then
            if (( $(find "$tmp_file" -printf %s) < $(find "$i" -printf %s) )); then
                mv -f -- "$tmp_file" "$i"
            else
                rm -f -- "$tmp_file"
            fi
            
            printf '%s\n' "$basename" >> "$db"
        else
            rm -f -- "$tmp_file"
            echo "ffmpeg failed for $i"
        fi
    done
done
