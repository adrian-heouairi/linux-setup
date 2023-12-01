#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

linux-setup-install-deb.sh code 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'

mkdir -p ~/.config/Code/User/

cp -f -- "$(linux-setup-get-resources-path.sh)"/vscode/{keybindings,settings}.json ~/.config/Code/User/
