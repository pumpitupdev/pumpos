#xhost +local:root #Needed if using hosts X display

if [ -z "$1" ]
  then
    echo "No data path supplied"
    echo "Usage example for pumpos: ./runnmesa.sh /piu/data/17_zero/"
    exit -1
fi
#
#docker run \
#    --privileged \
#    -v /dev/bus/usb:/dev/bus/usb \
#    --device /dev/dri \
#    --device /dev/vga_arbiter \
#    -it \
#    --rm \
#    -v /tmp/.X11-unix:/tmp/.X11-unix \
#    -v "$1":/piu \
#    -e DISPLAY="$DISPLAY" \
#    --name piu-mesa pumpos:piu-mesa

nvidia-docker run \
    --privileged \
    -v /dev/bus/usb:/dev/bus/usb \
    --gpus all \
    -it \
    --rm \
    -v "$XAUTHORITY":/root/.Xauthority \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$1":/piu \
    -e DISPLAY="$DISPLAY" \
    --name piu-nvidia piu:latest