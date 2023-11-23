#!/bin/bash

package_list=$(linux-setup-get-resources-path.sh)/install-apt.txt

content=$(< "$package_list")

sudo apt update

[ "$content" ] && sudo apt install $content
