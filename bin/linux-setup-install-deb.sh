#!/bin/bash

# Give either $2 or $3 + $4

package_name=$1 # E.g. code for VSCode
other_deb_url=$2 # Any .deb URL which is not GitHub
github_repo_url=$3 # E.g. https://github.com/VSCodium/vscodium
github_deb_filename_template=$4 # May contain :VERSION: which will be replaced (s///g) by the latest version when downloading, e.g. codium_:VERSION:_amd64.deb

if apt -- policy "$package_name" | grep -E '(https?|s?ftps?)://'; then
    sudo apt -- install "$package_name"
    exit
fi

cd /tmp || exit 1
downloaded_deb_filename=linux-setup-$package_name-$(date +%s)-$(uuidgen).deb

if [ "$other_deb_url" ]; then
    wget --tries=5 -O "$downloaded_deb_filename" -- "$other_deb_url" &&
    sudo apt install ./"$downloaded_deb_filename"
else
    current_ver=$(apt -- show "$package_name" 2>/dev/null | sed -En 's/^Version: //p')
    latest_ver=$(curl --retry 5 -Lso /dev/null -w '%{url_effective}' "$github_repo_url"/releases/latest | sed 's|.*/||')

    if [ "$current_ver" != "$latest_ver" ]; then
        github_latest_deb_filename=$(sed "s/:VERSION:/$latest_ver/g" <<< "$github_deb_filename_template")
        github_latest_deb_url=$github_repo_url/releases/download/$latest_ver/$github_latest_deb_filename

        wget --tries=5 -O "$downloaded_deb_filename" -- "$github_latest_deb_url" &&
        sudo apt install ./"$downloaded_deb_filename"
    fi
fi
