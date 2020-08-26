#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="deploy-piu-data"

data_deploy_game()
{
	local target_pumpos_dir="$1"
	local piu_data_dir="$2"
    local lib_type="$3"
    local game_ver="$4"

    local source_ver_dir="$piu_data_dir/$game_ver"
    local target_ver_dir="$target_pumpos_dir/data/$game_ver"

    log_info "  $game_ver, target $target_ver_dir, source $source_ver_dir..."

    local game_zip="$source_ver_dir/game.zip"
    local lib_zip="$source_ver_dir/lib-$lib_type.zip"
    local piu_exec="$source_ver_dir/piu"
    local version_file="$source_ver_dir/version"

    log_debug "    Data checks..."
    verify_file_exists "$game_zip"
    verify_file_exists "$lib_zip"
    verify_file_exists "$piu_exec"
    verify_file_exists "$version_file"

    local source_data_ver
    source_data_ver="$(cat "$version_file")"

    log_debug "    Source data version $source_data_ver"

    if [ -e "$target_ver_dir/piu"  ]; then
        log_debug "    Detected existing data, clear first..."
        rm -rf "$target_ver_dir/game"
        rm -rf "${target_ver_dir:?}/lib"
        rm -f "$target_ver_dir/piu"
        rm -f "$target_ver_dir/version"

        changelog_append "$target_pumpos_dir/log" "deploy-data" "clean $game_ver"
    fi

    log_debug "    game.zip..."
    unzip "$game_zip" -d "$target_ver_dir" > /dev/null

    log_debug "    lib-$lib_type.zip..."
    unzip "$lib_zip" -d "$target_ver_dir" > /dev/null

    log_debug "    piu..."
    cp "$piu_exec" "$target_ver_dir"

    log_debug "    version..."
    cp "$version_file" "$target_ver_dir"

    changelog_append "$target_pumpos_dir/log" "deploy-data" "deployed $game_ver, version $source_data_ver"
}

data_deploy()
{
    local target_pumpos_dir="$1"
    local piu_data_dir="$2"
    local lib_type="$3"
    local limit_game_version="$4"

    verify_file_exists "$target_pumpos_dir"
    verify_file_exists "$piu_data_dir"

    case "$lib_type" in
        "local")
            ;&
        "ld")
            ;;
        *)
            log_error_and_exit "Invalid lib_type parameter $lib_type provided"
    esac

    verify_file_exists "$target_pumpos_dir/data"

    if [ "$limit_game_version" ]; then
        log_debug "Verifying game version $limit_game_version..."

        verify_file_exists "$piu_data_dir/$limit_game_version"
        verify_file_exists "$target_pumpos_dir/data/$limit_game_version"
    fi

    if [ ! "$limit_game_version" ]; then
        log_info "Deployment ALL games, source data dir $piu_data_dir, target piu dir $target_pumpos_dir..."

        changelog_append "$target_pumpos_dir/log" "deploy-data" "start all"

        for game_path in "$target_pumpos_dir"/data/*; do
            game_ver="$(basename "$game_path")"

            # Not a game
            if [ "$game_ver" = "00_bootstrap" ]; then
                continue
            fi

            data_deploy_game "$target_pumpos_dir" "$piu_data_dir" "$lib_type" "$game_ver"
        done
    else
        log_info "Deployment of SELECTED game $limit_game_version, source data dir $piu_data_dir, target piu dir $target_pumpos_dir..."

        changelog_append "$target_pumpos_dir/log" "deploy-data" "start version $limit_game_version"

        data_deploy_game "$target_pumpos_dir" "$piu_data_dir" "$lib_type" "$limit_game_version"
    fi

    log_info "Done."
}

####################
# Main entry point #
####################

if [ "$#" -lt 3 ]; then
    echo "Pump It Up OS Deploy Game Data"
    echo "Deploy game data to a prepared base directory."
    echo "Usage: deploy-piu-data <path to /pumpos folder of mounted pumpos drive> <data dir> <lib type: ld, local> [single deployment, e.g. 01_1st]"
    exit 1
fi

target_pumpos_dir="$1"
data_dir="$2"
lib_type="$3"
single_deployment="$4"

data_deploy "$target_pumpos_dir" "$data_dir" "$lib_type" "$single_deployment"
