#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

linux-setup-install-deb.sh zoom 'https://zoom.us/client/latest/zoom_amd64.deb'
