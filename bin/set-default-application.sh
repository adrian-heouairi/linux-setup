#!/bin/bash

mime_type=$1
desktop_file=$2

file=~/.config/mimeapps.list

[ -e "$file" ] || echo -e '[Added Associations]\n\n[Default Applications]' >> "$file"

sed -zEi -- "s|(\[Default Applications\].*)\n$mime_type=[^\n]*\n|\1\n|" "$file"

printf '%s\n' "$mime_type=$desktop_file;" >> "$file"
