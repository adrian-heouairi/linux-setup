#!/bin/bash

clipboard=$(xsel)

HOME=~
if printf %s "$clipboard" | grep -E '^~(/|$)' > /dev/null; then
    clipboard=$(printf %s "$clipboard" | sed "s|^~|$HOME|")
fi

if printf %s "$clipboard" | grep '^file://' > /dev/null; then
    clipboard=$(file-url-to-fullpath.sh "$clipboard")
fi

if ! [ "$1" ]; then
    clipboard=$(printf %s "$clipboard" | sed 's|^|file://|')
fi

printf %s "$clipboard" | xsel -b
notify-send -i clipboard -- 'Copied to clipboard' "$clipboard"
