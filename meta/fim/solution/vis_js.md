---
name: Vis.js Network
description: Interactive network visualization library with physics simulation and clustering
docs: https://visjs.github.io/vis-network/docs/network/
examples: https://visjs.github.io/vis-network/examples/
---

# Vis.js Network

Browser-based dynamic network visualization with built-in physics simulation and interaction handling.

## Install/Setup
```bash
npm install vis-network
# or via CDN
<link href="https://cdn.jsdelivr.net/npm/vis-network@latest/dist/dist/vis-network.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/vis-network@latest/dist/vis-network.min.js"></script>
```

## Basic Usage
```javascript
import { Network } from 'vis-network/standalone';

const nodes = [
  { id: 1, label: 'Node 1', color: '#ff0000' },
  { id: 2, label: 'Node 2', color: '#00ff00' },
  { id: 3, label: 'Node 3', color: '#0000ff' }
];

const edges = [
  { from: 1, to: 2, arrows: 'to' },
  { from: 1, to: 3, arrows: 'to' }
];

const container = document.getElementById('network');
const data = { nodes, edges };
const options = {
  physics: { enabled: true, solver: 'forceAtlas2Based' },
  interaction: { hover: true, zoomView: true }
};

const network = new Network(container, data, options);
```

## Strengths
- Rich interaction features
- Built-in physics engines
- Clustering & hierarchical layouts
- Extensive configuration options
- Good documentation

## Limitations
- Performance issues with 1000+ nodes
- Large bundle size
- Complex configuration API

## Best For
Interactive network diagrams, organizational charts, dependency graphs, workflow visualization