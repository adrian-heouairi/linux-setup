#!/bin/bash

linux-setup-install-deb.sh code 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'

linux-setup-add-env-var.sh GTK_USE_PORTAL 1 vscode.sh

mkdir -p ~/.config/Code/User/

[ -e ~/.config/Code/User/settings.json ] || cp -f -- "$(linux-setup-get-resources-path.sh)"/vscode/{keybindings,settings}.json ~/.config/Code/User/
