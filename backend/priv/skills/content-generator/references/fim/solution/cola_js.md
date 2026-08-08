---
name: Cola.js (WebCola)
description: Constraint-based graph layout library with advanced positioning algorithms
docs: https://ialab.it.monash.edu/webcola/
examples: https://ialab.it.monash.edu/webcola/examples.html
---

# Cola.js (WebCola)

Constraint-based layout for network visualization with support for hierarchical grouping and alignment.

## Install/Setup
```bash
npm install webcola
# or via CDN
<script src="https://cdn.jsdelivr.net/npm/webcola@latest/WebCola/cola.min.js"></script>
```

## Basic Usage
```javascript
import * as cola from 'webcola';

const nodes = [
  { x: 100, y: 100, width: 50, height: 30 },
  { x: 200, y: 100, width: 50, height: 30 },
  { x: 150, y: 200, width: 50, height: 30 }
];

const links = [
  { source: 0, target: 1, length: 100 },
  { source: 1, target: 2, length: 100 }
];

const constraints = [
  { type: 'alignment', axis: 'y', offsets: [{ node: 0 }, { node: 1 }] }
];

const colaLayout = cola.d3adaptor(d3)
  .size([width, height])
  .nodes(nodes)
  .links(links)
  .constraints(constraints)
  .linkDistance(100)
  .avoidOverlaps(true)
  .start();

// Use with D3 for rendering
const svg = d3.select('svg');
const node = svg.selectAll('.node').data(nodes);
const link = svg.selectAll('.link').data(links);
```

## Strengths
- Advanced constraint system
- Hierarchical grouping
- Overlap prevention
- Works with D3.js
- Academic backing

## Limitations
- Steeper learning curve
- Less active development
- Limited documentation

## Best For
UML diagrams, hierarchical networks, constrained layouts, academic visualizations