#!/bin/bash

sudo apt install mpv mpv-mpris

rm -rf /tmp/mpv-watch_later
cp -rf ~/.config/mpv/watch_later /tmp/mpv-watch_later

rm -rf ~/.config/mpv
rm -rf ~/.mpv

cp -rf -- "$(linux-setup-get-resources-path.sh)/mpv" ~/.config/mpv
mv -f /tmp/mpv-watch_later ~/.config/mpv/watch_later

cp -f /usr/share/doc/mpv/examples/lua/autoload.lua ~/.config/mpv/scripts/

cp -f -- "$(linux-setup-get-resources-path.sh)/dot-desktop-files/mpv-open-at-timestamp.desktop" ~/.local/share/applications/

echo 'pidof -x mpv-auto-backup.sh || exec mpv-auto-backup.sh' > ~/.config/linux-setup/autostart/mpv-auto-backup.sh

set-default-application.sh video/mp4 mpv.desktop
set-default-application.sh video/x-matroska mpv.desktop

w=$(which mpv-open.sh) && ln -s -- "$w" ~/Desktop
w=$(which mpv-close.sh) && ln -s -- "$w" ~/Desktop || true
