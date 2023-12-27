#!/bin/bash

# Use linux-setup-backup-kde-conf.sh my-conf to generate the conf backup

rsync -rl -- "$(linux-setup-get-resources-path.sh)"/kde/my-kubuntu-22.04-kde-conf/ ~/
