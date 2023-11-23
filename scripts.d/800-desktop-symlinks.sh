#!/bin/bash

old_IFS=$IFS
IFS=$'\n'
rm -f -- $(find ~/Desktop -type l -name '*.sh')
IFS=$old_IFS
for i in $(< "$(linux-setup-get-resources-path.sh)"/desktop-symlinks.txt); do
    w=$(which -- "$i") && ln -s -- "$w" ~/Desktop
done
