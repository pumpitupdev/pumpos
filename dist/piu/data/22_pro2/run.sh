#!/usr/bin/env bash

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$root_path" || exit 1
"$root_path/cabinet-startx.sh" ./xorg.conf/xorg-fx-720-pro2.conf 720 44