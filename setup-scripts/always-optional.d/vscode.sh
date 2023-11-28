#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

if ! which code; then
    deb='download?build=stable&os=linux-deb-x64'

    cd /tmp || exit 1
    rm -f -- "$deb" &>/dev/null
    wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' &&
    sudo apt install ./"$deb"
fi

sudo apt update
sudo apt upgrade

mkdir -p ~/.config/Code/User/

cp -f -- "$(linux-setup-get-resources-path.sh)"/vscode/{keybindings,settings}.json ~/.config/Code/User/
