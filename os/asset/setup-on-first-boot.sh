#!/usr/bin/env bash

# DO NOT RUN THIS SCRIPT !!!
# This script is copied to a fresh pumpos disk, run once on first boot and deleted afterwards

apply_network_config()
{
    echo ""
	echo "##### Apply network config... #####"

    netplan apply
}

check_internet_access()
{
    echo ""
	echo "##### Checking internet access... #####"

	# Let's consider Google = Internet *shrug*
    if ping -q -c 1 -W 5 8.8.8.8 > /dev/null; then
        echo "IPv4 is up, internet access ok."
    else
        echo "IPv4 is down, no internet access."
        echo "Ensure you have a network cable plugged in that this machine is not blocked by your router."
        echo "To retry, reboot this machine."
        echo "Halting."
        sleep infinity
    fi
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

install_alsa()
{
    echo ""
	echo "##### Install alsa... #####"

	apt-get -y install \
	alsa-base \
	alsa-utils \
	alsa-tools
}

install_x11()
{
    echo ""
	echo "##### Install X11... #####"

	apt-get -y install \
	xorg \
	xinit \
	x11-xserver-utils \
	xserver-xorg-core
}

install_dev_tools()
{
    echo ""
    echo "##### Install dev tools... #####"

    # nano because I am not going to torture myself using vi
    apt-get -y install \
        vim \
        nano \
	gdb \
	gdbserver\
	strace
}

install_deps_pumptools()
{
    echo ""
    echo "##### Install deps pumptools... #####"

    apt-get -y install \
    libusb-1.0-0:i386
    libxtst6:i386 \
    libstdc++5:i386 \
    libcurl4-gnutls-dev:i386
}

install_deps_sgl()
{
    echo ""
    echo "##### Install deps sgl... #####"

    apt-get -y install \
	libsdl2-2.0-0 \
	libsdl2-image-2.0-0 \
	libsdl2-ttf-2.0-0 \
	ffmpeg
}

install_deps_mk3_ports()
{
    echo ""
    echo "##### Install deps mk3 ports... #####"

    apt-get -y install \
    gcc-multilib \
    libusb-0.1-4:i386 \
    libconfig++9v5:i386 \
    lib32tinfo5 \
    lib32ncurses5 \
    libxcursor1:i386 \
    libxinerama1:i386 \
    libxi6:i386 \
    libxrandr2:i386 \
    libxxf86vm1:i386 \
    libx11-6:i386 \
    libasound2:i386
}

install_deps_exc()
{
    echo ""
    echo "##### Install deps exc... #####"

    apt-get -y install \
    gcc-multilib \
    libx11-6:i386 \
    zlib1g:i386 \
    libasound2:i386
}

####################
# Main entry point #
####################

# Exit if any command fails
set -e

# Boot script to finalize setup once the drive is booted on the target hardware
# Script "self destructs" and creates a placeholder for deployment later
clear
echo "===== Post installation pumpos ====="
echo "Note: If this script encounters any errors it will abort and not complete!"

echo "Installation continues in 10 seconds..."
sleep 10

apply_network_config
check_internet_access

# Disable the piu script as some installation steps trigger a restart of this
# for unknown reasons which crashes the installtion process
systemctl disable piu

set_timezone
enable_multiarch
install_ssh
install_gpu_driver
install_alsa
install_x11
install_dev_tools
install_deps_pumptools
install_deps_sgl
install_deps_mk3_ports
install_deps_exc

chmod +x /piu/boot.sh

# Typically, you will have a user with user/group id 1000 on your host machine
# To make this file accessible by the (piu) user on the remote machine and
# potentially on your host, change ownership
chown 1000:1000 /piu/boot.sh

# Renable for next boot
systemctl enable piu

echo "===== Done ====="
echo "Installation completed. Reboot the system."

printf '%s' '#!/bin/bash
clear
echo "======= OS installation completed ======="
echo "Error booting, no data deployed."
exit 0' > /piu/boot.sh
