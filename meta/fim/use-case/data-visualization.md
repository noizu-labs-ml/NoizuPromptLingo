# Data Visualization
Interactive charts, graphs, and dashboards for data exploration and presentation.
[Documentation](https://d3js.org/getting-started)

## WWHW
**What**: Creating interactive charts, graphs, and dashboards to visualize datasets and metrics.
**Why**: Transform raw data into comprehensible visual insights for decision-making and analysis.
**How**: Using D3.js, Chart.js, or SVG with NPL-FIM for dynamic data binding and interactivity.
**When**: Data analysis, reporting, monitoring dashboards, business intelligence presentations.

## When to Use
- Need to display quantitative data patterns and trends
- Building interactive dashboards for real-time monitoring
- Creating statistical visualizations for reports
- Developing business intelligence tools
- Presenting financial data, sales metrics, or performance indicators

## Key Outputs
`svg`, `canvas`, `html+css`, `json-data`

## Quick Example
```javascript
// D3.js bar chart with NPL-FIM data binding
const data = [30, 86, 168, 281, 303, 365];
const svg = d3.select("svg")
  .attr("width", 420)
  .attr("height", 200);

svg.selectAll("rect")
  .data(data)
  .enter().append("rect")
  .attr("x", (d, i) => i * 70)
  .attr("y", d => 200 - d)
  .attr("width", 65)
  .attr("height", d => d)
  .attr("fill", "steelblue");
```

## Extended Reference
- [D3.js Gallery](https://observablehq.com/@d3/gallery) - Comprehensive visualization examples
- [Chart.js Documentation](https://www.chartjs.org/docs/) - Simple chart library
- [Observable Plot](https://observablehq.com/plot/) - Grammar of graphics approach
- [Vega-Lite](https://vega.github.io/vega-lite/) - Declarative visualization grammar
- [React + D3](https://2019.wattenberger.com/blog/react-and-d3) - Integration patterns
- [Data Visualization Handbook](https://datavizhandbook.info/) - Design principles