#!/bin/bash

kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta ""
#qdbus org.kde.KWin /KWin reconfigure # TODO Necessary but bothersome
