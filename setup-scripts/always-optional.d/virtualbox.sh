#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

sudo apt install virtualbox-qt virtualbox-guest-additions-iso virtualbox-ext-pack

sudo usermod -a -G vboxusers "$USER" # For USB
