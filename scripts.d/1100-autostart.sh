#!/bin/bash

mkdir -p ~/.config/autostart

cp -f -- "$(linux-setup-get-resources-path.sh)/linux-setup-startup.sh.desktop" ~/.config/autostart/
