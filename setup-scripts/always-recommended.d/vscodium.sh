#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

base_url=https://github.com/VSCodium/vscodium/releases
current_ver=$(apt show codium 2>/dev/null | sed -En 's/^Version: //p')
latest_ver=$(curl --retry 10 -Lso /dev/null -w '%{url_effective}' "$base_url"/latest | sed 's|.*/||')

if [ "$current_ver" != "$latest_ver" ]; then
    deb=codium_${latest_ver}_amd64.deb

    cd /tmp || exit 1
    rm -f -- "$deb" &>/dev/null
    wget "$base_url"/download/"$latest_ver"/"$deb" &&
    sudo apt install ./"$deb"
fi
