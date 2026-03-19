#!/bin/bash

# Module GLPI

installGlpi() {
    echo "Installation des dépendances pour GLPI..."
    aptUpdate
    apt install apache2 php8.4-fpm mariadb-server -y
    apt install php8.4-{curl,gd,intl,mysql,zip,bcmath,mbstring,xml,bz2,ldap} -y
    systemctl enable --now apache2 mariadb
    echo "Configuration de PHP8.4-FPM avec Apache2..."
    a2enmod proxy_fcgi setenvif
    a2enconf php8.4-fpm
    sed -i 's/^;session.cookie_httponly = .*/session.cookie_httponly = on/' /etc/php/8.4/fpm/php.ini
    sed -i 's/^;session.cookie_samesite = .*/session.cookie_samesite = Lax/' /etc/php/8.4/fpm/php.ini
    systemctl restart php8.4-fpm.service apache2
    echo "Configuration de la base de données pour GLPI..."
    sleep 1
    mariaDBRootPassword=$(openssl rand -base64 12)
    mariaDBGlpiPassword=$(openssl rand -base64 12)
    # Set the root password (MariaDB 10.4+ syntax)
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$mariaDBRootPassword';"
    # Remove anonymous user accounts
    mysql -u root -p"$mariaDBRootPassword" -e "DELETE FROM mysql.user WHERE User = ''"
    # Disable remote root login
    mysql -u root -p"$mariaDBRootPassword" -e "DELETE FROM mysql.user WHERE User = 'root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
    # Remove the test database (ignore error if it doesn't exist)
    mysql -u root -p"$mariaDBRootPassword" -e "DROP DATABASE IF EXISTS test"
    # Reload privileges
    mysql -u root -p"$mariaDBRootPassword" -e "FLUSH PRIVILEGES"
    # Create a new database
    mysql -u root -p"$mariaDBRootPassword" -e "CREATE DATABASE IF NOT EXISTS glpi"
    # Create a new user
    mysql -u root -p"$mariaDBRootPassword" -e "CREATE USER IF NOT EXISTS 'glpi_user'@'localhost' IDENTIFIED BY '$mariaDBGlpiPassword'"
    # Grant privileges to the new user for the new database
    mysql -u root -p"$mariaDBRootPassword" -e "GRANT ALL PRIVILEGES ON glpi.* TO 'glpi_user'@'localhost'"
    # Reload privileges
    mysql -u root -p"$mariaDBRootPassword" -e "FLUSH PRIVILEGES"
    echo "Téléchargement et installation de GLPI..."
    apt install -y wget tar jq curl
    glpiDownloadLink=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | jq -r '.assets[0].browser_download_url')
    wget -O /tmp/glpi-latest.tgz "$glpiDownloadLink"
    tar -xvzf /tmp/glpi-latest.tgz -C /var/www
    chown -R www-data:www-data /var/www/glpi
    chmod -R 775 /var/www/glpi
    cat > /etc/apache2/sites-available/000-default.conf <<EOL
    <VirtualHost *:80>
        DocumentRoot /var/www/glpi/public
        <Directory /var/www/glpi/public>
            Require all granted
            RewriteEngine On
            RewriteCond %{HTTP:Authorization} ^(.+)$
            RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule ^(.*)$ index.php [QSA,L]
        </Directory>
    </VirtualHost>
EOL
    a2enmod rewrite && systemctl restart apache2
    success "GLPI installé avec succès."
    echo "Configuration de GLPI"
    cd /var/www/glpi
    #php bin/console db:install --db-name=glpi --db-user=glpi_user --db-password=$mariaDBGlpiPassword --allow-superuser --no-interaction
    #rm -rf /var/www/glpi/install
    systemctl reload apache2
    echo "Installation de GLPI terminée. Veuillez noter les informations suivantes :"
    echo "========================================="
    echo "Accès à GLPI : http://<votre_ip>/"
    echo "Utilisateur administrateur par défaut : glpi"
    echo "Mot de passe administrateur par défaut : glpi"
    echo "Mot de passe root MariaDB : $mariaDBRootPassword"
    echo "========================================="
    echo "Informations de la base de données GLPI :"
    echo "Adresse du serveur MariaDB : localhost"
    echo "Nom de la base de données GLPI : glpi"
    echo "Utilisateur MariaDB pour GLPI : glpi_user"
    echo "Mot de passe MariaDB pour l'utilisateur GLPI : $mariaDBGlpiPassword"
    echo "========================================="
}

# Provision GLPI
glpi_provision() {
    echo "Ce script va installer GLPI et ses dépendances. Voulez-vous continuer ? (Y/N)"
    read -r response
    if [ "$response" != "Y" ]; then
        info "Installation de GLPI annulée."
        exit 0
    fi
    installGlpi
}
