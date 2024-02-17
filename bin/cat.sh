#!/bin/bash

for i; do
    printf '######################################## '
    realpath -- "$i"
    echo
    cat -- "$i"
    echo
done
