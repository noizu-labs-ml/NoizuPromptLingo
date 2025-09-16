# Cytoscape.js
Graph theory network visualization library. [Docs](https://js.cytoscape.org/) | [Demos](https://js.cytoscape.org/demos/)

## Install/Setup
```bash
npm install cytoscape  # Node.js
# Or CDN for browser
<script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.28.1/cytoscape.min.js"></script>
```

## Basic Usage
```javascript
const cy = cytoscape({
  container: document.getElementById('cy'),
  elements: [
    { data: { id: 'a', label: 'Node A' } },
    { data: { id: 'b', label: 'Node B' } },
    { data: { source: 'a', target: 'b' } }
  ],
  style: [{
    selector: 'node',
    style: { 'label': 'data(label)' }
  }],
  layout: { name: 'cose' }
});
```

## Strengths
- Rich graph algorithms (shortest path, centrality, clustering)
- Multiple layout algorithms (force-directed, hierarchical, circular)
- Extensive API for interaction and animation
- Plugin ecosystem for extended functionality

## Limitations
- Steep learning curve for complex visualizations
- Performance degrades with >1000 nodes
- Requires manual optimization for large graphs

## Best For
`network-analysis`, `biological-pathways`, `social-networks`, `dependency-graphs`, `mind-maps`