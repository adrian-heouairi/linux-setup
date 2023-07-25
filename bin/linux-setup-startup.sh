#!/bin/bash

# This script can be launched multiple times, it won't launch programs that are already launched.

# Launches a program if it is not already running. Doesn't work with multiple instances.
f() { pidof -x -- "$(basename -- "$1")" || "$@" & }


linux-setup-startup-addon.sh &

f mpris.py

f xbindkeys

f fix-kde-loop.sh

f syncthing --no-browser

#sleep infinity | pacat & # '|' has priority over '&'

f autokey-qt

sleep infinity
