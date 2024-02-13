#!/bin/bash

[ "$1" = --user ] && user=--user || user=

log=$(systemctl -n 2000000000 $user status "$1")

first_empty_line_number=$(grep -n '^$' <<< "$log" | sed 's/:.*//')

sed "1,$first_empty_line_number"d <<< "$log"
