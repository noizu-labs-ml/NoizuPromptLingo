# Observable Plot NPL-FIM Solution

Observable Plot provides concise, expressive data visualization with a grammar of graphics approach.

## Installation

```html
<script type="module">
import * as Plot from "https://cdn.jsdelivr.net/npm/@observablehq/plot@0.6/+esm";
</script>
```

NPM: `npm install @observablehq/plot`

## Working Example

```javascript
import * as Plot from "@observablehq/plot";

const chart = Plot.plot({
  marks: [
    Plot.dot(data, {
      x: "gdp",
      y: "life_expectancy",
      r: "population",
      fill: "continent"
    }),
    Plot.ruleY([0]),
    Plot.ruleX([0])
  ],
  x: { label: "GDP per capita →" },
  y: { label: "↑ Life expectancy" },
  color: { legend: true }
});

document.body.append(chart);
```

## NPL-FIM Integration

```markdown
⟨npl:fim:observable-plot⟩
grammar: marks-based
data: tidy_dataset
facets: [year, region]
interactions: brush
⟨/npl:fim:observable-plot⟩
```

## Key Features
- Faceted plots for small multiples
- Statistical transforms (bin, group, window)
- Automatic scale inference
- SVG output with semantic markup
- Responsive by default

## Best Practices
- Use marks composition for layered visualizations
- Apply transforms for data aggregation
- Leverage facets for comparative analysis
- Export SVG for publication quality