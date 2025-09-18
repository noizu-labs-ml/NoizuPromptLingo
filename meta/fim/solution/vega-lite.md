# Vega-Lite
Declarative JSON grammar for interactive visualizations. [Docs](https://vega.github.io/vega-lite/) | [Examples](https://vega.github.io/vega-lite/examples/)

## Install/Setup
```bash
npm install vega-lite vega-embed  # Node.js
# Or CDN for browser
<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>
```

## Basic Usage
```javascript
const spec = {
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": {"url": "data.json"},
  "mark": "bar",
  "encoding": {
    "x": {"field": "category", "type": "nominal"},
    "y": {"field": "value", "type": "quantitative"}
  }
};
vegaEmbed('#vis', spec);
```

## Strengths
- Concise declarative syntax for complex visualizations
- Built-in statistical transforms (regression, density, binning)
- Automatic scales, legends, and responsive design
- Composable views with faceting and layering

## Limitations
- Limited customization compared to D3.js
- JSON-only specification can be verbose
- Performance issues with large datasets (>50k points)

## Best For
`statistical-charts`, `dashboards`, `exploratory-data-analysis`, `academic-papers`