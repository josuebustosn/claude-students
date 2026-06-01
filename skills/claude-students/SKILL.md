---
name: claude-students
description: Transforma una carpeta cruda de material de un parcial universitario (PDFs, DOC/DOCX, PPT, audios .ogg de WhatsApp, capturas) en un material de estudio polished y completo — HTML SOTA autocontenido + paquete de artefactos de NotebookLM (podcast en español, infografía, guía de estudio, briefing doc, mind map, quiz, flashcards). Usar este skill SIEMPRE que el usuario diga "tengo parcial de X", "ayúdame con este parcial", "armame el material de estudio", "convierte estos archivos en un HTML estudiable", "transforma esta carpeta en material de parcial", "pásame esta carpeta a HTML interactivo", o simplemente comparta una carpeta con archivos de materia universitaria. También activar cuando aparezcan archivos tipo "GUIA PARCIAL", "TEMA X", "CamScanner", "WhatsApp Ptt", "Parcial.pdf", "Acumulativo" en el contexto. El skill replica un patrón validado en múltiples entregas reales — no preguntar metodología antes de empezar, arrancar directo.
---

# Parcial Estudio · Workflow Automatizado para Parciales Universitarios

Este skill encapsula una metodología validada para transformar material crudo de parciales universitarios (típicamente entregado en formatos heterogéneos por compañeros de clase) en un paquete de estudio polished y completo, en una sola sesión de Claude Code.

El usuario típico es un estudiante universitario que recibe material horas antes del examen — vía WhatsApp, carpeta compartida, escaneos rápidos — y necesita maximizar el rendimiento del estudio en el tiempo restante.

## Por qué este skill existe

Sin el skill, procesar un parcial de cero requiere ~50 turnos sucesivos donde Claude re-descubre el flujo de trabajo, comete los mismos errores conocidos (autenticación de NotebookLM expirada, problemas de encoding en nombres de archivo, transcripción de audio fallando con caracteres especiales, etc.) y reescribe el HTML desde el patrón cero. **Con el skill, todo está documentado: el workflow, los componentes UI, los bugs conocidos y sus fixes.** Un parcial nuevo toma 10-15 turnos en vez de 50.

## Cuándo activar el skill

| Señal | Ejemplo | Acción |
|---|---|---|
| Frase tipo "tengo parcial de…" | "tengo parcial de derecho mañana" | Activar inmediato |
| Comparte una carpeta con PDFs/DOCs/audios | `@'Carpeta-materia/'` | Activar inmediato |
| Dice "haz lo mismo que la vez pasada" | "haz el mismo ejercicio para…" | Activar inmediato |
| Aparece archivo con "Parcial", "TEMA", "GUIA" en el path | Detectar automáticamente | Activar inmediato |
| Comparte un `.ogg` de WhatsApp con material académico | "WhatsApp Ptt 2026-…" | Activar inmediato |

**No preguntar la metodología.** El patrón ya está validado. Confirmar solo el path de la carpeta y arrancar las fases en paralelo.

## Convención de salida

Todo el output generado vive **dentro de una subcarpeta `Claude/`** en la carpeta del parcial original. Los archivos del usuario nunca se mueven ni se modifican.

```
<carpeta-parcial-original>/
├── <archivos originales tal cual los pasó el usuario · NO TOCAR>
└── Claude/                            ← TODO lo que el skill produce vive aquí
    ├── <MATERIA>.html                 ← Entregable principal
    ├── _artefactos/
    │   ├── NotebookLM_Podcast_ES.mp3
    │   ├── NotebookLM_Infographic.png
    │   ├── NotebookLM_GuiaEstudio.md
    │   ├── NotebookLM_BriefingDoc.md
    │   ├── NotebookLM_MindMap.json
    │   ├── NotebookLM_Quiz.md
    │   └── NotebookLM_Flashcards.md
    └── _transcripcion/                ← solo si hay audios
        └── <audio>.transcripcion.md
```

**Regla absoluta:** NUNCA crear carpetas en el escritorio del usuario. Todo va dentro del parcial original. Esta es una convención dura, no negociable.

## Dependencias

Este skill orquesta varios componentes externos:

