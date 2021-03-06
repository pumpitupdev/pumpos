#!/bin/bash

# Includes
source "util/util.sh"

# Root path is path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="deploy-sgl"

readonly DIST_ROOT_PATH="$ROOT_PATH/../../dist"

deploy_sgl()
{
    local target_pumpos_piu_dir="$1"
    local sgl_zip_path="$2"
    local sgldata_data_asset_dir="$3"

    local target_pumpos_piu_sgl_dir="$target_pumpos_piu_dir/sgl"

    verify_file_exists "$sgl_zip_path"
    verify_file_exists "$sgldata_data_asset_dir"
    verify_file_exists "$target_pumpos_piu_dir"
    verify_file_exists "$target_pumpos_piu_sgl_dir"

	log_info "Deploying sgl"

    log_debug "  Updating sgl binary distribution files..."

    cp "$sgl_zip_path" "$target_pumpos_piu_sgl_dir"
    unzip -o "$target_pumpos_piu_sgl_dir/$(basename "$sgl_zip_path")" -d "$target_pumpos_piu_sgl_dir" > /dev/null
    rm "$target_pumpos_piu_sgl_dir/$(basename "$sgl_zip_path")"

    # Fix permissions
    chmod +x "$target_pumpos_piu_sgl_dir/sgl.sh"
    chmod +x "$target_pumpos_piu_sgl_dir/sgl-trap.sh"
    chmod +x "$target_pumpos_piu_sgl_dir/sgl-startx.sh"

    log_debug "  Updating sgl assets..."

    cp -r "$sgldata_data_asset_dir"/* "$target_pumpos_piu_sgl_dir/data"

    changelog_append "$target_pumpos_piu_dir/log" "sgl" "update"

    log_info "Done"
}

####################
# Main entry point #
####################

if [ "$#" -lt 3 ]; then
    echo "Deploy/update sgl (Simple Game Loader)"
    echo "Usage: sgl <path to /piu folder of mounted pumpos drive> <path sgl.zip distribution file> <path sgl assets data dir>"
    exit 1
fi

target_pumpos_piu_dir="$1"
sgl_zip_path="$2"
sgldata_data_asset_dir="$3"

deploy_sgl "$target_pumpos_piu_dir" "$sgl_zip_path" "$sgldata_data_asset_dir"