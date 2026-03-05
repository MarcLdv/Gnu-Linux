#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.env"

case $1 in
    archive)
        DB_NAME="$DB_ARCHIVE"
        ;;
    *)
        DB_NAME="$DB_PROD"
        ;;
esac

if [ -n "$DB_PASSWORD" ]; then
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
else
    mysql -h "$DB_HOST" -u "$DB_USER" "$DB_NAME"
fi
