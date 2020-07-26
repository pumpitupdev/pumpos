#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="deploy-itg-mame-roms"

deploy_ddrio()
{
    local target_pumpos_dir="$1"
    local ddr_mame_roms_dir="$2"

    verify_file_exists "$target_pumpos_dir"
    verify_file_exists "$ddr_mame_roms_dir"

    if [ ! -e "$target_pumpos_dir/boot.sh" ]; then
        log_error "Target pumpos folder $target_pumpos_dir does not contain boot.sh."
        exit 1
    fi

    log_info "Updating roms of ddr-mame..."

    cp -r "$ddr_mame_roms_dir"/* "$target_pumpos_dir/data/ddr-mame/roms/"

    changelog_append "$target_pumpos_dir/log" "deploy-itg-mame-roms" "update"

    log_info "Done"
}

####################
# Main entry point #
####################

if [ "$#" -lt 2 ]; then
    echo "ddr-mame-roms deployment for ddr-mame"
    echo "Usage: deploy-itg-mame-roms <path to /pumpos folder of mounted pumpos drive> <path to ddrio.zip>"
    exit 1
fi

target_pumpos_dir="$1"
ddr_mame_roms_dir="$2"

deploy_ddrio "$target_pumpos_dir" "$ddr_mame_roms_dir"