#!/bin/bash

# Returns non-zero if there is no cover

mp3=$1
cover_path=$2

python3 -c $'import sys; from mutagen.id3 import ID3; id3 = ID3(sys.argv[1])\nwith open(sys.argv[2], "wb") as f: f.write(id3.getall("APIC")[0].data)' "$mp3" "$cover_path" 2>/dev/null || rm -f "$cover_path"
