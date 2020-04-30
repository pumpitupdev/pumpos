#!/usr/bin/env bash

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

xorg_conf="$root_path/xorg.conf/xorg-fx-480.conf"

"$root_path/cabinet-startx.sh" "$xorg_conf" 480 44