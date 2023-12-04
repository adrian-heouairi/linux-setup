#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

linux-setup-install-deb.sh zoom 'https://zoom.us/client/5.16.10.668/zoom_amd64.deb'
