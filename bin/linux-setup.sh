#!/bin/bash

# These two must not begin with '-'
base=$(realpath -- "$0" | sed -E 's|/bin/[^/]+$||')
addon=~/D/linux-setup-addon
mkdir -p -- "$addon"/bin
mkdir -p ~/.local/share/applications

trap exit SIGINT # The scripts launched by this script must also have this line for Ctrl+C to exit everything

# Set ~/bin and ~/.local/bin
#[ -e ~/bin -a ! -L ~/bin ] && mv -vf -- ~/bin "$addon"/bin/previous-tilde-bin
#[ -e ~/.local/bin -a ! -L ~/.local/bin ] && mv -vf -- ~/.local/bin "$addon"/bin/previous-tilde-local-bin
#rm -f ~/bin ~/.local/bin 2>/dev/null # Remove if they are symbolic links
#ln -s -- "$addon"/bin ~/.local/bin || exit
#ln -s -- "$base"/bin ~/bin || exit
#export "PATH=$HOME/.local/bin:$HOME/bin:$PATH"
export "PATH=$PATH:$base/bin:$addon/bin"

cp -f -- "$(linux-setup-get-resources-path.sh)"/dot-desktop-files-main-script/* ~/.local/share/applications/

mkdir -p ~/D/linux-setup-programs

# Setup autostart at login system
mkdir -p ~/.config/autostart ~/.config/linux-setup/autostart
cp -f -- "$(linux-setup-get-resources-path.sh)/dot-desktop-files/linux-setup-autostart.desktop" ~/.config/autostart/
echo 'pidof -x mpris.py || exec mpris.py' > ~/.config/linux-setup/autostart/mpris.py.sh

sudo apt update

IFS=$'\n'
for i in $(find "$base"/setup-scripts/always-recommended.d/ -type f | sort -V); do
    echo "Running setup script $(realpath -- "$i"):"
    bash -- "$i" || echo "FAILED: $i"
done

if [ "$1" ]; then
    for i in $(find "$base"/setup-scripts/always-optional.d/ -type f | sort -V); do
        echo "Running setup script $(realpath -- "$i"):"
        bash -- "$i" || echo "FAILED: $i"
    done
fi

grep .config/linux-setup-env ~/.profile &>/dev/null || echo -e '\nfor i in ~/.config/linux-setup-env/*; do . "$i"; done' >> ~/.profile

linux-setup-add-env-var.sh PATH "\$PATH:$base/bin:$addon/bin" path.sh

for i in ~/.config/linux-setup/autostart/*; do bash -- "$i" &>/dev/null & disown; done
