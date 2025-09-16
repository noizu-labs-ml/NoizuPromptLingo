# D3.js Networks & Graphs Use Case

## Overview
D3.js provides powerful force simulation and graph layout algorithms for visualizing network relationships and hierarchical data structures.

## NPL-FIM Integration
```npl
@fim:d3_js {
  layout_type: "force_directed"
  node_data: "network_nodes.json"
  edge_data: "network_links.json"
  physics_enabled: true
}
```

## Common Implementation
```javascript
// Create force-directed network graph
const simulation = d3.forceSimulation(nodes)
  .force("link", d3.forceLink(links).id(d => d.id))
  .force("charge", d3.forceManyBody().strength(-300))
  .force("center", d3.forceCenter(width / 2, height / 2));

const link = svg.selectAll("line")
  .data(links)
  .enter().append("line")
  .attr("stroke", "#999");

const node = svg.selectAll("circle")
  .data(nodes)
  .enter().append("circle")
  .attr("r", 5)
  .call(d3.drag());

simulation.on("tick", () => {
  link.attr("x1", d => d.source.x)
      .attr("y1", d => d.source.y)
      .attr("x2", d => d.target.x)
      .attr("y2", d => d.target.y);

  node.attr("cx", d => d.x)
      .attr("cy", d => d.y);
});
```

## Use Cases
- Social network analysis and visualization
- Organizational hierarchy mapping
- Dependency graph visualization
- Knowledge graph exploration
- System architecture diagrams

## NPL-FIM Benefits
- Automatic layout algorithm selection
- Interactive node manipulation
- Dynamic graph updates and animations