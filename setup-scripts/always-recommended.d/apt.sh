#!/bin/bash

package_list=$(linux-setup-get-resources-path.sh)/install-apt.txt

content=$(sed '/^#/d' "$package_list")

[ "$content" ] && sudo apt install $content

echo 'pidof -x syncthing || exec syncthing --no-browser' > ~/.config/linux-setup/autostart/syncthing.sh
echo 'pidof -x fcitx5 || exec fcitx5' > ~/.config/linux-setup/autostart/fcitx5.sh

cp -f -- "$(linux-setup-get-resources-path.sh)/dot-desktop-files/qpaeq.desktop" ~/.local/share/applications/

cp -f -- "$(linux-setup-get-resources-path.sh)/dot-desktop-files/thunar-bulk-renamer.desktop" ~/.local/share/applications/
