#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: os-qemu-boot <target disk, e.g. sdd>"
    exit 1
fi

target_disk="$1"

if [ ! "$(command -v qemu-system-x86_64)" ]; then
    echo "Error: qemu not found"
    exit 1
fi

if [ ! -e "/dev/$target_disk" ]; then
    echo "Target disk $target_disk does not exist"
    exit 1
fi

qemu-system-x86_64 \
-smp 2 \
-m 2048M \
-vga std \
-device virtio-net,netdev=vmnic -netdev user,id=vmnic \
-drive file="/dev/$target_disk"