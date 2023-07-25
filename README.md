# linux-setup

Setup script that setups a Kubuntu installation. Installs apt packages, puts my scripts in the path, etc.

All of this procedure is independent from the Linux username.

This folder may be anywhere but the addon is expected at ~/D/linux-setup-addon/, or it can be absent.

Launch linux-setup.sh to setup. It launches linux-setup-addon.sh if present to perform additional actions.

linux-setup-startup.sh is started at login and it starts linux-setup-startup-addon.sh if present.

apt virtualbox: virtualbox-qt virtualbox-guest-additions-iso virtualbox-ext-pack + sudo usermod -a -G vboxusers username?

apt virtualbox guest: imwheel virtualbox-guest-x11

snap: chromium code intellij-idea-community drawio discord zoom-client
