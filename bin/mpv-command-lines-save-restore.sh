#!/bin/bash

# The window title is used to extract playlist position, it should follow ^[0-9]+ (mpv.conf: title="${playlist-pos-1}...")

# For playlist position to be restored (e.g. remember the current file in the playlist), you must select all files in your file explorer and open them (all files must be in the command line of the mpv instance). If you open only one file and rely on autoload.lua to add the playlist automatically, the playlist doesn't exist at launch time (it is created right after), thus the --playlist-start=n option we add doesn't work

dir=~/Documents/mpv-save-restore

if [ "$1" = save ]; then
    rm -rf -- "$dir"
    mkdir -p -- "$dir" || exit
    cd /proc || exit 1
    wmctrl_lp=$(wmctrl -lp)
    
    pids=$(printf -- '%s\n' * | grep -E '^[0-9]+$')
    for pid in $pids; do
        if [ "$(cat "$pid"/comm 2>/dev/null)" == mpv ]; then
            grep -- '/.local/share/Anki2/mpv.conf' "$pid"/cmdline &>/dev/null && continue
        
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
