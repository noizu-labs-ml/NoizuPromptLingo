# Observable Plot
Grammar of graphics data visualization library by Observable. [Docs](https://observablehq.com/plot/) | [GitHub](https://github.com/observablehq/plot) | [Examples](https://observablehq.com/@observablehq/plot-gallery) | [Community](https://talk.observablehq.com/c/plot/)

## Overview
Observable Plot is a grammar of graphics library for JavaScript that provides a concise API for exploratory data visualization. Created by the makers of D3, it emphasizes simplicity and expressiveness while maintaining the power needed for complex visualizations. Plot automatically handles common visualization tasks like scales, axes, and legends while providing extensive customization options.

## Install/Setup

### Browser (ES Modules)
```html
<script type="module">
import * as Plot from "https://cdn.jsdelivr.net/npm/@observablehq/plot@0.6/+esm";
</script>
```

### NPM Installation
```bash
npm install @observablehq/plot@0.6.11
# Peer dependencies
npm install d3  # Required for data manipulation utilities
```

### Node.js Setup
```javascript
import * as Plot from "@observablehq/plot";
import {JSDOM} from "jsdom";  // For server-side rendering

// Server-side rendering setup
const dom = new JSDOM(`<!DOCTYPE html><body></body>`);
global.document = dom.window.document;
```

## Environment Requirements

### Browser Support
- **Chrome/Edge**: 63+
- **Firefox**: 60+
- **Safari**: 12+
- **Mobile**: iOS Safari 12+, Chrome Mobile 63+

### Dependencies
- **D3.js**: v7+ (automatic with Plot installation)
- **ES2017+**: Modern JavaScript environment
- **SVG Support**: Required for rendering

### Performance Characteristics
- **Dataset Size**: Optimal for <100k points
- **Memory Usage**: ~50MB for typical dashboards
- **Render Time**: <200ms for standard charts
- **File Size**: ~180KB minified + gzipped

## License and Pricing

### License
- **Type**: ISC License (MIT-compatible)
- **Commercial Use**: ✅ Permitted
- **Distribution**: ✅ Permitted
- **Modification**: ✅ Permitted
- **Attribution**: Required

### Pricing
- **Observable Plot**: Free and open source
- **Observable Platform**: Freemium model
  - Free tier: Public notebooks, community features
  - Pro tier: $20/month for private notebooks and teams
  - Enterprise: Custom pricing for organizations

## Basic Usage Examples

### Simple Scatter Plot
```javascript
import * as Plot from "@observablehq/plot";

// Sample data
const data = [
  {gdp: 2000, life_expectancy: 70, population: 1000000, continent: "Asia"},
  {gdp: 5000, life_expectancy: 75, population: 2000000, continent: "Europe"},
  {gdp: 8000, life_expectancy: 80, population: 500000, continent: "Europe"},
  {gdp: 1500, life_expectancy: 65, population: 3000000, continent: "Africa"}
];

// Create scatter plot
const chart = Plot.plot({
  marks: [
    Plot.dot(data, {
      x: "gdp",
      y: "life_expectancy",
      r: "population",
      fill: "continent",
      stroke: "white",
      strokeWidth: 1
    }),
    Plot.ruleY([0]),
    Plot.ruleX([0])
  ],
  x: {
    label: "GDP per capita →",
    domain: [0, 10000],
    tickFormat: "$,.0f"
  },
  y: {
    label: "↑ Life expectancy (years)",
    domain: [60, 85]
  },
  r: {
    range: [3, 20],
    label: "Population size"
  },
  color: {
    legend: true,
    scheme: "category10"
  },
  marginLeft: 60,
  width: 640,
  height: 400
});

document.body.append(chart);
```

### Bar Chart with Aggregation
```javascript
const salesData = [
  {month: "Jan", sales: 100, region: "North"},
  {month: "Jan", sales: 150, region: "South"},
  {month: "Feb", sales: 120, region: "North"},
  {month: "Feb", sales: 180, region: "South"}
];

const barChart = Plot.plot({
  marks: [
    Plot.barY(salesData, {
      x: "month",
      y: "sales",
      fill: "region",
      tip: true  // Interactive tooltips
    }),
    Plot.ruleY([0])
  ],
  x: {label: "Month"},
  y: {label: "Sales ($)", tickFormat: "$,.0f"},
  color: {legend: true}
});
```

### Line Chart with Time Series
```javascript
const timeData = d3.timeParse("%Y-%m-%d");
const stockData = [
  {date: timeData("2023-01-01"), price: 100},
  {date: timeData("2023-01-02"), price: 105},
  {date: timeData("2023-01-03"), price: 98},
  {date: timeData("2023-01-04"), price: 102}
];

const lineChart = Plot.plot({
  marks: [
    Plot.lineY(stockData, {
      x: "date",
      y: "price",
      stroke: "steelblue",
      strokeWidth: 2
    }),
    Plot.dot(stockData, {
      x: "date",
      y: "price",
      fill: "steelblue",
      r: 3
    })
  ],
  x: {type: "time", label: "Date"},
  y: {label: "Price ($)"},
  grid: true
});
```

## Advanced Features and Patterns

### Faceting (Small Multiples)
```javascript
// Faceted scatter plots by category
const facetedChart = Plot.plot({
  marks: [
    Plot.dot(data, {
      x: "gdp",
      y: "life_expectancy",
      fill: "continent",
      facet: "continent"
    })
  ],
  facet: {
    data: data,
    x: "continent",
    label: "Continent"
  },
  x: {label: "GDP per capita"},
  y: {label: "Life expectancy"}
});
```

### Statistical Transforms
```javascript
// Regression line with confidence interval
const regressionChart = Plot.plot({
  marks: [
    // Raw data points
    Plot.dot(data, {x: "gdp", y: "life_expectancy", fill: "lightblue"}),

    // Linear regression
    Plot.linearRegressionY(data, {
      x: "gdp",
      y: "life_expectancy",
      stroke: "red",
      strokeWidth: 2
    }),

    // Confidence interval
    Plot.linearRegressionY(data, {
      x: "gdp",
      y: "life_expectancy",
      stroke: "red",
      strokeOpacity: 0.3,
      strokeWidth: 10
    })
  ]
});

// Histogram with density overlay
const histogramChart = Plot.plot({
  marks: [
    Plot.rectY(data, Plot.binX({y: "count"}, {x: "gdp", fill: "lightblue"})),
    Plot.lineY(data, Plot.binX({y: "count"}, {x: "gdp", stroke: "red", curve: "basis"}))
  ]
});
```

### Interactive Features
```javascript
// Brushing and linking
const brushChart = Plot.plot({
  marks: [
    Plot.dot(data, {
      x: "gdp",
      y: "life_expectancy",
      fill: "continent",
      tip: true,  // Hover tooltips
      href: d => `#country-${d.country}`  // Clickable links
    })
  ],
  interactions: {
    brush: {x: "gdp", y: "life_expectancy"}  // Selection brush
  }
});

