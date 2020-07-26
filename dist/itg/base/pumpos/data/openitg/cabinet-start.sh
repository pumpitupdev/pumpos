#!/usr/bin/env bash

###
# Run OpenITG on an actual dedicated hardware setup/cabinet
#
# This script is expected to be called from the cabinet-startx.sh script which is started within an X session.
###

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default if not specified
if [ ! "$DDR_MAME_RES_VERT" ]; then
    DDR_MAME_RES_VERT="480"
fi

case $DDR_MAME_RES_VERT in
    "480")
        ;&
    *)
        xrandr -s 640x480 -r 60
        ;;
esac

# Set proper volume level
amixer -q set Master 96% unmute

if [ ! -e "$root_path/openitg" ]; then
    echo "Cannot find openitg executable. Make sure this is available and located next to this script."
    exit 1
fi

# Enables vsync on nvidia cards
export __GL_SYNC_TO_VBLANK=1

"$root_path/openitg" "--type=Preferences-cabinet"