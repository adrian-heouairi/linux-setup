#!/bin/sh

if [ "$*" ]; then
    exec python3 -c 'import sys; from urllib.parse import unquote; print(unquote(sys.argv[1]))' "$*"
else
    python3 -c 'import sys; from urllib.parse import unquote; print(unquote(sys.argv[1]))' "$(cat /dev/stdin)"
fi
