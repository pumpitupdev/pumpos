#!/usr/bin/env bash

###
# Bootstrap a Pump It Up game on an actual dedicated hardware setup/cabinet
#
# This scripts reads a "configuration" file which defines bash variables required by this script
# to allow tweaking some settings that are different on some games, e.g. xorg conf or resolution.
###

# Root path is path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <run.cfg>"
    exit 1
fi

run_cfg_path="$1"

source "$run_cfg_path"

xorg_conf_path="$ROOT_PATH/xorg.conf/$XORG_CONF"

"$ROOT_PATH/cabinet-startx.sh" "$GAME" "$xorg_conf_path" "$RESOLUTION_Y" "$AUDIO_FREQ_KHZ"