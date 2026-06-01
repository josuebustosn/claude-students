# Bugs conocidos · Workflow de parciales

Estos bugs son recurrentes en cada parcial procesado. Documentarlos aquí ahorra ~10 turnos de re-descubrimiento por entrega.

## 1. Auth de NotebookLM expira más rápido de lo esperado

**Síntoma:** `notebook_list` o cualquier call MCP devuelve `"Authentication expired. Run 'nlm login' in your terminal to re-authenticate."`

**Frecuencia:** ~80% de las sesiones, incluso si la sesión anterior fue hace 30 minutos.

**Por qué pasa:** Las cookies de Google que el MCP cachea se invalidan rápido. Además, el MCP server cachea las cookies en memoria al arrancar y NO las recarga de disco automáticamente.

**Fix:**

```bash
# 1. Lanzar nlm login en background
nlm login  # (run_in_background=true en Claude Code)
# Esto abre Chrome — el usuario completa OAuth (este es el ÚNICO paso humano)

# 2. Esperar notification de completion
# Output esperado: "✓ Successfully authenticated! Profile: default"

# 3. Recargar tokens en el MCP corriendo (CRÍTICO)
# Llamar mcp__notebooklm-mcp__refresh_auth

# 4. Verificar con un nuevo notebook_list
```

**NO usar `server_info` como health check** — siempre retorna success aunque las cookies estén expiradas (es una call local que no golpea Google).

## 2. Nombres de archivo con paréntesis / caracteres especiales

**Síntoma:**
- `Read` tool falla: "File does not exist"
- Bash `mv "Captura...(s).pdf"` falla por interpretación de subshell
- PowerShell `Move-Item -LiteralPath` también falla

**Ejemplo típico:** `Captura de pantalla 2026-05-25 a la(s) 11.06.03 p. m..pdf`

**Fix:** PowerShell wildcard, NO path literal:

```powershell
Get-ChildItem "Captura*" | Rename-Item -NewName "SYLLABUS.pdf"
```

Equivalente en bash (Mac/Linux):
```bash
mv Captura* SYLLABUS.pdf
```

## 3. MCP `source_add` con `file_path` FALLA

**Síntoma:** error genérico sin procesar el archivo.

**Fix:** usar el CLI directo:

```bash
nlm source add <notebook_id> --file "<ruta-al-archivo.pdf>"
# Devuelve: "Source ID: <uuid>"
```

## 4. Quiz y Flashcards de NotebookLM salen en INGLÉS

**Síntoma:** pese a `language="es"` y prompts agresivos en español, quiz y flashcards de NotebookLM salen en inglés en ~50% de las generaciones.

**Frecuencia:** consistente en múltiples entregas.

**Reports (Study Guide, Briefing Doc) y Audio SÍ respetan el idioma.** Mind map a veces respeta a veces no.

**Fix:** NO reintentar más de 2 veces — es un bug aguas arriba en NotebookLM. Los de NotebookLM quedan como backup. **El quiz y flashcards definitivos se generan en el HTML propio**, donde Claude los escribe directamente con base en el contenido procesado.

## 5. Sesgo de tema cuando hay múltiples PDFs

**Síntoma:** cuando se suben 5+ PDFs simultáneamente, el mind map y reports se enfocan en el contenido **más voluminoso o repetido** — los temas menos representados quedan diluidos.

**Ejemplo típico:** un parcial con 7 PDFs donde un mismo tema aparece en 3 fuentes distintas → el mind map se enfoca solo en ese tema.

**Workaround:**
- El **audio sí distribuye balanceado** si el `focus_prompt` lista TODOS los temas explícitamente.
- Reports e infografía pueden estar sesgados — el HTML propio compensa garantizando cobertura balanceada.
- Alternativa: subir un PDF combinado (mergeado) en lugar de múltiples PDFs separados.

## 6. Mind map: download falla

**Síntoma:** `download_artifact(type="mind_map")` devuelve `"Download failed for mind_map."`

**Fix:** el JSON del mind map YA está en la respuesta del `studio_create` original. Guardarlo manualmente con `Write` directamente al path destino.

## 7. Transcripción Gemini default falla con encoding ñ/acentos

**Síntoma:**
```
RuntimeError: Gemini devolvio JSON invalido: Expecting ',' delimiter
```
con el raw mostrando caracteres `\x...` rotos donde había ñ o acentos.

**Modelo que falla:** `gemini-3.5-flash` (default del skill `transcribir`).

**Modelo `--pro` también falla:** `gemini-pro-latest` con error:
```
Budget 0 is invalid. This model only works in thinking mode.
```

**Fix validado:** usar `gemini-2.5-flash` explícitamente:

```powershell
$env:GEMINI_API_KEY = [Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "User")
$env:PYTHONIOENCODING = "utf-8"
python "<ruta-skill-transcribir>/transcribe.py" --model gemini-2.5-flash --out "<destino>" "<audio.ogg>"
```

## 8. GEMINI_API_KEY no aparece en el sandbox de bash

**Síntoma:** `ERROR: GEMINI_API_KEY no esta en el entorno`.

**Por qué:** las env vars permanentes del Usuario en Windows solo se aplican a procesos nuevos del User shell. El sandbox de Claude Code no la hereda automáticamente.

**Fix:** inyectar desde PowerShell con scope User:

```powershell
$env:GEMINI_API_KEY = [Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "User")
```

Esto se hace ANTES de invocar `python` en la misma llamada PowerShell.

En Mac/Linux equivalente:
```bash
export GEMINI_API_KEY=$(cat ~/.gemini_api_key)  # o leer de donde se guarde
```

## 9. PyMuPDF "No common ancestor in structure tree"

**Síntoma:** al renderizar PDFs convertidos por LibreOffice, aparecen warnings:
```
MuPDF error: format error: No common ancestor in structure tree.
```

**Impacto:** NINGUNO. Solo warnings. El render se completa correctamente.

**Fix:** ignorar los warnings — los PNGs salen bien.

## 10. Bash `sleep` largo es bloqueado por el harness

**Síntoma:** `sleep 60 && echo OK` falla con "Blocked: sleep 60... To wait for a condition, use Monitor".

**Fix:** no usar sleep para esperar — usar `studio_status` directamente cuando se necesite verificar progreso de NotebookLM, o `run_in_background=true` + esperar notification automática.

## 11. WALKTROUGHT.md NO crear para parciales

Algunos flujos de Claude Code crean automáticamente un `WALKTROUGHT.md` en cada proyecto nuevo. Para parciales (carpetas ephemeral que se borran después del examen), no agregar este archivo. Aplica solo a repos de código que viven mucho tiempo.

## 12. Output va dentro de `<parcial>/Claude/`, NUNCA en el Escritorio raíz

Anti-pattern de las primeras entregas: crear `Lenguaje parcial/`, `Materia parcial/`, etc. directamente en el escritorio del usuario. Esto satura el desktop, ensucia el sistema y dificulta encontrar el material relevante después.

**Convención correcta:** todo el output va dentro de la carpeta original del parcial, en una subcarpeta `Claude/`. Los originales del usuario permanecen en la raíz de la carpeta del parcial. Esta convención es no-negociable.
