#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly LOG_MODULE="deploy-dir"

deploy_dir()
{
    local log_tag="$1"
    local target_pumpos_dir="$2"
    local dist_dir="$3"

    verify_file_exists "$target_pumpos_dir"
    verify_file_exists "$dist_dir"

    if [ ! -e "$target_pumpos_dir/boot.sh" ]; then
        log_error "Target pumpos folder $target_pumpos_dir does not contain boot.sh."
        exit 1
    fi

    log_info "Updating \"$target_pumpos_dir\" with \"$dist_dir\"..."

    cp -r "$dist_dir"/* "$target_pumpos_dir/"

    changelog_append "$target_pumpos_dir/log" "deploy-dir" "update $log_tag"

    log_info "Done"
}

####################
# Main entry point #
####################

if [ $# -lt 3 ]; then
    echo "Deploy a directory to pumpos"
    echo "Deploys a directory matching the directory layout on the target pumpos folder"
    echo "Usage: deploy-dir <tag for log> <path to /pumpos folder of mounted pumpos drive> <path to folder with dist files>"
    exit 1
fi

log_tag="$1"
target_pumpos_dir="$2"
dist_dir="$3"

deploy_dir "$log_tag" "$target_pumpos_dir" "$dist_dir"