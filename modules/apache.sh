#!/bin/bash

# Module Apache2

installApache() {
    echo "Installation de Apache2..."
    aptUpdate
    apt-get install -y apache2
    success "Apache2 installé avec succès."
    echo "Activation et démarrage du service Apache2..."
    systemctl enable --now apache2
}

# Check if apache2 is installed and install if needed
apache_provision() {
    if ! dpkg -s apache2 >/dev/null 2>&1; then
        installApache
    else
        info "Apache2 est déjà installé."
    fi
}
