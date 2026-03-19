# Easy-Install

Ce projet est un script d'installation modulaire en Bash conçu pour les systèmes Linux, permettant la configuration automatisée et la mise en place de services essentiels tels que OpenSSH, Apache2, MariaDB et GLPI. Il utilise un système de chargement dynamique pour charger uniquement les modules requis à la demande, assurant une efficacité mémoire et une évolutivité. Le script inclut des fonctions d'aide communes pour la journalisation, la gestion des erreurs et la gestion des paquets, facilitant l'ajout de nouveaux modules pour des services supplémentaires. Il est destiné aux administrateurs système cherchant une alternative légère et maintenable aux scripts d'installation monolithiques.

## Structure

```
script/
├── easy-install.sh          # Script principal - orchestrateur avec chargement dynamique
├── common.sh                # Fonctions communes (helpers, logging)
└── modules/
    ├── ssh.sh               # Module OpenSSH
    ├── apache.sh            # Module Apache2
    ├── apache-php.sh        # Module Apache2 + PHP
    ├── mariadb.sh           # Module MariaDB
    └── glpi.sh              # Module GLPI
```

## Usage

### Lister les modules disponibles

```bash
./script/easy-install.sh
```

Affiche la liste de tous les modules disponibles dans le répertoire `modules/`.

### Installation d'un module

```bash
sudo ./script/easy-install.sh ssh
sudo ./script/easy-install.sh apache
sudo ./script/easy-install.sh apache-php
sudo ./script/easy-install.sh mariadb
sudo ./script/easy-install.sh glpi
```

## Fonctionnement

Le script principal fonctionne avec un **système de chargement dynamique** :

1. **Vérification des privilèges root** - Le script doit être exécuté en tant que root
2. **Récupération du paramètre** - Le nom du module à installer
3. **Vérification du module** - Confirm que le fichier `modules/{nom}.sh` existe
4. **Chargement du module** - Source uniquement le module demandé (pas tous les modules)
5. **Conversion du nom** - Les tirets sont convertis en underscores pour l'appel de fonction
   - `apache-php` → `apache_php_provision()`
   - `mariadb` → `mariadb_provision()`
6. **Exécution** - Appelle la fonction `{module_name}_provision()` du module

### Avantages

✅ **Optimisation mémoire** - Un seul module chargé à la fois  
✅ **Pas de case statement** - Code plus maintenable et scalable  
✅ **Découverte automatique** - Les nouveaux modules sont détectés automatiquement  
✅ **Gestion d'erreurs** - Vérification que le module et sa fonction existent  

## Ajouter un nouveau module

Créer un fichier `modules/newservice.sh` avec une fonction de provision :

```bash
#!/bin/bash

# Module pour NewService
# La fonction DOIT être nommée {filename_underscore}_provision()
# Ex: pour newservice.sh → newservice_provision()

installNewService() {
    echo "Installation de NewService..."
    aptUpdate
    apt-get install -y newservice
    success "NewService installé."
    systemctl enable --now newservice
}

newservice_provision() {
    if ! dpkg -s newservice >/dev/null 2>&1; then
        installNewService
    else
        info "NewService est déjà installé."
    fi
}
```

**Important** : La fonction doit être nommée `{module_name}_provision()` (tirets remplacés par underscores).

## Fonctions communes disponibles

Les fonctions suivantes sont disponibles dans tous les modules via `common.sh` :

- `aptUpdate()` - Met à jour la liste des paquets
- `warn()` - Affiche un avertissement en rouge
- `error()` - Affiche une erreur et quitte (exit 1)
- `success()` - Affiche un message de succès
- `info()` - Affiche une information
