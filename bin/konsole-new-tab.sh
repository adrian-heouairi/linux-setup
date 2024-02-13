#!/bin/bash

konsole --new-tab --workdir "$(realpath -- "$1")" & disown
wmctrl -Fxa konsole.konsole || true
