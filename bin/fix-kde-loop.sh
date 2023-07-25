#!/bin/sh

while sleep 1; do pidof kwin kwin_x11 > /dev/null || (kwin_x11 --replace &); pidof plasmashell > /dev/null || (plasmashell --replace &); done #fixkdeloop
