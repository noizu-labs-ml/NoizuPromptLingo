# WaveDrom

## Overview
JavaScript library for rendering digital timing diagrams from JSON descriptions. Web-based with SVG output.

## Installation
```bash
# Node.js
npm install -g wavedrom-cli

# Python wrapper
pip install wavedrom

# Web editor
# https://wavedrom.com/editor.html
```

## Basic Example
```json
{
  "signal": [
    {"name": "clk", "wave": "p......"},
    {"name": "data", "wave": "x.345x.", "data": ["D1", "D2", "D3"]},
    {"name": "valid", "wave": "0.1...0"}
  ]
}
```

## Strengths
- Simple JSON syntax
- Web-based editor
- SVG/PNG export
- Bus and data labels
- Interactive web viewer

## Limitations
- Digital signals only
- Limited analog support
- No complex protocol diagrams
- Browser dependency for editing

## NPL-FIM Integration
```yaml
renderer: wavedrom
format: json
output: svg|png
embed: markdown_compatible
```