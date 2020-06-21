# Pumpos: Create, deploy, configure and manage a setup for running Pump It Up
Version: 1.05</br>
[Release history](CHANGELOG.md)

## What is this all about?
* Easy and automatic creation of an OS base image for use with Pump games.
This includes all required configuration and software packages.
* Basic filesystem structure for easy deployment of any supported game
* Quick and easy deployment/update of pumptools, also batch deployment
* Batch configuration of multiple games, e.g. configure all games to use keyboard inputs

## Disclaimer
Some of the scripts require root previliges and can dangerous when not used
correctly. You are advised to read any on-screen instructions and
readme/documentation before using them. Mistakes can be as crucial as wiping
your host machine you are running these scripts on or other kinds of data loss.

## Hardware requirements
For your host machine, the "workstation" that you use to deploy the data, anything
that is capable of moving around data is fine.

For your target remote machine, which is going to run the deployed operating system
and games, make sure it fulfills the following requirements:
* CPU with 64-bit support; sorry, stock MK6 hardware won't work
* If using a Nvidia GPU: Anything that supports the 340 driver which means at least a GeForce 8 series (8000+) card 
from around end of 2006. Sorry, but that criteria kills stock MK9 hardware which comes with a 7200. There is patched
version of the 304 driver which supports these cards but it's hacky and not worth the additional effort, at least at
this point in time.

## Dependencies
Naturally, these scripts require a Linux environment, e.g. either a native
installation running on a machine, a virtual machine or you might also be able
to use WSL on Windows 10 (untested and officially not supported).

Currently compatible with a bash shell. Not sure about other shells as I am not
very familiar with anything else. If supporting them isn't creating a lot of
noise in the scripts, feel free to do so and submit a PR.

Tools you need to install before using the scripts:
* debootstrap
* lsblk
* genfstab
* chroot
* sfdisk
* mkfs.xfs
* qemu
* unzip

