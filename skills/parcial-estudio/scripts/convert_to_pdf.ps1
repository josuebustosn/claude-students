# convert_to_pdf.ps1
# Convierte archivos .doc/.docx/.ppt/.pptx a PDF usando LibreOffice headless.
#
# Uso:
#   .\convert_to_pdf.ps1 -OutDir "C:\destino\_pdf" -Files "archivo1.docx","archivo2.ppt"
#
# Si LibreOffice no está en la ruta estandar, el script falla con mensaje claro.

param(
    [Parameter(Mandatory=$true)] [string]$OutDir,
    [Parameter(Mandatory=$true)] [string[]]$Files
)

$soffice = "C:\Program Files\LibreOffice\program\soffice.exe"
if (-not (Test-Path $soffice)) {
    Write-Error "LibreOffice no encontrado en $soffice. Instalar desde libreoffice.org."
    exit 1
}

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
}

# LibreOffice headless convierte todos los archivos en una sola call
$argsList = @('--headless', '--convert-to', 'pdf', '--outdir', $OutDir) + $Files
& $soffice $argsList

Write-Host "Conversion completa. PDFs en: $OutDir"
