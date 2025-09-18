---
name: GoJS
description: Feature-rich commercial diagramming library for interactive flowcharts and graphs
docs: https://gojs.net/latest/
examples: https://gojs.net/latest/samples/
---

# GoJS

Commercial JavaScript library for building interactive diagrams, flowcharts, and complex graphs.

## Install/Setup
```bash
npm install gojs
# Requires license for production use
```

## Basic Usage
```javascript
import * as go from 'gojs';

const $ = go.GraphObject.make;

const diagram = $(go.Diagram, 'myDiagramDiv', {
  'undoManager.isEnabled': true,
  layout: $(go.TreeLayout, { angle: 90, layerSpacing: 35 })
});

// Define node template
diagram.nodeTemplate = $(go.Node, 'Horizontal',
  { background: '#44CCFF' },
  $(go.Picture, { width: 35, height: 35 },
    new go.Binding('source')),
  $(go.TextBlock, 'Default Text',
    { margin: 12, font: 'bold 16px sans-serif' },
    new go.Binding('text', 'name'))
);

// Define link template
diagram.linkTemplate = $(go.Link,
  { routing: go.Link.Orthogonal, corner: 5 },
  $(go.Shape, { strokeWidth: 3, stroke: '#555' })
);

// Set model
diagram.model = new go.GraphLinksModel(
  [
    { key: 1, name: 'Alpha', source: 'icon1.png' },
    { key: 2, name: 'Beta', source: 'icon2.png' }
  ],
  [
    { from: 1, to: 2 }
  ]
);
```

## Strengths
- Extensive feature set
- Professional templates
- Built-in undo/redo
- Touch support
- Excellent documentation

## Limitations
- Commercial license required
- Large library size
- Proprietary API

## Best For
Enterprise applications, BPMN diagrams, org charts, complex flowcharts, commercial products