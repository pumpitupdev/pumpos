#!/usr/bin/env bash

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly ROOT_PATH_PROJECT="$ROOT_PATH/../.."
readonly DIST_DIR="$ROOT_PATH_PROJECT/dist"
readonly PUMPOS_SCRIPT="$ROOT_PATH_PROJECT/pumpos.sh"

if [ $# -lt 1 ]; then
    echo "Pipeline to deploy PIU games to a pumpos target"
    echo "Usage: $0 <cfg file>"
    exit 1
fi

cfg_file="$1"

if [ ! -e "$cfg_file" ]; then
    echo "ERROR: Could not find cfg file $cfg_file"
    exit 1
fi

source "$cfg_file"

set -e

"$PUMPOS_SCRIPT" deploy-dir "base" "$PUMPOS_ROOT" "$DIST_DIR/base/pumpos"
"$PUMPOS_SCRIPT" deploy-dir "piu-base" "$PUMPOS_ROOT" "$DIST_DIR/piu/base/pumpos"
"$PUMPOS_SCRIPT" deploy-piu-data "$PUMPOS_ROOT" "$PIU_DIST_DATA_DIR" "$PIU_DATA_LIB_TYPE"
"$PUMPOS_SCRIPT" deploy-piu-pumptools "$PUMPOS_ROOT" "$PUMPTOOLS_ZIP_PATH"
"$PUMPOS_SCRIPT" deploy-sgl "$PUMPOS_ROOT" "$SGL_ZIP_PATH" "$SGL_ASSET_PATH"
"$PUMPOS_SCRIPT" deploy-dir "piu-sgl" "$PUMPOS_ROOT" "$DIST_DIR/piu/sgl/pumpos"