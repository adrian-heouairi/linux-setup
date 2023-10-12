#!/bin/bash

notify() {
    #notify-send -u critical -i folder-snap -- 'Snap refresh' "$1"
    notify-send -u critical -i /usr/share/snapd/snapcraft-logo-bird.svg -- 'Snap refresh' "$1"
}

# Returns a space-separated list of PIDs
# May include the same PID multiple times
snap-name-to-PIDs() {
#     case "$1" in
#     discord) pidof discord Discord;;
#     code) echo $(pidof code) $(pgrep -f /snap/code/);;
#     *) pidof -- "$1";;
#     esac
    echo $(pgrep -f /snap/"$1"/)
}

refreshable_snaps=$(snap refresh --list | sed 1d | awk '{ print $1 }')

snaps_to_refresh=()
for i in $refreshable_snaps; do
    case "$i" in
    firefox)
        if wmctrl -l | grep 'Mozilla Firefox Private Browsing'; then
            notify 'Close Firefox private browsing to refresh snap'
            continue
        fi;;
    esac
    snaps_to_refresh+=("$i")
done

[ "$snaps_to_refresh" ] || exit 0

snaps_to_relaunch=()
for i in "${snaps_to_refresh[@]}"; do
    if [ "$(snap-name-to-PIDs "$i")" ]; then
        snaps_to_relaunch+=("$i")

        kill -- $(snap-name-to-PIDs "$i")
        j=0
        while [ "$(snap-name-to-PIDs "$i")" ] && ((j++ < 100)); do
            sleep .1
        done

        kill -9 -- $(snap-name-to-PIDs "$i")
    fi
done
sleep .5 # For the last kill -9

#if pkexec snap refresh || sudo snap refresh; then

konsole --separate -e bash -c 'echo snap refresh; sudo snap refresh'
still_not_refreshed=$(snap refresh --list 2>/dev/null)
if [ "$still_not_refreshed" ]; then
    notify "snap refresh was run, but the following snaps were not refreshed:\n$still_not_refreshed"
else
    notify 'All snaps have been refreshed successfully'
fi

#else
#    notify "Couldn't run snap refresh command"
#fi

for i in "${snaps_to_relaunch[@]}"; do "$i" & done
