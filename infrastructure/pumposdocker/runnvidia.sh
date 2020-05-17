#!/bin/sh

if [ -z "$1" ]
  then
    echo "No data path supplied"
    echo "Usage example for pumpos: ./runnvidia.sh /piu/data/17_zero/"
    exit -1
fi

#xhost +local:root #Needed if using hosts X display

docker run --privileged -v /dev/bus/usb:/dev/bus/usb --gpus all -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix -v $1:/piu -e DISPLAY=$DISPLAY --name piudocker piu:latest
