#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.env"

# Sélection bdd selon argument
case $1 in
    archive)
        # Base d'archive
        DB_NAME="$DB_ARCHIVE"
        ;;
    *)
        # Base de production (par défault)
        DB_NAME="$DB_PROD"
        ;;
esac

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"