#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

sudo apt install xbindkeys

cp -f -- "$(linux-setup-get-resources-path.sh)/.xbindkeysrc" ~/.xbindkeysrc

killall -9 xbindkeys

xbindkeys & disown