// Custom tooltip content
const tipChart = Plot.plot({
  marks: [
    Plot.dot(data, {
      x: "gdp",
      y: "life_expectancy",
      tip: {
        format: {
          gdp: d => `$${d.toLocaleString()}`,
          life_expectancy: d => `${d} years`,
          fill: false  // Hide fill value in tooltip
        }
      }
    })
  ]
});
```

### Animations and Transitions
```javascript
// Data-driven animations
function updateChart(newData) {
  const chart = Plot.plot({
    marks: [
      Plot.dot(newData, {
        x: "gdp",
        y: "life_expectancy",
        fill: "continent",
        // Transition properties
        transition: {
          duration: 750,
          ease: "cubic-out"
        }
      })
    ]
  });

  // Replace existing chart
  document.getElementById("chart-container").replaceChildren(chart);
}
```

## Strengths

### 1. **Concise Grammar of Graphics**
- Declarative syntax reduces code complexity by 60-80% compared to D3
- Automatic handling of scales, axes, legends, and layout
- Composable marks system allows complex visualizations through simple combinations
- Follows Leland Wilkinson's grammar of graphics principles

### 2. **Intelligent Defaults with Full Customization**
- Smart default styling and layout decisions
- Automatic scale inference from data types and domains
- Responsive design works across device sizes
- Complete override capability for advanced customization

### 3. **Built-in Statistical Computing**
- Native support for binning, grouping, and windowing operations
- Statistical transforms: regression, smoothing, density estimation
- Automatic handling of missing data and edge cases
- Integration with D3's data manipulation utilities

### 4. **Performance and Accessibility**
- SVG output provides crisp scaling and semantic markup
- Efficient rendering for datasets up to 100k points
- Built-in accessibility features (ARIA labels, keyboard navigation)
- Print-friendly output with vector graphics

### 5. **Ecosystem Integration**
- Seamless integration with Observable notebooks
- Works with any JavaScript framework (React, Vue, Svelte)
- Compatible with D3 data manipulation patterns
- Extensive community examples and resources

## Limitations

### 1. **Learning Curve for Complex Visualizations**
- Grammar of graphics concepts require understanding
- Advanced customization still requires D3 knowledge
- Limited documentation for edge cases and complex interactions
- Debugging can be challenging with complex mark compositions

### 2. **Performance Constraints**
- Large datasets (>100k points) cause rendering slowdowns
- Limited support for WebGL acceleration
- Memory usage can be high with complex faceted visualizations
- Animation performance degrades with many elements

### 3. **Customization Boundaries**
- Some advanced D3 patterns not directly supported
- Limited control over fine-grained styling details
- Custom mark types require extending the library
- Layout algorithms less flexible than pure D3 approaches

### 4. **Browser and Environment Dependencies**
- Requires modern JavaScript environment (ES2017+)
- SVG-only output limits some interactive possibilities
- Server-side rendering requires additional setup
- Mobile performance can be inconsistent

### 5. **Ecosystem Maturity**
- Smaller community compared to D3 or other established libraries
- Fewer third-party extensions and plugins
- Limited enterprise support options
- Breaking changes possible as library evolves

## NPL-FIM Integration Patterns

### Basic Chart Generation
```markdown
⟨npl:fim:observable-plot⟩
grammar: marks-based
data: tidy_dataset
chart_type: scatter
encoding:
  x: gdp_per_capita
  y: life_expectancy
  color: continent
  size: population
