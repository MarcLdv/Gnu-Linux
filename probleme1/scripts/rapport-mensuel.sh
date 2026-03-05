#!/bin/bash

# Script de génération du rapport mensuel de chiffre d'affaires
# Appelle generation-rapport.sh sans argument
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/generation-rapport.sh"
