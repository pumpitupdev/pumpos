#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="deploy-itg-mame-ddrio"

deploy_ddrio()
{
    local target_pumpos_dir="$1"
    local ddrio_zip_path="$2"

    verify_file_exists "$target_pumpos_dir"
    verify_file_exists "$ddrio_zip_path"

    if [ ! -e "$target_pumpos_dir/boot.sh" ]; then
        log_error "Target pumpos folder $target_pumpos_dir does not contain boot.sh."
        exit 1
    fi

    log_info "Updating ddrio of ddr-mame..."

    local tmp_ddrio_unzip_dir="$target_pumpos_dir/tmp/ddrio"

    mkdir -p "$tmp_ddrio_unzip_dir"

    unzip -o -d "$tmp_ddrio_unzip_dir" "$ddrio_zip_path" > /dev/null

    cp "$tmp_ddrio_unzip_dir/ddrio-piuio-itg.so" "$target_pumpos_dir/data/ddr-mame/ddrio.so"

    rm -r "$tmp_ddrio_unzip_dir"

    changelog_append "$target_pumpos_dir/log" "deploy-itg-mame-ddrio" "update"

    log_info "Done"
}

####################
# Main entry point #
####################

if [ "$#" -lt 2 ]; then
    echo "ddr-mame deploy ddrio for ITG"
    echo "Usage: deploy-itg-mame-ddrio <path to /pumpos folder of mounted pumpos drive> <path to ddrio.zip>"
    exit 1
fi

target_pumpos_dir="$1"
ddrio_zip_path="$2"

deploy_ddrio "$target_pumpos_dir" "$ddrio_zip_path"