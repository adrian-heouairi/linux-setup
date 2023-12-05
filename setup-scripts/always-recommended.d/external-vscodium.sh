#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

linux-setup-install-deb.sh codium '' https://github.com/VSCodium/vscodium codium_:VERSION:_amd64.deb

mkdir -p ~/.config/VSCodium/User/

[ -e ~/.config/VSCodium/User/settings.json ] || cp -f -- "$(linux-setup-get-resources-path.sh)"/vscode/{keybindings,settings}.json ~/.config/VSCodium/User/
