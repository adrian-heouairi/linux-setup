#!/bin/bash

if [ "$HOSTNAME" = aetu2 ]; then
    echo 2
elif [ "$HOSTNAME" = atnr ]; then
    echo 3
else
    exit 1
fi
