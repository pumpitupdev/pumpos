#!/usr/bin/env bash

readonly LOG_LEVEL_ERROR="E"
readonly LOG_LEVEL_WARN="W"
readonly LOG_LEVEL_INFO="I"
readonly LOG_LEVEL_DEBUG="M"

log()
{
    local level="$1"
    local msg="$2"

    local timestamp="$(date "+%Y/%m/%d-%H:%M:%S:%3N")"

    local color=""

    case $level in
        $LOG_LEVEL_ERROR)
            color="\e[1m\e[31m"
            ;;
        $LOG_LEVEL_WARN)
            color="\e[33m"
            ;;
        $LOG_LEVEL_INFO)
            color="\e[34m"
            ;;
        $LOG_LEVEL_DEBUG)
            color="\e[37m"
            ;;
    esac

    echo -e "${color}[$level]\e[0m[$timestamp][$LOG_MODULE] ${msg}"
}

log_error()
{
    log "$LOG_LEVEL_ERROR" "$@"
}

log_warn()
{
    log "$LOG_LEVEL_WARN" "$@"
}

log_info()
{
    log "$LOG_LEVEL_INFO" "$@"
}

log_debug()
{
    log "$LOG_LEVEL_DEBUG" "$@"
}

log_error_and_exit()
{
	  log "$LOG_LEVEL_ERROR" "$@"
	  exit 1
}

changelog_append()
{
	local path="$1"
	local type="$2"
	local comment="$3"

	local time=$(date +"%Y-%m-%d %H:%M:%S:%3N")

	echo "[$time] $comment" >> "$path/changelog-$type"
}

verify_file_exists()
{
    local file_path="$1"
    local warn_only="$2"

    # log_debug "Verify file/dir exists $file_path..."

    if [ ! -e "$file_path" ]; then
        if [ "$warn_only" ]; then
            log_warn "Missing file/folder \"$file_path\""
        else
            log_error_and_exit "Missing required file/folder \"$file_path\""
        fi
    fi
}