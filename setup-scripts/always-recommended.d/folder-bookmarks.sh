#!/bin/bash

tmp_bookmark_proof=' <bookmark href="file:///tmp">'

tmp_bookmark=' <bookmark href="file:///tmp">\n  <title>tmp</title>\n  <info>\n   <metadata owner="http://freedesktop.org">\n    <bookmark:icon name="folder-temp"/>\n   </metadata>\n   <metadata owner="http://www.kde.org">\n    <ID>1698215335/0</ID>\n   </metadata>\n  </info>\n </bookmark>'

if ! grep -Fx -- "$tmp_bookmark_proof" "$HOME"/.local/share/user-places.xbel; then
    sed -zEi.linux-setup-backup -- "s|</bookmark>\n <separator>|</bookmark>\n$tmp_bookmark\n <separator>|" "$HOME"/.local/share/user-places.xbel
fi

# Put all Qt bookmarks in GTK
awk -F\" '/<bookmark href=\"file/ {print $2}' < "$HOME"/.local/share/user-places.xbel > "$HOME"/.config/gtk-3.0/bookmarks
