# WaveJSON

## Overview
JSON format specification for waveform descriptions. Standard for timing diagram interchange.

## Installation
```bash
# Python parser
pip install wavejson

# Node.js tools
npm install wavejson-parser

# Converters
pip install vcd2wavedrom
```

## Basic Example
```json
{
  "signal": [
    {"name": "clock", "wave": "p.....|..."},
    {"name": "data", "wave": "x.=.x.|=..",
     "data": ["head", "tail"]},
    {"name": "req", "wave": "0.1..0|1.."},
    {}
  ],
  "config": {"hscale": 2}
}
```

## Strengths
- Standard JSON format
- Tool-agnostic
- Version control friendly
- Extensible schema
- Cross-platform

## Limitations
- No native rendering
- Requires parser/renderer
- Limited to digital timing
- No analog waveforms

## NPL-FIM Integration
```yaml
format: wavejson
version: 2.0
converters:
  - vcd2wavejson
  - wavejson2svg
validate: schema.json
```