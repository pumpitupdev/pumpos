#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="backup-piu-save"

readonly BACKUP_PATH="$ROOT_PATH/../../backup/piu"

deploy_save()
{
    local target_pumpos_dir="$1"

    local data_dir="$target_pumpos_dir/data"
    local backup_dir="$BACKUP_PATH/save"

    verify_file_exists "$target_pumpos_dir"
    verify_file_exists "$data_dir"
    verify_file_exists "$backup_dir"

    log_debug "Deploying backed up saves to $data_dir..."

    for save_zip_path in "$backup_dir"/*; do
        save_zip="$(basename "$save_zip_path")"
        game_ver="${save_zip%.*}"

        log_debug "    Deploying backed up save of $game_ver..."

        local game_dir="$data_dir/$game_ver"

        if [ -e "$game_dir" ]; then
            rm -rf "$game_dir/save"
            unzip -d "$game_dir" "$save_zip_path" > /dev/null
        else
            log_warn "    Directory $game_dir does not exist, skipping..."
        fi
    done
}

####################
# Main entry point #
####################

if [ ! "$1" ]; then
    echo "Pump It Up OS Backup Save"
    echo "Deploy all backed up save directories to a target /piu deployment."
    echo "Usage: deploy-piu-save <path to /pumpos folder of mounted pumpos drive>"
    exit 1
fi

target_pumpos_dir="$1"

deploy_save "$target_pumpos_dir"