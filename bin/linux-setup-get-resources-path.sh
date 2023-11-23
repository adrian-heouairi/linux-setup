#!/bin/bash

printf '%s\n' "$(dirname -- "$(dirname -- "$(realpath -- ~/bin/linux-setup.sh)")")/resources"
