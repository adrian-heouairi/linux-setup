#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

sudo cp -f -- "$(linux-setup-get-resources-path.sh)"/55-CUSTOM-force-noto-japanese-font.conf /etc/fonts/conf.d/
