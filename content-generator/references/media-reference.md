# Media & Visualization Reference

Index into the FIM (Fill-in-the-Middle) library for generating content with rich media. Use this guide to find the right tool/format for any visualization, diagram, document, or media need in your content.

## How to Use

1. **Identify the media need** from the category table below
2. **Read the concise use-case file** for an overview and quick examples
3. **Read the verbose use-case file** (if available) for detailed implementation
4. **Read the specific solution file** for tool-specific API details and code samples

All paths are relative to `references/fim/`.

---

## Use-Case Quick Reference

| Content Need | Concise Guide | Verbose Guide | Top Solutions |
|-------------|---------------|---------------|---------------|
| **Charts & dashboards** | `use-case/data-visualization.md` | `use-case/data-visualization.verbose.md` | Chart.js, D3.js, Plotly, Vega-Lite |
| **3D graphics & WebGL** | `use-case/3d-graphics.md` | `use-case/3d-graphics.verbose.md` | Three.js, Babylon.js, A-Frame |
| **Flowcharts & UML** | `use-case/diagram-generation.md` | — | Mermaid, PlantUML, Graphviz |
| **Network graphs** | `use-case/networks-graphs.md` | `use-case/networks-graphs.verbose.md` | Cytoscape.js, D3-force, Sigma.js |
| **Animations** | `use-case/creative-animation.md` | `use-case/creative-animation.verbose.md` | GSAP, Anime.js, P5.js, Lottie |
| **Maps & geospatial** | `use-case/geospatial-mapping.md` | — | Leaflet.js, Mapbox GL, Deck.gl |
| **Documents & publishing** | `use-case/document-processing.md` | `use-case/document-processing.verbose.md` | Pandoc, LaTeX, Markdown, Typst |
| **Math & science** | `use-case/mathematical-scientific.md` | — | KaTeX, MathJax, SymPy, TikZ |
| **Music notation** | `use-case/music-notation.md` | `use-case/music-notation.verbose.md` | VexFlow, ABC.js, LilyPond |
| **Engineering diagrams** | `use-case/engineering-diagrams.md` | `use-case/engineering-diagrams.verbose.md` | WaveDrom, CircuiTikZ, KiCad |
| **Media processing** | `use-case/media-processing.md` | — | Sharp, FFmpeg-WASM, PDFKit |
| **Design systems** | `use-case/design-systems.md` | `use-case/design-systems.verbose.md` | SVG, CSS, Canvas API |
| **Python code gen** | `use-case/python-code-generation.md` | `use-case/python-code-generation.verbose.md` | Matplotlib, Seaborn, Plotly-Python |
| **Elixir Livebook** | `use-case/elixir-livebook-components.md` | — | Kino-VegaLite, Kino-JS |
| **Prototyping** | `use-case/prototyping.md` | `use-case/prototyping.verbose.md` | SVG, P5.js, HTML/CSS |

---

## Solution Files by Category

### Data Visualization & Charting (18 solutions)

| Solution | File | Best For |
|----------|------|----------|
| Altair | `solution/altair.md` | Python statistical visualization |
| Apache ECharts | `solution/apache-echarts.md` | Interactive charting |
| Bokeh | `solution/bokeh.md` | Python interactive viz |
| Chart.js | `solution/chart_js.md` | Simple canvas charts |
| D3.js | `solution/d3_js.md` | Advanced data-driven viz |
| Dash | `solution/dash.md` | Python analytical apps |
| ggplot2 | `solution/ggplot2.md` | R grammar of graphics |
| Google Charts | `solution/google-charts.md` | Quick embedded charts |
| Highcharts | `solution/highcharts.md` | Commercial charting |
| HoloViews | `solution/holoviews.md` | Python data analysis |
| Matplotlib | `solution/matplotlib.md` | Python plotting |
| Observable Plot | `solution/observable-plot.md` | JS grammar of graphics |
| Pandas Plotting | `solution/pandas-plotting.md` | Quick data exploration |
| Plotly (Python) | `solution/plotly-python.md` | Python interactive plots |
| Plotly.js | `solution/plotly_js.md` | JS interactive plots |
| Plots.jl | `solution/plots_jl.md` | Julia plotting |
| Seaborn | `solution/seaborn.md` | Statistical visualization |
| Vega/Vega-Lite | `solution/vega.md`, `solution/vega-lite.md` | Declarative viz grammar |

