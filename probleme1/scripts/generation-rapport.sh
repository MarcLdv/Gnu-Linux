#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.env"

MYSQL_OPTS="-h$DB_HOST -u$DB_USER"
[ -n "$DB_PASSWORD" ] && MYSQL_OPTS="$MYSQL_OPTS -p$DB_PASSWORD"

if [ $# -eq 0 ]; then
    # Aucun argument → Rapport du mois précédent
    DATE_DEBUT=$(date -d "last month" +%Y-%m-01)
    DATE_FIN=$(date -d "$(date +%Y-%m-01) -1 day" +%Y-%m-%d)
    MOIS_DEBUT=$(date -d "last month" +%m)
    ANNEE_DEBUT=$(date -d "last month" +%y)
    MOIS_FIN=$(date -d "$(date +%Y-%m-01) -1 day" +%m)
    ANNEE_FIN=$(date -d "$(date +%Y-%m-01) -1 day" +%y)
    PERIODE="$MOIS_DEBUT/$ANNEE_DEBUT au $MOIS_FIN/$ANNEE_FIN"

elif [ $# -eq 1 ]; then
    # Un argument → Format YYYYMM attendu
    if [[ ! $1 =~ ^[0-9]{6}$ ]]; then
        echo "Erreur: Format invalide pour l'argument"
        echo "Usage: $0 YYYYMM"
        echo "Exemple: $0 202603"
        exit 1
    fi
    
    ANNEE=${1:0:4}
    MOIS=${1:4:2}
    DATE_DEBUT="$ANNEE-$MOIS-01"
    DATE_FIN=$(date -d "$DATE_DEBUT +1 month -1 day" +%Y-%m-%d)
    MOIS_DEBUT=$MOIS
    ANNEE_DEBUT=${ANNEE:2:2}
    MOIS_FIN=$MOIS
    ANNEE_FIN=${ANNEE:2:2}
    PERIODE="$MOIS_DEBUT/$ANNEE_DEBUT au $MOIS_FIN/$ANNEE_FIN"

elif [ $# -eq 2 ]; then
    # Deux arguments → Format YYYY-MM YYYY-MM attendu
    if [[ ! $1 =~ ^[0-9]{4}-[0-9]{2}$ ]] || [[ ! $2 =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
        echo "Erreur: Format invalide pour les dates"
        echo "Usage: $0 YYYY-MM YYYY-MM"
        echo "Exemple: $0 2026-01 2026-03"
        exit 1
    fi
    
    DATE_DEBUT="$1-01"
    DATE_FIN=$(date -d "$2-01 +1 month -1 day" +%Y-%m-%d)
    MOIS_DEBUT=${1:5:2}
    ANNEE_DEBUT=${1:2:2}
    MOIS_FIN=${2:5:2}
    ANNEE_FIN=${2:2:2}
    PERIODE="$MOIS_DEBUT/$ANNEE_DEBUT au $MOIS_FIN/$ANNEE_FIN"

else
    echo "Erreur: Nombre d'arguments invalide"
    echo "Cas d'usage :"
    echo "  $0                    # Rapport du mois précédent"
    echo "  $0 YYYYMM             # Rapport d'un mois spécifique"
    echo "  $0 YYYY-MM YYYY-MM    # Rapport sur une période"
    echo ""
    exit 1
fi

# Nom du fichier de rapport basé sur la période
RAPPORT_FILE="$SCRIPT_DIR/../report-${ANNEE_DEBUT}-${MOIS_DEBUT}-to-${ANNEE_FIN}-${MOIS_FIN}.txt"

# En-tête du rapport
echo "Rapport généré le $(date '+%d/%m/%y')" > "$RAPPORT_FILE"
echo "Période : $PERIODE" >> "$RAPPORT_FILE"
echo "Mois, année, CA TTC" >> "$RAPPORT_FILE"

# Requête SQL pour récupérer le CA par mois
REQUETE="
    SELECT 
        DATE_FORMAT(date_facture, '%m') AS mois,
        DATE_FORMAT(date_facture, '%Y') AS annee,
        SUM(montant) AS ca_ttc
    FROM (
        SELECT date_facture, montant FROM $DB_PROD.factures
        WHERE date_facture BETWEEN '$DATE_DEBUT' AND '$DATE_FIN'
        UNION ALL
        SELECT date_facture, montant FROM $DB_ARCHIVE.factures_archives
        WHERE date_facture BETWEEN '$DATE_DEBUT' AND '$DATE_FIN'
    ) AS toutes_factures
    GROUP BY annee, mois
    ORDER BY annee, mois;
"

# Exécution de la requête et formatage des résultats
mysql $MYSQL_OPTS -N -e "$REQUETE" | while IFS=$'\t' read -r mois annee ca_ttc; do
    printf "%s %s %.2f\n" "$mois" "$annee" "$ca_ttc" >> "$RAPPORT_FILE"
done

# Affiche le rapport à l'écran
cat "$RAPPORT_FILE"
echo "" 
echo "Rapport sauvegardé : $RAPPORT_FILE"