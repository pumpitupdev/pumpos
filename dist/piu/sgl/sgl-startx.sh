#!/usr/bin/env bash

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
xorg_conf="$root_path/xorg-fx-480.conf"

"$root_path/sgl-trap.sh" "$xorg_conf"