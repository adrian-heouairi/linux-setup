#!/bin/bash

# Third argument must be only one shortcut, fourth argument must be the default shortcuts in KDE separated by \\t (\\t between simple quotes in Bash) for this shortcut or nothing
put_kde_keyboard_shortcut() {
    sed -i "/$3\(,\|\\\\t\)/d" ~/.config/kglobalshortcutsrc # $3 may contain '+' so we can't use sed -E
    kwriteconfig5 --file kglobalshortcutsrc --group "$1" --key "$2" "$3",,
    
    # \t or \\t doesn't work with kwriteconfig5
    if [ "$4" ]; then
        sed -i "s/^\($2=$3\),,$/\1\\\\t$4,$4,/" ~/.config/kglobalshortcutsrc
    fi
}

killall -9 kglobalaccel5

# See ~/.config/kglobalshortcutsrc

#put_kde_keyboard_shortcut kmix mic_mute Alt+Z 'Microphone Mute'
put_kde_keyboard_shortcut kmix mute Alt+X 'Volume Mute'
put_kde_keyboard_shortcut plasmashell 'toggle do not disturb' Alt+C
put_kde_keyboard_shortcut mediacontrol playpausemedia Meta+Z 'Media Play'
put_kde_keyboard_shortcut kmix decrease_volume Meta+Alt+A 'Volume Down'
put_kde_keyboard_shortcut kmix increase_volume Meta+Alt+S 'Volume Up'
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 4' Meta+Q Meta+4
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 5' Meta+W Meta+5
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 6' Meta+E Meta+6
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 7' Meta+Shift+Q Meta+7
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 8' Meta+Shift+W Meta+8
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 9' Meta+Shift+E Meta+9
put_kde_keyboard_shortcut kwin 'Window Close' Meta+X Alt+F4
put_kde_keyboard_shortcut org.kde.krunner.desktop _launch Alt+Space Alt+F2

kde-add-keyboard-shortcut.sh 'xrandr-brightness.sh down' Meta+Shift+A
kde-add-keyboard-shortcut.sh 'xrandr-brightness.sh up' Meta+Shift+S

kglobalaccel5 &>/dev/null & disown
