#!/usr/bin/env bash

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly ROOT_PATH_PROJECT="$ROOT_PATH/../.."
readonly DIST_DIR="$ROOT_PATH_PROJECT/dist"
readonly PUMPOS_SCRIPT="$ROOT_PATH_PROJECT/pumpos.sh"

if [ $# -lt 1 ]; then
    echo "Pipeline to deploy games for an ITG cabinet to a pumpos target"
    echo "Usage: pipeline-itg-deploy <cfg file>"
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
"$PUMPOS_SCRIPT" deploy-dir "itg-base" "$PUMPOS_ROOT" "$DIST_DIR/itg/base/pumpos"

"$PUMPOS_SCRIPT" deploy-zip "itg-openitg" "$PUMPOS_ROOT" "data/openitg" "$OPENITG_ZIP_PATH"
"$PUMPOS_SCRIPT" deploy-zip "itg-ddr-mame" "$PUMPOS_ROOT" "data/ddr-mame" "$DDR_MAME_ZIP_PATH"

"$PUMPOS_SCRIPT" deploy-itg-mame-ddrio "$PUMPOS_ROOT" "$DDR_MAME_DDRIO_ZIP_PATH"
"$PUMPOS_SCRIPT" deploy-itg-mame-roms "$PUMPOS_ROOT" "$DDR_MAME_ROMS_PATH"

"$PUMPOS_SCRIPT" deploy-dir "itg-data" "$PUMPOS_ROOT" "$ITG_DATA_PATH"

# "Configure" step applies different StepMania configuration files after OpenITG dist package is depoyed
"$PUMPOS_SCRIPT" deploy-dir "itg-openitg-conf" "$PUMPOS_ROOT" "$DIST_DIR/itg/openitg/pumpos"

"$PUMPOS_SCRIPT" deploy-sgl "$PUMPOS_ROOT" "$SGL_ZIP_PATH" "$SGL_ASSET_PATH"
"$PUMPOS_SCRIPT" deploy-dir "itg-sgl" "$PUMPOS_ROOT" "$DIST_DIR/itg/sgl/pumpos"