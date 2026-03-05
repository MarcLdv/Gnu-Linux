#!/bin/bash

# Chargement config et env
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.env"

# Options MYSQL et date d'archivage
MYSQL_OPTS="-h$DB_HOST -u$DB_USER -p$DB_PASSWORD"
DATE_ARCHIVE=$(date +%Y-%m-%d)

echo "Début archivage"

# Recherche clients inactifs (plus de 3 ans inactif ou sans factures)
CLIENTS_INACTIFS=$(mysql $MYSQL_OPTS -D$DB_PROD -N -e "
    SELECT DISTINCT c.id 
    FROM clients c
    LEFT JOIN factures f ON c.id = f.client_id
    GROUP BY c.id
    HAVING MAX(f.date_facture) < DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    OR MAX(f.date_facture) IS NULL;
")

if [ -n "$CLIENTS_INACTIFS" ]; then
    for CLIENT_ID in $CLIENTS_INACTIFS; do
        # Génère un ID anonymisé
        ANO_ID=$(uuidgen)
        
        # Archive le client
        mysql $MYSQL_OPTS -D$DB_ARCHIVE -e "
            INSERT INTO clients_archives (id, ano_id, date_archivage) 
            VALUES ($CLIENT_ID, '$ANO_ID', '$DATE_ARCHIVE');
        "
        
        # Archive ses factures
        mysql $MYSQL_OPTS -e "
            INSERT INTO $DB_ARCHIVE.factures_archives (id, ano_id, montant, date_facture, date_archivage)
            SELECT id, '$ANO_ID', montant, date_facture, '$DATE_ARCHIVE'
            FROM $DB_PROD.factures
            WHERE client_id = $CLIENT_ID;
        "
        
        # Supprime de la base prod 
        mysql $MYSQL_OPTS -D$DB_PROD -e "DELETE FROM factures WHERE client_id = $CLIENT_ID;"
        mysql $MYSQL_OPTS -D$DB_PROD -e "DELETE FROM clients WHERE id = $CLIENT_ID;"
    done
fi

# Recherche des factures de plus de 10 ans
FACTURES_ANCIENNES=$(mysql $MYSQL_OPTS -D$DB_PROD -N -e "
    SELECT f.id, f.client_id, f.montant, f.date_facture
    FROM factures f
    WHERE f.date_facture < DATE_SUB(CURDATE(), INTERVAL 10 YEAR);
")

if [ -n "$FACTURES_ANCIENNES" ]; then
    while read -r FACTURE_ID CLIENT_ID MONTANT DATE_FACTURE; do

        # Récupère ou crée l'ID anonymisé du client
        ANO_ID=$(mysql $MYSQL_OPTS -D$DB_ARCHIVE -N -e "
            SELECT ano_id FROM clients_archives WHERE id = $CLIENT_ID LIMIT 1;
        ")
        
        if [ -z "$ANO_ID" ]; then
            ANO_ID=$(uuidgen)
            mysql $MYSQL_OPTS -D$DB_ARCHIVE -e "
                INSERT INTO clients_archives (id, ano_id, date_archivage) 
                VALUES ($CLIENT_ID, '$ANO_ID', '$DATE_ARCHIVE');
            "
        fi
        
        # Archive la facture et supprime de la production
        mysql $MYSQL_OPTS -D$DB_ARCHIVE -e "
            INSERT INTO factures_archives (id, ano_id, montant, date_facture, date_archivage)
            VALUES ($FACTURE_ID, '$ANO_ID', $MONTANT, '$DATE_FACTURE', '$DATE_ARCHIVE');
        "
        mysql $MYSQL_OPTS -D$DB_PROD -e "DELETE FROM factures WHERE id = $FACTURE_ID;"
    done
fi

echo "Archivage terminé"