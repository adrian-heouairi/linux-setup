#!/bin/bash

current_anki_ver=$(anki --version | sed -n '$s/.* //p')
latest_anki_ver=$(curl --retry 10 -Lso /dev/null -w '%{url_effective}' https://github.com/ankitects/anki/releases/latest | sed 's|.*/||')
if [ "$current_anki_ver" != "$latest_anki_ver" ]; then
    anki_dir=/tmp/anki-"$(uuidgen)"
    anki_archive=anki-"$latest_anki_ver"-linux-qt6.tar.zst
    mkdir -p -- "$anki_dir"
    cd -- "$anki_dir"
    wget https://github.com/ankitects/anki/releases/download/"$latest_anki_ver"/"$anki_archive" &&
    tar --use-compress-program=unzstd -xf "$anki_archive" &&
    cd anki-"$latest_anki_ver"-linux-qt6 && {
        sudo apt remove anki
        sudo /usr/local/share/anki/uninstall.sh
        sudo ./install.sh
    }
fi
