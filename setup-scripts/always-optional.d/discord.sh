#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

linux-setup-install-deb.sh discord 'https://discord.com/api/download?platform=linux&format=deb'
