# setup_carpeta.ps1
# Crea la estructura estandar Claude/ dentro de la carpeta del parcial.
#
# Uso:
#   .\setup_carpeta.ps1 -ParcialPath "C:\Users\Usuario\Desktop\Etica parcial 2\Derecho angeli"

param(
    [Parameter(Mandatory=$true)] [string]$ParcialPath
)

if (-not (Test-Path $ParcialPath)) {
    Write-Error "La carpeta del parcial no existe: $ParcialPath"
    exit 1
}

$claudeDir = Join-Path $ParcialPath "Claude"
$subdirs = @("_artefactos", "_paginas", "_pdf", "_transcripcion")

foreach ($sub in $subdirs) {
    $path = Join-Path $claudeDir $sub
    New-Item -ItemType Directory -Force -Path $path | Out-Null
}

Write-Host "Estructura creada en: $claudeDir"
Get-ChildItem $claudeDir | Format-Table Name, Mode -AutoSize
