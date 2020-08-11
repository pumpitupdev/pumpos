#!/usr/bin/env bash

# Includes
source "util/util.sh"

# Root path is path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_MODULE="conf-pumptools"

deploy_pumptools_config_apply()
{
    local target_piu_game_hook_conf="$1"
    local config_key="$2"
    local config_value="$3"

    log_debug "    $config_key=$config_value"

	# Use alternative character ~ as delimitier instead of / to avoid issues with replacing paths
    sed -i -- "s~$config_key=.*~$config_key=$config_value~g" "$target_piu_game_hook_conf"
}

deploy_pumptools_conf_parse()
{
	local target_pumpos_piu_dir="$1"
	local config_file_path="$2"
	local limit_to_version="$3"

	log_info "Deploying pumptools config $config_file_path..."

	local line=""
	local number_of_lines
	number_of_lines=$(wc -l < "$config_file_path")
	local counter=0

	while [  $counter -le "$number_of_lines" ]; do
		local counter=$((counter + 1))
		local line
		line="$(sed "${counter}q;d" < "$config_file_path")"

		# Skip empty lines
		if [ "$line" = "" ]; then
			continue
		fi

		# Skip comments
		if [[ $line == \#* ]]; then
			continue
		fi

		# Game version (folder name)
		local game
		game="$(echo "$line" | cut -d ';' -f 1)"
        local target_piu_game_dir="$target_pumpos_piu_dir/data/$game"

        log_debug "  $game..."

        if [ "$limit_to_version" ] && [ "$limit_to_version" != "$game" ]; then
            log_warn "Limited to version \"$limit_to_version\", skipping \"$game\""
            continue
        fi

        if [ ! -e "$target_piu_game_dir" ]; then
            log_warn "Could not find game path $target_piu_game_dir for game $game, skipping"
            continue
        fi

        local game_hook_conf="$target_piu_game_dir/hook.conf"

        verify_file_exists "$game_hook_conf"

		# Get parameters
      	iter=2

      	while true ; do
        	local tmp
        	tmp=$(echo "$line" | cut -d ';' -f $iter)
        	local iter=$((iter + 1))

            local arg_key
            arg_key=$(echo "$tmp" | cut -d '=' -f 1)
            local arg_value
            arg_value=$(echo "$tmp" | cut -d '=' -f 2)

            if [ "$arg_key" = "" ] ; then
          		break
            fi

            deploy_pumptools_config_apply "$game_hook_conf" "$arg_key" "$arg_value"
      	done

        changelog_append "$target_pumpos_piu_dir/log" "conf-pumptools" "hook.conf changed $game"
	done
}

deploy_pumptools_conf()
{
    local target_pumpos_piu_dir="$1"
	local config_file_path="$2"
    local limit_to_version="$3"

    verify_file_exists "$target_pumpos_piu_dir"
    verify_file_exists "$config_file_path"

    deploy_pumptools_conf_parse "$target_pumpos_piu_dir" "$config_file_path" "$limit_to_version"

	log_info "Done"
}

####################
# Main entry point #
####################

if [ "$#" -lt 2 ]; then
    echo "Pump It Up OS Configuration pumptools"
    echo "Apply further (hook) settings to deployed games using pumptools."
    echo "Usage: conf-pumptools <path to /piu folder of mounted pumpos drive> <path to pumptools.conf file> [limit to version]"
    exit 1
fi

target_pumpos_piu_dir="$1"
pumptools_conf_path="$2"
limit_to_version="$3"

deploy_pumptools_conf "$target_pumpos_piu_dir" "$pumptools_conf_path" "$limit_to_version"