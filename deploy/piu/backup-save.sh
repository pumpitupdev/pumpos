#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="backup-piu-save"

readonly BACKUP_PATH="$ROOT_PATH/../../backup/piu"

backup_save()
{
    local target_pumpos_dir="$1"

    local data_dir="$target_pumpos_dir/data"
    local backup_dir="$BACKUP_PATH/save"

    mkdir -p "$backup_dir"

    verify_file_exists "$target_pumpos_dir"
    verify_file_exists "$data_dir"

    log_debug "Backing up save folders of $data_dir to $backup_dir..."

    for game_path in "$data_dir"/*; do
        game_ver="$(basename "$game_path")"

        log_debug "    Backing up $game_ver..."

        cd "$game_path" || exit
        zip -r "$game_ver.zip" save/  > /dev/null
        mv "$game_ver.zip" "$backup_dir"
    done
}

####################
# Main entry point #
####################

if [ ! "$1" ]; then
    echo "Pump It Up OS Backup Save"
    echo "Backup all save directories on a target /pumpos deployment."
    echo "Usage: deploy-backup-piu-save <path to /pumpos folder of mounted pumpos drive>"
    exit 1
fi

target_pumpos_dir="$1"

backup_save "$target_pumpos_dir"