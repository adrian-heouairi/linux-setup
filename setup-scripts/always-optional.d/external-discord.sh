#!/bin/bash

killall discord Discord
sleep 1
pidof discord Discord && {
    killall -9 discord Discord
    sleep 1
}

linux-setup-install-deb.sh discord 'https://discord.com/api/download?platform=linux&format=deb'
