#!/usr/bin/env bash

# Root path is path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$ROOT_PATH/../00_bootstrap/run.sh" "$ROOT_PATH/run.cfg"
