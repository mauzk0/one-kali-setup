#!/bin/bash

# System update
system_update() {
    echo "Full system update:"
    sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
    sudo timedatectl set-timezone Europe/Prague
    echo "System update finnished"
}

# Install tools
install_default() {
    echo "Installing default apps:"
    sudo apt install -y \
        realtek-rtl88xxau-dkms \
        autoconf \
        automake \
        neofetch \
        golang \
	jython \
	maven \
        powershell \
        xclip \
	remmina
    mkdir ~/Git
# Add path for Go binaries
    cat profile_additions.txt >> $HOME/.profile
    echo "Default apps installed"
}

# Install tools and DBs
install_tools() {
    echo "Installing tools and repos:"
    sudo apt install -y \
        seclists
    # Install golang packages
    go install github.com/projectdiscovery/cvemap/cmd/cvemap@latest
    # Git tools and packages
    git clone https://github.com/projectdiscovery/nuclei-templates.git $HOME/Git/nuclei-templates
    git clone https://github.com/peass-ng/PEASS-ng.git $HOME/Git/PEAS-ng
    echo "Tools installed"
    # Tools adjustments and preparations
    sudo msfdb init
}

# Install network tools
install_tools_network() {
    echo "Installing network tools:"
    sudo apt install -y \
        yersinia \
        zaproxy \
        nuclei \
        naabu \
        bettercap \
        sipvicious \
	ssh-audit \
        freeradius
}

# Install wireless tools
install_tools_wireless() {
    echo "Installing wireless tools:"
    sudo apt install -y \
        eaphammer \
        horst \
        asleap \
        hostapd-mana \
	gpsd-clients \
	gpsd-tools \
	gpsd
    git clone https://github.com/Kismon/kismon.git $HOME/Git/kismon
# Add kali user to Kismet group
    sudo usermod -aG kismet kali
}

# Install web tools
install_tools_web() {
    echo "Installing web tools:"
    sudo apt install -y \
        gobuster \
        cyberchef \
        seclists \
        subfinder \
        httpx-toolkit \
        beef-xss
# Install Katana crawler
    go install github.com/projectdiscovery/katana/cmd/katana@latest
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
    echo "setup remote access with firewall"
    sudo apt install -y \
        xrdp \
        ufw \
        fail2ban
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
    echo "firewall and remote access installed and configured"
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
    sudo apt clean -y && sudo apt autoclean -y && sudo apt autoremove -y && sudo apt update -y
    sudo apt install -y code # or code-insiders
    # Set vscode as default editor
    sudo update-alternatives --set editor /usr/bin/code
    echo "VSCode installed"
}

# Install Nessus
nessus_install() {
    echo "Installing Nessus"
    nessus_latest_deb=$(curl -s https://www.tenable.com/downloads/api/v1/public/pages/nessus | grep -Po 'Nessus-\d+\.\d+\.\d+-debian10_amd64\.deb' | head -n 1)
    sudo curl -o /tmp/$nessus_latest_deb --request GET https://www.tenable.com/downloads/api/v2/pages/nessus/files/$nessus_latest_deb
    sudo dpkg -i /tmp/$nessus_latest_deb
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
    sudo apt clean -y && sudo apt autoclean -y && sudo apt autoremove -y
}

# Script execution
echo "Starting additional Kali tools installation and configuration"
system_update
install_default
install_tools
install_tools_network
install_tools_wireless
install_tools_web
ssh-key-reconf
remote_access
vscode_install
nessus_install
zshrc_additions
tmux_config
clean
echo "Script finished"
