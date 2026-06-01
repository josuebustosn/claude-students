# Instalación

Guía paso a paso para dejar el skill `parcial-estudio` funcionando.

## Requisitos previos

- **[Claude Code](https://claude.ai/code)** instalado y configurado.
- **Cuenta Google** con acceso a [NotebookLM](https://notebooklm.google.com/) — el plan gratuito alcanza.
- **API key de Gemini** (gratuito hasta cierto cupo) — [aistudio.google.com/apikey](https://aistudio.google.com/apikey).

## Paso 1 · Instalar dependencias del sistema

### Python 3.10+ con PyMuPDF

```bash
# Verifica que tienes Python 3.10+
python --version

# Instala PyMuPDF (fitz)
pip install pymupdf
```

### LibreOffice (para convertir .doc/.docx/.ppt/.pptx)

**Windows:**
```powershell
winget install TheDocumentFoundation.LibreOffice
# o descargar de https://www.libreoffice.org/download/
```

**macOS:**
```bash
brew install --cask libreoffice
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get install libreoffice
```

Verifica que `soffice` esté disponible:

```bash
# Windows
"C:\Program Files\LibreOffice\program\soffice.exe" --version

# macOS / Linux
soffice --version
```

### NotebookLM CLI + MCP (`notebooklm-mcp-cli`)

```bash
npm install -g notebooklm-mcp-cli
# Verifica
nlm --version
```

Autentica con tu cuenta Google:

```bash
nlm login
```

Abre Chrome para OAuth — completa el flow y vuelve.

Configura el MCP server en Claude Code:

```json
// En ~/.claude/claude_desktop_config.json (Mac) o equivalente
{
  "mcpServers": {
    "notebooklm-mcp": {
      "command": "nlm-mcp",
      "args": []
    }
  }
}
```

## Paso 2 · Configurar la API key de Gemini

**Windows (permanente, en el usuario):**
```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "<tu_api_key>", "User")
```

**macOS / Linux (en `~/.zshrc` o `~/.bashrc`):**
```bash
export GEMINI_API_KEY="<tu_api_key>"
```

Después abre una terminal nueva para que la variable se cargue.

## Paso 3 · Clonar este repo + la dependencia

Elige un lugar para los skills source (ej. `~/claude-skills/`):

```bash
mkdir -p ~/claude-skills
cd ~/claude-skills

# Este repo
git clone https://github.com/josuebustosn/claude-students

# La dependencia de transcripción
git clone https://github.com/josuebustosn/gemini-transcribe
```

## Paso 4 · Conectar los skills a Claude Code

Claude Code busca skills en `~/.claude/skills/`. Hay dos formas:

### Opción A · Symlinks (recomendado, los updates del repo se propagan solos)

**macOS / Linux:**
```bash
mkdir -p ~/.claude/skills
ln -s ~/claude-skills/claude-students/skills/parcial-estudio ~/.claude/skills/parcial-estudio
ln -s ~/claude-skills/gemini-transcribe ~/.claude/skills/transcribir
```

**Windows (PowerShell admin):**
```powershell
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills\parcial-estudio" -Target "$env:USERPROFILE\claude-skills\claude-students\skills\parcial-estudio"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills\transcribir" -Target "$env:USERPROFILE\claude-skills\gemini-transcribe"
```

### Opción B · Copia simple

```bash
mkdir -p ~/.claude/skills
cp -r ~/claude-skills/claude-students/skills/parcial-estudio ~/.claude/skills/
cp -r ~/claude-skills/gemini-transcribe ~/.claude/skills/transcribir
```

(Si copias, tienes que volver a copiar después de cada `git pull`.)

## Paso 5 · Verificar la instalación

Abre Claude Code en cualquier carpeta y escribe:

```
qué skills tienes disponibles?
```

Deberías ver `parcial-estudio` y `transcribir` en la lista.

Probar el skill:

```
tengo parcial de [materia], aquí está la carpeta @<ruta-a-tu-carpeta-con-PDFs>
```

El skill debería arrancar y producir el output en `<carpeta>/Claude/`.

## Troubleshooting

### "GEMINI_API_KEY no está en el entorno" al transcribir

La env var permanente solo aplica a procesos nuevos. Cierra y abre Claude Code.

### "Authentication expired" en NotebookLM

Es normal — pasa en ~80% de las sesiones. El skill maneja la recuperación: lanza `nlm login`, completa OAuth en el navegador, y el skill continúa automáticamente.

### LibreOffice no encontrado en Windows

Verifica la ruta exacta:
```powershell
Get-ChildItem "C:\Program Files\LibreOffice\program\soffice.exe"
```

Si está en otra ubicación (LibreOffice portable, etc.), edita `skills/parcial-estudio/scripts/convert_to_pdf.ps1` con la ruta correcta.

### PyMuPDF "No common ancestor in structure tree"

Es solo un warning, no un error. El render se completa correctamente.

### NotebookLM devuelve quiz/flashcards en inglés

Bug conocido aguas arriba. El skill genera quiz y flashcards también en el HTML — los de NotebookLM quedan como backup.

## Actualizar

```bash
cd ~/claude-skills/claude-students && git pull
cd ~/claude-skills/gemini-transcribe && git pull
```

Si usaste symlinks, los cambios se aplican solos. Si copiaste, repite el Paso 4.

## Desinstalar

```bash
rm ~/.claude/skills/parcial-estudio
rm ~/.claude/skills/transcribir
rm -rf ~/claude-skills/claude-students
rm -rf ~/claude-skills/gemini-transcribe
```
