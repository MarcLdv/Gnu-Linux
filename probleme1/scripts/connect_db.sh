#!/bin/bash

# Charger les variables d'environnement
source "$(dirname "$0")/.env"

# Sélection de la base
case $1 in
    archive)
        DB_NAME="$DB_ARCHIVE"
        ;;
    *)
        DB_NAME="$DB_PROD"
        ;;
esac

# Connexion
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
