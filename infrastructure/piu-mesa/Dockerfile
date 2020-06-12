FROM ubuntu:18.04

LABEL description="Userspace environment to run Pump It Up games"

# Enable multi arch
RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y \
    alsa-base \
    alsa-utils \
    alsa-tools \
    xorg \
    xinit \
    x11-xserver-utils \
    xserver-xorg-core \
    gdb \
    gdbserver \
    strace \
    libusb-1.0-0:i386 \
    libsdl2-2.0-0 \
	libsdl2-image-2.0-0 \
	libsdl2-ttf-2.0-0 \
	ffmpeg \
	gcc-multilib \
    libusb-0.1-4:i386 \
    libconfig++9v5:i386 \
    libfreetype6:i386 \
    lib32tinfo5 \
    lib32ncurses5 \
    libxcursor1:i386 \
    libxinerama1:i386 \
    libxi6:i386 \
    libxrandr2:i386 \
    libxxf86vm1:i386 \
    libx11-6:i386 \
    libasound2:i386 \
    gcc-multilib \
    libx11-6:i386 \
    zlib1g:i386 \
    libcurl4-gnutls-dev:i386 \
    libglu1-mesa:i386 \
    mesa-utils \
    mesa-utils-extra

#Set working directory
WORKDIR /piu

#Set entrypoint
#ENTRYPOINT ["./piueb", "run"]
