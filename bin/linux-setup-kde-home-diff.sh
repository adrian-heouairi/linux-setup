#!/bin/bash

d=$(diff -qr "$(linux-setup-get-resources-path.sh)"/kde/default-kubuntu-22.04-home/ ~/ | grep 'differ$' | awk '{ print $4 }')

IFS=$'\n'
for i in $d; do
    [ -e "$i" ] && printf '%s\n' "$i"
done
