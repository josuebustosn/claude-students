# Patrón HTML SOTA · Estructura validada

Este es el patrón del HTML autocontenido validado en múltiples entregas reales de parciales universitarios. Tamaño típico: 100-180 KB.

## Estructura general

```
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>...</title>
  <style>
    :root { /* custom properties: --paper, --ink, --t1..--tN, --serif, --sans */ }
    /* Modo oscuro: body:has(.darkmode-input:checked) {...} */
    /* Modo focus: body:has(.focusmode-input:checked) section:not(:hover) {...} */
    /* Todos los componentes... */
    @media print { /* expandir todos los <details>, ocultar toolbar */ }
  </style>
</head>
<body>
  <input type="checkbox" id="dm" class="darkmode-input">
  <input type="checkbox" id="fm" class="focusmode-input">
  <header class="toolbar"> /* brand + buttons */ </header>
  <nav class="toc"> /* chips de navegación */ </nav>
  <main>
    <div class="hero"> /* título + TL;DR */ </div>
    <section id="..." class="t1"> /* contenido temático */ </section>
    ...
    <section id="quiz"> /* quiz interactivo */ </section>
    <section id="match"> /* match game */ </section>
    <section id="flashcards"> /* flashcards */ </section>
    <section id="glosario"> /* glosario */ </section>
    <section id="mnemo"> /* mnemotecnia */ </section>
  </main>
  <footer> /* atribución + meta */ </footer>
</body>
</html>
```

## Custom properties base

```css
:root{
  --paper:#fbf6ea;        /* fondo principal */
  --ink:#1c1a14;          /* tinta */
  --muted:#6b6357;
  --line:#d9cfb8;
  --accent:#8b1a1a;       /* color de marca */
  --gold:#c98a00;         /* highlights */
  --t1..--tN: ...         /* uno por tema, paleta diversa */
  --bg-card:#ffffff;
  --bg-soft:#f3edde;
  --serif:"Iowan Old Style","Palatino Linotype","Palatino",Georgia,serif;
  --sans:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif;
  --mono:"SF Mono","Cascadia Mono","Consolas",monospace;
}
```

## Dark mode (CSS-only, sin JS)

```html
<input type="checkbox" id="dm" class="darkmode-input" style="position:absolute;opacity:0">
<label for="dm" class="btn">🌓 Modo oscuro</label>
```

```css
body:has(.darkmode-input:checked){
  --paper:#0e0d0a;
  --ink:#f0e8d6;
  /* etc — override todas las custom properties */
}
```

## Focus mode (atenúa secciones no hovereadas)

```css
body:has(.focusmode-input:checked) section:not(:hover):not(:focus-within){
  opacity:.17; filter:blur(.4px);
}
```

## Componentes validados

### Hero con TL;DR

```html
<div class="hero">
  <span class="kicker">CONTEXTO · MATERIA · FECHA</span>
  <h1>Título grande</h1>
  <p class="lead">Subtítulo descriptivo en serif.</p>
  <div class="meta"><span>📚 N fuentes</span><span>📄 X páginas</span></div>
  <div class="tldr">
    <h4>TL;DR para el parcial</h4>
    <p>Resumen ejecutivo del contenido completo.</p>
  </div>
</div>
```

### Card grid

```css
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:1rem}
.card{background:var(--bg-card);border:1px solid var(--line);border-radius:14px;padding:1.1rem 1.25rem;transition:transform .15s, box-shadow .15s}
.card:hover{transform:translateY(-3px);box-shadow:0 10px 24px -10px rgba(0,0,0,.18)}
.card.t1{border-top:3px solid var(--t1)} /* uno por tema */
```

### Quiz con feedback inmediato (CSS puro)

```html
<div class="q">
  <p class="qtxt">1. Pregunta?</p>
  <div class="opts">
    <label class="opt wrong"><input type="radio" name="q1"><span>Opción A</span></label>
    <label class="opt correct"><input type="radio" name="q1"><span>Opción B (correcta)</span></label>
  </div>
  <div class="explain ok"><strong>✓ Correcto.</strong> Explicación...</div>
  <div class="explain ko"><strong>✗ No.</strong> Explicación del error...</div>
</div>
```

