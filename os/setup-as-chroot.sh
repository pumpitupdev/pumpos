#!/bin/bash

readonly PATH_PUMPOS_ROOT="/pumpos"
readonly PATH_PACKAGES="$PATH_PUMPOS_ROOT/packages.txt"
readonly APT_SOURCES="/etc/apt/sources.list"

environment_check()
{
    # Check if this is running inside the chroot environment
    if [ ! -d "$PATH_PUMPOS_ROOT" ]; then
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

    # Force to non-interactive to avoid dialogs popping up
    DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade
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

set_timezone()
{
    echo ""
	echo "##### Setting timezone... #####"

	ln -sf /usr/share/zoneinfo/UTC /etc/localtime
	hwclock --systohc
}

enable_multiarch()
{
    echo ""
	echo "##### Enable multiarch packages... #####"

    dpkg --add-architecture i386
    apt update
}

install_ssh()
{
    echo ""
	echo "##### Install sshd... #####"

    apt-get -y install openssh-server

    # Service automatically enabled

	# Enable password auth
	echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

	systemctl restart sshd
}

install_gpu_driver()
{
    echo ""
	echo "##### Install gpu driver... #####"

    # Required for add-apt-repository
    apt-get -y install software-properties-common

    # Add official Nvidia PPA
    add-apt-repository -y ppa:graphics-drivers/ppa

    apt-get update

    # TODO read this from config, nvidia-304, nvidia-340 or nvidia-384 allowed for nvidia driver
    apt-get -y install \
    nvidia-340 \
    libglu1-mesa:i386
}

install_packages()
{
    echo ""
	echo "##### Install packages ... #####"

    if [ -e "$PATH_PACKAGES" ]; then
        cat "$PATH_PACKAGES" | xargs sudo apt-get -y install
        rm "$PATH_PACKAGES"
    else
        echo "WARNING: Missing packages.txt file, skipping package installation"
        sleep 5
    fi
}

remove_apt_get_proxy()
{
    local proxy_file="/etc/apt/apt.conf.d/01proxy"

    if [ -f "$proxy_file" ]; then
        echo ""
        echo "##### Removing apt get proxy (package caching)... #####"
        rm $proxy_file
    fi
}

setup_pumpos_boot_env()
{
    echo ""
    echo "##### Setup pumpos boot environment... #####"

    # Create startup service for boot.sh to run on tty1
    printf "%s" "
[Unit]
Description=pumpos boot
After=getty.target
Conflicts=getty@tty1.service

[Install]
WantedBy=graphical.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/pumpos/boot.sh
WorkingDirectory=/pumpos
StandardInput=tty-force
StandardOutput=inherit
StandardError=inherit
" > /etc/systemd/system/pumpos.service

    chmod +x /etc/systemd/system/pumpos.service
    systemctl enable pumpos.service
}

setup_pumpos_boot_default_script()
{
    printf '%s' '#!/bin/bash
clear
echo "========================================="
echo "======= Empty pumpos installation ======="
echo "========================================="
echo "Error booting, no data deployed."
exit 0' > /pumpos/boot.sh

    chmod +x /pumpos/boot.sh

    # Typically, you will have a user with user/group id 1000 on your host machine
    # To make this file accessible by the (piu) user on the remote machine and
    # potentially on your host, change ownership
    chown 1000:1000 /pumpos/boot.sh
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
set_timezone

# Packages
enable_multiarch
install_ssh
install_gpu_driver
install_packages
remove_apt_get_proxy

# Bootstrapping for pumpos
setup_pumpos_boot_default_script
setup_pumpos_boot_env

echo "##### Done in chroot environment #####"
exit 0
