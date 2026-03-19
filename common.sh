#!/bin/bash

# Fonctions communes pour tous les modules

aptUpdate() {
    echo "Mise à jour de la liste des paquets..."
    apt-get update -y
}

warn() {
    echo "[ATTENTION] $1" >&2
}

error() {
    echo "[ERREUR] $1" >&2
    exit 1
}

success() {
    echo "[✓] $1"
}

info() {
    echo "[INFO] $1"
}
