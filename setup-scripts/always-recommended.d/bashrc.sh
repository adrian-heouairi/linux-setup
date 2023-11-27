#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

cp -f -- "$(linux-setup-get-resources-path.sh)"/.bash_aliases ~/
