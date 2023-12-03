#!/bin/bash

c=$(xprop -id "$(xdotool getactivewindow)" WM_CLASS)
c=${c#*'"'}
c=${c/'", "'/'.'}
c=${c%'"'}
printf '%s\n' "$c"