scales:
  x: linear
  y: linear
  color: categorical
legend: true
⟨/npl:fim:observable-plot⟩
```

### Faceted Visualization
```markdown
⟨npl:fim:observable-plot⟩
grammar: marks-based
data: time_series_data
chart_type: line
facet:
  columns: region
  rows: null
encoding:
  x: date
  y: sales
  color: product_category
interactions:
  - tooltip
  - brush_x
transforms:
  - smooth: loess
⟨/npl:fim:observable-plot⟩
```

### Statistical Analysis
```markdown
⟨npl:fim:observable-plot⟩
grammar: marks-based
data: measurement_data
chart_type: histogram
encoding:
  x: measurement_value
  y: count
statistical_transforms:
  - bin: {thresholds: 20}
  - density_overlay: true
  - regression_line: linear
style:
  theme: minimal
  color_scheme: viridis
⟨/npl:fim:observable-plot⟩
```

### Interactive Dashboard Component
```markdown
⟨npl:fim:observable-plot⟩
grammar: marks-based
data: dashboard_metrics
chart_type: composite
marks:
  - type: bar
    encoding: {x: month, y: revenue}
  - type: line
    encoding: {x: month, y: profit_margin}
  - type: rule
    encoding: {y: target_line}
interactions:
  - brush: {x: month}
  - zoom: true
  - crossfilter: dashboard_id
responsive: true
⟨/npl:fim:observable-plot⟩
```

### Advanced Customization
```markdown
⟨npl:fim:observable-plot⟩
grammar: marks-based
data: complex_dataset
chart_type: custom
marks:
  - type: area
    encoding: {x: date, y: value, fill: category}
    style: {fillOpacity: 0.7}
  - type: line
    encoding: {x: date, y: trend_line}
    style: {stroke: red, strokeWidth: 2}
scales:
  x: {type: time, domain: auto, nice: true}
  y: {type: linear, zero: false}
  color: {scheme: category20}
layout:
  width: 800
  height: 400
  margin: {top: 20, right: 40, bottom: 40, left: 60}
accessibility:
  title: "Revenue trends by category"
  description: "Monthly revenue data showing trends across product categories"
⟨/npl:fim:observable-plot⟩
```

## Best Practices and Patterns

### 1. **Data Preparation**
```javascript
// Ensure tidy data format
const tidyData = rawData.map(d => ({
  date: d3.timeParse("%Y-%m-%d")(d.date),
  value: +d.value,  // Ensure numeric values
  category: d.category.trim()  // Clean categorical data
}));

