#!/usr/bin/env bash

###
# Run a Pump It Up game on an actual dedicated hardware setup/cabinet
#
# This script is expected to be called from the cabinet-startx.sh script which is started within an X session.
###

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" != "2" ]; then
    echo "Usage: $0 <game res> <audio freq>"
    echo "  game res: Either 480 or 720 for SD or HD resolution games."
    echo "  audio freq: Either 44 for 44100 hz or 48 for 48000 hz audio playback frequency."
    exit 1
fi

game_res="$1"
audio_freq="$2"

# Apply some settings to the current xsession
case $game_res in
    "480")
        xrandr -s 640x480 -r 60
        ;;

    "720")
        xrandr -s 1280x720 -r 60
        ;;

    *)
        echo "Game resolution argument must be either 480 or 720."
        exit 1
        ;;
esac

# A rather hacky way to switch between 44.1 khz and 48 khz on alsa.
# Set the correct configuration parameters if running multiple games on the
# same setup (different refresh rates on some newer games)
case $audio_freq in
# For 1st to Exceed, Pro 1 and Pro 2
    "44")
        sed -i 's/rate \$RATE/rate 44100/g' /usr/share/alsa/pcm/dmix.conf
        sed -i 's/format \$FORMAT/format S16_LE/g' /usr/share/alsa/pcm/dmix.conf

        sed -i 's/rate 48000/rate 44100/g' /usr/share/alsa/pcm/dmix.conf
        sed -i 's/format S16_LE/format S16_LE/g' /usr/share/alsa/pcm/dmix.conf
        ;;
# For Exceed 2 to Prime
    "48")
        sed -i 's/rate \$RATE/rate 48000/g' /usr/share/alsa/pcm/dmix.conf
        sed -i 's/format \$FORMAT/format S16_LE/g' /usr/share/alsa/pcm/dmix.conf

        sed -i 's/rate 44100/rate 48000/g' /usr/share/alsa/pcm/dmix.conf
        sed -i 's/format S16_LE/format S16_LE/g' /usr/share/alsa/pcm/dmix.conf
        ;;

    *)
        echo "Audio frequency argument must be either 44 or 48."
        exit 1
        ;;
esac

# Set proper volume level (necessary for FX cabinet equalizers to look nice)
amixer -q set Master 96% unmute

# Execute the game
if [ ! -e "$root_path/piueb" ]; then
    echo "Cannot start game, cannot find piueb script."
    exit 1
fi

"$root_path/piueb" run
