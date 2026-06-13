# Render Chains

Each text format produces a primary output file. Some formats require a render step to convert to a final visual output (PNG, SVG, PDF). This document specifies the render chain for each format.

## Chain Reference

### Diagrams

**Mermaid** (.mmd -> .svg/.png)
```yaml
post_processing:
  - action: render
    params:
      tool: mermaid
      output_format: svg    # or png
      theme: dark           # default | dark | forest | neutral
      background: transparent
```
Tool: `mmdc` (mermaid-cli). Install: `npm install -g @mermaid-js/mermaid-cli`

**PlantUML** (.puml -> .svg/.png)
```yaml
post_processing:
  - action: render
    params:
      tool: plantuml
      output_format: svg
```
Tool: `plantuml`. Requires Java runtime.

**Graphviz** (.dot -> .svg/.png)
```yaml
post_processing:
  - action: render
    params:
      tool: graphviz
      output_format: svg
      layout: dot           # dot | neato | fdp | sfdp | circo | twopi
```
Tool: `dot` (graphviz). Install: `brew install graphviz`

**Draw.io** (.drawio -> .png/.svg)
```yaml
post_processing:
  - action: render
    params:
      tool: drawio
      output_format: png
```
Tool: `draw.io` CLI or desktop export. No standard CLI render pipeline.

### Pages and Components

**HTML** (.html -> .png)
```yaml
post_processing:
  - action: render
    params:
      tool: puppeteer
      output_format: png
      viewport:
        width: 1440
        height: 900
```
Tool: Puppeteer (headless Chromium). Install: `npm install puppeteer`

**TSX/JSX** (.tsx -> .png)
```yaml
post_processing:
  - action: render
    params:
      tool: puppeteer
      output_format: png
      viewport:
        width: 1440
        height: 900
```
Requires: build step (vite/esbuild) before puppeteer screenshot. Consider wrapping in minimal HTML harness.

### Images

**SVG** (.svg -> no render needed)
SVG is a final output format. No post-processing required unless rasterization to PNG is desired:
```yaml
post_processing:
  - action: render
    params:
      tool: rsvg-convert     # or inkscape
      output_format: png
      width: 1024
```

### Documents

**LaTeX** (.tex -> .pdf)
```yaml
post_processing:
  - action: render
    params:
      tool: latex
      output_format: pdf
      engine: pdflatex      # pdflatex | xelatex | lualatex
```
Tool: TeX Live distribution. Install: `brew install --cask mactex`

**Typst** (.typ -> .pdf)
```yaml
post_processing:
  - action: render
    params:
      tool: typst
      output_format: pdf
```
Tool: `typst`. Install: `brew install typst`

### Music

**ABC** (.abc -> text output, optional render)
ABC notation is typically consumed by web renderers (abcjs). No standard CLI render chain. For PDF output, convert via abc2midi + notation software.

**LilyPond** (.ly -> .pdf)
```yaml
post_processing:
  - action: render
    params:
      tool: lilypond
      output_format: pdf
```
Tool: `lilypond`. Install: `brew install lilypond`

### Engineering

**WaveDrom** (.json -> .svg)
```yaml
post_processing:
  - action: render
    params:
      tool: wavedrom
      output_format: svg
```
Tool: `wavedrom-cli`. Install: `npm install -g wavedrom-cli`

### Math

**KaTeX** (.tex -> inline render)
KaTeX expressions are typically rendered inline in HTML/Markdown. No standalone render chain. For standalone use, wrap in minimal HTML with KaTeX JS/CSS and render via puppeteer.

## Summary Table

| Format | Primary | Rendered | Tool | Required |
|--------|---------|----------|------|----------|
| mermaid | .mmd | .svg/.png | mmdc | npm |
| plantuml | .puml | .svg/.png | plantuml | java |
| graphviz | .dot | .svg/.png | dot | brew |
| drawio | .drawio | .png/.svg | draw.io | manual |
| html | .html | .png | puppeteer | npm |
| tsx | .tsx | .png | puppeteer | npm+build |
| svg | .svg | (final) | N/A | -- |
| latex | .tex | .pdf | pdflatex | mactex |
| typst | .typ | .pdf | typst | brew |
| abc | .abc | (text) | N/A | -- |
| lilypond | .ly | .pdf | lilypond | brew |
| wavedrom | .json | .svg | wavedrom-cli | npm |
| katex | .tex | (inline) | N/A | -- |
