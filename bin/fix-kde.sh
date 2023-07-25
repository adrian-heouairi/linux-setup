#!/bin/sh

killall -9 plasmashell kwin kwin_x11
sleep 1
DISPLAY=:0 plasmashell --replace &
DISPLAY=:0 kwin_x11 --replace &
