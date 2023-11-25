#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

sudo apt install autokey-gtk

killall -9 autokey-qt autokey autokey-gtk

rm -rf ~/.config/autokey

cp -rf -- "$(linux-setup-get-resources-path.sh)/autokey" ~/.config/autokey

echo 'pidof -x autokey-gtk || exec autokey-gtk' > ~/.config/linux-setup/autostart/autokey.sh

autokey-gtk & disown
