#!/usr/bin/env bash

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PREPARE_HDD_SCRIPT_PATH="$ROOT_PATH/prepare-hdd.sh"
readonly SYTEM_INSTALL_SCRIPT_PATH="$ROOT_PATH/system-install.sh"

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

    # Read configuration with bash variables
    source "$config_file"
}

configuration_confirmation()
{
    echo "Summary configuration:"
    echo "hostname: $PUMPOS_CONFIG_HOSTNAME"
    echo "username: $PUMPOS_CONFIG_USERNAME"
    echo "password: ***HIDDEN***"
    echo "gpu driver: $PUMPOS_CONFIG_GPU_DRIVER"
    echo "apt host (optional): $PUMPOS_CONFIG_APT_HOST"
    echo "apt mirror (optional): $PUMPOS_CONFIG_APT_MIRROR"

    echo ""
    echo "Are these values correct?"
    echo "Confirm by typing yes in caps and confirm."

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

        echo "Please select the target disk to install pumpos on, e.g. sdd."
        echo "Leave empty to abort."

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

system_installation()
{
    echo "##################################################################"
    echo "System installation"
    echo "##################################################################"

    "$SYTEM_INSTALL_SCRIPT_PATH" "$config_target_disk" "$PUMPOS_CONFIG_HOSTNAME" "$PUMPOS_CONFIG_USERNAME" "$PUMPOS_CONFIG_PASSWORD" "$PUMPOS_CONFIG_APT_HOST" "$PUMPOS_CONFIG_APT_MIRROR"

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
	  echo "Pump OS Installer"
	  echo "Creates a drive/partition layout on the target drive and installs a Linux system for use with Pump games."
	  echo ""
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
system_installation
remove_drive

echo "################"
echo "##### Done #####"
echo "################"
echo ""
echo "1. Disk unmouned, remove it from your host"
echo "2. Attach it to your target system"
echo "3. Boot and check if everything's good. You should see some output indicating that it's an empty installation"
echo "4. Continue with software and data deployment"

exit 0