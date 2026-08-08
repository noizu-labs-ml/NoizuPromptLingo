# SchemDraw

## Overview
Python package for schematic diagrams. Programmatic circuit drawing with matplotlib backend.

## Installation
```bash
pip install schemdraw

# With extras
pip install schemdraw[matplotlib]
pip install schemdraw[svgwrite]
```

## Basic Example
```python
import schemdraw
import schemdraw.elements as elm

with schemdraw.Drawing() as d:
    d += elm.Resistor().label('10kΩ')
    d += elm.Capacitor().down().label('100nF')
    d += elm.Ground()
    d.push()
    d += elm.SourceV().up().label('5V')
```

## Strengths
- Pure Python
- Programmatic generation
- Flow-based syntax
- Matplotlib integration
- SVG export

## Limitations
- Python-only
- Basic component library
- Manual layout required
- Limited automatic routing

## NPL-FIM Integration
```yaml
renderer: schemdraw
language: python
output: svg|png|pdf
backend: matplotlib|svg
```