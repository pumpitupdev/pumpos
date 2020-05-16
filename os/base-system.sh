#!/usr/bin/env bash

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MOUNT_POINT_PUMPOS="/tmp/pumpos2"
readonly PUMPOS_DATA="/piu"
readonly MOUNT_POINT_PUMPOS_DATA="$MOUNT_POINT_PUMPOS$PUMPOS_DATA"
readonly CHROOT_SETUP_SCRIPT="setup-as-chroot.sh"
readonly BOOT_SETUP_SCRIPT="setup-on-first-boot.sh"
readonly CHROOT_SETUP_SCRIPT_PATH="$ROOT_PATH/asset/$CHROOT_SETUP_SCRIPT"
readonly BOOT_SETUP_SCRIPT_PATH="$ROOT_PATH/asset/$BOOT_SETUP_SCRIPT"
readonly CHROOT_EXEC_SCRIPT_PATH="$ROOT_PATH/chroot.sh"

mount_partition()
{
    echo ""
    echo "##### Mounting partition.. #####"

    # Mount OS partition
    mkdir -p "$MOUNT_POINT_PUMPOS"
    mount "/dev/${target_disk}1" "$MOUNT_POINT_PUMPOS"
}

install_base_system()
{
    echo ""
    echo "##### Installing base system... #####"

    # Install base system, Ubuntu 18.xx LTS
    debootstrap --arch amd64 bionic "$MOUNT_POINT_PUMPOS" "$config_apt_host/$config_apt_mirror"
}

generate_fstab()
{
    echo ""
    echo "##### Generating fstab... #####"

    genfstab -U "$MOUNT_POINT_PUMPOS" > "$MOUNT_POINT_PUMPOS/etc/fstab"
}

add_apt_mirror()
{
    if [ "$config_apt_mirror" ]; then
        echo ""
        echo "##### Adding apt mirror $config_apt_host... #####"

        echo "Acquire::http { Proxy \"$config_apt_host\"; };" >> "$MOUNT_POINT_PUMPOS/etc/apt/apt.conf.d/01proxy"
    fi
}

setup_pumpos()
{
    echo ""
    echo "##### Setup pumpos... #####"

    mkdir -p "$MOUNT_POINT_PUMPOS_DATA"

    # Typically, you will have a user with user/group id 1000 on your host machine
    # To make this folder accessible by the (piu) user on the remote machine and
    # potentially on your host, change ownership
    chown 1000:1000 "$MOUNT_POINT_PUMPOS_DATA"

    cp "$CHROOT_SETUP_SCRIPT_PATH" "$MOUNT_POINT_PUMPOS_DATA/$CHROOT_SETUP_SCRIPT"
    chmod +x "$MOUNT_POINT_PUMPOS_DATA/$CHROOT_SETUP_SCRIPT"
}

chroot_exec_install()
{
    echo ""
    echo "##### Exec install inside chroot... #####"

    $CHROOT_EXEC_SCRIPT_PATH "$MOUNT_POINT_PUMPOS" "$PUMPOS_DATA/$CHROOT_SETUP_SCRIPT" "$config_hostname" "$config_username" "$config_password"
}

prepare_boot_post_install()
{
    echo ""
    echo "##### Prepare boot post install... #####"

    # Copy initial boot script which executes further post installation on first boot
    cp "$BOOT_SETUP_SCRIPT_PATH" "$MOUNT_POINT_PUMPOS_DATA/boot.sh"
    chmod +x "$MOUNT_POINT_PUMPOS_DATA/boot.sh"

    # Cleanup after post install
    rm "$MOUNT_POINT_PUMPOS_DATA/$CHROOT_SETUP_SCRIPT"
}

unmount_partition()
{
    echo ""
    echo "##### Cleanup... #####"

    umount "$MOUNT_POINT_PUMPOS"
}

####################
# Main entry point #
####################

if [ $# -lt 4 ]; then
    echo "Usage: $0 <target disk, e.g. sdd> <hostname> <username> <password> [apt host] [apt mirror]"
    exit 1
fi

target_disk="$1"
config_hostname="$2"
config_username="$3"
config_password="$4"
config_apt_host="$5"
config_apt_mirror="$6"

# Exit if any command fails
set -e

mount_partition
install_base_system
generate_fstab
add_apt_mirror
setup_pumpos
chroot_exec_install
prepare_boot_post_install
unmount_partition

echo ""
echo "##### Done #####"

exit 0