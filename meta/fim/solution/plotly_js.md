# Plotly.js
High-level charting library for scientific and 3D visualizations. [Docs](https://plotly.com/javascript/) | [Examples](https://plotly.com/javascript/basic-charts/)

## Install/Setup
```bash
npm install plotly.js-dist  # v2.35.2
# or CDN
<script src="https://cdn.plot.ly/plotly-2.35.2.min.js"></script>
```

## Basic Usage
```javascript
// Minimal 3D surface plot
const data = [{
  z: [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
  type: 'surface'
}];

const layout = {
  title: '3D Surface',
  width: 500,
  height: 400
};

Plotly.newPlot('myDiv', data, layout);
```

## Strengths
- Extensive chart types (100+)
- Built-in 3D visualizations
- WebGL rendering for performance
- Interactive by default (zoom, pan, hover)
- Export to PNG/SVG/JSON

## Limitations
- Large file size (3MB+)
- Commercial license for some features
- Less customizable than D3
- Limited animation capabilities

## Best For
`scientific-plots`, `3d-visualizations`, `statistical-charts`, `financial-data`, `heatmaps`, `contour-plots`