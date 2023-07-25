#!/bin/bash

hardcoded_output=DP-3-1
increment=0.1

current_brightness=$(cat /dev/shm/xrandr-brightness 2>/dev/null || echo 1)

if [ "$1" = up ]; then
    modification="+ $increment"
elif [ "$1" = down ]; then
    modification="- $increment"
else
    modification=
fi

new_brightness=$(LC_ALL=C awk "BEGIN { b = $current_brightness $modification; if (b < 0) b = 0; print b }")

if ! xrandr --output "$hardcoded_output" --brightness "$new_brightness"; then
    for i in $(xrandr | sed -En 's/^(.+) connected.*/\1/p'); do
        xrandr --output "$i" --brightness "$new_brightness"
    done
fi

printf %s "$new_brightness" > /dev/shm/xrandr-brightness
