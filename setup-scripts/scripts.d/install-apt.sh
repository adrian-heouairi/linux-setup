#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

package_list=$(linux-setup-get-resources-path.sh)/apt.txt

content=$(sed '/^#/d' "$package_list")

sudo apt update

[ "$content" ] && sudo apt install $content
