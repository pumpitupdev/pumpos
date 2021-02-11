#!/usr/bin/env bash

enable_multiarch()
{
    echo ""
	echo "##### Enable multiarch packages... #####"

    dpkg --add-architecture i386
    apt update
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

echo "===== Extra installation pumpos ====="

enable_multiarch
install_alsa
install_x11
install_dev_tools
install_deps_pumptools
install_deps_sgl
install_deps_mk3_ports
install_deps_exc

echo "===== Done ====="
echo "Installation completed."
