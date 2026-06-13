# Vega
Declarative visualization grammar for creating, saving, and sharing graphics. [Docs](https://vega.github.io/vega/) | [Examples](https://vega.github.io/vega/examples/)

## Install/Setup
```bash
npm install vega  # v5.30.0
# or CDN
<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
```

## Basic Usage
```javascript
// Minimal bar chart specification
const spec = {
  "$schema": "https://vega.github.io/schema/vega/v5.json",
  "width": 400,
  "height": 200,
  "data": [{
    "name": "table",
    "values": [
      {"category": "A", "amount": 28},
      {"category": "B", "amount": 55},
      {"category": "C", "amount": 43}
    ]
  }],
  "marks": [{
    "type": "rect",
    "from": {"data": "table"},
    "encode": {
      "enter": {
        "x": {"scale": "xscale", "field": "category"},
        "width": {"scale": "xscale", "band": 1},
        "y": {"scale": "yscale", "field": "amount"},
        "y2": {"scale": "yscale", "value": 0}
      }
    }
  }],
  "scales": [
    {"name": "xscale", "type": "band", "domain": {"data": "table", "field": "category"}, "range": "width"},
    {"name": "yscale", "domain": {"data": "table", "field": "amount"}, "range": "height"}
  ]
};

const view = new vega.View(vega.parse(spec))
  .renderer('canvas')
  .initialize('#vis')
  .run();
```

## Strengths
- JSON-based specifications
- Declarative and reproducible
- Vega-Lite for simpler syntax
- Extensible with transforms
- Server-side rendering support

## Limitations
- Verbose specifications
- Learning curve for grammar
- Limited 3D support
- Debugging can be difficult

## Best For
`data-pipelines`, `reproducible-research`, `automated-reporting`, `grammar-based-viz`, `statistical-graphics`