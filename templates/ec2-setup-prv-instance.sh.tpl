#!/usr/bin/env bash

# configure non-interactive apt
export DEBIAN_FRONTEND=noninteractive

# set the hostname
hostnamectl set-hostname ${server_name}

# flag that we're ready
touch ~ubuntu/READY
chown ubuntu.ubuntu ~ubuntu/READY

