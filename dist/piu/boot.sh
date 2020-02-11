#!/usr/bin/env bash

###
# Pumpos Boot(strap) script to run a game after the OS has booted.
#
# This should be called from an init/service script by something like systemd
# at the end of the boot cycle.
#
# A configuration file named "boot.cfg" defines what to do when this script is
# called:
# 1. Development mode: The system drops into a shell on boot. Can come in handy
#    for direct interaction with the system using a keyboard if remote SSH
#    access it not available.
#    The "boot.cfg" file must contain the line "mode=dev" (without quotes).
# 2. Run game mode: Every time the system boots, the specified game is
#    run automatically.
#    The "boot.cfg" file must contain the line "mode=game" (without quotes) and
#    the line "game=01_1st" (without quotes and replace 01_1st with any other
#    game folder name existing in the "data" folder).
# 3. Game loader (SGL): A separate program to provide an interface to select a
#    game from a list of available ones.
#    The "boot.cfg" file must contain the line "mode=sgl" (without quotes).
###

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly DATA_DIR="$ROOT_PATH/data"
readonly SGL_DIR="$ROOT_PATH/sgl"
readonly BOOT_SCRIPT_PATH="$ROOT_PATH/boot.sh"
readonly SGL_SCRIPT_PATH="$SGL_DIR/sgl.sh"
readonly BOOT_CFG_FILE_PATH="$ROOT_PATH/boot.cfg"

boot_cfg_mode=""
boot_cfg_mode_game_selected=""

verify_environment()
{
    if [ ! -d "$DATA_DIR" ]; then
	    echo "Error: Missing game data directory"
	    exit 1
    fi

    if [ -e "$BOOT_CFG_FILE_PATH" ]; then
        echo "Error: Cannot find boot.cfg file."
        exit 1
    fi
}

boot_cfg_read()
{
    while IFS= read -r line; do
        # Skip empty lines
        if [ "$line" = "" ]; then
            continue
        fi

        # Skip comments
        if [[ $line == \#* ]]; then
            continue
        fi

        local key
        key="$(echo "$line" | cut -d '=' -f 1)"
        local value
        value="$(echo "$line" | cut -d '=' -f 2)"

        case "$key" in
            mode)
                boot_cfg_mode="$value"
                ;;
            game)
                boot_cfg_mode_game_selected="$value"
                ;;
            *)
                ;;
        esac
    done < "$BOOT_CFG_FILE_PATH"
}

verify_boot_cfg_values()
{
    if [ ! "$boot_cfg_mode" ]; then
        echo "Error: boot.cfg does not specify mode."
        exit 1
    fi

    if [ ! "$boot_cfg_mode" == "game" ] && [ ! "$boot_cfg_mode_game_selected" ]; then
        echo "Error: boot.cfg in mode game does not specify game to boot."
        exit 1
    fi
}

boot_mode_dev()
{
	echo "===== DEVELOPMENT MODE ====="
	echo "Dropping to shell"
	bash
	exit 0
}

boot_mode_sgl()
{
    echo "===== Starting game loader ====="
    "$SGL_SCRIPT_PATH"
}

boot_mode_game()
{
    if [ ! -d "$DATA_DIR/$boot_cfg_mode_game_selected" ]; then
        echo "Error: Cannot boot game \"$boot_cfg_mode_game_selected\": game does not exist."
        exit 1
    else
        if [ ! -e "$DATA_DIR/$boot_cfg_mode_game_selected/run.sh" ]; then
            echo "Error: Cannot boot game \"$boot_cfg_mode_game_selected\": missing entry point script."
            exit 1
        else
            # Finally boot the game defined by gameboot bootstrap file
            "$DATA_DIR/$boot_cfg_mode_game_selected/run.sh"

            # Replace the current session with a new one to avoid recrusive
            # calls and restarting the game
            exec "$BOOT_SCRIPT_PATH"
        fi
    fi
}

####################
# Main entry point #
####################

echo "===== Pumpos Boot ====="
echo "Root directory: $ROOT_PATH"

verify_environment
boot_cfg_read
verify_boot_cfg_values

case "$boot_cfg_mode" in
    dev)
        boot_mode_dev
        ;;
    sgl)
        boot_mode_sgl
        ;;
    game)
        boot_mode_game
        ;;
    *)
        echo "Error: Invalid boot mode \"$boot_cfg_mode\" specified."
        ;;
esac