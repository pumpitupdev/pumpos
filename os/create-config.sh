#!/usr/bin/env bash

hostname()
{
    echo "Please enter a hostname (leave empty for 'pumpos' default):"
    echo -n "> "
    read -r config_hostname

    if [ ! "$config_hostname" ]; then
        config_hostname="pumpos"
    fi
}

username()
{
    echo "Please enter a username (leave empty for 'piu' default):"
    echo -n "> "
    read -r config_username

    if [ ! "$config_username" ]; then
        config_username="piu"
    fi
}

password()
{
    config_password2=" "

    while [ "$config_password" != "$config_password2" ]; do
        echo "Please enter a password for user '$config_username':"

        while [ ! "$config_password" ]; do
            echo -n "> "
            read -r config_password

            if [ ! "$config_password" ]; then
                echo "Empty passwords not allowed, please enter a password for user '$config_username':"
            fi
        done

        echo "Please re-enter the same password:"

        echo -n "> "
        read -r config_password2

        if [ "$config_password" != "$config_password2" ]; then
            echo "Passwords do not match."
        fi
    done
}

gpu_driver()
{
    while [ ! "$config_gpu_driver" ]; do
        echo "Please select a GPU driver for the target hardware from the list:"
        echo "nvidia"

        echo -n "> "
        read -r config_gpu_driver

        case "$config_gpu_driver" in
            "nvidia")
                ;;
            *)
                echo "Invalid driver selected."
                config_gpu_driver=""
                ;;
        esac
    done
}

print_summary()
{
    echo "Summary configuration:"
    echo "hostname: $config_hostname"
    echo "username: $config_username"
    echo "password: ***HIDDEN***"
    echo "gpu driver: $config_gpu_driver"
}

write_to_config_file()
{
    local out_file="$1"

    {
        echo "$config_hostname"
        echo "$config_username"
        echo "$config_password"
        echo "config_gpu_driver"
    } > "$out_file"

    echo "Config written to file $out_file"
}

####################
# Main entry point #
####################

if [ ! "$1" ]; then
    echo "Pumpt It Up OS Configuration Creator"
    echo "Usage: os-config <path to output file to save config to>"
    exit 1
fi

hostname
username
password
gpu_driver

print_summary
write_to_config_file "$1"