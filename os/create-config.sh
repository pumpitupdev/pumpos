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
    echo "Please enter a username (leave empty for 'pumpos' default):"
    echo -n "> "
    read -r config_username

    if [ ! "$config_username" ]; then
        config_username="pumpos"
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

packages()
{
    while [ ! "$config_packages" ]; do
        echo "Please select a package list file with software to install (apt-packages path):"
        echo "piu"

        echo -n "> "
        read -r config_packages

        case "$config_packages" in
            "piu")
                ;;
            *)
                echo "Invalid package list selected."
                config_packages=""
                ;;
        esac
    done
}

apt_mirror()
{
    echo "Optional: Please enter an apt host, e.g. a local cache (leave empty to skip)"
    echo -n "> "
    read -r config_apt_host

    if [ "$config_apt_host" ]; then
        echo "Please enter a mirror URL that gets appeneded to the host, e.g. eu.archive.ubuntu.com/ubuntu/ or us.archive.ubuntu.com/ubuntu/"
        echo -n "> "
        read -r config_apt_mirror
    fi
}

print_summary()
{
    echo "Summary configuration:"
    echo "hostname: $config_hostname"
    echo "username: $config_username"
    echo "password: ***HIDDEN***"
    echo "gpu driver: $config_gpu_driver"
    echo "packages: $config_packages"
    echo "apt host (optional): $config_apt_host"
    echo "apt mirror (optional): $config_apt_mirror"
}

write_to_config_file()
{
    local out_file="$1"

    {
        echo "PUMPOS_CONFIG_HOSTNAME=$config_hostname"
        echo "PUMPOS_CONFIG_USERNAME=$config_username"
        echo "PUMPOS_CONFIG_PASSWORD=$config_password"
        echo "PUMPOS_CONFIG_GPU_DRIVER=$config_gpu_driver"
        echo "PUMPOS_CONFIG_PACKAGES=$config_packages"
        echo "PUMPOS_CONFIG_APT_HOST=$config_apt_host"
        echo "PUMPOS_CONFIG_APT_MIRROR=$config_apt_mirror"
    } > "$out_file"

    echo "Config written to file $out_file"
}

####################
# Main entry point #
####################

if [ ! "$1" ]; then
    echo "Pump OS Configuration Creator"
    echo "Usage: os-config <path to output file to save config to>"
    exit 1
fi

hostname
username
password
gpu_driver
packages
apt_mirror

print_summary
write_to_config_file "$1"