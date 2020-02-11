# Pumpos: Install a Linux based operating system for use with Pump It Up games
**Disclaimer**
Some of the scripts require root previliges and can dangerous when not used
correctly. You are advised to read any on-screen instructions and
readme/documentation before using them. Mistakes can be as crucial as wiping
your host machine you are running these scripts on or other kinds of data loss.

If you do not really know what you are doing, you are advised to create a
separate virtual machine and run the scripts from there instead of doing this on
your native host machine.

Running the install script and installing everything takes about 20-25 minutes
if you are not connected to the world by carrier pigeon and you do not install
this to a potato. Stick around when everything runs and does the job because
there are a few package configuration interfaces popping up that require manual
interaction, see [here](#user-prompts-during-installation).

The scripts in the sub-folder [os](../os) create a fully bootable and ready to
use Ubuntu 18.04 (LTS) disk for use with Pump It Up games. Different scripts
take care of formatting the physical disk, setting up a base system using
`debootstrap`, setting up a basic environment for chroot, chroot'ing into the
base image to create a bootable disk and execute final post installation steps
on first boot. The latter includes installing various software and dependencies
required to run the games.

Once the installation is complete, which includes the post installation on first
boot, you can SSH into your remote box by using the hostname and credentials
you set for the installation configuration. Be aware that SSH is set up with
password authentication by default which is ok for home setups but not a good
idea on public/non private networks. In that case, you should edit the
configuration and switch to public key authentication.

## Why aren't you providing a pre-built image which is ready to go?
There are quite a few drawbacks if it comes to preservation and customization:
* Pre-built images are static and cannot be easily post configured
* Static images are fixed to one version of the kernel and software. Constant
updating is difficult as it requires re-distributing a full image. When time
moves on the static image ages when not being maintained/updated by the user.
* These scripts build an image from currently up-to-date packages every time you
run it.
* The whole process is properly documented allowing anyone to extend, customize
and update it.
* Still an option for yourself: Build once, back it up (no pun intended) and
re-use it if you don't care about the above stuff.

Naturally, there also some drawbacks regarding incompatibilities due to updates
which can also be annoying. But better maintainability and flexibility
outweighed them...and you can still go for a static build and never update if
that's your desire.

## User prompts during installation
### Configure console-setup
This package configuration menu pops up during the `debootstrap` phase and you
have to select a character set to support for the console. Otherwise, the
installation process does not continue.

### Select a drive to install the bootloader on
During installation of the Linux kernel, which appears in the chroot
installation phase, you are prompted to select a drive to install the grub
bootloader on. Make sure to select the same drive you have chosen when starting
the installation process, e.g. if that was `sdd`, you have to pick `/dev/sdd`
from the list of options.

## All installation steps completed, what now?
You successfully completed the last post installation step on your target
hardware, the system reboots and you are "stuck" on a screen just showing some
log output by systemd and some other output. But, no login shell.

Now it's time to deploy some data and configure the system to run a game.
These steps are covered by additional deployment scripts and explained in the
main readme.

You can also connect the drive back to your host and set up everything manually.
Which application/game to start on boot is controlled by the script
`/piu/boot.sh`.

## FAQ
## What do I do when I encounter any errors during any of the installation steps?
Depending on when the error happened, you might not be able to recover from it
easily and better just start from scratch. However, you should checkout what
went wrong and try to fix it/ask for help since just restarting the process 
without changing anything might not change the outcome.

## Debootstrap fails with errors about keyring file not available
If you see this message during the `debootstrap` phase:
```
I: Keyring file not available at /usr/share/keyrings/ubuntu-archive-keyring.gpg; switching to https mirror https://deb.debian.org/debian
I: Retrieving InRelease 
I: Retrieving Release 
E: Failed getting release file https://deb.debian.org/debian/dists/bionic/Release
```

You need to install the ubuntu keyring, e.g. on Arch Linux that's the
`ubuntu-keyring` package.

## Errors about the drive being in use when formatting it
Ensure that you do not have the drive you want to use mounted anywhere. Use
the `mount` command to check that and unmount any mounted locations of the
drive.

## The disk finished installation on the host but does not boot on the target system, e.g. black screen, stuck etc.
Well, you have to debug this and get some output. If you do not see any output
during boot, you have to change some boot parameters. To get the grub boot menu
on start, you have to hold down the left shift key. Once the menu appears,
select the first entry which should say something like "Ubuntu" and press the
'e' key. This brings up an editor where you change the kernel boot parameters
(close to the bottom) from `quiet splash` to `debug nosplash`. Hit ctrl + x to
boot with the new parameters. You should get a bunch of output during the boot
process now. Check for any messages about errors, stuff missing etc.

To make this more comfortable, you can also boot the physical disk attached to
your host machine using qemu, e.g. `./pumpos.sh os-qemu-boot sdd` if your
attached drive shows up as `sdd`.