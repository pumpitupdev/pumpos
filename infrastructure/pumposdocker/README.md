### Using the scripts

### Nvidia

### Prereqs
Install the Nvidia proprietary drivers for your host machine
Install the Nvidia container toolkit:
  Ubuntu/Centos: follow the instuctions on https://github.com/NVIDIA/nvidia-docker
  Arch: install https://aur.archlinux.org/packages/nvidia-container-toolkit/ from the AUR
Restart Docker

### Build and run
Run buildnvidia.sh, this will pull the matching nvidia drivers to your host and build the container.
Then run runnivida.sh /path/to/game/files

### Intel/AMD

### Prereqs
None

### Build and run
Run buildmesa.sh
Then run runmesa.sh /path/to/game/files

