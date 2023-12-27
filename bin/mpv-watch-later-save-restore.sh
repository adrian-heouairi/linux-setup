#!/bin/bash

if [ "$1" = save ]; then
    mpv-socket-all.sh write-watch-later-config # If this is not finished, it will be ready for the next launch of the script
    #sleep 1
    [ -e ~/Documents/mpv-watch-later-backup ] && rm -rf -- ~/Documents/mpv-watch-later-backup
    cp -r -- ~/.config/mpv/watch_later ~/Documents/mpv-watch-later-backup
else
    [ -e ~/.config/mpv/watch_later ] && rm -rf -- ~/.config/mpv/watch_later
    cp -r -- ~/Documents/mpv-watch-later-backup ~/.config/mpv/watch_later
fi
