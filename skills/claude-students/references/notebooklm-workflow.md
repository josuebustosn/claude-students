# NotebookLM · Workflow validado para parciales

## Orden de operaciones

1. **Auth check** primero
2. Crear notebook
3. Subir PDFs vía CLI (NO MCP)
4. Lanzar 7 artefactos en paralelo
5. Construir HTML mientras procesan
6. Descargar todos los artefactos

## Auth check

```python
# Primer call obligatorio:
mcp__notebooklm-mcp__notebook_list
```

Si devuelve `"Authentication expired"` (esto pasa CASI SIEMPRE entre sesiones):

1. Lanzar `nlm login` en background → abre Chrome, Josue completa OAuth
2. Esperar notification de completion
3. **CRÍTICO:** llamar `mcp__notebooklm-mcp__refresh_auth` para que el MCP recargue cookies
4. Reverificar con `notebook_list`

**Nota:** `mcp__notebooklm-mcp__server_info` NO es un health check válido — siempre retorna success aunque las cookies estén expiradas.

## Crear notebook

```python
mcp__notebooklm-mcp__notebook_create(
  title="<Materia> - <Tipo Parcial> Temas X-Y (UCAT 2026)"
)
# Guardar el notebook_id devuelto
```

## Subir PDFs (CLI, NO MCP)

El MCP `source_add` con `file_path` **FALLA** consistentemente. Usar el CLI directamente:

```bash
nlm source add <notebook_id> --file "ruta/al/archivo.pdf"
# Devuelve "Source ID: <uuid>"
```

Si hay múltiples PDFs, lanzar todos los uploads en paralelo (cada uno como Bash call separado).

## Lanzar los 7 artefactos (paralelo)

### 1. Audio (podcast deep dive)

```python
mcp__notebooklm-mcp__studio_create(
  notebook_id=<id>,
  artifact_type="audio",
  audio_format="deep_dive",
  language="es",
  focus_prompt="Manual practico EN ESPAÑOL para <parcial>. Cubre balanceado: (1) <tema 1>, (2) <tema 2>, ... Tono didactico para estudiante universitario de Mercadeo. <Notas específicas si aplica>. Duracion completa.",
  confirm=True
)
```

### 2. Infografía

```python
mcp__notebooklm-mcp__studio_create(
  notebook_id=<id>,
  artifact_type="infographic",
  orientation="portrait",
  detail_level="detailed",
  focus_prompt="Infografia vertical EN ESPAÑOL sobre <tema>. Mostrar: (1) ..., (2) ..., (3) ... <comparativas si hay>",
  confirm=True
)
```

### 3. Guía de Estudio (Study Guide)

```python
mcp__notebooklm-mcp__studio_create(
  notebook_id=<id>,
  artifact_type="report",
  report_format="Study Guide",
  language="es",
  focus_prompt="Guia de estudio completa EN ESPAÑOL para <parcial>. Estructura por los N temas. Incluir <citas/articulos/conceptos clave>. Glosario y preguntas tipicas de examen con respuestas modelo.",
  confirm=True
)
```

### 4. Briefing Doc

```python
mcp__notebooklm-mcp__studio_create(
  notebook_id=<id>,
  artifact_type="report",
  report_format="Briefing Doc",
  language="es",
  focus_prompt="Briefing doc ejecutivo EN ESPAÑOL sobre <tema>: ..."
)
```

### 5. Mind Map (suele salir en inglés — bug conocido)

```python
mcp__notebooklm-mcp__studio_create(
  notebook_id=<id>,
  artifact_type="mind_map",
  title="<Materia> - Mapa Mental",
  focus_prompt="Mapa mental EN ESPAÑOL con nodo central <X> y ramas: ...",
  confirm=True
)
```

### 6. Quiz (15 preguntas)

```python
mcp__notebooklm-mcp__studio_create(
  notebook_id=<id>,
  artifact_type="quiz",
  language="es",
  question_count=15,
  focus_prompt="Quiz EN ESPAÑOL de 15 preguntas multiple choice cubriendo: ..."
)
```

### 7. Flashcards

```python
mcp__notebooklm-mcp__studio_create(
  notebook_id=<id>,
  artifact_type="flashcards",
  language="es",
  focus_prompt="Flashcards EN ESPAÑOL cubriendo terminos clave de <tema>: ..."
)
```

## Descargar artefactos (paralelo, al final)

```python
# Audio
mcp__notebooklm-mcp__download_artifact(
  notebook_id=<id>,
  artifact_type="audio",
  artifact_id=<audio_artifact_id>,
  output_path="<destino>/_artefactos/NotebookLM_Podcast_ES.mp3"
)

# Infografía → .png
# Reports (study guide, briefing) → .md
# Mind map → .json (si falla download, guardar manualmente el JSON del studio_create response)
# Quiz/Flashcards → .md (con output_format="markdown")
```

**Mind map gotcha:** el download a veces falla con "Download failed". El JSON ya viene completo en la respuesta del `studio_create` — guardarlo manualmente con `Write` si el `download_artifact` falla.

## Verificar status

```python
mcp__notebooklm-mcp__studio_status(notebook_id=<id>)
# Devuelve summary: {total, completed, in_progress}
```

## Convención de nombres de archivos

| Artefacto | Nombre archivo |
|---|---|
| Audio | `NotebookLM_Podcast_ES.mp3` |
| Infografía | `NotebookLM_Infographic.png` |
| Study Guide | `NotebookLM_GuiaEstudio.md` |
| Briefing Doc | `NotebookLM_BriefingDoc.md` |
| Mind map | `NotebookLM_MindMap.json` |
| Quiz | `NotebookLM_Quiz.md` |
| Flashcards | `NotebookLM_Flashcards.md` |

Estos nombres consistentes son los que Josue espera por la experiencia de las 6 entregas anteriores.
