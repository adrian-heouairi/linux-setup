#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

# Use linux-setup-backup-kde-conf.sh my-conf to generate the conf backup

rsync -rl -- "$(linux-setup-get-resources-path.sh)"/kde/my-kubuntu-22.04-kde-conf/ ~/
