---
name: yFiles for HTML
description: Professional commercial graph visualization library with automatic layouts
docs: https://www.yworks.com/yfileshtml
examples: https://live.yworks.com/demos/
---

# yFiles for HTML

Enterprise-grade diagramming library with sophisticated automatic layout algorithms and rich interactions.

## Install/Setup
```bash
# Commercial license required
npm install yfiles
# Contact yWorks for licensing
```

## Basic Usage
```javascript
import { GraphComponent, GraphEditorInputMode, License } from 'yfiles';

// Set license
License.value = { /* license data */ };

// Create graph component
const graphComponent = new GraphComponent('#graphComponent');
graphComponent.inputMode = new GraphEditorInputMode();

// Create nodes
const node1 = graphComponent.graph.createNode({
  layout: [100, 100, 30, 30],
  style: new ShapeNodeStyle({
    shape: 'ellipse',
    fill: 'lightblue'
  })
});

const node2 = graphComponent.graph.createNode({
  layout: [200, 150, 30, 30],
  style: new ShapeNodeStyle({
    shape: 'rectangle',
    fill: 'orange'
  })
});

// Create edge
graphComponent.graph.createEdge(node1, node2);

// Apply automatic layout
const layout = new HierarchicLayout();
graphComponent.morphLayout(layout, '1s');

// Fit graph in view
graphComponent.fitGraphBounds();
```

## Strengths
- Industry-leading layout algorithms
- High performance with 10K+ elements
- Extensive customization
- Professional support
- Rich interaction features

## Limitations
- Expensive licensing
- Complex API
- Heavy framework

## Best For
Enterprise visualization, network management tools, CAD applications, business process modeling