### 3D Graphics & WebGL (8 solutions)

| Solution | File | Best For |
|----------|------|----------|
| A-Frame | `solution/a-frame.md` | Web VR |
| Babylon.js | `solution/babylon_js.md` | 3D engine |
| Cesium.js | `solution/cesium_js.md` | 3D globes |
| PlayCanvas | `solution/playcanvas.md` | 3D game engine |
| React Three Fiber | `solution/react-three-fiber.md` | React + Three.js |
| Three.js | `solution/three_js.md` | JS 3D library |
| Verge3D | `solution/verge3d.md` | Artist-friendly 3D |
| X3DOM | `solution/x3dom.md` | Declarative 3D HTML |

### Diagramming & UML (15 solutions)

| Solution | File | Best For |
|----------|------|----------|
| Mermaid | `solution/mermaid.md` | Markdown diagrams |
| PlantUML | `solution/plantuml.md` | UML from text |
| Graphviz | `solution/graphviz.md` | Graph visualization |
| Draw.io XML | `solution/drawio-xml.md` | General flowcharts |
| C4-PlantUML | `solution/c4-plantuml.md` | Architecture diagrams |
| Structurizr DSL | `solution/structurizr-dsl.md` | Architecture DSL |
| Nomnoml | `solution/nomnoml.md` | Quick UML |
| Blockdiag family | `solution/blockdiag.md`, `actdiag.md`, `seqdiag.md`, `nwdiag.md` | Specialized diagrams |

### Networks & Graphs (11 solutions)

| Solution | File | Best For |
|----------|------|----------|
| Cytoscape.js | `solution/cytoscape_js.md` | Graph analysis |
| D3-Force | `solution/d3-force.md` | Force simulation |
| Sigma.js | `solution/sigma_js.md` | Graph rendering |
| Go.js | `solution/go_js.md` | Interactive diagrams |
| NetworkX | `solution/networkx.md` | Python graph analysis |
| Vis.js | `solution/vis_js.md` | Dynamic networks |
| igraph | `solution/igraph.md` | Network analysis |

### Animation & Creative (13 solutions)

| Solution | File | Best For |
|----------|------|----------|
| GSAP | `solution/gsap.md` | High-performance animation |
| Anime.js | `solution/anime_js.md` | Lightweight animation |
| P5.js | `solution/p5_js.md` | Creative coding |
| Lottie | `solution/lottie.md` | After Effects animations |
| Paper.js | `solution/paper_js.md` | Vector graphics |
| Rough.js | `solution/rough_js.md` | Hand-drawn style |
| SVG.js | `solution/svg_js.md` | SVG manipulation |

### Geospatial & Mapping (11 solutions)

| Solution | File | Best For |
|----------|------|----------|
| Leaflet.js | `solution/leaflet_js.md` | Mobile-friendly maps |
| Mapbox GL JS | `solution/mapbox-gl-js.md` | Vector tile maps |
| MapLibre GL JS | `solution/maplibre-gl-js.md` | Open-source maps |
| Deck.gl | `solution/deck_gl.md` | WebGL data layers |
| Folium | `solution/folium.md` | Python maps |
| OpenLayers | `solution/openlayers.md` | Full-featured maps |
| Turf.js | `solution/turf_js.md` | Geospatial analysis |

### Document Processing (12 solutions)

