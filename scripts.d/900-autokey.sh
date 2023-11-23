#!/bin/bash

killall -9 autokey-qt autokey autokey-gtk

rm -rf ~/.config/autokey

cp -rf -- "$(linux-setup-get-resources-path.sh)/autokey" ~/.config/autokey

autokey-gtk & disown
