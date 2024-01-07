#!/bin/bash

if [ "$HOSTNAME" = aetu2 ] && ! mountpoint /mnt/Shared-SMB-atnr; then
    notify-send "Mount SMB first"
    exit 1
fi

mpv-watch-later-save-restore.sh restore
mpv-command-lines-save-restore.sh restore

touch /tmp/mpv-save
