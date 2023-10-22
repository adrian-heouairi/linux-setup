# linux-setup

Setup script that setups a Kubuntu installation. Installs apt packages, puts my scripts in the path, etc.

All of this procedure is independent from the Linux username.

This folder may be anywhere but the addon is expected at ~/D/linux-setup-addon/, or it can be absent.

Launch linux-setup.sh to setup. It launches linux-setup-addon.sh if present to perform additional actions.

linux-setup-startup.sh is started at login and it starts linux-setup-startup-addon.sh if present.

apt virtualbox: virtualbox-qt virtualbox-guest-additions-iso virtualbox-ext-pack + sudo usermod -a -G vboxusers username?

apt virtualbox guest: imwheel virtualbox-guest-x11

snap: chromium code intellij-idea-community drawio discord zoom-client

use KWalletManager and set an empty Kwallet-password, thus preventing the need of entering a password to unlock a wallet. Simply do not enter a password on both fields in Change Password... This may however lead to unwanted (read/write) access to the user's wallet. Enabling Prompt when an application accesses a wallet under Access Control is highly recommended to prevent unwanted access to the wallet.
