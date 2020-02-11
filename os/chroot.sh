#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: os-chroot <mounted root dir> [script to execute inside chroot [args...]]"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "Script needs to be run as root."
    exit 1
fi

mounted_root_dir="$1"
script_to_execute="$2"
script_args="${*:3}"

if [ ! -e "$mounted_root_dir" ]; then
    echo "Mounted root dir $mounted_root_dir does not exist"
    exit 1
fi

if [ ! "$(ls "$mounted_root_dir")" ]; then
    echo "Root dir likely not mounted, directory $mounted_root_dir empty".
    exit 1
fi

mount -o bind /dev "/$mounted_root_dir/dev"
mount -o bind /dev/pts "/$mounted_root_dir/dev/pts"
mount -t sysfs /sys "/$mounted_root_dir/sys"
mount -t proc /proc "/$mounted_root_dir/proc"

# Clear and previous env vars (-i) and setup a proper environment for the next steps
# Execute a script to setup more stuff inside the chroot environment
if [ ! "$script_to_execute" ]; then
    chroot "$mounted_root_dir" \
    /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash
else
    chroot "$mounted_root_dir" \
    /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    "$script_to_execute" $script_args
fi

exit_error="$?"

umount "$mounted_root_dir/proc"
umount "$mounted_root_dir/sys"
umount "$mounted_root_dir/dev/pts"
umount "$mounted_root_dir/dev"

exit $exit_error