#!/bin/bash

script_path=$(realpath -- "$0")
resources=$(dirname -- "$script_path")
bin_dir=$(dirname -- "$resources")/bin

export "PATH=$HOME/D/linux-setup-addon/bin:$bin_dir:$PATH"
