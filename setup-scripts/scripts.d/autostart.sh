#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

mkdir -p ~/.config/autostart

cp -f -- "$(linux-setup-get-resources-path.sh)/linux-setup-startup.sh.desktop" ~/.config/autostart/
