#!/bin/bash

increment=0.1

get-connected-outputs() {
    xrandr=$(xrandr)
    local connected=$(sed -En 's/^(.+) connected.*/\1/p' <<< "$xrandr")
    local res=
    for i in $connected; do
        local full=$(grep -ozE "$i .+\*" <<< "$xrandr") || continue
        sed 1d <<< "$full" | grep -q '^[^[:blank:]]' || res+=$i$'\n'
    done
    printf %s "$res"
}

outputs=$(cat /dev/shm/xrandr-brightness-outputs 2>/dev/null || get-connected-outputs)$'\n'

current_brightness=$(cat /dev/shm/xrandr-brightness-brightness 2>/dev/null || echo 1)

if [ "$1" = up ]; then
    modification="+ $increment"
elif [ "$1" = down ]; then
    modification="- $increment"
else
    modification=
fi
new_brightness=$(LC_ALL=C awk "BEGIN { b = $current_brightness $modification; if (b < 0) b = 0; print b }")

done=
for i in $outputs; do
    xrandr --output "$i" --brightness "$new_brightness" && done+=$i$'\n'
done

[ "$done" != "$outputs" ] && {
    echo "$done"
    echo "$outputs"

    echo Redoing

    outputs=$(get-connected-outputs)

    todo=$(grep -vFx "$done" <<< "$outputs")

    for i in $todo; do
        xrandr --output "$i" --brightness "$new_brightness"
    done
}

printf %s "$new_brightness" > /dev/shm/xrandr-brightness-brightness
printf %s "$outputs" > /dev/shm/xrandr-brightness-outputs
