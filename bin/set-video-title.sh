#!/bin/bash

video=$1
title=$2

[ -f "$video" ] || exit 1

extension=${video##*.}

tmp_file="$1"TMP.$extension

ffmpeg -y -i "$1" -codec copy -metadata title="$title" -- "$tmp_file" && mv -f -- "$tmp_file" "$1" || rm -f -- "$tmp_file"
