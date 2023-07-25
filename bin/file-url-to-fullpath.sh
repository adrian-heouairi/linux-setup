#!/bin/bash

# Give one or more lines in $1.
# If one line: returns 0 if the file exists, 1 otherwise. If multiple lines, returns 2.

no_protocol=$(sed 's;^file://;;' <<< "$1")
fullpaths=$(python3 -c 'import sys; from urllib.parse import unquote; print(unquote(sys.argv[1]))' "$no_protocol")
printf '%s\n' "$fullpaths"

if [ "$(grep -c . <<< "$fullpaths")" = 1 ]; then
    [ -e "$fullpaths" ]
else
    exit 2
fi
