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
    sudo apt install zaproxy gobuster cyberchef seclists horst
    echo "Tools installed"
}

# SSH key re-generation
ssh-key-reconf() {
    echo "SSH keys reconfiguration"
    sudo mkdir /etc/ssh/old_keys
    sudo mv /etc/ssh/ssh_host_* /etc/ssh/old_keys
    sudo dpkg-reconfigure openssh-server
    # add checksum checks in future
    # sudo md5sum /etc/ssh/old_keys/ssh_host_*
    # sudo md5sum /etc/ssh/ssh_host_*
    echo "SSH keys reconfiguration done"
}

# Install VSCode
vscode_install() {
    echo "VSCode installation"
    # MS apt repository and key manual installation
    sudo apt install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    # Update the package cache and install the package using
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code # or code-insiders
    # Set vscode as default editor
    sudo update-alternatives --set editor /usr/bin/code
    echo "VSCode installed"
}

# .zshrc additions
zshrc_additions() {
    echo ".zshrc file additions"
    cat zshrc_additions.txt >> ~/.zshrc
    echo ".zshrc additions complete"
}

# tmux configuration
tmux_config() {
    echo "tmux configuration"
    sudo apt install xsel
    git clone https://github.com/mauzk0/one-tmux-conf.git ~/Downloads/Git/one-tmux-conf
    cp ~/Downloads/Git/one-tmux-conf/.tmux.conf ~/
    echo "tmux configuration ready"
}

# Script execution
echo "Starting additional Kali tools installation and configuration"
system_update
install_tools
ssh-key-reconf
vscode_install
zshrc_additions
tmux_config
echo "Script finished"
