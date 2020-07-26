#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly LOG_MODULE="deploy-zip"

deploy_dir()
{
    local log_tag="$1"
    local target_pumpos_dir="$2"
    local dir_on_pumpos="$3"
    local zip_path="$4"

    verify_file_exists "$target_pumpos_dir"
    verify_file_exists "$target_pumpos_dir/$dir_on_pumpos"

    if [ ! -e "$target_pumpos_dir/boot.sh" ]; then
        log_error "Target pumpos folder $target_pumpos_dir does not contain boot.sh."
        exit 1
    fi

    log_info "Updating \"$target_pumpos_dir\", folder \"$dir_on_pumpos\" with \"$zip_path\"..."

    unzip -o "$zip_path" -d "$target_pumpos_dir/$dir_on_pumpos" > /dev/null

    changelog_append "$target_pumpos_dir/log" "deploy-zip" "update $log_tag"

    log_info "Done"
}

####################
# Main entry point #
####################

if [ $# -lt 3 ]; then
    echo "Deploy a zip file to a directory on pumpos"
    echo "Usage: deploy-zip <tag for log> <path to /pumpos folder of mounted pumpos drive> <relative path on pumpos to extract contents of zip to> <zip file>"
    exit 1
fi

log_tag="$1"
target_pumpos_dir="$2"
dir_on_pumpos="$3"
zip_path="$4"

deploy_dir "$log_tag" "$target_pumpos_dir" "$dir_on_pumpos" "$zip_path"