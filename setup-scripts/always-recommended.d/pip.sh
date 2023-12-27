#!/bin/bash

package_list=$(linux-setup-get-resources-path.sh)/install-pip.txt

sudo apt remove yt-dlp youtube-dl

sudo apt install pipx

for i in $(< "$package_list"); do
    pipx install "$i"
done

pipx upgrade-all
