#!/bin/bash

notification_delay=700

pattern=$1
command=$2

all_windows_list=$(wmctrl -l)

matching_window_titles=$(printf %s "$all_windows_list" | awk '{ $3 = ""; $2 = ""; print $0 }' | grep -E -- "$pattern" | LC_ALL=C sort -k 2gr)

matching_window_ids=$(awk '{ print $1 }' <<< "$matching_window_titles")
#matching_window_titles=$(sed 's/^[^ ]*   //' <<< "$matching_window_titles")

#echo "DEBUG: matching_window_titles"$'\n'"$matching_window_titles"
#echo "DEBUG: matching_window_ids"$'\n'"$matching_window_ids"

[ "$matching_window_ids" ] || { eval -- "$command" & disown; exit 0; }

current_window_id=$(printf 0x%08x "$(xdotool getactivewindow)")
#echo "DEBUG: current_window_id"$'\n'"$current_window_id"
current_and_next_window_ids=$(grep -A 1 -Fx -- "$current_window_id" <<< "$matching_window_ids")
#echo "DEBUG: current_and_next_window_ids"$'\n'"$current_and_next_window_ids"
situation=$(grep -c . <<< "$current_and_next_window_ids")
#echo "DEBUG: situation"$'\n'"$situation"

if ((situation == 2)); then
    #notify-send -i flag-green -t "$notification_delay" Cycle ON
    next_window_id=$(awk NR==2 <<< "$current_and_next_window_ids")
#    echo "DEBUG: next_window_title"$'\n'"$next_window_title"
    wmctrl -ia "$next_window_id"
elif ((situation == 1)); then
    notify-send -i flag-red -t "$notification_delay" Cycle OFF
    for i in $matching_window_ids; do
        xdotool windowminimize -- "$i"
    done
elif ((situation == 0)); then
    notify-send -i flag-green -t "$notification_delay" Cycle ON
    first_window_id=$(awk NR==1 <<< "$matching_window_ids")
#    echo "DEBUG: first_window_title"$'\n'"$first_window_title"
    wmctrl -ia "$first_window_id"
fi
