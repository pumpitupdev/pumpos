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
        
    deploy-dir)
        "$ROOT_PATH/deploy/dir.sh" "${@:2}"
        ;;

    deploy-sgl)
        "$ROOT_PATH/deploy/sgl/sgl.sh" "${@:2}"
        ;;

    deploy-piu-data)
        "$ROOT_PATH/deploy/piu/data.sh" "${@:2}"
        ;;
    deploy-piu-pumptools)
        "$ROOT_PATH/deploy/piu/pumptools.sh" "${@:2}"
        ;;
    deploy-piu-backup-save)
        "$ROOT_PATH/deploy/piu/backup-save.sh" "${@:2}"
        ;;
    deploy-piu-save)
        "$ROOT_PATH/deploy/piu/save.sh" "${@:2}"
        ;;

    conf-boot)
        "$ROOT_PATH/conf/boot.sh" "${@:2}"
        ;;
    conf-pumptools)
        "$ROOT_PATH/conf/piu/pumptools.sh" "${@:2}"
        ;;

    pipeline-piu-deploy)
        "$ROOT_PATH/pipeline/piu/deploy.sh" "${@:2}"
        ;;
    pipeline-piu-conf)
        "$ROOT_PATH/pipeline/piu/conf.sh" "${@:2}"
        ;;
        
    *)
        echo "Pump It Up OS (pumpos) build script, available options:"
        echo ""
        echo "OS install related commands"
        echo "  os-config    - Create a configuration for installing pumpos to a physical disk"
        echo "  os-install   - Install pumpos to a connected physical disk"
        echo "  os-qemu-boot - Boot physical disk with pumpos in qemu for further configuration or debugging"
        echo "  os-chroot    - Chroot into the mounted installation of pumpos for configuration or debugging"
        echo ""
        echo ""
        echo "Deploy stuff (fine granular)"
        echo "  deploy-dir - Deploy/update a directory on pumpos with a local one"
        echo ""
        echo ""
        echo "  deploy-sgl - Deploy/update SGL data from distribution package"
        echo ""
        echo "  deploy-piu-data        - Deploy/update the data of one or multiple piu games"
        echo "  deploy-piu-pumptools   - Deploy/update pumptools of one or multiple piu games"
        echo "  deploy-piu-backup-save - Backup all piu save directories on a target pumpos deployment"
        echo "  deploy-piu-save        - Deploy all backed up save directories of piu games to a target deployment"
        echo ""
        echo ""
        echo "Configure stuff"
        echo "  conf-boot - Configure what pumpos is supposed to do/run on boot"
        echo ""
        echo "  conf-piu-pumptools - Configure the hooks of the pumptools deployment of one or multiple games"
        echo ""
        echo ""
        echo "Pipelines combining many steps (coarse granular)"
        echo "  pipeline-piu-deploy - Pipeline to deploy piu games to a pumpos target"
        echo "  pipeline-piu-conf   - Pipeline to configure piu games on a pumpos target"
        echo ""
        
        exit 1
esac