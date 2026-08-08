# Networks & Graphs
Node-link diagrams for relationships, hierarchies, and network topology visualization.
[Documentation](https://d3js.org/d3-force)

## WWHW
**What**: Visualizing connected data as networks with nodes and edges, including force-directed layouts.
**Why**: Reveal relationships, hierarchies, and patterns in complex interconnected systems.
**How**: Force simulations, tree layouts, and graph algorithms using D3.js or specialized libraries.
**When**: Social networks, dependency graphs, organizational charts, system architecture diagrams.

## When to Use
- Mapping relationships between entities or concepts
- Visualizing software dependencies and module structures
- Creating organizational hierarchies and team structures
- Analyzing social networks and communication patterns
- Displaying knowledge graphs and semantic relationships

## Key Outputs
`svg`, `canvas`, `interactive-html`, `json-graph`

## Quick Example
```javascript
// Force-directed graph with D3.js
const nodes = [{id: "A"}, {id: "B"}, {id: "C"}];
const links = [{source: "A", target: "B"}, {source: "B", target: "C"}];

const simulation = d3.forceSimulation(nodes)
  .force("link", d3.forceLink(links).id(d => d.id))
  .force("charge", d3.forceManyBody().strength(-300))
  .force("center", d3.forceCenter(400, 300));

const svg = d3.select("svg");
const link = svg.selectAll("line").data(links).enter().append("line");
const node = svg.selectAll("circle").data(nodes).enter().append("circle")
  .attr("r", 10).call(d3.drag());
```

## Extended Reference
- [D3 Force Documentation](https://github.com/d3/d3-force) - Physics simulations
- [Cytoscape.js](https://cytoscape.org/) - Graph theory library
- [Vis.js Network](https://visjs.github.io/vis-network/docs/network/) - Interactive networks
- [Sigma.js](https://www.sigmajs.org/) - Large graph visualization
- [Graphology](https://graphology.github.io/) - Graph data structure library
- [Network Visualization Principles](https://kateto.net/networks-r-igraph) - Design guidelines