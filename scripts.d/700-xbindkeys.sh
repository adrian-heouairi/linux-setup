#!/bin/bash

cp -f -- "$(linux-setup-get-resources-path.sh)/.xbindkeysrc" ~/.xbindkeysrc

killall -9 xbindkeys

xbindkeys & disown
