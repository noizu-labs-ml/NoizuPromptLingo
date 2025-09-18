---
name: D3 Force
description: Force-directed graph layout module for D3.js with customizable physics simulation
docs: https://github.com/d3/d3-force
examples: https://observablehq.com/@d3/force-directed-graph
---

# D3 Force

Physics-based force simulation for positioning nodes in network graphs using D3.js.

## Install/Setup
```bash
npm install d3-force d3-selection
# or via CDN
<script src="https://cdn.jsdelivr.net/npm/d3@7"></script>
```

## Basic Usage
```javascript
import * as d3 from 'd3';

const nodes = [
  { id: 'a', group: 1 },
  { id: 'b', group: 2 },
  { id: 'c', group: 2 }
];

const links = [
  { source: 'a', target: 'b', value: 1 },
  { source: 'b', target: 'c', value: 2 }
];

const simulation = d3.forceSimulation(nodes)
  .force('link', d3.forceLink(links).id(d => d.id).distance(50))
  .force('charge', d3.forceManyBody().strength(-300))
  .force('center', d3.forceCenter(width / 2, height / 2))
  .force('collision', d3.forceCollide().radius(20));

simulation.on('tick', () => {
  // Update node and link positions
  node.attr('cx', d => d.x).attr('cy', d => d.y);
  link.attr('x1', d => d.source.x).attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x).attr('y2', d => d.target.y);
});
```

## Strengths
- Highly customizable forces
- Smooth animations
- Part of D3 ecosystem
- Fine-grained control
- Excellent performance

## Limitations
- Requires D3 knowledge
- Manual rendering setup
- No built-in UI controls

## Best For
Custom network visualizations, research papers, data journalism, animated transitions