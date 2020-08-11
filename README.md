# Pumpos: Create, deploy, configure and manage a setup for running Pump It Up and In The Groove
Version: 1.06</br>
[Release history](CHANGELOG.md)

## What is this all about?
* Easy and automatic creation of an OS base image for use with Pump games and ITG.
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
* If using a Nvidia GPU: Anything that supports the 340 driver which means at least
a GeForce 8 series (8000+) card from around end of 2006. Sorry, but that criteria
kills stock MK9 hardware which comes with a 7200. There is patched version of the
304 driver which supports these cards but it's hacky and not worth the additional
effort, at least at this point in time.

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
`pumpdata/data`. This folder contains one sub-folder for each game identical to the
directory structure in this repositories `dist/piu/base/pumpos/data` folder, e.g.
```
pumpdata
  data
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
  ...
```
1. A distribution package of pumptools, the `pumptools.zip` file.
1. Optional: A distributation package of SGL, the `sgl-linux.zip` file.
1. Optional: SGL assets for PIU/ITG, e.g. `sgldata/data/piu` housing the assets.

### Using the scripts
In general, you can always just run `./pumpos.sh` to get a list of available
commands and a brief description. To get usage information about single
commands, just run the script with the command as an argument without any
further arguments, e.g. `./pumpos.sh os-conf`.

#### Building your pumpos disk image step by step
Each command requires you to check for errors and not move on with any further
steps. The following example shows you how to create a multi-disk for PIU
games. Similar steps apply for a ITG multi-disk.

