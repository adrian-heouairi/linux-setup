#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

mkdir -p ~/.local/share/applications

cp -f -- "$(linux-setup-get-resources-path.sh)/dot-desktop-files"/* ~/.local/share/applications/
