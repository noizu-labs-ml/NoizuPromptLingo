# D3.js
Data-driven documents for creating dynamic, interactive visualizations. [Docs](https://d3js.org/) | [Examples](https://observablehq.com/@d3/gallery)

## Install/Setup
```bash
npm install d3  # v7.9.0
# or CDN
<script src="https://cdn.jsdelivr.net/npm/d3@7"></script>
```

## Basic Usage
```javascript
// Minimal bar chart
const data = [30, 86, 168, 234, 12, 86];
const svg = d3.select("body").append("svg")
  .attr("width", 500).attr("height", 200);

svg.selectAll("rect")
  .data(data)
  .enter().append("rect")
  .attr("x", (d, i) => i * 80)
  .attr("y", d => 200 - d)
  .attr("width", 70)
  .attr("height", d => d)
  .attr("fill", "steelblue");
```

## Strengths
- Complete control over every element
- Powerful data binding and transitions
- Extensive ecosystem of utilities
- SVG, Canvas, and WebGL support

## Limitations
- Steep learning curve
- Low-level API requires more code
- No built-in chart types
- Performance issues with large datasets

## Best For
`custom-visualizations`, `interactive-dashboards`, `geographic-maps`, `network-graphs`, `complex-animations`