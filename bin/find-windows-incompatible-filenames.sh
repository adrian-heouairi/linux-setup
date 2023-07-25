#!/bin/sh

[ "$1" ] && dir=$1 || dir=~

find "${dir%/}/" | grep '.*[|<>?"*:\\].*'
