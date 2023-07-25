#!/bin/bash

rm -r -- ~/.config/mpv/watch_later
mkdir -p -- ~/.config/mpv/watch_later

while wmctrl -xc .mpv; do sleep .2; done
