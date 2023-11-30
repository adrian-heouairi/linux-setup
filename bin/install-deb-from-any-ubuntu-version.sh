#!/bin/bash

# Usage: <suite> package
# suite is for example focal-updates

# Example: dl-install-deb.sh jammy-updates linux-headers-5.17.0-1034-oem linux-modules-5.17.0-1034-oem linux-image-5.17.0-1034-oem linux-oem-5.17-headers-5.17.0-1034

dir=~/D/dl-install-deb

mkdir -p -- "$dir"
cd -- "$dir" || exit 1

suite=$1

shift

deb_filenames=() pkgs=()
for i; do
    pkg=$i
    arch=amd64 # Website will yield "all" if amd64 version doesn't exist
    
    while ! page=$(wget -O - https://packages.ubuntu.com/"$suite"/"$arch"/"$pkg"/download); do :; done

    deb_url=$(printf %s "$page" | grep -Eom1 '"https?://[^"]+\.deb"' | sed -E 's/^"|"$//g')
    [ "$deb_url" ] || exit 1

    deb_filename=${deb_url##*/}

    if ! [ -e "$deb_filename" ]; then
        while ! wget -- "$deb_url"; do :; done
    fi

    deb_filenames+=(./"$deb_filename")
    pkgs+=("$pkg")
done

if ! sudo apt install "${deb_filenames[@]}"; then
    sudo apt -y remove -- "${pkgs[@]}"
    echo "$0: Error, no packages have been installed"
    exit 1
fi
