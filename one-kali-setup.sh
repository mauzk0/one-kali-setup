#!/bin/bash

# System update
system_update() {
    echo "Full system update:"
    sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
    sudo timedatectl set-timezone Europe/Prague
    echo "System update finnished"
}

# Install tools
install_tools() {
    echo "Installing tools:"
    sudo apt install -y \
        realtek-rtl88xxau-dkms \
        autoconf \
        automake \
        ufw \
        yersinia \
        neofetch \
        fail2ban \
        zaproxy \
        gobuster \
        cyberchef \
        seclists \
        horst \
        nuclei \
        subfinder \
        httpx-toolkit \
        naabu \
        bettercap \
        beef-xss \
        golang \
        powershell \
	sipvicious
    # Install golang packages
    go install github.com/projectdiscovery/cvemap/cmd/cvemap@latest
    go install github.com/projectdiscovery/katana/cmd/katana@latest
    # Add path for Go binaries
    export PATH=$PATH:/home/kali/go/bin
    # Git tools and packages
    mkdir ~/Git
    git clone https://github.com/projectdiscovery/nuclei-templates.git ~/Git/nuclei-templates
    git clone https://github.com/peass-ng/PEASS-ng.git ~/Git/PEAS-ng.git
    echo "Tools installed"
    # Tools adjustments and preparations
    sudo msfdb init
    sudo usermod -aG kismet kali
    # add Burp Suite Pro in future?
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

# SSH, RDP and Fail2Ban
remote_access() {
    sudo apt install -y \
        xrdp \
        ufw
    sudo systemctl enable ssh
    sudo systemctl start ssh
    sudo systemctl enable xrdp
    sudo systemctl start xrdp
    # Instalation and setting up Fail2Ban
    sudo apt install fail2ban
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    # add ufw with allowed SSH access
    sudo ufw default allow incoming
    sudo ufw default allow outgoing
    sudo ufw deny 8834
    sudo ufw allow OpenSSH # just sanity check if someone would change default incoming
    sudo ufw enable
}

# Install VSCode
vscode_install() {
    echo "VSCode installation"
    # MS apt repository and key manual installation
    sudo apt install -y \
        wget \
        gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    # Update the package cache and install the package using
    sudo apt install -y \
        apt-transport-https
    sudo apt clean && sudo apt autoclean && sudo apt autoremove && sudo apt update
    sudo apt install -y code # or code-insiders
    # Set vscode as default editor
    sudo update-alternatives --set editor /usr/bin/code
    echo "VSCode installed"
}

# Install Nessus
nessus_install() {
    echo "Installing Nessus"
    nessus_latest_deb=$(curl -s https://www.tenable.com/downloads/api/v1/public/pages/nessus | grep -Po 'Nessus-\d+\.\d+\.\d+-debian10_amd64\.deb' | head -n 1)
    sudo curl -o ~/tmp/$nessus_latest_deb --request GET https://www.tenable.com/downloads/api/v2/pages/nessus/files/$nessus_latest_deb
    sudo dpkg -i ~/tmp/$nessus_latest_deb
    sudo systemctl enable nessusd
    sudo systemctl start nessusd
    echo "Nessus Installed"
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
    sudo apt install -y xsel
    git clone https://github.com/mauzk0/one-tmux-conf.git ~/Git/one-tmux-conf
    ln -s ~/Git/one-tmux-conf/.tmux.conf ~/.tmux.conf
    echo "tmux configuration ready"
}

# clean
clean() {
    sudo apt clean && sudo apt autoclean && sudo apt autoremove
}

# Script execution
echo "Starting additional Kali tools installation and configuration"
system_update
install_tools
ssh-key-reconf
remote_access
vscode_install
nessus_install
zshrc_additions
tmux_config
clean
echo "Script finished"