// Handle missing data
const cleanData = tidyData.filter(d =>
  d.date && !isNaN(d.value) && d.category
);
```

### 2. **Performance Optimization**
```javascript
// Use data sampling for large datasets
const sampledData = data.length > 50000
  ? data.filter((_, i) => i % Math.ceil(data.length / 50000) === 0)
  : data;

// Optimize mark selection
const efficientChart = Plot.plot({
  marks: [
    // Use rect instead of dot for dense scatter plots
    Plot.rect(sampledData, {
      x: "gdp",
      y: "life_expectancy",
      width: 2,
      height: 2,
      fill: "continent"
    })
  ]
});
```

### 3. **Responsive Design**
```javascript
// Responsive chart function
function createResponsiveChart(data, containerWidth) {
  const isMobile = containerWidth < 600;

  return Plot.plot({
    marks: [
      Plot.dot(data, {
        x: "gdp",
        y: "life_expectancy",
        r: isMobile ? 2 : 4,  // Smaller points on mobile
        fill: "continent"
      })
    ],
    width: containerWidth,
    height: isMobile ? containerWidth * 0.8 : containerWidth * 0.6,
    marginLeft: isMobile ? 40 : 60,
    x: {label: isMobile ? "GDP" : "GDP per capita"},
    y: {label: isMobile ? "Life exp." : "Life expectancy"}
  });
}

// Update on window resize
window.addEventListener('resize', () => {
  const container = document.getElementById('chart-container');
  const newChart = createResponsiveChart(data, container.clientWidth);
  container.replaceChildren(newChart);
});
```

### 4. **Accessibility Implementation**
```javascript
const accessibleChart = Plot.plot({
  marks: [
    Plot.dot(data, {
      x: "gdp",
      y: "life_expectancy",
      fill: "continent",
      // Accessibility attributes
      ariaLabel: d => `${d.country}: GDP $${d.gdp}, Life expectancy ${d.life_expectancy} years`,
      title: d => `${d.country}\nGDP: $${d.gdp.toLocaleString()}\nLife expectancy: ${d.life_expectancy} years`
    })
  ],
  // Chart-level accessibility
  ariaLabel: "Scatter plot showing relationship between GDP and life expectancy by continent",
  ariaDescription: "Higher GDP generally correlates with higher life expectancy, with some variation by continent"
});
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. **Data Not Rendering**
```javascript
// Problem: Empty or no chart appears
// Solution: Check data format and encoding
console.log("Data sample:", data.slice(0, 3));
console.log("Data types:", {
  x: typeof data[0]?.x,
  y: typeof data[0]?.y
});

// Ensure proper data types
const fixedData = data.map(d => ({
  ...d,
  x: +d.x,  // Convert to number
  y: +d.y   // Convert to number
}));
```

#### 2. **Scale Issues**
```javascript
// Problem: Data appears compressed or cut off
// Solution: Explicit domain setting
const chartWithDomains = Plot.plot({
  marks: [Plot.dot(data, {x: "gdp", y: "life_expectancy"})],
  x: {
    domain: d3.extent(data, d => d.gdp),  // Explicit domain
    nice: true  // Round to nice values
  },
  y: {
    domain: [0, d3.max(data, d => d.life_expectancy) * 1.1],  // Add padding
    nice: true
  }
});
```

#### 3. **Performance Problems**
```javascript
// Problem: Slow rendering with large datasets
// Solution: Implement data aggregation
const aggregatedData = d3.rollup(
  data,
  v => ({
    count: v.length,
    avgGDP: d3.mean(v, d => d.gdp),
    avgLifeExp: d3.mean(v, d => d.life_expectancy)
  }),
  d => Math.floor(d.gdp / 1000) * 1000,  // GDP bins
  d => Math.floor(d.life_expectancy / 5) * 5  // Life expectancy bins
);

const optimizedChart = Plot.plot({
  marks: [
    Plot.dot(Array.from(aggregatedData, ([gdp, lifeExpMap]) =>
      Array.from(lifeExpMap, ([lifeExp, stats]) => ({
        gdp,
        life_expectancy: lifeExp,
        count: stats.count
      }))
    ).flat(), {
      x: "gdp",
      y: "life_expectancy",
      r: "count",
      fill: "steelblue"
    })
  ]
});
```

