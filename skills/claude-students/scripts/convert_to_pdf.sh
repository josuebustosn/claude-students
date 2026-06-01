#!/usr/bin/env bash
# convert_to_pdf.sh
# Convierte archivos .doc/.docx/.ppt/.pptx a PDF usando LibreOffice headless.
#
# Uso:
#   ./convert_to_pdf.sh <out_dir> <file1> [file2] [file3] ...
#
# Requiere: LibreOffice instalado y `soffice` en PATH.

set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Uso: $0 <out_dir> <file1> [file2] ..."
    exit 1
fi

OUT_DIR="$1"
shift

# Verifica que soffice esté disponible
if ! command -v soffice >/dev/null 2>&1; then
    echo "ERROR: 'soffice' no encontrado. Instala LibreOffice:"
    echo "  macOS:  brew install --cask libreoffice"
    echo "  Linux:  sudo apt-get install libreoffice"
    exit 1
fi

mkdir -p "$OUT_DIR"

# LibreOffice headless convierte todos los archivos en una sola call
soffice --headless --convert-to pdf --outdir "$OUT_DIR" "$@"

echo "Conversión completa. PDFs en: $OUT_DIR"
