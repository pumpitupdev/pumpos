#!/usr/bin/env bash

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export DDR_MAME_GAME="ddrexproc"
cd "$root_path/../ddr-mame" && ./cabinet-startx.sh