If you want a summary of the commands to run or run them in batch easily,
use the [pipeline commands](#use-pipelines-for-batching-steps) instead.

##### OS
1. Create a OS configuration by running the `os-config` command and following
the instructions:
```bash
./pumpos.sh os-config ./pumpos.cfg
```
1. Run the installation of the Linux system by running the `os-install` command
with the created configuration provided: 
```bash
./pumpos.sh os-install ./pumpos.cfg
```
Follow the instructions on screen. Stick around for the installation process
because you will be prompted to 
[select the drive where to install the bootloader on](doc/pumpos.md#select-a-drive-to-install-the-bootloader-on).
1. Once installation on your host machine finished successfully, you are
instructed to connect the disk to your target hardware and check if everything
boots up nicely. Do it! Do it!
1. If everything turns out to be fine shutdown the target hardware and
disconnect the disk. Re-connect it to your host machine.

##### Deploy PIU data
1. Ensure you have the root folder of the disk mounted somewhere. For example,
if the disk shows up as `sdd` (use `lsblk`):
```bash
mount /dev/sdd1 /mnt/pumpos
```
Examples of further steps assume you have it mounted on `/mnt/pumpos`. Change
the path if necessary.
1. If you want to use pumpnet, put the certificate files you have received
into the `dist/piu/base/pumpos/data/00_bootstrap/certs` folder without adding
further sub-folders. The certs will be deployed on one of the next steps.
1. Deploy the pumpos base directory structure by running the `deploy-dir` command:
```bash
./pumpos.sh deploy-base /mnt/pumpos/pumpos ./dist/base/pumpos
```
1. Deploy the piu base directory structure by running the `deploy-dir` command:
```bash
./pumpos.sh deploy-base /mnt/pumpos/pumpos ./dist/piu/base/pumpos
```
1. Deploy game data to the disk by using the `deploy-piu-data` command. You can
either batch deploy multiple games:
```bash
./pumpos.sh deploy-data /mnt/pumpos/pumpos /path/to/pumpdata/data local
```
or single games
```bash
./pumpos.sh deploy-data /mnt/pumpos/piu /path/to/pumpdata/data local 01_1st
```
1. Deploy pumptools by running the `deploy-piu-pumptools` command. You can either
batch deploy to multiple games:
```bash
./pumpos.sh deploy-piu-pumptools /mnt/pumpos/pumpos /path/to/pumptools.zip
```
 or to a single game:
 ```bash
./pumpos.sh deploy-piu-pumptools /mnt/pumpos/pumpos /path/to/pumptools.zip 01_1st
```

##### Optional: deploy SGL
1. Optional: If you want to use [SGL](https://dev.s-ul.eu/hackitup/sgl) for
bootstrapping the games, you have to deploy the binaries and assets:
`./pumpos.sh deploy-sgl /mnt/pumpos/piu /path/to/sgl-linux.zip /path/to/sgldata/data/piu`


##### Configure
1. Configure the boot process of pumpos with the `conf-boot` command defining how the
games are bootstrapped:
    1. Single game bootstrapping: e.g. to always boot 01_1st:
    ```bash
    ./pumpos.sh conf-boot /mnt/pumpos/pumpos game 01_1st
    ```
    1. SGL bootstrapping (requires SGL deployed): 
    ```bash
    ./pumpos.sh conf-boot /mnt/pumpos/pumpos sgl
    ```
    1. For development, dropping to shell:
    ```bash
    ./pumpos.sh conf-boot /mnt/pumpos/pumpos dev
    ```
1. Use one of the available pumptools configuration files from `cfg/piu/pumptools` or
[create a custom one](doc/conf-pumptools.md).
    1. For running on cabinets with real IO support, use `cfg/piu/pumptools/cabinet.cfg`.
    1. For running on desktops with keyboard support, use `cfg/piu/pumptools/desktop.cfg`.
1. Configure pumptools of the deployed games by using the `conf-piu-pumptools`
command. You can either batch configure all games:
```bash
./pumpos.sh conf-piu-pumptools /mnt/pumpos/pumpos /path/to/pumptools.cfg
```
or configure just a single game
```bash
./pumpos.sh conf-piu-pumptools /mnt/pumpos/pumpos /path/to/pumptools.cfg 01_1st
```
1. If you want to use pumpnet, modify the `cfg/piu/pumptools/network.conf` file
by setting your machine ID and the pumpnet URL. Execute another `conf-piu-pumptools`
command to apply the changes to the games in the list:
```bash
`/pumpos.sh conf-piu-pumptools /mnt/pumpos/pumpos ./cfg/piu/pumptools/pumptools-network.conf
```

##### Wrapping things up
1. Unmount: `umount /mnt/pumpos` 
1. Disconnect the disk attached to your host.
1. Connect the disk back to your target hardware.
1. Boot the target hardware and it should start the configured game.

#### Use pipelines for batching steps
The following assumes that you are familiar with how the different pumpos scripts work to reduce
the effort of typing in many commands.

Pipelines are just shell scripts combining multiple steps for either a (repetitive) standard
deployment, e.g. PIU multi disk for arcade cabinet use.

##### Pump It Up
* `pipeline/piu/deploy.sh`: Execute a full deployment on an empty pumpos disk (fresh OS install).
A configuration file defines various variables/paths required. See
`cfg/piu/pipeline/deploy-piu.cfg`. Adjust the paths as needed pointing to the required data for
deployment.
* `pipeline/piu/conf.sh`: Execute configuration after the deployment. A configuration file defines
various variables. See `cfg/piu/pipeline/conf-piu-cabinet.cfg`

Run the pipeline deployment:
```bash
./pumpos.sh pipeline-piu-deploy ./cfg/piu/pipeline/deploy-piu.cfg
```

Configure the deployment:
```bash
./pumpos.sh pipeline-piu-conf ./cfg/piu/pipeline/conf-piu.cfg
```

Check the `pipeline/piu/conf.sh` file for the configuration steps applied and tweak the involved
configuration files accordingly, e.g. `./cfg/piu/pipeline/conf-piu.cfg` bemanitools config file etc.

##### In The Groove
Same as the PIU scripts in the above section applies here.

Run the pipeline deployment:
```bash
./pumpos.sh pipeline-itg-deploy ./cfg/itg/pipeline/deploy-itg.cfg
```

Configure the deployment:
```bash
./pumpos.sh pipeline-itg-conf ./cfg/itg/pipeline/conf-itg.cfg
```

### Use scripts to deploy data and configure local setups on a host
For development and testing, you can also use the scripts to deploy/update data
on the same host machine. Instead of specifying paths to a mounted disk on the
commands `deploy-dir`, `deploy-piu-data`, `deploy-piu-pumptools` and `conf-piu-pumptools`,
just set it to a local folder. Any other commands are not required for such a
setup and can be ignored.

### PIU: Backup save folders before full re-deployment
If you want to fully re-deploy to your existing disk which includes a fresh installation of the
base OS, you can let the pumpos scripts backup your save folders which includes operator settings,
local high scores and more.

Make sure your drive is connected and mounted on your local machine.

```shell script
./pumpos.sh deploy-piu-backup-save /mnt/pumpos/pumpos
```

Running the above command creates zip files of all save folders and backs them up to the folder
`backup/piu/save` of the local pumpos project.

You can restore the backup once you have re-deployed everything with the following command:

```shell script
./pumpos.sh deploy-piu-save /mnt/pumpos/pumpos
```

### Enable caching layer for apt packages
If you have to install pumpos multiple times, e.g. developing, testing or debugging, it is highly
recommended to start the `apt-cache` docker container provided with pumpos. This container runs
locally on your host workstation and serves all packages to download as a proxy from your local
network which speeds up installation and build times of pumpos images a lot.

To enable this caching layer:
1. Go to the infrastructure sub-folder: `cd infrastructure`
1. Build the `apt-cache` container image: `make build-apt-cache`
1. Run the container: `make start-apt-cache`
1. When finished, you can stop the container again: `make stop-apt-cache`
1. If there are any issues, you can take a look at the logs which should show you some activity when
having to fetch the packages from the actual remote repository to cache them: `make logs-apt-cache`

Now, you have to provide the proxy's address as an apt host to the pumpos installation
configuration. Make sure to provide it when running `./pumpos.sh os-config` as well as entering a
valid mirror (suggestions are already given during the configuration phase).

The resulting `pumpos.cfg` should look similar to the following example:
```bash
PUMPOS_CONFIG_HOSTNAME=piu
PUMPOS_CONFIG_USERNAME=piu
PUMPOS_CONFIG_PASSWORD=piu
PUMPOS_CONFIG_GPU_DRIVER=nvidia
PUMPOS_CONFIG_PACKAGES=piu
PUMPOS_CONFIG_APT_HOST=http://<some ip v4 address>:3142
PUMPOS_CONFIG_APT_MIRROR=eu.archive.ubuntu.com/ubuntu/
```

## License
Source code license is the Unlicense; you are permitted to do with this as thou
wilt. For details, please refer to the [LICENSE file](LICENSE) included with the
source code.