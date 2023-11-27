#!/bin/bash

source "${0%/*}"/../../resources/setup-scripts-base.sh

kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta ""
qdbus org.kde.KWin /KWin reconfigure
