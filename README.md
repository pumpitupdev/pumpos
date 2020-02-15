# Pumpos: Create, deploy, configure and manage a setup for running Pump It Up
Version: 1.02</br>
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
1. Configure the boot process of pumpos by defining which game to boot using
the `conf-boot` command, e.g. to boot 01_1st
`./pumpos.sh conf-boot /mnt/pumpos/piu game 01_1st`
1. Unmount: `umount /mnt/pumpos` 
1. Disconnect the disk attached to your host.
1. Connect the disk back to your target hardware.
1. Boot the target hardware and it should start the configured game.

### Use the scripts to deploy data and configure local setups on a host
For development and testing, you can also use the scripts to deploy/update data
on the same host machine. Instead of specifying paths to a mounted disk on the
commands `deploy-base`, `deploy-data`, `deploy-pumptools` and `conf-pumptools`,
just set it to a local folder. Any other commands are not required for such a
setup and can be ignored.

## License
Source code license is the Unlicense; you are permitted to do with this as thou
wilt. For details, please refer to the [LICENSE file](LICENSE) included with the
source code.