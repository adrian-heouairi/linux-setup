#!/bin/bash

sudo apt install xbindkeys

cp -f -- "$(linux-setup-get-resources-path.sh)/.xbindkeysrc" ~/.xbindkeysrc

killall -9 xbindkeys

echo 'pidof -x xbindkeys || exec xbindkeys' > ~/.config/linux-setup/autostart/xbindkeys.sh

xbindkeys &>/dev/null & disown
