#!/usr/bin/env bash

###
# Run MAME on actual dedicated hardware setup/cabinet
#
# For convenience, this script runs a follow-up script in an xserver. Therefore, it assumes you are
# running this, as typically intended on a dedicated setup, in headless/non-gui mode.
#
# DDR_MAME_RES_VERT - Force a pre-defined resolution when running mame, e.g. DDR_MAME_RES_VERT=480
#                     for 640x480. A xorg.conf file must be available for the specified resolution,
#                     e.g. xorg-480.conf when setting this to 480 or leaving it empty (default).
###

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default if not specified
if [ ! "$DDR_MAME_RES_VERT" ]; then
    DDR_MAME_RES_VERT="480"
fi

xorg_conf="./xorg-${DDR_MAME_RES_VERT}.conf"

if [ ! -e "$xorg_conf" ]; then
    echo "Cannot find xorg.conf file $xorg_conf"
    exit 1
fi

if [ ! -e "$root_path/cabinet-start.sh" ]; then
    echo "Cannot find required cabinet-start.sh script. Make sure this is available and located next to this script."
    exit 1
fi

xinit "$root_path/cabinet-start.sh" -- /usr/bin/X -config "$xorg_conf"