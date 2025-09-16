# D3.js Data Visualization Use Case

## Overview
D3.js excels at creating interactive, data-driven visualizations through DOM manipulation and scalable vector graphics (SVG).

## NPL-FIM Integration
```npl
@fim:d3_js {
  data_source: "user_metrics.json"
  chart_type: "bar_chart"
  interactive: true
  responsive: true
}
```

## Common Implementation
```javascript
// Load data and create bar chart
d3.json("data.json").then(data => {
  const svg = d3.select("#chart")
    .append("svg")
    .attr("width", 800)
    .attr("height", 400);

  const bars = svg.selectAll("rect")
    .data(data)
    .enter()
    .append("rect")
    .attr("x", (d, i) => i * 40)
    .attr("y", d => 400 - d.value * 10)
    .attr("width", 35)
    .attr("height", d => d.value * 10)
    .attr("fill", "steelblue");
});
```

## Use Cases
- Dashboard analytics with real-time updates
- Complex multi-dimensional data exploration
- Custom interactive chart components
- Geospatial data mapping and visualization
- Time series analysis with zoom/pan capabilities

## NPL-FIM Benefits
- Declarative chart configuration through NPL syntax
- Automatic data binding and transformation
- Responsive design patterns built-in
- Animation and transition management