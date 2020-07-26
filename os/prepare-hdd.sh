#!/usr/bin/env bash

user_prompt()
{
    echo "!!! WARNING !!!"
    echo "Are you sure you want to install pumpos on disk"
    echo ">>>  $config_target_disk  <<<"
    echo "This will wipe the ENTIRE disk and cannot be undone!"
    echo "To continue, type i am sure in caps."

    echo -n "> "
    read -r confirm

    if [ "$confirm" != "I AM SURE" ]; then
        echo "Aborting installation."
        exit 1
    fi
}

check_disk_exists()
{
    if [ ! -e "/dev/$config_target_disk" ]; then
        echo "The target disk '$config_target_disk' does not exist, aborting installation."
        exit 1
    fi
}

create_disk_layout()
{
    echo ""
    echo "##### Creating disk layout... #####"

    if ! echo ';' | sfdisk "/dev/$config_target_disk"; then
        echo "Creating disk layout failed, aborting installation."
        exit 1
    fi
}

format_partition()
{
    echo ""
    echo "##### Formating partition 1... #####"

    # -i sparse=0 to avoid getting errors about "unknown filesystem" when installing grub
    if ! mkfs.xfs -i sparse=0 -f -L PUMPOS "/dev/${config_target_disk}1" > /dev/null; then
        echo "Formatting partition failed, aborting installation."
        exit 1
    fi
}

####################
# Main entry point #
####################

if [ ! "$1" ]; then
    echo "Usage: $0 <target disk, e.g. sdd>"
    exit 1
fi

config_target_disk="$1"

user_prompt
check_disk_exists
create_disk_layout
format_partition

# TODO swap partition?

sync

exit 0