#!/bin/bash

printf '%s\n' "$(dirname -- "$(dirname -- "$(which linux-setup.sh)")")/resources"
