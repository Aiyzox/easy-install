#!/bin/bash

# Module MariaDB

installMariaDB() {
    echo "Installation de MariaDB Server..."
    aptUpdate
    apt-get install -y mariadb-server
    success "MariaDB Server installé avec succès."
    echo "Activation et démarrage du service MariaDB..."
    systemctl enable --now mariadb
}

# Check if mariadb-server is installed and install if needed
mariadb_provision() {
    if ! dpkg -s mariadb-server >/dev/null 2>&1; then
        installMariaDB
    else
        info "MariaDB Server est déjà installé."
    fi
}
