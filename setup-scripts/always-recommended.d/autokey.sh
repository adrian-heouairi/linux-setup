#!/bin/bash

sudo apt install autokey-gtk

killall -9 autokey-qt autokey autokey-gtk

rm -rf ~/.config/autokey

if [ "$HOSTNAME" = aetu2 ]; then
    ln -s -- "$(linux-setup-get-resources-path.sh)"/autokey ~/.config/autokey
else
    cp -rf -- "$(linux-setup-get-resources-path.sh)/autokey" ~/.config/autokey
fi

echo 'pidof -x autokey-gtk || exec autokey-gtk' > ~/.config/linux-setup/autostart/autokey.sh

autokey-gtk &>/dev/null & disown