- **Skill `transcribir`** (del repo público [`gemini-transcribe`](https://github.com/josuebustosn/gemini-transcribe)) — para procesar audios `.ogg` de WhatsApp. Si no está instalado, el skill funciona pero ignora los audios. Ver `references/bugs-conocidos.md` para los flags exactos (el default `gemini-3.5-flash` falla con caracteres ñ; usar `--model gemini-2.5-flash`).
- **NotebookLM CLI + MCP** (`notebooklm-mcp-cli`) — para generar el podcast, infografía, reports, mind map, quiz, flashcards.
- **LibreOffice headless** — para convertir `.doc/.docx/.ppt/.pptx` a PDF.
- **PyMuPDF** (`fitz`) — para renderizar PDFs a PNG y hacer Read multimodal.

Ver `INSTALL.md` del repo para la instalación completa.

## Workflow de 8 fases · ejecutar en orden con paralelización agresiva

### Fase 0 · Setup y verificación

1. Crear la estructura `<parcial>/Claude/_artefactos/`, `_paginas/`, `_pdf/`, `_transcripcion/` (usar `scripts/setup_carpeta.ps1` o equivalente).
2. **En paralelo:** verificar auth de NotebookLM con `mcp__notebooklm-mcp__notebook_list`. Si devuelve `"Authentication expired"`, seguir el recovery flow en `references/bugs-conocidos.md`.

### Fase 1 · Normalizar archivos multi-formato

Convertir todo a PDF para procesamiento uniforme:

- `.docx` / `.doc` / `.ppt` / `.pptx` → LibreOffice headless (ver `scripts/convert_to_pdf.ps1` para Windows o `scripts/convert_to_pdf.sh` para Mac/Linux)
- `.pdf` → dejar igual
- Capturas en PDF (`CamScanner`, scans) → dejar igual

**CRÍTICO — nombres con paréntesis o caracteres especiales:** rompen `Read`, `Bash mv/cp` con globs, y PowerShell con paths literales. Usar wildcards de PowerShell:

```powershell
Get-ChildItem "Captura*" | Rename-Item -NewName "SYLLABUS.pdf"
```

Equivalente en bash:
```bash
mv Captura* SYLLABUS.pdf
```

### Fase 2 · Renderizar PDFs a PNG con PyMuPDF (paralelo)

Usar `scripts/render_pdfs.py`. 170-180 DPI es suficiente para multimodal. Prefijo por archivo (`T5_p01.png`, `GUIA_p001.png`) para evitar colisiones.

### Fase 3 · Lectura multimodal + Transcripción de audios (paralelo)

**Lectura:** invocar el tool `Read` sobre los PNGs en lotes paralelos (~10 a la vez). Para PDFs muy largos (>50 páginas, ej. códigos legales completos), leer de forma selectiva guiado por la guía oficial — no leer toda la fuente página por página.

**Audios `.ogg` de WhatsApp:** invocar el skill `transcribir`. Ver `references/bugs-conocidos.md` sección "Transcripción Gemini" — el default `gemini-3.5-flash` puede fallar con encoding de caracteres ñ y acentos. Usar `--model gemini-2.5-flash` directamente para evitarlo.

```powershell
$env:GEMINI_API_KEY = [Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "User")
$env:PYTHONIOENCODING = "utf-8"
python "<ruta-skill-transcribir>/transcribe.py" --model gemini-2.5-flash --out "<destino>" "<audio.ogg>"
```

### Fase 4 · Setup NotebookLM (paralelo a la lectura)

1. `mcp__notebooklm-mcp__notebook_create` con un título descriptivo y único.
2. Subir cada PDF vía CLI (el MCP `source_add` con `file_path` **falla** — bug confirmado):
   ```bash
   nlm source add <notebook_id> --file "ruta/archivo.pdf"
   ```
3. Si hay transcripción de audio, considerar agregarla como source de tipo `text`.

### Fase 5 · Lanzar los 7 artefactos de NotebookLM (paralelo)

Lanzar todos en una sola tanda paralela:

1. **audio** · formato `deep_dive`, `language: "es"`, focus_prompt detallado en español
2. **infographic** · orientación `portrait`, `detail_level: "detailed"`, focus_prompt en español
3. **report** · formato `Study Guide`, en español
4. **report** · formato `Briefing Doc`, en español
5. **mind_map** · español (puede salir en inglés — bug recurrente, no insistir)
6. **quiz** · 15 preguntas, español
7. **flashcards** · español

Ver `references/notebooklm-workflow.md` para los prompts exactos que han funcionado.

### Fase 6 · Construir HTML SOTA (paralelo a artefactos)

**No esperar** a que terminen los artefactos de NotebookLM. El HTML es la fuente única de verdad — los artefactos son backup. Mientras NotebookLM procesa, escribir el HTML en una sola call de `Write`.

Ver `references/html-pattern.md` para el patrón validado (~100-180 KB típicos). Reusar componentes:

- Quiz interactivo con feedback inmediato (CSS `:has() + :checked`)
- Match game (par ↔ par)
- Flashcards `<details>` colapsables
- Tabs CSS-only (radios sibling)
- Timeline horizontal color-coded
- Pirámide CSS pura
- Glosario con `<details>`
- Modo claro/oscuro + modo focus (body `:has()`)
- **Explorador chip + ficha desplegable** (para taxonomías cerradas: artículos legales, INCOTERMS, fórmulas)
- **Corrector interactivo** (texto con errores subrayados + checkboxes para detectarlos)
- **Wizard 7 pasos** (radio buttons tipo stepper)
- Tabla comparativa lado-a-lado (ej. versiones distintas de una ley)

Recomendación: cada vez que se procese un nuevo parcial, intentar agregar **una técnica nueva** al catálogo de componentes — el HTML mejora iterativamente entre entregas.

### Fase 7 · Descargar artefactos + limpieza (paralelo)

1. `studio_status` para confirmar que los 7 artefactos están completados
2. `download_artifact` por cada uno → `Claude/_artefactos/`
3. Eliminar `Claude/_paginas/` y `Claude/_pdf/` (auxiliares, ya no se necesitan)
4. **NO eliminar** `_transcripcion/` ni los archivos originales del usuario

### Fase 8 · Entregar

1. Abrir el HTML en el navegador (`start` en Windows, `open` en Mac, `xdg-open` en Linux)
2. Resumen al usuario con:
   - Tabla de entregables (HTML, podcast, infografía, etc.) con tamaños
   - Notas sobre cualquier limitación detectada (sesgo de tema, idioma de artefactos)
   - Sugerencia de plan de estudio basado en el material procesado

## Reglas no negociables

- **HTML sin JavaScript.** Todo CSS puro. El JS rompe en mobile inconsistente.
- **Print-friendly.** `@media print` fuerza `display:block !important` en `<details>` colapsados y expande los exploradores.
- **Footer obligatorio:** atribución a Claude (puede personalizarse, pero el patrón canónico es `"Sintetizado y diseñado por Claude · Anthropic"`).
- **Español natural.** El skill está optimizado para español. Sin voseo argentino (cultural marker fuerte). Mantener neutralidad latinoamericana.
- **Tipografía:** Iowan Old Style / Palatino para headings (serif), system sans para body, monospace solo para badges/código.
- **Mobile-first.** Todas las grids con `auto-fit minmax(NNpx, 1fr)`.
- **Color-coded por tema** con custom properties `--t1`…`--tN`.

## Recursos del skill

Leer estos archivos cuando el contexto lo requiera:

- `references/html-pattern.md` — Estructura completa del HTML SOTA con todos los componentes CSS validados, snippets listos para usar.
- `references/notebooklm-workflow.md` — Prompts exactos y configuración de los 7 artefactos.
- `references/bugs-conocidos.md` — 12 gotchas documentados: auth NotebookLM, encoding de archivos, Gemini transcripción, sesgo de tema, idioma inglés en mind_map/quiz, etc.
- `scripts/convert_to_pdf.ps1` / `.sh` — LibreOffice headless wrapper (Windows / Mac+Linux).
- `scripts/render_pdfs.py` — PyMuPDF render a 170-180 DPI.
- `scripts/setup_carpeta.ps1` — Crear estructura `Claude/` + subcarpetas.

## Tamaño esperado del HTML

| Cantidad de temas | Tamaño típico | Notas |
|---|---|---|
| 1-3 temas, contenido simple | 50-80 KB | Quiz + flashcards + glosario básicos |
| 4-6 temas, mediana profundidad | 90-130 KB | Agregar match + explorador + comparativas |
| 6+ temas con material legal/citas | 130-180 KB | Explorador de artículos + corrector + wizard |

Si el HTML pasa de 200 KB, considerar dividirlo en 2 archivos (uno por bloque temático) o reducir la cantidad de flashcards/quiz por tema.

## Cantidad recomendada de componentes interactivos

| Componente | Mínimo | Recomendado | Tope útil |
|---|---|---|---|
| Quiz preguntas | 10 | 15-20 | 25 |
| Match pares | 6 | 8-10 | 12 |
| Flashcards | 20 | 30-45 | 60 |
| Glosario | 15 | 25-30 | 40 |
| Mnemotecnias | 4 | 6-9 | 12 |

Estos números están calibrados al tiempo que un estudiante invierte realmente en repasar antes de un parcial. Más de lo recomendado satura visualmente; menos no rinde para fijar conceptos.
