# linux-setup

Setup scripts that setup a Kubuntu installation. Installs apt packages, puts my scripts in the PATH, etc. The scripts can be relaunched to update programs, etc.

I might have reinvented the wheel. I don't know.

All of this procedure is independent from the Linux username.

The linux-setup directory can be anywhere. Launch linux-setup/bin/linux-setup.sh to setup (it doesn't need to be in PATH). Logout login or even reboot is required the first time for Ubuntu to put the scripts in PATH.

The only addon features as of right now:
- You can add bash scripts you want to start at login in `~/.config/linux-setup/autostart/`. They must be scripts that start a program only if it is not already started.
- You can put `export KEY=value` environment variable in `~/.config/linux-setup-env/*`.

The scripts in setup-scripts can be run directly if you want, but having run linux-setup.sh and having the scripts in PATH is required. They must stay in the linux-setup folder because they need `../../resources/`.

# To do manually

apt virtualbox guest: virtualbox-guest-x11 # imwheel

snap: chromium drawio

snap --classic: intellij-idea-community pycharm-community

`use KWalletManager and set an empty Kwallet-password, thus preventing the need of entering a password to unlock a wallet. Simply do not enter a password on both fields in Change Password... This may however lead to unwanted (read/write) access to the user's wallet. Enabling Prompt when an application accesses a wallet under Access Control is highly recommended to prevent unwanted access to the wallet.`

# KDE bug in Kubuntu 22.04

After modifying a .desktop file in `~/.local/share/applications`, you have to rename it for changes to take effect.

# Setup script guidelines

Setup scripts can print errors, but they should silence programs that print useless information.
