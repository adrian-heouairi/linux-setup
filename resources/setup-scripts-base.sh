#!/bin/bash

trap exit SIGINT

script_path=$(realpath -- "$BASH_SOURCE")
resources=$(dirname -- "$script_path")
base_bin_dir=$(dirname -- "$resources")/bin

export "PATH=$HOME/D/linux-setup-addon/bin:$base_bin_dir:$PATH"
