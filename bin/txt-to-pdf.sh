#!/bin/bash

# Requires sudo apt install enscript

# You can check available fonts using fc-list.

for i; do
    tmp=/tmp/$(uuidgen).ps
    enscript -f "Times-Roman12" -p "$tmp" "$i"
    ps2pdf "$tmp" "${i%.*}.pdf"
    rm -- "$tmp"

    #pandoc "$i" -o "${i%.*}.pdf" --from txt --to pdf
done
