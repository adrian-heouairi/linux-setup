#!/bin/bash

# Perl: /s allows . to match \n.
# With perl -0777, $ only matches the end of document

section_name=$1
if [[ $section_name =~ ^"[" ]]; then
    section_name=$(sed 's/^\[//; s/\]$//' <<< "$section_name")
fi

file=$2

perl -0777pi -e "s/(\n?)\[$section_name\]\n.*?\n\[/\1\[/s" -- "$file"
perl -0777pi -e "s/(\n?)\[$section_name\]\n.*//s" -- "$file"
