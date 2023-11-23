#!/bin/bash

current_tagainijisho_ver=$(apt show tagainijisho 2>/dev/null | sed -En 's/^Version: //p')
latest_tagainijisho_ver=$(curl --retry 10 -Lso /dev/null -w '%{url_effective}' https://github.com/Gnurou/tagainijisho/releases/latest | sed 's|.*/||')
if [ "$current_tagainijisho_ver" != "$latest_tagainijisho_ver" ]; then
    cd /tmp || exit 1
    rm -f tagainijisho-"$latest_tagainijisho_ver".deb &>/dev/null
    wget https://github.com/Gnurou/tagainijisho/releases/download/"$latest_tagainijisho_ver"/tagainijisho-"$latest_tagainijisho_ver".deb &&
    sudo apt install ./tagainijisho-"$latest_tagainijisho_ver".deb
fi
