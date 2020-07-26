#!/usr/bin/env bash

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly ROOT_PATH_PROJECT="$ROOT_PATH/../.."
readonly PUMPOS_SCRIPT="$ROOT_PATH_PROJECT/pumpos.sh"

if [ $# -lt 1 ]; then
    echo "Pipeline to configure games for an ITG cabinet to a pumpos target"
    echo "Usage: pipeline-itg-conf <cfg file>"
    exit 1
fi

cfg_file="$1"

if [ ! -e "$cfg_file" ]; then
    echo "ERROR: Could not find cfg file $cfg_file"
    exit 1
fi

source "$cfg_file"

set -e

"$PUMPOS_SCRIPT" conf-boot "$PUMPOS_ROOT" "sgl"