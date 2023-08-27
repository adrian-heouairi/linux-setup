#!/bin/bash

# These two must not begin with '-'
base=$(realpath -- "$0") base=$(sed -E 's|/bin/[^/]+$||' <<< "$base")
addon=~/D/linux-setup-addon

trap exit SIGINT

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
    echo
fi

rm -f ~/bin ~/.local/bin 2>/dev/null
ln -s -- "$addon"/bin ~/.local/bin || exit
ln -s -- "$base"/bin ~/bin || exit
PATH=$HOME/.local/bin:$HOME/bin:$PATH

cat "$base"/xbindkeysrc.txt <(echo) "$addon"/xbindkeysrc.txt > ~/.xbindkeysrc 2>/dev/null
killall xbindkeys 2>/dev/null # It is assumed that xbindkeys is in the startup script

# TODO KDE disable Windows key

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
    cd "$1/files"
    find ! -type d
    echo
    
    [ -d "$1"/files/home ] && rsync -rl "$1"/files/home/ ~/
    
    if ! [ "$1" ]; then
        [ -d "$1"/files/slash ] && sudo rsync -rl "$1"/files/slash/ /
    fi
}
copy-files "$base"
copy-files "$addon"

linux-setup-addon.sh 2>/dev/null

cp -f /usr/share/doc/mpv/examples/lua/autoload.lua ~/.config/mpv/scripts/

if [ "$HOSTNAME" = agnr ]; then
    rm -rf ~/.config/autokey
    ln -s ../D/Shared-ST-agnr/linux-setup/files/home/.config/autokey ~/.config/autokey
fi

#crontab -l > /tmp/linux-setup-crontab 2>/dev/null
#if ! grep mpv-backup.sh /tmp/linux-setup-crontab &>/dev/null; then
#    echo '* * * * * bash -lc mpv-backup.sh' >> /tmp/linux-setup-crontab
#    crontab /tmp/linux-setup-crontab
#fi

linux-setup-startup.sh &>/dev/null &

echo "Do not forget to run systemd daemon-reload, enable --now or any other action related to the added files"