```css
.q .explain{display:none}
.q:has(.opt.correct input:checked) .explain.ok{display:block;background:color-mix(in srgb,#22c55e 12%,var(--bg-card));border-left:3px solid #22c55e}
.q:has(.opt.wrong input:checked) .explain.ko{display:block;background:color-mix(in srgb,#ef4444 12%,var(--bg-card));border-left:3px solid #ef4444}
.q .opt.correct:has(input:checked){background:color-mix(in srgb, #22c55e 18%, var(--bg-card));border-color:#22c55e}
.q .opt.wrong:has(input:checked){background:color-mix(in srgb, #ef4444 18%, var(--bg-card));border-color:#ef4444}
```

### Match game (par ↔ par)

```html
<div class="match">
  <div class="match-board">
    <div class="match-col">
      <div class="match-row r1"><input type="radio" name="m1"><span>Item 1</span></div>
      <div class="match-row r2"><input type="radio" name="m2"><span>Item 2</span></div>
    </div>
    <div class="match-col">
      <div class="match-row a2"><span>Descripción del 2</span></div>
      <div class="match-row a1"><span>Descripción del 1</span></div>
    </div>
  </div>
</div>
```

```css
.match:has(.r1 input:checked) .a1,
.match:has(.r2 input:checked) .a2,
.match:has(.r3 input:checked) .a3 /* etc */{
  background:color-mix(in srgb, #22c55e 18%, var(--bg-card));
  border-color:#22c55e;
}
```

### Flashcards `<details>` colapsables

```html
<details class="fc t1">
  <summary>¿Pregunta?</summary>
  <div class="answer">Respuesta detallada.</div>
</details>
```

```css
.fc summary{cursor:pointer;list-style:none;display:flex;justify-content:space-between;align-items:center}
.fc summary::after{content:"+";transition:transform .2s}
.fc[open] summary::after{transform:rotate(45deg)}
.fc summary::-webkit-details-marker{display:none}
```

### Explorador chip + ficha desplegable (taxonomías cerradas tipo INCOTERMS, artículos CRBV)

```html
<div class="explorer">
  <input type="radio" name="x" id="x-a" checked class="cit-radios">
  <input type="radio" name="x" id="x-b" class="cit-radios">
  <div class="cit-grid">
    <label for="x-a" class="cit-chip"><span class="num">A</span>Concepto A</label>
    <label for="x-b" class="cit-chip"><span class="num">B</span>Concepto B</label>
  </div>
  <div class="cit-ficha f-a"><h5>Concepto A</h5><p>Detalle completo.</p></div>
  <div class="cit-ficha f-b"><h5>Concepto B</h5><p>Detalle completo.</p></div>
</div>
```

```css
.cit-radios{position:absolute;opacity:0;pointer-events:none}
.cit-ficha{display:none}
.explorer:has(#x-a:checked) .f-a,
.explorer:has(#x-b:checked) .f-b{display:block}
.explorer:has(#x-a:checked) [for="x-a"],
.explorer:has(#x-b:checked) [for="x-b"]{
  background:color-mix(in srgb, currentColor 18%, var(--paper));
  transform:translateY(-2px);
}
```

### Wizard / Stepper de N pasos

```html
<div class="wizard">
  <input type="radio" name="ws" id="ws1" checked class="wizard-radios">
  <input type="radio" name="ws" id="ws2" class="wizard-radios">
  <div class="wizard-nav">
    <label for="ws1">Paso 1</label>
    <label for="ws2">Paso 2</label>
  </div>
  <div class="wizard-step ws-1">Contenido paso 1</div>
  <div class="wizard-step ws-2">Contenido paso 2</div>
</div>
```

