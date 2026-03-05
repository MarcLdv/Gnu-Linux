#!/bin/bash

# Chargement des variables d'environnement
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.env"

MYSQL_OPTS="-h$DB_HOST -u$DB_USER"
[ -n "$DB_PASSWORD" ] && MYSQL_OPTS="$MYSQL_OPTS -p$DB_PASSWORD"

# Gestion des paramètres de date
if [ $# -eq 0 ]; then
    DATE_DEBUT=$(date -d "last month" +%Y-%m-01)
    DATE_FIN=$(date -d "$(date +%Y-%m-01) -1 day" +%Y-%m-%d)
    PERIODE="Mois précédent"
    MOIS_DEBUT=$(date -d "last month" +%m)
    ANNEE_DEBUT=$(date -d "last month" +%y)
    MOIS_FIN=$(date -d "$(date +%Y-%m-01) -1 day" +%m)
    ANNEE_FIN=$(date -d "$(date +%Y-%m-01) -1 day" +%y)
elif [ $# -eq 1 ]; then
    ANNEE_MOIS=$1
    ANNEE=${ANNEE_MOIS:0:4}
    MOIS=${ANNEE_MOIS:4:2}
    DATE_DEBUT="$ANNEE-$MOIS-01"
    DATE_FIN=$(date -d "$DATE_DEBUT +1 month -1 day" +%Y-%m-%d)
    PERIODE="$MOIS/$ANNEE"
    MOIS_DEBUT=$MOIS
    ANNEE_DEBUT=${ANNEE:2:2}
    MOIS_FIN=$MOIS
    ANNEE_FIN=${ANNEE:2:2}
elif [ $# -eq 2 ]; then
    if [[ $1 =~ ^[0-9]{2}/[0-9]{2}$ ]]; then
        MOIS1=${1:0:2}
        ANNEE1="20${1:3:2}"
        DATE_DEBUT="$ANNEE1-$MOIS1-01"
        MOIS_DEBUT=$MOIS1
        ANNEE_DEBUT=${1:3:2}
    else
        DATE_DEBUT="$1-01"
        MOIS_DEBUT=$(date -d "$DATE_DEBUT" +%m)
        ANNEE_DEBUT=$(date -d "$DATE_DEBUT" +%y)
    fi
    
    if [[ $2 =~ ^[0-9]{2}/[0-9]{2}$ ]]; then
        MOIS2=${2:0:2}
        ANNEE2="20${2:3:2}"
        DATE_FIN=$(date -d "$ANNEE2-$MOIS2-01 +1 month -1 day" +%Y-%m-%d)
        MOIS_FIN=$MOIS2
        ANNEE_FIN=${2:3:2}
    else
        DATE_FIN=$(date -d "$2-01 +1 month -1 day" +%Y-%m-%d)
        MOIS_FIN=$(date -d "$DATE_FIN" +%m)
        ANNEE_FIN=$(date -d "$DATE_FIN" +%y)
    fi
    PERIODE="De $1 à $2"
else
    echo "Usage: $0 [DATE_DEBUT] [DATE_FIN]"
    exit 1
fi

RAPPORT_FILE="$SCRIPT_DIR/../report-${ANNEE_DEBUT}-${MOIS_DEBUT}-to-${ANNEE_FIN}-${MOIS_FIN}.txt"

echo "  RAPPORT CA TTC PAR MOIS" >> "$RAPPORT_FILE"
echo "                          " >> "$RAPPORT_FILE"
echo "Période : $PERIODE" >> "$RAPPORT_FILE"
echo "Généré le : $(date '+%d/%m/%Y %H:%M:%S')" >> "$RAPPORT_FILE"
echo "                          " >> "$RAPPORT_FILE"
echo "" >> "$RAPPORT_FILE"

REQUETE="
    SELECT 
        DATE_FORMAT(date_facture, '%Y-%m') AS mois,
        DATE_FORMAT(date_facture, '%m/%Y') AS mois_affichage,
        SUM(montant) AS ca_ttc,
        COUNT(*) AS nb_factures
    FROM (
        SELECT date_facture, montant FROM $DB_PROD.factures
        WHERE date_facture BETWEEN '$DATE_DEBUT' AND '$DATE_FIN'
        UNION ALL
        SELECT date_facture, montant FROM $DB_ARCHIVE.factures_archives
        WHERE date_facture BETWEEN '$DATE_DEBUT' AND '$DATE_FIN'
    ) AS toutes_factures
    GROUP BY mois
    ORDER BY mois;
"

echo "Mois           CA TTC (€)    Nb Factures" >> "$RAPPORT_FILE"
echo "--------------------------------------------" >> "$RAPPORT_FILE"

mysql $MYSQL_OPTS -N -e "$REQUETE" | while IFS=$'\t' read -r mois mois_affichage ca_ttc nb_factures; do
    printf "%-12s %12.2f %12d\n" "$mois_affichage" "$ca_ttc" "$nb_factures" >> "$RAPPORT_FILE"
done

TOTAL_CA=$(mysql $MYSQL_OPTS -N -e "
    SELECT SUM(montant)
    FROM (
        SELECT montant FROM $DB_PROD.factures
        WHERE date_facture BETWEEN '$DATE_DEBUT' AND '$DATE_FIN'
        UNION ALL
        SELECT montant FROM $DB_ARCHIVE.factures_archives
        WHERE date_facture BETWEEN '$DATE_DEBUT' AND '$DATE_FIN'
    ) AS toutes_factures;
")

TOTAL_FACTURES=$(mysql $MYSQL_OPTS -N -e "
    SELECT COUNT(*)
    FROM (
        SELECT 1 FROM $DB_PROD.factures
        WHERE date_facture BETWEEN '$DATE_DEBUT' AND '$DATE_FIN'
        UNION ALL
        SELECT 1 FROM $DB_ARCHIVE.factures_archives
        WHERE date_facture BETWEEN '$DATE_DEBUT' AND '$DATE_FIN'
    ) AS toutes_factures;
")

echo "--------------------------------------------" >> "$RAPPORT_FILE"
printf "%-12s %12.2f %12d\n" "TOTAL" "${TOTAL_CA:-0}" "${TOTAL_FACTURES:-0}" >> "$RAPPORT_FILE"
echo "" >> "$RAPPORT_FILE"
echo "========================================" >> "$RAPPORT_FILE"

cat "$RAPPORT_FILE"
echo ""
echo "Rapport sauvegardé : $RAPPORT_FILE"