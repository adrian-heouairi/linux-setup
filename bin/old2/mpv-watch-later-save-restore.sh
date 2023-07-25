#!/bin/bash

if ! [ "$1" ]; then # Save

[ -e ~/Documents/mpv-watch-later-backup ] && rm -rf -- ~/Documents/mpv-watch-later-backup
cp -r -- ~/.config/mpv/watch_later ~/Documents/mpv-watch-later-backup

else

[ -e ~/.config/mpv/watch_later ] && rm -rf -- ~/.config/mpv/watch_later
cp -r -- ~/Documents/mpv-watch-later-backup ~/.config/mpv/watch_later

fi
