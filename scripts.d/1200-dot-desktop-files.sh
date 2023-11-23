#!/bin/bash

mkdir -p ~/.local/share/applications

cp -f -- "$(linux-setup-get-resources-path.sh)/dot-desktop-files"/* ~/.local/share/applications/
