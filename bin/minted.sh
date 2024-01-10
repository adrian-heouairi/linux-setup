#!/bin/bash

path=$1

fullpath=$(realpath -- "$path")

if ! [ -e "$fullpath" ]; then
    notify-send ".tex file '$fullpath' doesn't exist"
    exit 1
fi

dir=$(dirname -- "$fullpath")
file=$(basename -- "$fullpath")

[ -e "$dir"/main.tex ] && file=main.tex

cd -- "$dir" || exit 1

pdflatex -halt-on-error -shell-escape "$dir/$file"
pdflatex -halt-on-error -shell-escape "$dir/$file"
