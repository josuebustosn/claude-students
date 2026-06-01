#!/usr/bin/env bash
# setup_carpeta.sh
# Crea la estructura estándar Claude/ dentro de la carpeta del parcial.
#
# Uso:
#   ./setup_carpeta.sh <parcial_path>

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Uso: $0 <parcial_path>"
    exit 1
fi

PARCIAL_PATH="$1"

if [ ! -d "$PARCIAL_PATH" ]; then
    echo "ERROR: la carpeta del parcial no existe: $PARCIAL_PATH"
    exit 1
fi

CLAUDE_DIR="$PARCIAL_PATH/Claude"
SUBDIRS=("_artefactos" "_paginas" "_pdf" "_transcripcion")

for sub in "${SUBDIRS[@]}"; do
    mkdir -p "$CLAUDE_DIR/$sub"
done

echo "Estructura creada en: $CLAUDE_DIR"
ls -la "$CLAUDE_DIR"
