#!/usr/bin/env bash

###
# Run MAME on an actual dedicated hardware setup/cabinet
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

# Fix permissions to allow normal user access to snd devices
chmod -R a+rw /dev/snd

# Fix permissions for accessing PIUIO as normal user
printf '%s' '
SUBSYSTEM=="usb", ATTRS{idVendor}=="0547", MODE="0666"
SUBSYSTEM=="usb_device", ATTRS{idVendor}=="0547", MODE="0666"
' > "/etc/udev/rules.d/50-piuio.rules"

# Reload udev rules
udevadm control --reload-rules && udevadm trigger

if [ ! -e "$root_path/ddr-mame" ]; then
    echo "Cannot find required ddr-mame script. Make sure this is available and located next to this script."
    exit 1
fi

# Enables vsync on nvidia cards
export __GL_SYNC_TO_VBLANK=1

# Important: Run MAME as a normal user (uid 1000). Running as root doesn't work properly.
sudo -Eu $(id -un 1000) bash -c "$root_path/ddr-mame"