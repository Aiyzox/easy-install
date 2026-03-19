#!/bin/bash

# Module Apache + PHP

installApachePhp() {
    echo "Installation de PHP pour Apache2..."
    apt-get install -y php libapache2-mod-php
    success "PHP installé avec succès pour Apache2."
    echo "Redémarrage du service Apache2 pour prendre en compte PHP..."
    systemctl restart apache2
}

# Check if apache2 and php are installed, install if needed
apache_php_provision() {
    if (! dpkg -s apache2 >/dev/null 2>&1); then
        # Source apache module first
        source "$(dirname "$0")/apache.sh"
        installApache
    fi
    if (! dpkg -s php >/dev/null 2>&1); then
        aptUpdate
        installApachePhp
    fi
    success "Apache2 et PHP sont installés."
}
