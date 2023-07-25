#!/bin/bash

# Returns 1 if tag is not present, 2 if mp3 file is invalid

# See https://mutagen-specs.readthedocs.io/en/latest/id3/id3v2.4.0-frames.html for list of frames

# There are major differences for date storage between ID3v2.3 and ID3v2.4, see https://eyed3.readthedocs.io/en/latest/compliance.html

# Title = TIT2, artist = TPE1, album = TALB, track number = TRCK

path=$1
frame=$2 # For example: TIT2, TXXX:description

python3 -c 'import sys, mutagen
try: file = mutagen.File(sys.argv[1])
except: exit(2)
if sys.argv[2] not in file.tags: exit(1)
print(file.tags[sys.argv[2]].text[0])' "$path" "$frame"
