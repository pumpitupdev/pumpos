#!/usr/bin/env bash

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
xorg_conf="$root_path/xorg-fx-480.conf"

xinit "$root_path/sgl.sh" -- /usr/bin/X -config "$xorg_conf"