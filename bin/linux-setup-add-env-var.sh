#!/bin/bash

key=$1
value=$2 # Must include quotes if there are shell characters or spaces unless it is wanted e.g. $PATH:$HOME/my-bin
file=$3
append=$4

mkdir -p ~/.config/linux-setup-env

line="export $key=$value"

if [ "$append" ]; then
    printf '%s\n' "$line" >> ~/.config/linux-setup-env/"$file"
else
    printf '%s\n' "$line" > ~/.config/linux-setup-env/"$file"
fi