## Creating a physical disk image, deploying data and configuration
### Preparations
Assuming you are starting from scratch, you have to prepare the following things
before using the scripts here:
1. Prepare your "virtual" [environment](#dependencies).
1. Get (an empty or) unused HDD/SSD
1. Connect the disk to your host machine you are going to use with these scripts.
Either directly by connecting it to the motherboard (if possible) or by using
1. USB adapter or similar external device.
1. Check that the connected disk is recognized by the system, e.g. `lsblk`.
1. Have game data to deploy ready on your host system in a directory, e.g.
`piu-data`. This folder contains one sub-folder for each game identical to the
directory structure in this repositories `dist/piu/data` folder, e.g.
```
piu-data
  01_1st
    game.zip
    lib-local.zip
    lib-ld.zip
    piu
    version
  02_2nd
    ...
  03_obg
    ...
  ...
```
1. A distribution package of pumptools, the `pumptools.zip` file.

### Using the scripts
In general, you can always just run `./pumpos.sh` to get a list of available
commands and a brief description. To get usage information about single
commands, just run the script with the command as an argument without any
further arguments, e.g. `./pumpos.sh os-conf`.

Each command requires you to check for errors and not move on with any further
steps.

1. Create a OS configuration by running the `os-config` command and following
the instructions: `./pumpos.sh os-config ./pumpos.conf`.
1. Run the installation of the Linux system by running the `os-install` command
with the created configuration provided: `./pumpos.sh os-install ./pumpos.conf`.
Follow the instructions on screen. Stick around for the installation process
because you will be prompted to select a
[console setup](doc/pumpos.md#configure-console-setup) and to
[select the drive where to install the bootloader on](doc/pumpos.md#select-a-drive-to-install-the-bootloader-on).
1. Once installation on your host machine finished successfully, you are
instructed to connect the disk to your target hardware to finish the post
installation process. Do it! Do it!
1. Power on the target hardware, let the system boot and finish the post
installation step. It should automatically reboot once it successfully
completed this step.
1. Shutdown the target hardware and disconnect the disk. Re-connect it to your
host machine.
1. Ensure you have the root folder of the disk mounted somewhere. Examples of
further steps assume you have it mounted on `/mnt/pumpos`. Change the path
if necessary.
1. Deploy the base directory structure by running the `deploy-base` command,
e.g. `./pumpos.sh deploy-base /mnt/pumpos/piu`.
1. Deploy game data to the disk by using the `deploy-data` command. You can
either batch deploy multiple games, e.g.
`./pumpos.sh deploy-data /mnt/pumpos/piu /path/to/piu-data local`, or single
games, e.g.
`./pumpos.sh deploy-data /mnt/pumpos/piu /path/to/piu-data local 01_1st`.
1. Deploy pumptools by running the `deploy-pumptools` command. You can either
batch deploy to multiple games, e.g.
`./pumpos.sh deploy-pumptools /mnt/pumpos/piu /path/to/pumptools.zip` or to a
single game, e.g.
`./pumpos.sh deploy-pumptools /mnt/pumpos/piu /path/to/pumptools.zip 01_1st`.
1. Create a
[configuration file for configuring the pumptools hooks](doc/conf-pumptools.md).
1. Configure pumptools of the deployed games by using the `conf-pumptools`
command. You can either batch configure all games e.g.
`./pumpos.sh conf-pumptools /mnt/pumpos/piu /path/to/pumptools.conf`, or
configure just a single game, e.g.
`./pumpos.sh conf-pumptools /mnt/pumpos/piu /path/to/pumptools.conf 01_1st`
1. Configure pumptools using the `conf-pumptools` command:
    1. For running on cabinets with real IO support, you can use the
    `conf/pumptools-cabinet.conf` included which configures all games:
    `./pumpos.sh conf-pumptools /mnt/pumpos/piu ./conf/pumptools-cabinet.conf`
    1. For running on desktops with keyboard support, you can use the
    `conf/pumptools-desktop.conf` included which configures all games:
    `./pumpos.sh conf-pumptools /mnt/pumpos/piu ./conf/pumptools-desktop.conf`
1. Optional: If you want to use [SGL](https://dev.s-ul.eu/hackitup/sgl) for
bootstrapping the games, you have to deploy the binaries and assets:
`./pumpos.sh deploy-sgl /mnt/pumpos/piu /path/to/sgl-linux.zip /path/to/sgldata/data/piu`
1. Configure the boot process of pumpos with the `conf-boot` command defining how the
games are bootstrapped:
    1. Single game bootstrapping: e.g. to always boot 01_1st:
    `./pumpos.sh conf-boot /mnt/pumpos/piu game 01_1st`
    1. SGL bootstrapping (requires SGL deployed): 
    `./pumpos.sh conf-boot /mnt/pumpos/piu sgl`
1. Unmount: `umount /mnt/pumpos/piu` 
1. Disconnect the disk attached to your host.
1. Connect the disk back to your target hardware.
1. Boot the target hardware and it should start the configured game.

### Use scripts to deploy data and configure local setups on a host
For development and testing, you can also use the scripts to deploy/update data
on the same host machine. Instead of specifying paths to a mounted disk on the
commands `deploy-base`, `deploy-data`, `deploy-pumptools` and `conf-pumptools`,
just set it to a local folder. Any other commands are not required for such a
setup and can be ignored.

### Use scripts to deploy and configure SGL (Simple Game Loader)
SGL provides a front-end to select a game of your choice on a setup with multiple
games on a single installation.

In order to enable that, you have to add the following steps to the deployment
and configuration process, e.g. before the end when
[unmounting the disk](#using-the-scripts):
1. Download or compile the SGL binary distribution package for Linux. See the
`sgl` repository for instructions. You need the `sgl-linux.zip` output file.
1. Have the `piu` data from the `sgldata` repository ready on your host
machine.
1. Deploy SGL: `./pumpos.sh deploy-sgl /mnt/pumpos/piu /path/to/sgl-linux.zip /path/to/sgldata/data/piu`
1. Configure the boot process to run SGL on boot: `./pumpos.sh conf-boot /mnt/pumpos/piu sgl`
1. Unmount: `umount /mnt/pumpos` 
1. Disconnect the disk attached to your host.
1. Connect the disk back to your target hardware.
1. Boot the target hardware and it should start SGL which allows you to select
the game that you want to play.

### Backup save folders before full re-deployment
If you want to fully re-deploy to your existing disk which includes a fresh installation of the base OS, you can let
the pumpos scripts backup your save folders which includes operator settings, local high scores and more.

Make sure your drive is connected and mounted on your local machine.

```shell script
./pumpos.sh backup-save /mnt/pumpos/piu
```

Running the above command creates zip files of all save folders and backs them up to the folder `backup/save` of the
local pumpos project.

You can restore the backup once you have re-deployed everything with the following command:

```shell script
./pumpos.sh deploy-save /mnt/pumpos/piu
```

### Enable caching layer for apt packages
If you have to install pumpos multiple times, e.g. developing, testing or debugging, it is highly recommended
to start the `apt-cache` docker container provided with pumpos. This container runs locally on your host
workstation and serves all packages to download as a proxy from your local network which speeds up installation
and build times of pumpos images a lot.

To enable this caching layer:
1. Go to the infrastructure sub-folder: `cd infrastructure`
1. Build the `apt-cache` container image: `make build-apt-cache`
1. Run the container: `make start-apt-cache`
1. When finished, you can stop the container again: `make stop-apt-cache`
1. If there are any issues, you can take a look at the logs which should show you some activity when having
to fetch the packages from the actual remote repository to cache them: `make logs-apt-cache`

Now, you have to provide the proxy's address as an apt host to the pumpos installation configuration. Make
sure to provide it when running `./pumpos.sh os-config` as well as entering a valid mirror (suggestions are
already given during the configuration phase).

The resulting `pumpos.conf` should look similar to the following example:
```text
pumpos
piu
piu
nvidia
http://<some ip v4 address>:3142
eu.archive.ubuntu.com/ubuntu/
```

## Complete flow for a full deployment for cabinet use with SGL
The following commands are to be run in order if you already know what you are doing. If you have no clue what these
commands are about, you are advised to carefully read the instructions of
[this section](#creating-a-physical-disk-image-deploying-data-and-configuration) first.

Preparations:
1. Connect external drive or prepare local folder
1. Either mount your drive on `/mnt/pumpos/piu` or replace it if required.
1. Have `pumpdata` prepared and located next to `pumpos`
1. Have `pumptools` repo or dist package prepared and located next to `pumpos`
1. Have `sgl` repo or dist package prepared and located next to `pumpos`
1. Have `sgldata` repo or dist package prepared and localted next to `pumpos`

Steps:
1. Skip the following OS install process if deployment to local folder.
    1. `./pumpos.sh os-config pumpos.conf`
    1. `./pumpos.sh os-install ./pumpos.conf`
    1. Finish OS install process on target hardware
    1. Plug disk back into workstation
1. `./pumpos.sh deploy-base /mnt/pumpos/piu`
1. `./pumpos.sh deploy-data /mnt/pumpos/piu ../pumpdata/data local`
1. `./pumpos.sh deploy-sgl /mnt/pumpos/piu ../sgl/build/docker/package/sgl-linux.zip ../sgldata/data/piu`
1. `./pumpos.sh deploy-pumptools /mnt/pumpos/piu ../pumptools/build/docker/pumptools.zip`
1. `./pumpos.sh conf-pumptools /mnt/pumpos/piu ./conf/pumptools-cabinet.conf`
1. `./pumpos.sh conf-boot /mnt/pumpos/piu sgl`
1. If you have a save backup of some old deployment to restore: `./pumpos.sh deploy-save /mnt/pumpos/piu`

## License
Source code license is the Unlicense; you are permitted to do with this as thou
wilt. For details, please refer to the [LICENSE file](LICENSE) included with the
source code.