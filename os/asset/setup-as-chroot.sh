#!/bin/bash

readonly PATH_PIU_DATA="/piu"
readonly APT_SOURCES="/etc/apt/sources.list"

environment_check()
{
    # Check if this is running inside the chroot environment
    if [ ! -d "$PATH_PIU_DATA" ]; then
        echo "Not running inside chroot environment, don't execute this script"
        exit 1
    fi

    # Check if running as root, required
    if [ "$EUID" -ne 0 ]; then
        echo "Script needs to be run as root"
        exit 1
    fi
}

set_locale()
{
    echo ""
    echo "##### Setting locale... #####"

    locale-gen en_US.UTF-8
}

set_apt_repos()
{
    echo ""
    echo "##### Setting apt repos... #####"

    rm -f "$APT_SOURCES"

	  printf "%s" "
deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse
" > "$APT_SOURCES"

    apt update
}

apt_upgrade()
{
    echo ""
    echo "##### Apt upgrade... #####"

    apt-get -y upgrade
}

install_kernel()
{
    echo ""
    echo "##### Installing kernel... #####"

    # xfsprogs required for updating initramfs
    # linux-generic installs kernel and grub
    apt-get -y install xfsprogs linux-generic
}

configure_grub()
{
    echo ""
    echo "##### Configure grub... #####"

    # Remove this script to not probe for more operating systems for the grub config file
    # Otherwise, this will find the host system and add it as an entry
    rm /etc/grub.d/30_os-prober

    # Hide splash screen and show debug info for installation. Will be removed by post install process.
    sed -i -- "s/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/GRUB_CMDLINE_LINUX_DEFAULT=\"debug nosplash\"/g" "/etc/default/grub"

    grub-mkconfig -o /boot/grub/grub.cfg
}

install_network_stuff()
{
    echo ""
    echo "##### Running system upgrade... #####"

    # With netplan, you cannot go the /etc/networks/interface route anymore
	  printf "%s" "
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
" > /etc/netplan/99_config.yaml

    # Applying network config cannot be done at this point. Finished by post install process.

    # To make configuration of this consistent, get the old endpoint eth0 back
    sed -i -- "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\"/g" "/etc/default/grub"

    grub-mkconfig -o /boot/grub/grub.cfg
}

set_hostname()
{
    local hostname="$1"

    echo ""
	  echo "##### Setting hostname...##### "

	  echo "$hostname" > "/etc/hostname"
}

set_root_password()
{
    local password="$1"

    echo ""
	  echo "##### Setting root password... #####"

	  # Pass needs to be sent twice
	  (echo "$password"; echo "$password") | passwd
}

create_user()
{
    local user="$1"
    local password="$2"

    echo ""
    echo "##### Creating user... #####"

    # Create user and home directory
    useradd -m "$user"
    # Pass needs to be sent twice
    (echo "$password"; echo "$password") | passwd "$user"

    # Change shell to bash
    usermod --shell /bin/bash "$user"
    usermod -aG sudo "$user"
}

setup_piu_boot_env()
{
    echo ""
    echo "##### Setup piu boot environment... #####"

    # Create startup service for boot.sh to run on tty1
    printf "%s" "
[Unit]
Description=PIU Boot
After=getty.target
Conflicts=getty@tty1.service

[Install]
WantedBy=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/piu/boot.sh
WorkingDirectory=/piu
StandardInput=tty-force
StandardOutput=inherit
StandardError=inherit
" > /etc/systemd/system/piu.service

    chmod +x /etc/systemd/system/piu.service
    systemctl enable piu.service
}

####################
# Main entry point #
####################

if [ $# -lt 3 ]; then
    echo "Usage: $0 <hostname> <username> <password>"
    exit 1
fi

config_hostname="$1"
config_username="$2"
config_password="$3"

# Exit if any command fails
set -e

environment_check

# Execute tasks
set_locale
set_apt_repos
apt_upgrade
install_kernel
configure_grub
install_network_stuff
set_hostname "$config_hostname"
set_root_password "$config_password"
create_user "$config_username" "$config_password"
setup_piu_boot_env

echo "##### Done in chroot environment #####"
exit 0
