#!/bin/bash

# System update
system_update() {
    echo "Full system update:"
    sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
    echo "System update finnished"
}

# Install tools
install_tools() {
    echo "Installing tools:"
    sudo apt install xsel gobuster cyberchef seclists
    echo "Tools installed"
}

# SSH key re-generation
ssh-key-reconf() {
    echo "SSH keys reconfiguration"
    sudo mkdir /etc/ssh/old_keys
    sudo mv /etc/ssh/ssh_host_* /etc/ssh/old_keys
    sudo dpkg-reconfigure openssh-server
    # add checks in future
    # sudo md5sum /etc/ssh/old_keys/ssh_host_*
    # sudo md5sum /etc/ssh/ssh_host_*
    echo "SSH keys reconfiguration done"
}


