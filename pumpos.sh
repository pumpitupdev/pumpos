#!/usr/bin/env bash

###
# Pump It Up OS (pumpos) build script.
#
# This is your entry point for creating disk images for use with Pump It Up
# games, deploy data to them and tweak configurations.
#
# Check the usage message for available commands. Call each command without
# parameters to get further usage messages about each of them.
###

# Root path of this script
readonly ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$1" in
    os-config)
        "$ROOT_PATH/os/create-config.sh" "${@:2}"
        ;;
    os-install)
        "$ROOT_PATH/os/install.sh" "${@:2}"
        ;;
    os-qemu-boot)
        "$ROOT_PATH/os/qemu-boot.sh" "${@:2}"
        ;;
    os-chroot)
        "$ROOT_PATH/os/chroot.sh" "${@:2}"
        ;;
    deploy-base)
        "$ROOT_PATH/deploy/base.sh" "${@:2}"
        ;;
    deploy-data)
        "$ROOT_PATH/deploy/data.sh" "${@:2}"
        ;;
    deploy-sgl)
        "$ROOT_PATH/deploy/sgl.sh" "${@:2}"
        ;;
    deploy-pumptools)
        "$ROOT_PATH/deploy/pumptools.sh" "${@:2}"
        ;;
    conf-pumptools)
        "$ROOT_PATH/conf/pumptools.sh" "${@:2}"
        ;;
    conf-boot)
        "$ROOT_PATH/conf/boot.sh" "${@:2}"
        ;;
    backup-save)
        "$ROOT_PATH/deploy/backup-save.sh" "${@:2}"
        ;;
    deploy-save)
        "$ROOT_PATH/deploy/save.sh" "${@:2}"
        ;;
    *)
        echo "Pump It Up OS (pumpos) build script, available options:"
        echo "  os-config: Create a configuration for installing pumpos to a physical disk."
        echo "  os-install: Install pumpos to a connected physical disk."
        echo "  os-qemu-boot: Boot physical disk with pumpos in qemu for further configuration or debugging."
        echo "  os-chroot: Chroot into the mounted installation of pumpos for configuration or debugging."
        echo "  deploy-base: Deploy/update a base directory structure to house multiple games on pumpos."
        echo "  deploy-data: Deploy/update the data of one or multiple games."
        echo "  deploy-sgl: Deploy/update data for SGL."
        echo "  deploy-pumptools: Deploy/update pumptools of one or multiple games."
        echo "  conf-pumptools: Configure the hooks of the pumptools deployment of one or multiple games."
        echo "  conf-boot: Configure what pumpos is supposed to do/run on boot."
        echo "  backup-save: Backup all save directories on a target /piu deployment."
        echo "  deploy-save: Deploy all backed up save directories to a target /piu deployment."
        exit 1
esac