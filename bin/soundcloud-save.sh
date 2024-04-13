#!/bin/bash

# Go on liked tracks, refresh with ctrl+shift+r, scroll on all the page and save on desktop with ctrl+s

file=~/Desktop/"Hear the tracks you’ve liked on SoundCloud.html"

links=$(grep -P -- '<a class="playableTile__artworkLink audibleTile__artworkLink" href=".+?">' "$file" | grep -oE 'https?://[^"]+')

echo "Downloading $(grep -c . <<< "$links") files..."

#mkdir -p ~/Desktop/"Hear the tracks you’ve liked on SoundCloud"
#cd ~/Desktop/"Hear the tracks you’ve liked on SoundCloud" || exit 1
cd ~/D/Shared-ST-apho/Music/Musique/"Hear the tracks you’ve liked on SoundCloud" || exit 1

failed=
for i in $links; do
    yt-dlp.sh -x -- "$i" || failed+=$i$'\n'
done

if [ "$failed" ]; then
    echo -en "\e[1;31mFAILED:\n$failed"
    echo -en "\e[m"
    exit 1
else
    echo "Nothing failed for $(grep -c . <<< "$links") files"
fi
