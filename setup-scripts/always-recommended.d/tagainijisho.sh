#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

linux-setup-install-deb.sh tagainijisho '' https://github.com/Gnurou/tagainijisho tagainijisho-:VERSION:.deb
