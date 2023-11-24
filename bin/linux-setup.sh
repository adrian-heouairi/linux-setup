#!/bin/bash

# These two must not begin with '-'
base=$(realpath -- "$0" | sed -E 's|/bin/[^/]+$||')
addon=~/D/linux-setup-addon
mkdir -p -- "$addon"/bin

#trap exit SIGINT

if ! [ -e "$addon"/bin/linux-setup-startup-addon.sh ]; then
    echo $'#!/bin/bash\n\n# You must launch a program only if it is not already running\n\nsleep infinity' >> "$addon"/bin/linux-setup-startup-addon.sh
    chmod +x -- "$addon"/bin/linux-setup-startup-addon.sh
fi

# Set ~/bin and ~/.local/bin
[ -e ~/bin -a ! -L ~/bin ] && mv -vf -- ~/bin "$addon"/bin/previous-tilde-bin
[ -e ~/.local/bin -a ! -L ~/.local/bin ] && mv -vf -- ~/.local/bin "$addon"/bin/previous-tilde-local-bin
rm -f ~/bin ~/.local/bin 2>/dev/null # Remove if they are symbolic links
ln -s -- "$addon"/bin ~/.local/bin || exit
ln -s -- "$base"/bin ~/bin || exit

#mkdir -p ~/D/linux-setup-programs

IFS=$'\n'
for i in $(find "$base"/setup-scripts/ -type f | sort -V); do
    echo "Running setup script $(realpath -- "$i"):"
    bash -- "$i"
done

# if [ "$HOSTNAME" = agnr ]; then
#     rm -rf ~/.config/autokey
#     ln -s ../D/Shared-ST-agnr/linux-setup/files/home/.config/autokey ~/.config/autokey
# fi

export "PATH=$HOME/.local/bin:$HOME/bin:$PATH"
linux-setup-startup.sh &>/dev/null & disown
