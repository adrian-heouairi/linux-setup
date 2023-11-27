#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

rsync -rl -- "$(linux-setup-get-resources-path.sh)"/kde/my-kde-conf/ ~/
