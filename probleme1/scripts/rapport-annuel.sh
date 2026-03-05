#!/bin/bash

# Script de génération du rapport annuel de chiffre d'affaires
# Utilise generation-rapport.sh avec un argument (Année)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/generation-rapport.sh" "$1"
