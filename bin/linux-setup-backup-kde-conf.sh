#!/bin/bash

files_to_backup_file=$(linux-setup-get-resources-path.sh)/kde/differences-between-mine-and-default.txt

files_to_backup=$(sed -- '/^#/d' "$files_to_backup_file")

dest=$1
[ "$dest" ] || exit 1

rm -rf -- "$dest"
mkdir -p -- "$dest"
cd -- "$dest"

IFS=$'\n'
for i in $files_to_backup; do
    new_dir=$(dirname -- "$i" | sed -E 's|^/home/[^/]+/?||')
    [ "$new_dir" ] || new_dir=.
    mkdir -p -- "$new_dir"
    cp -f -- "$i" "$new_dir"/
done

sed -i '/^History=/d' .config/dolphinrc
sed -i '/^History Items/d' .config/kdeglobals
sed -i '/^Recent/d' .config/konsolerc
sed -Ei '/^(Recent|[^=]*History)/d' .config/katerc
delete-ini-section.sh 'Recent Files' .config/gwenviewrc
