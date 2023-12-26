#!/bin/bash

#IFS=$'\n'
for i in $(find /tmp/mpv-sockets/ -type s); do
    socat - "$i" <<< "$*" || rm -f -- "$i"
done
