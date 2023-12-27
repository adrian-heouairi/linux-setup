#!/bin/bash

sudo apt install kde-config-fcitx5 fcitx5-mozc fcitx5-frontend-gtk2

linux-setup-add-env-var.sh GTK_IM_MODULE fcitx fcitx.sh
linux-setup-add-env-var.sh QT_IM_MODULE fcitx fcitx.sh append
linux-setup-add-env-var.sh XMODIFIERS @im=fcitx fcitx.sh append
