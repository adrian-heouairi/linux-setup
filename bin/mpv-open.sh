#!/bin/bash

mpv-watch-later-save-restore.sh restore
mpv-command-lines-save-restore.sh restore & disown

sleep 30

touch /tmp/mpv-save
