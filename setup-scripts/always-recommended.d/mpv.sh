#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

sudo apt install mpv mpv-mpris

rm -rf /tmp/mpv-watch_later
cp -rf ~/.config/mpv/watch_later /tmp/mpv-watch_later

rm -rf ~/.config/mpv
rm -rf ~/.mpv

cp -rf -- "$(linux-setup-get-resources-path.sh)/mpv" ~/.config/mpv
mv -f /tmp/mpv-watch_later ~/.config/mpv/watch_later

cp -f /usr/share/doc/mpv/examples/lua/autoload.lua ~/.config/mpv/scripts/

cp -f -- "$(linux-setup-get-resources-path.sh)/dot-desktop-files/mpv-open-at-timestamp.desktop" ~/.local/share/applications/

w=$(which mpv-open.sh) && ln -s -- "$w" ~/Desktop
w=$(which mpv-backup.sh) && ln -s -- "$w" ~/Desktop
