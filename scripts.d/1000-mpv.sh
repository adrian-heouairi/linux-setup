#!/bin/bash

rm -rf ~/.config/mpv ~/.mpv

cp -rf -- "$(linux-setup-get-resources-path.sh)/mpv" ~/.config/mpv

cp -f /usr/share/doc/mpv/examples/lua/autoload.lua ~/.config/mpv/scripts/
