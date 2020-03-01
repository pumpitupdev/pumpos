#!/usr/bin/env bash

# Root path is path of this script
root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$root_path/cabinet-startx.sh" ./xorg.conf/xorg-fx-480.conf 480 48