#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path is path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="deploy-pumptools"

declare -A GAME_VER_PT_HOOK_MAP

# Mappings from game version/folder names to pumptool's hook naming for hook deployment
GAME_VER_PT_HOOK_MAP=(
    ["01_1st"]="mk3hook"
    ["02_2nd"]="mk3hook"
    ["03_obg"]="mk3hook"
    ["04_3se"]="mk3hook"
    ["05_tc"]="mk3hook"
    ["06_pc"]="mk3hook"
    ["07_extra"]="mk3hook"
    ["08_prem1"]="mk3hook"
    ["09_prex1"]="mk3hook"
    ["10_reb"]="mk3hook"
    ["11_prem2"]="mk3hook"
    ["12_prex2"]="mk3hook"
    ["13_prem3"]="mk3hook"
    ["14_prex3"]="mk3hook"
    ["15_exc"]="exchook"
    ["16_exc2"]="x2hook"
    ["17_zero"]="zerohook"
    ["18_nx"]="nxhook"
    ["20_nx2"]="nx2hook")

deploy_pumptools_game()
{
	local target_pumpos_piu_dir="$1"
	local pumptools_unpack_path="$2"
    local game_ver="$3"

    local hook_name="${GAME_VER_PT_HOOK_MAP[$game_ver]}"

    log_debug "  Deploying pumptools for $game_ver, target dir $target_pumpos_piu_dir..."

    if [ ! "${GAME_VER_PT_HOOK_MAP[$game_ver]}" ]; then
        log_warn "No game version to hook mapping for $game_ver available, skipping"
        return
    fi

    local hook_path="$pumptools_unpack_path/$hook_name"
    local piuio_path="$pumptools_unpack_path/piuio"
    local piubtn_path="$pumptools_unpack_path/piubtn"

    local hook_file="$hook_path/$hook_name.so"

    verify_file_exists "$hook_path"
    verify_file_exists "$hook_file"

    cp "$hook_file" "$target_pumpos_piu_dir/hook.so"
    cp "$hook_path/$hook_name.conf" "$target_pumpos_piu_dir/hook.conf"
    cp "$hook_path/piueb" "$target_pumpos_piu_dir"
    cp "$piuio_path/ptapi-io-piuio-joystick.so" "$target_pumpos_piu_dir"
    cp "$piuio_path/ptapi-io-piuio-joystick-conf" "$target_pumpos_piu_dir"
    cp "$piuio_path/ptapi-io-piuio-keyboard.so" "$target_pumpos_piu_dir"
    cp "$piuio_path/ptapi-io-piuio-keyboard-conf" "$target_pumpos_piu_dir"
    cp "$piuio_path/ptapi-io-piuio-real.so" "$target_pumpos_piu_dir"
}

deploy_pumptool_unpack()
{
    local target_pumpos_piu_dir="$1"
	local pumptools_zip_path="$2"

    # Create temporary folder and unzip
	local temp="$target_pumpos_piu_dir/tmp/pt-depl"

    if [ -e "$temp" ]; then
        log_debug "Delete existing tmp dir $temp"
        rm -rf "$temp"
    fi

	mkdir "$temp"

	local pumptools_zip
	pumptools_zip="$(basename "$pumptools_zip_path")"

	log_info "Unpacking pumptools..."

	cp "$pumptools_zip_path" "$temp"
	local pumptools_dir="$temp/pumptools"
	mkdir "$pumptools_dir"
	unzip "$temp/$pumptools_zip" -d "$pumptools_dir" > /dev/null

	# Unpack all sub-zip files
	for f in "$pumptools_dir"/*.zip; do
		log_debug "  Unpacking $f..."
		local tmp="${f%.*}"
		mkdir "$tmp"
		unzip "$f" -d "$tmp" > /dev/null
	done
}

deploy_pumptools()
{
	local target_pumpos_piu_dir="$1"
	local pumptools_zip_path="$2"
    local limit_to_version="$3"

    verify_file_exists "$target_pumpos_piu_dir"
    verify_file_exists "$pumptools_zip_path"

    deploy_pumptool_unpack "$target_pumpos_piu_dir" "$pumptools_zip_path"

    local pumptools_unpack_path="$target_pumpos_piu_dir/tmp/pt-depl/pumptools"
    local pumptools_version
    pumptools_version="$(cat "$pumptools_unpack_path/git-version")"

    log_info "Deploying pumptools version $pumptools_version"
    changelog_append "$target_pumpos_piu_dir/log" "deploy-pumptools" "unpacked $pumptools_version"

    if [ ! "$limit_to_version" ]; then
        log_info "Deployment pumptools ALL games..."

        changelog_append "$target_pumpos_piu_dir/log" "deploy-pumptools" "start all"

        for game_path in "$target_pumpos_piu_dir"/data/*; do
            game_ver="$(basename "$game_path")"

            deploy_pumptools_game "$target_pumpos_piu_dir/data/$game_ver" "$pumptools_unpack_path" "$game_ver"
        done
    else
        log_info "Deployment pumptools SELECTED game $limit_to_version..."

        changelog_append "$target_pumpos_piu_dir/log" "deploy-pumptools" "start version $limit_to_version"

        deploy_pumptools_game "$target_pumpos_piu_dir/data/$limit_to_version" "$pumptools_unpack_path" "$limit_to_version"
    fi

    changelog_append "$target_pumpos_piu_dir/log" "deploy-pumptools" "deployed $pumptools_version"

    log_info "Done"
}

####################
# Main entry point #
####################

if [ "$#" -lt 2 ]; then
    echo "Pump It Up OS Deploy pumptools"
    echo "Deploy/update pumptools of a prepared base directory."
    echo "Usage: deploy-pumptools <path to /piu folder of mounted pumpos drive> <path pumptools.zip> [limit to version]"
    exit 1
fi

set -e

target_pumpos_piu_dir="$1"
pumptools_zip_path="$2"
limit_to_version="$3"

deploy_pumptools "$target_pumpos_piu_dir" "$pumptools_zip_path" "$limit_to_version"
