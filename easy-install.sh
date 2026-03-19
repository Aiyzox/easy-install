#!/bin/bash

# Script d'installation modulaire avec chargement dynamique
# Charge uniquement le module demandé pour optimiser les performances

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# Source common functions
source "$SCRIPT_DIR/common.sh"

# Vérification des privilèges root
if [[ "$(id -u)" -ne 0 ]]; then
    warn "This script must be run as root"
    exit 1
else
    info "Root privilege: OK"
fi

# Vérification du module demandé
if [[ -z "$1" ]]; then
    echo "Usage : $0 {module_name}"
    echo "Modules disponibles :"
    ls -1 "$MODULES_DIR"/*.sh | xargs -n1 basename | sed 's/\.sh$//'
    exit 1
fi

MODULE_NAME="$1"
MODULE_FILE="$MODULES_DIR/$MODULE_NAME.sh"

# Vérifier que le module existe
if [[ ! -f "$MODULE_FILE" ]]; then
    error "Module non trouvé : $MODULE_NAME"
    exit 1
fi

# Charger et exécuter le module
source "$MODULE_FILE"

# Exécuter la fonction de provision du module
PROVISION_FUNC="${MODULE_NAME//-/_}_provision"

if [[ $(type -t "$PROVISION_FUNC") == function ]]; then
    $PROVISION_FUNC
else
    error "Fonction $PROVISION_FUNC non trouvée dans le module $MODULE_NAME"
    exit 1
fi