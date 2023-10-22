#!/bin/bash

# These two must not begin with '-'
base=$(realpath -- "$0") base=$(sed -E 's|/bin/[^/]+$||' <<< "$base")
addon=~/D/linux-setup-addon

trap exit SIGINT

mkdir -p -- "$addon"/bin
if ! [ -e "$addon"/bin/linux-setup-startup-addon.sh ]; then
    echo $'#!/bin/bash\n\n# You must launch a program only if it is not already running\n\nsleep infinity' >> "$addon"/bin/linux-setup-startup-addon.sh
    chmod +x -- "$addon"/bin/linux-setup-startup-addon.sh
fi
if ! [ -e "$addon"/bin/linux-setup-addon.sh ]; then
    echo $'#!/bin/bash' >> "$addon"/bin/linux-setup-addon.sh
    chmod +x -- "$addon"/bin/linux-setup-addon.sh
fi

if ! [ "$1" ]; then
    sudo apt update
    sudo apt install $(cat "$base"/install-apt.txt) $(cat "$addon"/install-apt.txt 2>/dev/null)
    sudo snap install $(cat "$base"/install-snap.txt) $(cat "$addon"/install-snap.txt 2>/dev/null)
    if [ -e ~/D/linux-setup-programs/clyrics ]; then
        cd ~/D/linux-setup-programs/clyrics
        git pull
    else
        mkdir -p ~/D/linux-setup-programs
        cd ~/D/linux-setup-programs
        git clone https://github.com/trizen/clyrics
    fi
    
    sudo apt remove yt-dlp youtube-dl
    for i in $(cat "$base"/install-pip.txt) $(cat "$addon"/install-pip.txt 2>/dev/null); do
        pipx install "$i"
    done
    pipx upgrade-all
    
    current_tagainijisho_ver=$(apt show tagainijisho 2>/dev/null | sed -En 's/^Version: //p')
    latest_tagainijisho_ver=$(curl --retry 10 -Lso /dev/null -w '%{url_effective}' https://github.com/Gnurou/tagainijisho/releases/latest | sed 's|.*/||')
    if [ "$current_tagainijisho_ver" != "$latest_tagainijisho_ver" ]; then
        cd /tmp || exit 1
        rm -f tagainijisho-"$latest_tagainijisho_ver".deb &>/dev/null
        wget https://github.com/Gnurou/tagainijisho/releases/download/"$latest_tagainijisho_ver"/tagainijisho-"$latest_tagainijisho_ver".deb &&
        sudo dpkg -i ./tagainijisho-"$latest_tagainijisho_ver".deb
    fi
    
    current_anki_ver=$(anki --version | sed -n '$s/.* //p')
    latest_anki_ver=$(curl --retry 10 -Lso /dev/null -w '%{url_effective}' https://github.com/ankitects/anki/releases/latest | sed 's|.*/||')
    if [ "$current_anki_ver" != "$latest_anki_ver" ]; then
        anki_dir=/tmp/anki-"$(uuidgen)"
        anki_archive=anki-"$latest_anki_ver"-linux-qt6.tar.zst
        mkdir -p -- "$anki_dir"
        cd -- "$anki_dir"
        wget https://github.com/ankitects/anki/releases/download/"$latest_anki_ver"/"$anki_archive" &&
        tar --use-compress-program=unzstd -xf "$anki_archive" &&
        cd anki-"$latest_anki_ver"-linux-qt6 && {
            sudo apt remove anki
            sudo /usr/local/share/anki/uninstall.sh
            sudo ./install.sh
        }
    fi
    
    echo
fi

[ -e ~/bin -a ! -L ~/bin ] && mv -vf -- ~/bin "$addon"/bin/tilde-bin
[ -e ~/.local/bin -a ! -L ~/.local/bin ] && mv -vf -- ~/.local/bin "$addon"/bin/tilde-local-bin
rm -f ~/bin ~/.local/bin 2>/dev/null
ln -s -- "$addon"/bin ~/.local/bin || exit
ln -s -- "$base"/bin ~/bin || exit
PATH=$HOME/.local/bin:$HOME/bin:$PATH

cat "$base"/xbindkeysrc.txt <(echo) "$addon"/xbindkeysrc.txt > ~/.xbindkeysrc 2>/dev/null
killall xbindkeys 2>/dev/null # It is assumed that xbindkeys is in the startup script

old_IFS=$IFS
IFS=$'\n'
rm -f -- $(find ~/Desktop -type l -name '*.sh')
IFS=$old_IFS
for i in $(cat "$base"/desktop-symlinks.txt) $(cat "$addon"/desktop-symlinks.txt 2>/dev/null); do
    w=$(which -- "$i") && ln -s -- "$w" ~/Desktop
done

killall autokey-qt 2>/dev/null # It is assumed that autokey-qt is in the startup script

copy-files() {
    [ -d "$1"/files ] || return
    
    echo Copying to system:
    cd -- "$1/files"
    find ! -type d
    echo
    
    [ -d "$1"/files/home ] && rsync -rl "$1"/files/home/ ~/
    
    [ "$2" ] || { [ -d "$1"/files/slash ] && sudo rsync -rl "$1"/files/slash/ /; }
}
copy-files "$base" "$@"
copy-files "$addon" "$@"

linux-setup-addon.sh 2>/dev/null

cp -f /usr/share/doc/mpv/examples/lua/autoload.lua ~/.config/mpv/scripts/

if [ "$HOSTNAME" = agnr ]; then
    rm -rf ~/.config/autokey
    ln -s ../D/Shared-ST-agnr/linux-setup/files/home/.config/autokey ~/.config/autokey
fi

kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta ""
qdbus org.kde.KWin /KWin reconfigure

put_kde_keyboard_shortcut() {
    sed -i "/$3\(,\|\\t\)/d" ~/.config/kglobalshortcutsrc
    kwriteconfig5 --file kglobalshortcutsrc --group "$1" --key "$2" "$3",,
}

# See ~/.config/kglobalshortcutsrc
killall kglobalaccel5
put_kde_keyboard_shortcut kmix mic_mute Alt+Z
put_kde_keyboard_shortcut kmix mute Alt+X
put_kde_keyboard_shortcut plasmashell 'toggle do not disturb' Alt+C
put_kde_keyboard_shortcut mediacontrol playpausemedia Meta+Z
put_kde_keyboard_shortcut kmix decrease_volume Meta+A
put_kde_keyboard_shortcut kmix increase_volume Meta+S
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 4' Meta+Q
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 5' Meta+W
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 6' Meta+E
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 7' Meta+Shift+Q
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 8' Meta+Shift+W
put_kde_keyboard_shortcut plasmashell 'activate task manager entry 9' Meta+Shift+E
kglobalaccel5 & disown

#crontab -l > /tmp/linux-setup-crontab 2>/dev/null
#if ! grep mpv-backup.sh /tmp/linux-setup-crontab &>/dev/null; then
#    echo '* * * * * bash -lc mpv-backup.sh' >> /tmp/linux-setup-crontab
#    crontab /tmp/linux-setup-crontab
#fi

linux-setup-startup.sh &>/dev/null &

echo "Do not forget to run systemd daemon-reload, enable --now or any other action related to the added files"
