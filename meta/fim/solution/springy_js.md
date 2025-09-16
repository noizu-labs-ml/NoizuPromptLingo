---
name: Springy.js
description: Lightweight force-directed graph layout library with spring physics simulation
docs: http://getspringy.com/
examples: http://getspringy.com/#demo
---

# Springy.js

Simple force-directed graph layout algorithm using spring forces between nodes.

## Install/Setup
```bash
npm install springy
# or download directly
<script src="springy.js"></script>
<script src="springyui.js"></script>
```

## Basic Usage
```javascript
// Create graph
const graph = new Springy.Graph();

// Add nodes
const node1 = graph.newNode({ label: 'Node 1', color: 'red' });
const node2 = graph.newNode({ label: 'Node 2', color: 'blue' });
const node3 = graph.newNode({ label: 'Node 3', color: 'green' });

// Add edges
graph.newEdge(node1, node2, { color: '#999', label: 'Edge 1' });
graph.newEdge(node2, node3, { color: '#999', label: 'Edge 2' });

// Render with Canvas
const canvas = document.getElementById('canvas');
const layout = new Springy.Layout.ForceDirected(
  graph,
  400.0, // Spring stiffness
  400.0, // Node repulsion
  0.5    // Damping
);

const renderer = new Springy.Renderer(
  layout,
  () => { canvas.width = canvas.width; }, // Clear
  (edge, p1, p2) => { /* Draw edge */ },
  (node, p) => { /* Draw node */ }
);
renderer.start();
```

## Strengths
- Very lightweight (8KB)
- Simple API
- Smooth animations
- No dependencies
- Easy customization

## Limitations
- Basic features only
- Limited layout options
- Small community
- Minimal documentation

## Best For
Simple network diagrams, educational visualizations, lightweight embedded graphs