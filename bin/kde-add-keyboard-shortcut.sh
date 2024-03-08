#!/bin/bash

# As of right now this requires a logout login

# (Standard order of modifiers in xbindkeys: Control+Shift+Alt+Mod4+Mod5)
# The order of modifiers in KDE programs is Meta+Ctrl+Alt+Shift (Alt Gr cannot be used as a modifier). You must follow this order.

# In khotkeysrc, command « dsads "a\bc\n" 'xy\z\n' x\ax \b » becomes « dsads "a\\bc\\n" 'xy\\z\\n' x\\ax \\b »

command=${1//'\'/'\\'}
shortcut=$2

remove-shortcut() {
    delete-ini-section.sh Data_"$1" ~/.config/khotkeysrc
    delete-ini-section.sh Data_"$1"Actions ~/.config/khotkeysrc
    delete-ini-section.sh Data_"$1"Actions0 ~/.config/khotkeysrc
    delete-ini-section.sh Data_"$1"Conditions ~/.config/khotkeysrc
    delete-ini-section.sh Data_"$1"Triggers ~/.config/khotkeysrc
    delete-ini-section.sh Data_"$1"Triggers0 ~/.config/khotkeysrc
}

cp -f ~/.config/khotkeysrc ~/.config/khotkeysrc.bak

if tmp2=$(grep -FxB1 "Key=$shortcut" ~/.config/khotkeysrc); then
    number=$(sed -En 's/^\[Data_([0-9]+).*/\1/p' <<< "$tmp2")
    remove-shortcut "$number"
else
    number_of_shortcuts=$(grep -Em1 '^DataCount=.+' ~/.config/khotkeysrc | sed 's/DataCount=//')
    sed -Ei "s/^DataCount=.+/DataCount=$((number_of_shortcuts + 1))/" ~/.config/khotkeysrc
    tmp=$(grep -cEx '\[Data_[0-9]+\]' ~/.config/khotkeysrc)
    number=$((tmp + 1))
fi

uuid=$(uuidgen)

to_append="[Data_${number}]
Comment=Comment
Enabled=true
Name=$command
Type=SIMPLE_ACTION_DATA

[Data_${number}Actions]
ActionsCount=1

[Data_${number}Actions0]
CommandURL=$command
Type=COMMAND_URL

[Data_${number}Conditions]
Comment=
ConditionsCount=0

[Data_${number}Triggers]
Comment=Simple_action
TriggersCount=1

[Data_${number}Triggers0]
Key=$shortcut
Type=SHORTCUT
Uuid={$uuid}"

printf '\n%s\n' "$to_append" >> ~/.config/khotkeysrc

cp -f ~/.config/kglobalshortcutsrc ~/.config/kglobalshortcutsrc.bak

content=$(< ~/.config/kglobalshortcutsrc)
[[ $content =~ (=|,|'\t')"$shortcut"(,|'\t') ]]
[ "$BASH_REMATCH" ] && content=$(grep -Fv "$BASH_REMATCH" <<< "$content")

content=${content/'_k_friendly_name=Custom Shortcuts Service'/'_k_friendly_name=Custom Shortcuts Service'$'\n'"{$uuid}=$shortcut,none,${command//,}"}

printf '%s\n' "$content" > ~/.config/kglobalshortcutsrc

#killall -9 kglobalaccel5; sleep .5; kglobalaccel5 & disown
