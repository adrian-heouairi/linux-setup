#!/bin/bash

while pidof -x mpv-backup.sh; do
    sleep .1
done

rm -f /tmp/mpv-save

[ -e /tmp/mpv-save ] && notify-send "Failed to delete /tmp/mpv-save"

killall mpv
