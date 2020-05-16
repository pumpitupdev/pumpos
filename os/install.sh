#!/usr/bin/env bash

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PREPARE_HDD_SCRIPT_PATH="$ROOT_PATH/prepare-hdd.sh"
readonly BASE_SYTEM_SCRIPT_PATH="$ROOT_PATH/base-system.sh"

check_command_available()
{
    local cmd="$1"

    echo -n "$cmd..."

    if [ ! "$(command -v "$cmd")" ]; then
        echo "not found"
        exit 1
    else
        echo "ok"
    fi
}

environment_checks()
{
    echo "##################################################################"
    echo "Environment checks"
    echo "##################################################################"

    check_command_available "debootstrap"
    check_command_available "lsblk"
    check_command_available "genfstab"
    check_command_available "chroot"
    check_command_available "sfdisk"
    check_command_available "mkfs.xfs"

    echo -n "Running as root..."

    if [ "$EUID" -ne 0 ]; then
        echo "fail"
        echo "Script needs to be run as root in order to make changes to the target drive."
        exit 1
    else
        echo "ok"
    fi
}

read_configuration()
{
    echo "##################################################################"
    echo "Configruation"
    echo "##################################################################"

    local config_file="$1"

    config_hostname="$(cat "$config_file" | cut -d$'\n' -f 1)"
    config_username="$(cat "$config_file" | cut -d$'\n' -f 2)"
    config_password="$(cat "$config_file" | cut -d$'\n' -f 3)"
    config_gpu_driver="$(cat "$config_file" | cut -d$'\n' -f 4)"
}

configuration_confirmation()
{
    echo "Summary configuration:"
    echo "hostname: $config_hostname"
    echo "username: $config_username"
    echo "password: ***HIDDEN***"
    echo "gpu driver: $config_gpu_driver"

    echo "Are these values correct? Confirm by typing yes in caps and confirm."

    echo -n "> "
    read -r confirm

    if [ "$confirm" != "YES" ]; then
        echo "Aborting installation."
        exit 1
    fi
}

select_target_disk()
{
    while [ ! "$config_target_disk" ]; do
        echo "Currently connected disks, lsblk output:"
        lsblk
        echo ""

        echo "Please select the target disk to install pumpos on, e.g. sdd. Leave empty to abort."

        echo -n "> "
        read -r config_target_disk

        if [ ! "$config_target_disk" ]; then
            echo "Aborting installation."
            exit 1
        fi

        if [ ! -e "/dev/$config_target_disk" ]; then
            echo "The target disk '$config_target_disk' does not exist"
            config_target_disk=""
        fi
    done
}

prepare_disk()
{
    echo "##################################################################"
    echo "Preparing physical disk"
    echo "##################################################################"

    "$PREPARE_HDD_SCRIPT_PATH" "$config_target_disk"

    if [ "$?" != "0" ]; then
        exit 1
    fi
}

base_system_installation()
{
    echo "##################################################################"
    echo "Base system installation"
    echo "##################################################################"

    "$BASE_SYTEM_SCRIPT_PATH" "$config_target_disk" "$config_hostname" "$config_username" "$config_password"

    if [ "$?" != "0" ]; then
        exit 1
    fi
}

remove_drive()
{
    echo "##################################################################"
    echo "Removing drive $config_target_disk"
    echo "##################################################################"

    sync
    echo "1" > "/sys/block/$config_target_disk/device/delete"
}

####################
# Main entry point #
####################

if [ ! "$1" ]; then
	  echo "Pump It Up OS Installer"
	  echo "Creates a drive/partition layout on the target drive and installs a base Linux system for use with Pump games."
	  echo "PREPARATIONS BEFORE YOU CONTINUE:"
	  echo " 1. Get an empty or unused HDD/SSD large enough to fit whatever games you want to put on it."
	  echo " 2. Connect the disk to the machine you are running this script on."
	  echo " 3. Check that your disk is recognized by the system, e.g. lsblk"
	  echo " 4. Run this script again with the the configuration you created: os-install <pumpos.conf>"
    exit 1
fi

environment_checks

config_file="$1"

if [ ! -e "$config_file" ]; then
    echo "Cannot find configuration file $1"
    exit 1
fi

read_configuration "$config_file"
configuration_confirmation
select_target_disk
prepare_disk
base_system_installation
remove_drive

echo "##### Done #####"
echo "Remove the disk from your host, attach it to your target system and boot it."
echo "Ensure that your target system is wired to your local network."
echo "Post installation steps are executed on initial boot, once, to finish installation."
echo "Once post installation completes and the machines rebooted, you can access it remotely: ssh ${config_username}@$config_hostname"

exit 0