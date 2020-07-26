#!/usr/bin/env bash

###
# Run OpenITG on actual dedicated hardware setup/cabinet
#
# For convenience, this script runs a follow-up script in an xserver. Therefore, it assumes you are
# running this, as typically intended on a dedicated setup, in headless/non-gui mode.
###

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

xorg_conf="./xorg-480.conf"

if [ ! -e "$xorg_conf" ]; then
    echo "Cannot find xorg.conf file $xorg_conf"
    exit 1
fi

if [ ! -e "$root_path/cabinet-start.sh" ]; then
    echo "Cannot find required cabinet-start.sh script. Make sure this is available and located next to this script."
    exit 1
fi

xinit "$root_path/cabinet-start.sh" -- /usr/bin/X -config "$xorg_conf"