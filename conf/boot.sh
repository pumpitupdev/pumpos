#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path is path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="conf-boot"

####################
# Main entry point #
####################

boot_cfg_mode_dev()
{
    local target_pumpos_piu_dir="$1"

    echo "mode=dev" > "$target_pumpos_piu_dir/boot.cfg"
}

boot_cfg_mode_game()
{
    local target_pumpos_piu_dir="$1"
    local target_game="$2"

    if [ ! "$target_game" ]; then
        log_error "Specify a target game, e.g. 01_1st as an additional argument."
        exit 1
    fi

    {
        echo "mode=game"
        echo "game=$target_game"
    } > "$target_pumpos_piu_dir/boot.cfg"
}

boot_cfg_mode_sgl()
{
    local target_pumpos_piu_dir="$1"

    echo "mode=sgl" > "$target_pumpos_piu_dir/boot.cfg"
}

boot_cfg_mode()
{
    local target_pumpos_piu_dir="$1"
    local boot_mode="$2"
    local args="${*:3}"

    case "$boot_mode" in
        dev)
            boot_cfg_mode_dev "$target_pumpos_piu_dir"
            ;;
        game)
            boot_cfg_mode_game "$target_pumpos_piu_dir" "$args"
            ;;
        sgl)
            boot_cfg_mode_sgl "$target_pumpos_piu_dir"
            ;;
        *)
            log_error "Invalid mode specified."
            exit 1
    esac

    log_info "Configured boot mode \"$boot_mode\""
}

if [ "$#" -lt 2 ]; then
    echo "Pump It Up OS Configuration Boot"
    echo "Configure what to boot when pumpos starts."
    echo "Usage: conf-boot <path to /piu folder of mounted pumpos drive> <mode to boot> [...]"
    exit 1
fi

target_pumpos_piu_dir="$1"
boot_mode="$2"
args="${*:3}"

boot_cfg_mode "$target_pumpos_piu_dir" "$boot_mode" "$args"