```css
.wizard-radios{position:absolute;opacity:0;pointer-events:none}
.wizard-step{display:none}
.wizard:has(#ws1:checked) .ws-1,
.wizard:has(#ws2:checked) .ws-2{display:block}
.wizard:has(#ws1:checked) [for="ws1"],
.wizard:has(#ws2:checked) [for="ws2"]{
  background:var(--accent);color:#fff;border-color:var(--accent);
}
```

### Corrector interactivo (texto con errores)

```html
<div class="corrector">
  <div class="corrector__text">
    Texto con <span class="err" title="error tipo X">parte mala</span> y <span class="err" title="error tipo Y">otra mala</span>.
  </div>
  <div class="corr-options">
    <label class="corr-check"><input type="checkbox"><span class="label"><strong>Tipo X</strong>Explicación...</span></label>
    <label class="corr-check"><input type="checkbox"><span class="label"><strong>Tipo Y</strong>Explicación...</span></label>
  </div>
</div>
```

```css
.err{background:color-mix(in srgb, #fb7185 35%, transparent);text-decoration:underline wavy #ef4444}
.corr-check:has(input:checked){background:color-mix(in srgb, #22c55e 12%, var(--bg-card));border-color:#22c55e}
```

### Tabla comparativa lado-a-lado (tipo 1961 vs 1999)

```html
<div class="cmp1961">
  <div class="cmp1961-head"><div>Versión A</div><div>Versión B</div></div>
  <div class="cmp1961-row"><div>Característica A</div><div>Característica B</div></div>
</div>
```

```css
.cmp1961{display:grid;border:2px solid var(--line);border-radius:14px;overflow:hidden}
.cmp1961-head,.cmp1961-row{display:grid;grid-template-columns:1fr 1fr}
.cmp1961-row > div:first-child{border-right:1px solid var(--line)}
```

### Mnemotecnia cards (estilo oro)

```html
<div class="mnemo-card">
  <span class="acro">ABCDE</span>
  <h5>Las 5 cosas</h5>
  <p>A · B · C · D · E</p>
  <p><em>"Frase mnemotécnica para recordar"</em></p>
</div>
```

```css
.mnemo-card{background:linear-gradient(135deg, color-mix(in srgb, var(--gold) 12%, var(--bg-card)) 0%, var(--bg-card) 100%);border:1px solid color-mix(in srgb, var(--gold) 30%, var(--line));border-radius:14px;padding:1.2rem}
.mnemo-card .acro{font-family:var(--mono);color:var(--gold);background:color-mix(in srgb, var(--gold) 18%, var(--bg-card));padding:.2rem .5rem;border-radius:4px}
```

## Print-friendly

```css
@media print{
  body{background:#fff;color:#000;font-size:11pt}
  .toolbar,.toc,footer{display:none}
  section{page-break-inside:avoid;margin:1rem 0}
  details:not([open]) > *:not(summary){display:block !important}
  .fc[open] summary::after,.fc summary::after{display:none}
  .cit-ficha{display:block !important;page-break-inside:avoid}
  .cit-grid{display:none}
}
```

## Footer canónico

```html
<footer>
  <p><strong>Materia · Examen · UCAT 2026</strong></p>
  <p>Fuentes: <em>Prof. Nombre</em></p>
  <p class="made">Sintetizado y diseñado por Claude Opus 4.7 · Anthropic · PLAN MAX 20×</p>
  <div class="meta">
    <span>📊 N flashcards</span>
    <span>📝 N preguntas quiz</span>
    <span>🎯 N pares match</span>
    <span>📚 N glosario</span>
  </div>
</footer>
```

## Cuántos items incluir (orden de magnitud típico)

| Componente | Mínimo | Recomendado | Tope útil |
|---|---|---|---|
| Quiz preguntas | 10 | 15-20 | 25 |
| Match pares | 6 | 8-10 | 12 |
| Flashcards | 20 | 30-45 | 60 |
| Glosario | 15 | 25-30 | 40 |
| Mnemotecnias | 4 | 6-9 | 12 |
