#!/bin/bash

package_list=$(linux-setup-get-resources-path.sh)/install-snap.txt
package_list_classic=$(linux-setup-get-resources-path.sh)/install-snap-classic.txt

content=$(< "$package_list")
content_classic=$(< "$package_list_classic")

[ "$content" ] && sudo snap install $content
[ "$content_classic" ] && sudo snap install --classic $content_classic || true
