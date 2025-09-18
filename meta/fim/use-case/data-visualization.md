# Data Visualization
Interactive charts, graphs, and dashboards for data exploration and presentation.

## When to Use
- Display quantitative data patterns and trends
- Build interactive dashboards for real-time monitoring
- Create statistical visualizations for reports
- Develop business intelligence tools
- Present financial data, sales metrics, or performance indicators

## Key Outputs
`svg`, `canvas`, `html+css`, `json-data`

## Dependencies
Choose one visualization approach:
- **SVG/CSS**: Native browser support, no dependencies
- **Chart.js**: `npm install chart.js` - Simple charts
- **D3.js**: `npm install d3` - Advanced visualizations
- **Canvas API**: Native browser support for performance-critical graphics

## Quick Examples

**SVG Bar Chart (No Dependencies)**
```html
<svg width="420" height="200">
  <rect x="0" y="130" width="65" height="70" fill="steelblue"/>
  <rect x="70" y="114" width="65" height="86" fill="steelblue"/>
  <rect x="140" y="32" width="65" height="168" fill="steelblue"/>
</svg>
```

**Chart.js Line Chart**
```javascript
// Requires: chart.js
new Chart(ctx, {
  type: 'line',
  data: { labels: ['Jan', 'Feb', 'Mar'], datasets: [{ data: [30, 86, 168] }] }
});
```

**Canvas Scatter Plot**
```javascript
// Native browser API
const ctx = canvas.getContext('2d');
data.forEach(([x, y]) => {
  ctx.fillRect(x * 10, y * 5, 3, 3);
});
```