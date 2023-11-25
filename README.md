# linux-setup

Setup scripts that setups a Kubuntu installation. Installs apt packages, puts my scripts in the PATH, etc. The scripts can be relaunched to update programs, etc.

All of this procedure is independent from the Linux username.

The linux-setup directory can be anywhere. Launch linux-setup/bin/linux-setup.sh to setup (it doesn't need to be in PATH). Logout login is required the first time for Ubuntu to put the scripts in PATH.

The only addon feature as of right now is putting your personal scripts in ~/D/linux-setup-addon/bin/ so they are in PATH.

You can add bash scripts you want to start at login in ~/.config/linux-setup/autostart/. They must be scripts that start a program only if it not already started.

The scripts in setup-scripts can be run directly if you want, but having run linux-setup.sh beforehand is necessary. They must stay in the linux-setup folder because they need ../../resources/.

# To do manually

apt virtualbox: virtualbox-qt virtualbox-guest-additions-iso virtualbox-ext-pack
sudo usermod -a -G vboxusers <username> # For USB

apt virtualbox guest: imwheel virtualbox-guest-x11

snap: chromium intellij-idea-community drawio

use KWalletManager and set an empty Kwallet-password, thus preventing the need of entering a password to unlock a wallet. Simply do not enter a password on both fields in Change Password... This may however lead to unwanted (read/write) access to the user's wallet. Enabling Prompt when an application accesses a wallet under Access Control is highly recommended to prevent unwanted access to the wallet.
