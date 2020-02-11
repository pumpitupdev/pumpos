#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly DIST_ROOT_PATH="$ROOT_PATH/../dist"
readonly DIST_PIU_PATH="$DIST_ROOT_PATH/piu"
readonly DIST_SHARED_PATH="$DIST_ROOT_PATH/shared"
readonly LOG_MODULE="deploy-base"

base_deploy()
{
    local target_pumpos_piu_dir="$1"

    verify_file_exists "$target_pumpos_piu_dir"

    if [ ! -e "$target_pumpos_piu_dir/boot.sh" ]; then
        log_error "Target piu folder $target_pumpos_piu_dir of pumpos does not contain boot.sh."
        exit 1
    fi

    log_info "Updating base of $target_pumpos_piu_dir..."

    cp -r "$DIST_PIU_PATH"/* "$target_pumpos_piu_dir"

    # Also copy files that are shared with all games
    for i in "$target_pumpos_piu_dir"/data/*; do
        cp -r "$DIST_SHARED_PATH"/* "$i"
    done

    changelog_append "$target_pumpos_piu_dir/log" "deploy-base" "update"

    log_info "Done"
}

####################
# Main entry point #
####################

if [ ! "$1" ]; then
    echo "Pump It Up OS Deploy Base"
    echo "Deploys a base directory layout with scripts to run the games."
    echo "Usage: deploy-base <path to /piu folder of mounted pumpos drive>"
    exit 1
fi

target_pumpos_piu_dir="$1"

base_deploy "$target_pumpos_piu_dir"