#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

sudo apt install libwww-mechanize-perl

if [ -e ~/D/linux-setup-programs/clyrics ]; then
    cd ~/D/linux-setup-programs/clyrics
    git pull
else
    cd ~/D/linux-setup-programs
    git clone https://github.com/trizen/clyrics
fi
