#!/bin/bash

# Module SSH

installSsh() {
    echo "Installation de OpenSSH Server..."
    aptUpdate
    apt-get install -y openssh-server
    success "OpenSSH Server installé avec succès."
    echo "Activation et démarrage du service OpenSSH..."
    systemctl enable --now ssh
}

# Check if openssh-server is installed and install if needed
ssh_provision() {
    if ! dpkg -s openssh-server >/dev/null 2>&1; then
        installSsh
    else
        info "OpenSSH Server est déjà installé."
    fi
}
