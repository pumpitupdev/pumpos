#!/usr/bin/env bash

###
# Run a Pump It Up game on an actual dedicated hardware setup/cabinet
#
# For convenience, this script runs a follow-up script in an xserver. Therefore, it assumes you are running
# this, as typically intended on a dedicated setup, in headless/non-gui mode.
###

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" != "4" ]; then
    echo "Usage: $0 <game> <xorg.conf> <game res> <audio freq>"
    echo "  game: The game to start, e.g. 01_1st"
    echo "  xorg.conf: Path to an xorg conf file to use."
    echo "  game res: Either 480 or 720 for SD or HD resolution games."
    echo "  audio freq: Either 44 for 44100 hz or 48 for 48000 hz audio playback frequency. 1st to Exceed, Pro 1 and Pro 2 need 44, all other games need 48."
    exit 1
fi

game="$1"
xorg_conf="$2"
game_res="$3"
audio_freq="$4"

if [ ! -e "$xorg_conf" ]; then
    echo "Cannot find xorg.conf file $xorg_conf"
    exit 1
fi

if [[ "$game_res" != "480" ]] && [[ "$game_res" != "720" ]]; then
    echo "Game resolution argument must be either 480 or 720."
    exit 1
fi

if [[ "$audio_freq" != "44" ]] && [[ "$audio_freq" != "48" ]]; then
    echo "Audio frequency argument must be either 44 or 48."
    exit 1
fi

if [ ! -e "$root_path/cabinet-start.sh" ]; then
    echo "Cannot find required cabinet-start.sh script. Make sure this is available and located next to this script."
    exit 1
fi

xinit "$root_path/cabinet-start.sh" "$game" "$game_res" "$audio_freq" -- /usr/bin/X -config "$xorg_conf"
