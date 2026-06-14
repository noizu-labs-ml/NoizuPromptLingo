---
name: Sigma.js
description: High-performance WebGL graph rendering library for large-scale network visualization
docs: https://www.sigmajs.org/
examples: https://www.sigmajs.org/demo/
---

# Sigma.js

WebGL-powered graph rendering library optimized for displaying large networks with thousands of nodes.

## Install/Setup
```bash
npm install sigma graphology graphology-layout-forceatlas2
# or via CDN
<script src="https://cdn.jsdelivr.net/npm/sigma@latest/build/sigma.min.js"></script>
```

## Basic Usage
```javascript
import Graph from 'graphology';
import Sigma from 'sigma';

const graph = new Graph();
graph.addNode('n1', { x: 0, y: 0, size: 10, label: 'Node 1', color: '#FF0000' });
graph.addNode('n2', { x: 100, y: 50, size: 8, label: 'Node 2', color: '#00FF00' });
graph.addEdge('n1', 'n2', { size: 2 });

const sigma = new Sigma(graph, document.getElementById('container'), {
  renderLabels: true,
  renderEdgeLabels: true
});
```

## Strengths
- WebGL rendering for 10K+ nodes
- Smooth pan/zoom interactions
- Extensible plugin system
- Memory efficient for large graphs
- Force-directed layouts included

## Limitations
- Learning curve for graphology
- Limited built-in layouts
- WebGL dependency limits older browsers

## Best For
Large network visualizations, social graphs, knowledge graphs, real-time network monitoring