#### 4. **Styling and Layout Issues**
```javascript
// Problem: Labels cut off or overlapping
// Solution: Adjust margins and formatting
const wellLayoutChart = Plot.plot({
  marks: [Plot.dot(data, {x: "gdp", y: "life_expectancy"})],
  marginLeft: 70,   // More space for y-axis labels
  marginBottom: 50, // More space for x-axis labels
  marginRight: 20,  // Space for legend if needed
  x: {
    label: "GDP per capita",
    tickFormat: "$,.0f",  // Currency formatting
    tickRotate: -45  // Rotate long labels
  },
  y: {
    label: "Life expectancy (years)",
    tickFormat: ".0f"  // No decimals for years
  }
});
```

### Debugging Techniques

```javascript
// Enable Plot debugging
Plot.plot.debug = true;

// Inspect generated SVG
const chart = Plot.plot({...});
console.log(chart.outerHTML);

// Check data binding
const marks = Plot.plot({...}).querySelectorAll('circle');
console.log(`Rendered ${marks.length} points from ${data.length} data points`);
```

## Integration Examples

### React Integration
```jsx
import React, { useEffect, useRef } from 'react';
import * as Plot from '@observablehq/plot';

function PlotChart({ data, options }) {
  const containerRef = useRef();

  useEffect(() => {
    if (data && containerRef.current) {
      const chart = Plot.plot({
        ...options,
        marks: [
          Plot.dot(data, {
            x: "gdp",
            y: "life_expectancy",
            fill: "continent"
          })
        ]
      });

      containerRef.current.replaceChildren(chart);
    }
  }, [data, options]);

  return <div ref={containerRef} />;
}
```

### Vue.js Integration
```vue
<template>
  <div ref="chartContainer"></div>
</template>

<script>
import * as Plot from '@observablehq/plot';

export default {
  props: ['data', 'config'],
  mounted() {
    this.renderChart();
  },
  watch: {
    data: {
      handler() { this.renderChart(); },
      deep: true
    }
  },
  methods: {
    renderChart() {
      if (this.data && this.$refs.chartContainer) {
        const chart = Plot.plot({
          ...this.config,
          marks: [
            Plot.dot(this.data, {
              x: "gdp",
              y: "life_expectancy",
              fill: "continent"
            })
          ]
        });

        this.$refs.chartContainer.replaceChildren(chart);
      }
    }
  }
};
</script>
```

### Observable Notebook Integration
```javascript
// Cell 1: Import Plot
import {Plot} from "@observablehq/plot"

// Cell 2: Load data
data = d3.csv("path/to/data.csv", d3.autoType)

// Cell 3: Create chart
Plot.plot({
  marks: [
    Plot.dot(data, {
      x: "gdp",
      y: "life_expectancy",
      fill: "continent",
      tip: true
    })
  ],
  color: {legend: true}
})
```

## Best For
`exploratory-data-analysis`, `statistical-visualization`, `dashboard-components`, `scientific-charts`, `publication-graphics`, `interactive-reports`, `time-series-analysis`, `geospatial-visualization`, `responsive-charts`, `accessible-visualizations`

## Related Tools and Alternatives
- **Vega-Lite**: More declarative, JSON-based grammar
- **D3.js**: Lower-level, complete control
- **Chart.js**: Pre-built chart types, less flexible
- **Plotly.js**: Interactive focus, different API paradigm
- **Apache ECharts**: Enterprise-focused, comprehensive features

## Community and Resources

### Official Resources
- **Documentation**: https://observablehq.com/plot/
- **API Reference**: https://github.com/observablehq/plot/blob/main/README.md
- **Examples Gallery**: https://observablehq.com/@observablehq/plot-gallery
- **GitHub Repository**: https://github.com/observablehq/plot

### Community Resources
- **Observable Forum**: https://talk.observablehq.com/c/plot/
- **Stack Overflow**: [observable-plot] tag
- **Discord**: Observable Community Server
- **Twitter**: @observablehq

### Learning Resources
- **Interactive Tutorials**: Observable notebook tutorials
- **Video Courses**: Observable Plot masterclass series
- **Blog Posts**: Official Observable blog
- **Case Studies**: Community-contributed examples

### Support Channels
- **GitHub Issues**: Bug reports and feature requests
- **Community Forum**: Questions and discussions
- **Professional Support**: Available through Observable Enterprise
- **Consulting**: Observable team available for custom projects