| Solution | File | Best For |
|----------|------|----------|
| Pandoc | `solution/pandoc.md` | Universal converter |
| LaTeX | `solution/latex.md` | Typesetting |
| Typst | `solution/typst.md` | Modern typesetting |
| Markdown | `solution/markdown.md` | Lightweight markup |
| Sphinx | `solution/sphinx.md` | Python docs |
| MkDocs | `solution/mkdocs.md` | Project docs |
| Quarto | `solution/quarto.md` | Scientific publishing |

### Mathematics & Scientific (12 solutions)

| Solution | File | Best For |
|----------|------|----------|
| KaTeX | `solution/katex.md` | Fast math rendering |
| MathJax | `solution/mathjax.md` | Math display |
| SymPy | `solution/sympy.md` | Symbolic math |
| TikZ/PGF | `solution/tikz-pgf.md` | LaTeX graphics |
| SageMath | `solution/sagemath.md` | Math software |

### Music Notation (13 solutions)

| Solution | File | Best For |
|----------|------|----------|
| VexFlow | `solution/vexflow.md` | Web notation rendering |
| ABC.js | `solution/abcjs.md` | ABC notation |
| LilyPond | `solution/lilypond.md` | Publication-quality scores |
| MusicXML | `solution/musicxml.md` | Interchange format |
| Tone.js | `solution/tone_js.md` | Audio synthesis |

### Engineering & Electronics (11 solutions)

| Solution | File | Best For |
|----------|------|----------|
| WaveDrom | `solution/wavedrom.md` | Timing diagrams |
| CircuiTikZ | `solution/circuitikz.md` | Circuit diagrams |
| KiCad | `solution/kicad.md` | PCB design |
| SchemDraw | `solution/schemdraw.md` | Circuit schematics |

### Media Processing (10 solutions)

| Solution | File | Best For |
|----------|------|----------|
| Sharp | `solution/sharp.md` | Image processing |
| FFmpeg-WASM | `solution/ffmpeg-wasm.md` | Browser video |
| PDFKit | `solution/pdfkit.md` | PDF generation |
| PDF.js | `solution/pdf_js.md` | PDF rendering |
| SheetJS | `solution/sheetjs.md` | Spreadsheet I/O |

---

## Content Type to Media Mapping

When creating content, use this mapping to decide what media to include:

| Article Type | Recommended Media | Solution Category |
|-------------|-------------------|-------------------|
| **Tutorial** | Code screenshots, diagrams, step visuals | Mermaid, SVG, Canvas |
| **Comparison** | Comparison charts, feature matrices | Chart.js, D3.js, tables |
| **Architecture** | System diagrams, flow charts | Mermaid, PlantUML, C4 |
| **Data analysis** | Interactive charts, dashboards | Plotly, D3.js, Vega-Lite |
| **API docs** | Sequence diagrams, request flows | Mermaid, PlantUML |
| **DevOps** | Infrastructure diagrams, pipelines | Graphviz, Mermaid |
| **Frontend** | UI mockups, component trees | SVG, P5.js, Figma |
| **Scientific** | Math notation, plots, 3D viz | KaTeX, Matplotlib, Three.js |
| **Geographic** | Maps, spatial data | Leaflet, Mapbox, Deck.gl |
| **Music/audio** | Notation, waveforms | VexFlow, WaveDrom, Tone.js |

---

## Quick Decision Tree

```
What media do you need?
├── Static diagram? → Mermaid (simple) or PlantUML (complex)
├── Data chart? → Chart.js (simple) or D3.js (custom) or Plotly (interactive)
├── 3D visualization? → Three.js (general) or Babylon.js (game-like)
├── Map? → Leaflet (simple) or Mapbox (styled) or Deck.gl (big data)
├── Animation? → GSAP (UI) or Lottie (designed) or P5.js (creative)
├── Math notation? → KaTeX (fast) or MathJax (comprehensive)
├── Music notation? → VexFlow (web) or LilyPond (print)
├── Circuit/timing? → CircuiTikZ (circuits) or WaveDrom (timing)
├── Document conversion? → Pandoc (universal) or Typst (modern)
└── Image processing? → Sharp (server) or Canvas API (browser)
```
