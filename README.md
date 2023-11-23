# linux-setup

Setup script that setups a Kubuntu installation. Installs apt packages, puts my scripts in the PATH, etc.

All of this procedure is independent from the Linux username.

Launch linux-setup.sh to setup (it doesn't need to be in PATH). Logout login is required the first time for Ubuntu to put the scripts in PATH.

linux-setup-startup.sh is started at login and it starts linux-setup-startup-addon.sh. Put programs you want to start at login in ~/D/linux-setup-addon/bin/linux-setup-startup-addon.sh

The only addon feature is ~/D/linux-setup-addon/bin/linux-setup-startup-addon.sh.

# To do manually

apt virtualbox: virtualbox-qt virtualbox-guest-additions-iso virtualbox-ext-pack
sudo usermod -a -G vboxusers <username> # For USB

apt virtualbox guest: imwheel virtualbox-guest-x11

snap: chromium intellij-idea-community drawio

use KWalletManager and set an empty Kwallet-password, thus preventing the need of entering a password to unlock a wallet. Simply do not enter a password on both fields in Change Password... This may however lead to unwanted (read/write) access to the user's wallet. Enabling Prompt when an application accesses a wallet under Access Control is highly recommended to prevent unwanted access to the wallet.
