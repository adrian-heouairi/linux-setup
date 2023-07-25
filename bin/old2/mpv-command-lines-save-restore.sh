#!/bin/bash

dir=~/Documents/mpv-save-restore

if ! [ "$1" ]; then # Save
    rm -rf -- "$dir"
    mkdir -p -- "$dir" || exit
    cd /proc || exit 1
    wmctrl_lp=$(wmctrl -lp)
    
    pids=$(printf -- '%s\n' * | grep -E '^[0-9]+$')
    for pid in $pids; do
        if [ "$(cat "$pid"/comm 2>/dev/null)" == mpv ]; then
            cp -- "$pid"/cmdline "$dir"/"$pid"_cmdline
            
            sed -zi -- '1d; /^--playlist-start=/d; /^--window-minimized/d; /^--pause/d; /^--loop-file/d' "$dir"/"$pid"_cmdline
            playlist_pos_1=$(printf %s "$wmctrl_lp" | awk "\$3 == \"$pid\" { print \$5 }" | sed -En '1s|^([0-9]+)/[0-9]+$|\1|p')
            [ "$playlist_pos_1" ] && sed -zi -- "1i --playlist-start=$((playlist_pos_1 - 1))" "$dir"/"$pid"_cmdline
            
            readlink --no-newline -- "$pid"/cwd > "$dir"/"$pid"_cwd
        fi
    done
else # Restore
    [ -d "$dir" ] || exit 1

    counter=0
    for cmdline in "$dir"/*_cmdline; do
        ((counter++ % 8 == 7)) && sleep 1
        cwd=$dir/$([[ $(basename -- "$cmdline") =~ [0-9]+ ]]; printf %s "$BASH_REMATCH")_cwd
        cd -- "$(< "$cwd")"
        cat -- "$cmdline" | xargs -0 mpv --pause $([[ $(sed -zn -- '$p' "$cmdline") =~ ^$(echo ~)/[DM]/My_videos/ ]] && printf -- --loop-file) & disown
    done
fi
