# NPL-FIM Network and Graph Visualization: Comprehensive Guide

## Table of Contents

1. [Overview and Background](#overview-and-background)
2. [Graph Theory Fundamentals](#graph-theory-fundamentals)
3. [Network Visualization Types](#network-visualization-types)
4. [Layout Algorithms](#layout-algorithms)
5. [Interactive Network Design](#interactive-network-design)
6. [Tool Recommendations](#tool-recommendations)
7. [Performance Optimization](#performance-optimization)
8. [Accessibility Guidelines](#accessibility-guidelines)
9. [Code Examples](#code-examples)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)
12. [Learning Resources](#learning-resources)

## Overview and Background

Network and graph visualization represents one of the most complex and powerful forms of data visualization, enabling the exploration of relationships, hierarchies, and connections between entities. In the NPL-FIM (Noizu PromptLingo - Fill-in-the-Middle) context, network visualization leverages structured prompting to create sophisticated, interactive graph representations that can handle everything from small social networks to large-scale infrastructure mappings.

### Why Network Visualization Matters

Networks are everywhere in our modern world:
- **Social Networks**: Understanding human connections and influence patterns
- **Infrastructure Networks**: Mapping system dependencies and communication flows
- **Biological Networks**: Protein interactions, neural networks, ecological relationships
- **Information Networks**: Knowledge graphs, citation networks, hyperlink structures
- **Business Networks**: Supply chains, organizational structures, market relationships

### NPL-FIM Advantages for Network Visualization

1. **Semantic Relationship Modeling**: Use NPL syntax to define complex relationship types
2. **Dynamic Graph Generation**: Leverage FIM capabilities for real-time network updates
3. **Multi-Scale Visualization**: Automatically adapt detail levels based on graph size
4. **Context-Aware Layouts**: Intelligently choose layout algorithms based on graph characteristics
5. **Interactive Exploration**: Generate responsive interfaces for network navigation

### Historical Context

Graph visualization has evolved from simple node-link diagrams drawn by hand to sophisticated interactive systems capable of handling millions of nodes and edges. The field combines insights from graph theory, human-computer interaction, and visual perception research to create effective representations of complex relational data.

Key milestones include:
- **1960s**: Early computer-generated graph drawings
- **1980s**: Development of fundamental layout algorithms (spring-embedder)
- **1990s**: Web-based network visualization emergence
- **2000s**: Large-scale network analysis tools
- **2010s**: Interactive web-based graph libraries
- **2020s**: AI-assisted graph layout and analysis

## Graph Theory Fundamentals

### Basic Concepts

#### Nodes and Edges
- **Nodes (Vertices)**: Individual entities in the network
- **Edges (Links)**: Connections or relationships between nodes
- **Directed vs. Undirected**: Whether relationships have direction
- **Weighted vs. Unweighted**: Whether connections have associated values

#### Graph Types

**Simple Graphs**:
- Undirected, unweighted connections
- Examples: Friendship networks, collaboration networks

**Directed Graphs (Digraphs)**:
- Connections have direction (source → target)
- Examples: Twitter follows, web page links, workflow processes

**Weighted Graphs**:
- Connections have associated values
- Examples: Transportation networks (distances), communication frequency

**Multipartite Graphs**:
- Nodes divided into distinct groups
- Examples: Author-paper relationships, actor-movie connections

#### Graph Properties

**Connectivity Measures**:
- **Degree**: Number of connections per node
- **Path Length**: Distance between nodes
- **Clustering Coefficient**: Local connectivity density
- **Betweenness Centrality**: Node importance in shortest paths

**Global Properties**:
- **Density**: Ratio of actual to possible edges
- **Diameter**: Maximum shortest path length
- **Components**: Disconnected subgraphs
- **Small-World Property**: High clustering with short path lengths

### NPL Syntax for Graph Definition

```npl
⟪network-graph⟫
  ↦ nodes: [
    {
      ↦ id: "${node_id}"
      ↦ label: "${node_label}"
      ↦ type: "${node_type}"
      ↦ properties: ${node_properties}
    }
  ]
  ↦ edges: [
    {
      ↦ source: "${source_id}"
      ↦ target: "${target_id}"
      ↦ type: "${edge_type}"
      ↦ weight: ${edge_weight}
      ↦ properties: ${edge_properties}
    }
  ]
  ↦ layout: "${layout_algorithm}"
  ↦ styling: ${visual_encoding}
⟪/network-graph⟫
```

### Mathematical Foundations

#### Adjacency Representations

**Adjacency Matrix**:
```
A[i][j] = {
  1 if edge exists between node i and j
  0 otherwise
}
```

**Adjacency List**:
```
adjacencyList = {
  nodeA: [nodeB, nodeC, nodeD],
  nodeB: [nodeA, nodeE],
  ...
}
```

#### Common Algorithms

**Traversal Algorithms**:
- Breadth-First Search (BFS)
- Depth-First Search (DFS)
- Dijkstra's shortest path

**Centrality Measures**:
- Degree centrality
- Betweenness centrality
- Closeness centrality
- PageRank

**Community Detection**:
- Modularity optimization
- Hierarchical clustering
- Label propagation

## Network Visualization Types

### Node-Link Diagrams

#### Standard Network Layouts
**Best for**: General-purpose network visualization
**Characteristics**:
- Nodes represented as shapes (circles, squares, etc.)
- Edges as lines or curves connecting nodes
- Flexible positioning based on layout algorithms

**Use Cases**:
- Social network analysis
- Organizational charts
- System architecture diagrams
- Citation networks

#### Hierarchical Networks
**Best for**: Tree structures and directed acyclic graphs
**Characteristics**:
- Clear parent-child relationships
- Levels representing hierarchy depth
- Often uses vertical or radial layouts

**Layout Options**:
- **Tree Layout**: Traditional top-down hierarchy
- **Radial Layout**: Circular arrangement from center
- **Indented Layout**: File-system style representation
- **Icicle Layout**: Nested rectangles showing hierarchy

### Matrix-Based Visualization

#### Adjacency Matrices
**Best for**: Dense networks and pattern detection
**Characteristics**:
- Rows and columns represent nodes
- Cell values represent edge weights or existence
- Effective for pattern recognition in dense graphs

**Advantages**:
- Scalable to large networks
- Clear pattern visibility
- No edge crossing issues
- Quantitative relationship display

#### Node-Link Hybrid
**Best for**: Combined overview and detail exploration
**Characteristics**:
- Matrix view for dense regions
- Node-link for sparse regions
- Interactive switching between representations

### Specialized Network Types

#### Bipartite Graphs
**Structure**: Two distinct node types with connections only between types
**Applications**:
- Author-publication networks
- Actor-movie relationships
- Gene-disease associations
- Customer-product interactions

**Visualization Approaches**:
- **Two-Column Layout**: Separate columns for each node type
- **Circular Layout**: Node types on opposite sides
- **Layered Layout**: Horizontal separation with vertical positioning

#### Multilayer Networks
**Structure**: Multiple relationship types or time slices
**Applications**:
- Social networks with different relationship types
- Transportation networks with multiple modes
- Temporal networks showing evolution over time

**Visualization Strategies**:
- **Layer Separation**: Side-by-side network views
- **Edge Bundling**: Group similar edge types
- **Animation**: Show temporal changes
- **Lens Effects**: Focus on specific layers

#### Geographic Networks
**Structure**: Nodes with geographic coordinates
**Applications**:
- Transportation networks
- Communication infrastructure
- Disease spread patterns
- Trade relationships

**Visualization Features**:
- **Map Integration**: Overlay on geographic maps
- **Great Circle Paths**: Curved edges following Earth's surface
- **Choropleth Combination**: Color-coded regions with network overlay
- **Multi-Scale Views**: Country, regional, and local levels

## Layout Algorithms

### Force-Directed Algorithms

#### Spring-Embedder Model
**Principle**: Treat edges as springs and nodes as masses
**Behavior**:
- Connected nodes attract each other
- All nodes repel each other
- System seeks equilibrium state

**Advantages**:
- Natural-looking layouts
- Reveals community structure
- Works well for medium-sized graphs

**Limitations**:
- Can be slow for large graphs
- May not converge to stable layout
- Sensitive to initial positioning

#### Implementation Example
```javascript
function forceSimulation(nodes, edges) {
  const simulation = d3.forceSimulation(nodes)
    .force("link", d3.forceLink(edges)
      .id(d => d.id)
      .distance(100)
      .strength(0.1))
    .force("charge", d3.forceManyBody()
      .strength(-300)
      .distanceMax(500))
    .force("center", d3.forceCenter(width / 2, height / 2))
    .force("collision", d3.forceCollide()
      .radius(d => d.radius + 5));

  return simulation;
}
```

#### Fruchterman-Reingold Algorithm
**Improvements over basic spring model**:
- Temperature system for gradual convergence
- Adaptive step sizes
- Better edge length uniformity

**Parameters**:
- **k**: Optimal edge length
- **Temperature**: Controls movement magnitude
- **Iterations**: Number of simulation steps

### Hierarchical Layouts

#### Tree Layouts
**Reingold-Tilford Algorithm**:
- Optimizes space usage in tree drawings
- Ensures no node overlaps
- Maintains aesthetic tree properties

**Layered Approach**:
1. Assign nodes to levels based on distance from root
2. Order nodes within levels to minimize crossings
3. Adjust positions for aesthetic improvement

#### Radial Layouts
**Characteristics**:
- Root node at center
- Children arranged in concentric circles
- Angular positioning based on subtree size

**Advantages**:
- Compact representation
- Natural focus on root
- Good for exploring tree structure

### Specialized Algorithms

#### Circular Layouts
**Applications**:
- Chord diagrams
- Network cycles
- Periodic structures

**Implementation Considerations**:
- Node ordering strategies
- Arc length optimization
- Label placement

#### Grid-Based Layouts
**Applications**:
- Regular network structures
- Lattice graphs
- Spatial networks

**Features**:
- Predictable positioning
- Easy navigation
- Clear spatial relationships

#### Multi-Level Algorithms
**Approach**:
1. Coarsen graph through node merging
2. Apply layout algorithm to coarsened graph
3. Refine layout by expanding merged nodes

**Benefits**:
- Handles large graphs efficiently
- Maintains global structure
- Reduces local minima problems

### Layout Selection Criteria

#### Graph Characteristics
- **Size**: Number of nodes and edges
- **Density**: Ratio of edges to possible edges
- **Structure**: Tree, cycle, clique, or general graph
- **Clustering**: Presence of distinct communities

#### Visualization Goals
- **Overview**: Global structure understanding
- **Detail**: Local relationship exploration
- **Pattern Detection**: Identifying specific structures
- **Navigation**: Moving through large networks

#### Performance Requirements
- **Real-time Updates**: Dynamic graph changes
- **Interaction Responsiveness**: User manipulation feedback
- **Memory Constraints**: Available computational resources
- **Rendering Speed**: Frame rate requirements

## Interactive Network Design

### User Interaction Patterns

#### Navigation and Exploration

**Pan and Zoom**:
- **Semantic Zoom**: Adjust detail level based on zoom factor
- **Constrained Navigation**: Prevent navigation beyond graph bounds
- **Smooth Transitions**: Animated movement between views
- **Reset Controls**: Return to overview state

**Node Selection and Highlighting**:
- **Single Selection**: Focus on individual nodes
- **Multi-Selection**: Compare multiple nodes
- **Neighborhood Highlighting**: Show connected nodes
- **Path Highlighting**: Visualize shortest paths

**Filtering and Search**:
- **Attribute Filtering**: Show/hide based on node/edge properties
- **Topological Filtering**: Filter by structural properties
- **Text Search**: Find nodes by label or attributes
- **Pattern Matching**: Identify structural motifs

#### Data Manipulation

**Dynamic Updates**:
- **Incremental Updates**: Add/remove nodes and edges
- **Batch Updates**: Process multiple changes efficiently
- **Animation**: Smooth transitions during updates
- **State Management**: Undo/redo capabilities

**Layout Adjustment**:
- **Manual Positioning**: Drag nodes to desired locations
- **Layout Switching**: Change between different algorithms
- **Parameter Tuning**: Adjust layout algorithm settings
- **Constraint Application**: Pin nodes in fixed positions

### Advanced Interaction Techniques

#### Lens and Focus Techniques

**Fisheye Distortion**:
- Magnify focus area while maintaining context
- Smooth distortion transition
- Preserve global structure awareness

**Detail-in-Context**:
- Show detailed view within overview
- Multiple simultaneous focus regions
- Coordinated highlighting between views

#### Temporal Navigation

**Time Slider Controls**:
- Navigate through network evolution
- Play/pause animation controls
- Speed adjustment
- Bookmark significant time points

**Temporal Brushing**:
- Select time ranges for analysis
- Aggregate temporal data
- Compare different time periods
- Identify temporal patterns

### Information Display

#### Node Information

**Tooltip Systems**:
- On-demand attribute display
- Rich content including images and links
- Responsive positioning
- Contextual information based on selection

**Panel Integration**:
- Dedicated information panels
- Tabbed interface for different data types
- Synchronized highlighting
- Editable attributes

#### Edge Information

**Edge Bundling**:
- Group similar edges to reduce visual clutter
- Hierarchical bundling for multi-level structures
- Interactive bundle expansion
- Curve-based routing for aesthetic appeal

**Edge Filtering**:
- Threshold-based display
- Type-based filtering
- Dynamic edge opacity
- Pattern-based selection

### Multi-View Coordination

#### Linked Views
- **Selection Linking**: Coordinate selections across views
- **Navigation Linking**: Synchronized pan and zoom
- **Filter Linking**: Apply filters across multiple representations
- **Highlight Linking**: Coordinated element highlighting

#### Overview + Detail
- **Minimap Navigation**: Small overview with current view indicator
- **Zoom Slider**: Dedicated zoom control
- **Breadcrumb Navigation**: Show current focus path
- **Quick Navigation**: Jump to specific graph regions

## Tool Recommendations

### JavaScript Libraries

| Tool | Strengths | Best For | Learning Curve | NPL-FIM Integration |
|------|-----------|----------|----------------|-------------------|
| D3.js | Maximum customization, performance | Custom network visualizations | Steep | Excellent |
| Cytoscape.js | Rich API, layout algorithms | Interactive graph applications | Moderate | Good |
| Vis.js | Easy setup, good documentation | Quick prototypes, dashboards | Gentle | Good |
| Sigma.js | Performance, WebGL rendering | Large networks | Moderate | Good |
| Graphology | Modern architecture, algorithms | Analysis-heavy applications | Moderate | Excellent |

### Specialized Tools

| Tool | Strengths | Best For | Platform | Cost |
|------|-----------|----------|----------|------|
| Gephi | Advanced analytics, plugins | Research, large-scale analysis | Desktop | Free |
| Cytoscape | Biological networks, research | Scientific visualization | Desktop | Free |
| yEd | Professional diagrams | Business process mapping | Desktop | Free/Paid |
| Neo4j Browser | Graph database integration | Database visualization | Web/Desktop | Free/Paid |
| Graphviz | Programmatic generation | Automated diagram creation | Command-line | Free |

### Web-Based Platforms

| Platform | Strengths | Best For | Accessibility | Integration |
|----------|-----------|----------|---------------|-------------|
| Observable | Collaborative development | Rapid prototyping | High | D3.js |
| Flourish | No-code creation | Non-technical users | High | Limited |
| Kumu | Social network analysis | Community mapping | Medium | Good |
| Linkurious | Enterprise features | Business analytics | Medium | Excellent |
| Graph Commons | Collaborative mapping | Public research projects | High | Limited |

### Python Libraries

| Library | Strengths | Best For | Ecosystem | Performance |
|---------|-----------|----------|-----------|-------------|
| NetworkX | Comprehensive algorithms | Analysis and computation | Scientific Python | Good |
| Plotly | Interactive web visualizations | Jupyter notebooks | Dash ecosystem | Good |
| Bokeh | Interactive applications | Complex dashboards | PyData | Good |
| Pyvis | Easy network visualization | Quick exploration | Limited | Fair |
| Graph-tool | High performance | Large-scale analysis | GTK/Qt | Excellent |

### R Libraries

| Package | Strengths | Best For | Integration | Documentation |
|---------|-----------|----------|-------------|---------------|
| igraph | Comprehensive analysis | Statistical analysis | R ecosystem | Excellent |
| ggraph | Grammar of graphics | Publication graphics | ggplot2 | Good |
| visNetwork | Interactive visualizations | Shiny applications | htmlwidgets | Good |
| networkD3 | D3.js integration | Web applications | R/JavaScript | Fair |
| tidygraph | Tidy data principles | Data pipeline integration | Tidyverse | Good |

## Performance Optimization

### Large Network Handling

#### Level-of-Detail Rendering

**Distance-Based LOD**:
- Adjust node detail based on zoom level
- Simplify edge rendering at overview levels
- Progressive enhancement as users zoom in

**Importance-Based LOD**:
- Show high-degree nodes at all zoom levels
- Filter low-importance edges
- Maintain network skeleton structure

**Implementation Strategy**:
```javascript
class LODNetworkRenderer {
  constructor(graph, viewport) {
    this.graph = graph;
    this.viewport = viewport;
    this.lodLevels = this.calculateLODLevels();
  }

  calculateLODLevels() {
    return {
      overview: { maxNodes: 1000, maxEdges: 2000 },
      intermediate: { maxNodes: 5000, maxEdges: 10000 },
      detail: { maxNodes: 20000, maxEdges: 50000 }
    };
  }

  getCurrentLOD() {
    const zoomLevel = this.viewport.getZoom();
    if (zoomLevel < 0.5) return 'overview';
    if (zoomLevel < 2.0) return 'intermediate';
    return 'detail';
  }

  filterGraphForLOD(lod) {
    const config = this.lodLevels[lod];

    // Filter nodes by importance
    const importantNodes = this.graph.nodes
      .sort((a, b) => b.degree - a.degree)
      .slice(0, config.maxNodes);

    // Filter edges by weight and node inclusion
    const relevantEdges = this.graph.edges
      .filter(edge =>
        importantNodes.includes(edge.source) &&
        importantNodes.includes(edge.target))
      .sort((a, b) => b.weight - a.weight)
      .slice(0, config.maxEdges);

    return { nodes: importantNodes, edges: relevantEdges };
  }
}
```

#### Virtualization Techniques

**Viewport Culling**:
- Only render visible elements
- Implement spatial indexing for efficient queries
- Update visible set during pan/zoom operations

**Batched Rendering**:
- Group similar rendering operations
- Minimize state changes
- Use instanced rendering for similar elements

**Incremental Updates**:
- Track changed elements only
- Implement dirty flagging system
- Optimize re-layout calculations

### Memory Management

#### Data Structure Optimization

**Efficient Graph Representation**:
```javascript
class OptimizedGraph {
  constructor() {
    // Use typed arrays for better memory efficiency
    this.nodePositions = new Float32Array(maxNodes * 2);
    this.nodeIds = new Int32Array(maxNodes);
    this.edgeIndices = new Int32Array(maxEdges * 2);

    // Spatial indexing for fast queries
    this.spatialIndex = new QuadTree();

    // Adjacency list for efficient traversal
    this.adjacencyList = new Map();
  }

  addNode(id, x, y) {
    const index = this.nodeCount++;
    this.nodeIds[index] = id;
    this.nodePositions[index * 2] = x;
    this.nodePositions[index * 2 + 1] = y;
    this.spatialIndex.insert({ id, x, y, index });
  }

  getNodesInRegion(bounds) {
    return this.spatialIndex.query(bounds);
  }
}
```

#### Garbage Collection Optimization

**Object Pooling**:
- Reuse DOM elements and data objects
- Implement element recycling systems
- Minimize object creation during interactions

**Reference Management**:
- Clean up event listeners
- Remove unused data references
- Implement proper cleanup procedures

### Rendering Performance

#### Canvas vs. SVG vs. WebGL

**Canvas Optimization**:
```javascript
class CanvasNetworkRenderer {
  constructor(canvas, graph) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.graph = graph;
    this.renderQueue = [];
  }

  render() {
    // Clear canvas
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // Batch similar operations
    this.renderEdges();
    this.renderNodes();
    this.renderLabels();
  }

  renderEdges() {
    this.ctx.save();
    this.ctx.strokeStyle = '#cccccc';
    this.ctx.lineWidth = 1;
    this.ctx.beginPath();

    // Batch all edge drawing operations
    this.graph.edges.forEach(edge => {
      this.ctx.moveTo(edge.source.x, edge.source.y);
      this.ctx.lineTo(edge.target.x, edge.target.y);
    });

    this.ctx.stroke();
    this.ctx.restore();
  }

  renderNodes() {
    this.ctx.save();

    // Group nodes by visual properties
    const nodeGroups = this.groupNodesByStyle();

    nodeGroups.forEach(group => {
      this.ctx.fillStyle = group.color;
      group.nodes.forEach(node => {
        this.ctx.beginPath();
        this.ctx.arc(node.x, node.y, node.radius, 0, 2 * Math.PI);
        this.ctx.fill();
      });
    });

    this.ctx.restore();
  }
}
```

**WebGL Acceleration**:
- Use Three.js or raw WebGL for massive networks
- Implement shader-based rendering
- Utilize GPU parallel processing
- Handle fallback to Canvas/SVG

#### Layout Algorithm Performance

**Multi-Threading**:
```javascript
class ThreadedLayoutEngine {
  constructor(graph) {
    this.graph = graph;
    this.worker = new Worker('layout-worker.js');
    this.setupWorkerCommunication();
  }

  setupWorkerCommunication() {
    this.worker.onmessage = (event) => {
      const { positions, iteration } = event.data;
      this.updateNodePositions(positions);
      this.onLayoutProgress(iteration);
    };
  }

  startLayout(algorithm, parameters) {
    this.worker.postMessage({
      command: 'start',
      algorithm: algorithm,
      nodes: this.graph.nodes,
      edges: this.graph.edges,
      parameters: parameters
    });
  }

  updateNodePositions(positions) {
    positions.forEach((pos, index) => {
      this.graph.nodes[index].x = pos.x;
      this.graph.nodes[index].y = pos.y;
    });
    this.requestRender();
  }
}
```

**Algorithm Optimization**:
- Implement multi-level algorithms
- Use spatial data structures for neighbor queries
- Apply early termination conditions
- Cache expensive calculations

## Accessibility Guidelines

### Screen Reader Support

#### Semantic Structure

**Alternative Text Generation**:
```javascript
function generateNetworkDescription(graph) {
  const stats = calculateGraphStatistics(graph);

  return `
    Network visualization with ${stats.nodeCount} nodes and ${stats.edgeCount} connections.
    The network has ${stats.componentCount} separate components.
    Average node degree is ${stats.averageDegree.toFixed(1)}.
    Most connected node: ${stats.maxDegreeNode.label} with ${stats.maxDegreeNode.degree} connections.
  `;
}

function generateNodeDescription(node, graph) {
  const neighbors = getNodeNeighbors(node, graph);

  return `
    ${node.label}: ${node.type || 'Node'} with ${neighbors.length} connections.
    Connected to: ${neighbors.map(n => n.label).join(', ')}.
    ${node.description || ''}
  `;
}
```

**ARIA Implementation**:
```html
<div role="img" aria-labelledby="network-title" aria-describedby="network-desc">
  <h2 id="network-title">Social Network Analysis</h2>
  <p id="network-desc">Interactive network showing relationships between 150 individuals...</p>

  <div role="application" aria-label="Network navigation controls">
    <button aria-label="Zoom in">+</button>
    <button aria-label="Zoom out">-</button>
    <button aria-label="Reset view">Reset</button>
  </div>

  <div role="region" aria-label="Network visualization" tabindex="0">
    <!-- SVG content with proper ARIA labels -->
  </div>
</div>
```

#### Data Table Alternative

**Structured Data Presentation**:
```javascript
class AccessibleNetworkTable {
  constructor(graph, container) {
    this.graph = graph;
    this.container = container;
    this.createTable();
  }

  createTable() {
    const table = document.createElement('table');
    table.setAttribute('role', 'table');
    table.setAttribute('aria-label', 'Network data in tabular format');

    // Create header
    const header = table.createTHead();
    const headerRow = header.insertRow();
    ['Node', 'Type', 'Connections', 'Connected To'].forEach(text => {
      const th = document.createElement('th');
      th.textContent = text;
      th.setAttribute('scope', 'col');
      headerRow.appendChild(th);
    });

    // Create body
    const tbody = table.createTBody();
    this.graph.nodes.forEach(node => {
      const row = tbody.insertRow();
      const neighbors = this.getNodeNeighbors(node);

      row.insertCell().textContent = node.label;
      row.insertCell().textContent = node.type || 'Node';
      row.insertCell().textContent = neighbors.length;
      row.insertCell().textContent = neighbors.map(n => n.label).join(', ');
    });

    this.container.appendChild(table);
  }
}
```

### Keyboard Navigation

#### Focus Management

**Sequential Navigation**:
```javascript
class KeyboardNavigableNetwork {
  constructor(svg, graph) {
    this.svg = svg;
    this.graph = graph;
    this.focusedElement = null;
    this.setupKeyboardHandlers();
    this.createFocusIndicators();
  }

  setupKeyboardHandlers() {
    this.svg.addEventListener('keydown', (event) => {
      switch(event.key) {
        case 'Tab':
          this.handleTabNavigation(event);
          break;
        case 'ArrowUp':
        case 'ArrowDown':
        case 'ArrowLeft':
        case 'ArrowRight':
          this.handleArrowNavigation(event);
          break;
        case 'Enter':
        case ' ':
          this.handleSelection(event);
          break;
        case 'Escape':
          this.handleEscape(event);
          break;
      }
    });
  }

  handleTabNavigation(event) {
    event.preventDefault();

    if (!this.focusedElement) {
      this.focusFirstNode();
    } else {
      const direction = event.shiftKey ? -1 : 1;
      this.moveToNextFocusableElement(direction);
    }
  }

  handleArrowNavigation(event) {
    event.preventDefault();

    if (!this.focusedElement) return;

    const neighbors = this.getNodeNeighbors(this.focusedElement);
    if (neighbors.length === 0) return;

    // Navigate to spatially closest neighbor in arrow direction
    const targetNeighbor = this.findNeighborInDirection(
      this.focusedElement,
      neighbors,
      event.key
    );

    if (targetNeighbor) {
      this.setFocus(targetNeighbor);
    }
  }

  createFocusIndicators() {
    this.focusRing = this.svg.append('circle')
      .attr('class', 'focus-ring')
      .attr('r', 0)
      .style('fill', 'none')
      .style('stroke', '#0066cc')
      .style('stroke-width', 3)
      .style('stroke-dasharray', '5,5')
      .style('opacity', 0);
  }

  setFocus(element) {
    this.focusedElement = element;

    // Update focus ring
    this.focusRing
      .transition()
      .duration(200)
      .attr('cx', element.x)
      .attr('cy', element.y)
      .attr('r', element.radius + 5)
      .style('opacity', 1);

    // Update screen reader
    this.announceElement(element);
  }
}
```

#### Shortcut Keys

**Common Shortcuts**:
- **Ctrl/Cmd + F**: Search nodes
- **Ctrl/Cmd + A**: Select all nodes
- **Ctrl/Cmd + Z**: Undo last action
- **Space**: Pan mode toggle
- **+/-**: Zoom in/out
- **0**: Reset zoom
- **H**: Show/hide help

### Color and Contrast

#### Color-Blind Friendly Palettes

**Accessible Color Schemes**:
```javascript
const accessiblePalettes = {
  colorBlindSafe: [
    '#1f77b4', // Blue
    '#ff7f0e', // Orange
    '#2ca02c', // Green
    '#d62728', // Red
    '#9467bd', // Purple
    '#8c564b', // Brown
    '#e377c2', // Pink
    '#7f7f7f', // Gray
    '#bcbd22', // Olive
    '#17becf'  // Cyan
  ],

  highContrast: [
    '#000000', // Black
    '#ffffff', // White
    '#ff0000', // Red
    '#00ff00', // Green
    '#0000ff', // Blue
    '#ffff00', // Yellow
    '#ff00ff', // Magenta
    '#00ffff'  // Cyan
  ],

  monochrome: [
    '#000000', '#333333', '#666666', '#999999',
    '#cccccc', '#ffffff'
  ]
};

function applyAccessibleColors(graph, palette = 'colorBlindSafe') {
  const colors = accessiblePalettes[palette];
  const nodeTypes = [...new Set(graph.nodes.map(n => n.type))];

  const colorMap = new Map();
  nodeTypes.forEach((type, index) => {
    colorMap.set(type, colors[index % colors.length]);
  });

  graph.nodes.forEach(node => {
    node.color = colorMap.get(node.type);
  });
}
```

#### Pattern and Shape Alternatives

**Visual Encoding Alternatives**:
```javascript
const shapeEncodings = {
  circle: 'M 0,5 A 5,5 0 1,1 0,-5 A 5,5 0 1,1 0,5',
  square: 'M -5,-5 L 5,-5 L 5,5 L -5,5 Z',
  triangle: 'M 0,-5 L 5,5 L -5,5 Z',
  diamond: 'M 0,-5 L 5,0 L 0,5 L -5,0 Z',
  star: 'M 0,-5 L 1.5,-1.5 L 5,0 L 1.5,1.5 L 0,5 L -1.5,1.5 L -5,0 L -1.5,-1.5 Z'
};

const patternEncodings = {
  solid: 'none',
  striped: 'url(#stripe-pattern)',
  dotted: 'url(#dot-pattern)',
  crosshatch: 'url(#crosshatch-pattern)'
};

function createPatternDefinitions(svg) {
  const defs = svg.append('defs');

  // Stripe pattern
  const stripePattern = defs.append('pattern')
    .attr('id', 'stripe-pattern')
    .attr('patternUnits', 'userSpaceOnUse')
    .attr('width', 8)
    .attr('height', 8);

  stripePattern.append('rect')
    .attr('width', 8)
    .attr('height', 8)
    .attr('fill', '#ffffff');

  stripePattern.append('path')
    .attr('d', 'M 0,8 L 8,0')
    .attr('stroke', '#000000')
    .attr('stroke-width', 1);
}
```

## Code Examples

### Basic Network Visualization

#### Simple Force-Directed Graph
```javascript
class BasicNetworkViz {
  constructor(container, data) {
    this.container = container;
    this.data = data;
    this.width = 800;
    this.height = 600;

    this.init();
  }

  init() {
    this.setupSVG();
    this.setupSimulation();
    this.render();
  }

  setupSVG() {
    this.svg = d3.select(this.container)
      .append('svg')
      .attr('width', this.width)
      .attr('height', this.height)
      .attr('viewBox', `0 0 ${this.width} ${this.height}`);

    // Add zoom behavior
    this.zoom = d3.zoom()
      .scaleExtent([0.1, 10])
      .on('zoom', (event) => {
        this.g.attr('transform', event.transform);
      });

    this.svg.call(this.zoom);

    this.g = this.svg.append('g');
  }

  setupSimulation() {
    this.simulation = d3.forceSimulation(this.data.nodes)
      .force('link', d3.forceLink(this.data.edges)
        .id(d => d.id)
        .distance(100)
        .strength(0.1))
      .force('charge', d3.forceManyBody()
        .strength(-300))
      .force('center', d3.forceCenter(
        this.width / 2,
        this.height / 2))
      .force('collision', d3.forceCollide()
        .radius(d => d.radius || 20));
  }

  render() {
    // Render edges
    this.edges = this.g.selectAll('.edge')
      .data(this.data.edges)
      .enter().append('line')
      .attr('class', 'edge')
      .style('stroke', '#999')
      .style('stroke-opacity', 0.6)
      .style('stroke-width', d => Math.sqrt(d.weight || 1));

    // Render nodes
    this.nodes = this.g.selectAll('.node')
      .data(this.data.nodes)
      .enter().append('circle')
      .attr('class', 'node')
      .attr('r', d => d.radius || 10)
      .style('fill', d => d.color || '#69b3a2')
      .call(this.dragBehavior());

    // Add labels
    this.labels = this.g.selectAll('.label')
      .data(this.data.nodes)
      .enter().append('text')
      .attr('class', 'label')
      .text(d => d.label)
      .style('text-anchor', 'middle')
      .style('dy', 3)
      .style('font-size', '12px')
      .style('pointer-events', 'none');

    // Update positions on simulation tick
    this.simulation.on('tick', () => {
      this.edges
        .attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y);

      this.nodes
        .attr('cx', d => d.x)
        .attr('cy', d => d.y);

      this.labels
        .attr('x', d => d.x)
        .attr('y', d => d.y);
    });
  }

  dragBehavior() {
    return d3.drag()
      .on('start', (event, d) => {
        if (!event.active) this.simulation.alphaTarget(0.3).restart();
        d.fx = d.x;
        d.fy = d.y;
      })
      .on('drag', (event, d) => {
        d.fx = event.x;
        d.fy = event.y;
      })
      .on('end', (event, d) => {
        if (!event.active) this.simulation.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      });
  }
}

// Usage
const networkData = {
  nodes: [
    { id: 'A', label: 'Node A', radius: 15, color: '#ff6b6b' },
    { id: 'B', label: 'Node B', radius: 12, color: '#4ecdc4' },
    { id: 'C', label: 'Node C', radius: 18, color: '#45b7d1' },
    { id: 'D', label: 'Node D', radius: 10, color: '#96ceb4' }
  ],
  edges: [
    { source: 'A', target: 'B', weight: 2 },
    { source: 'B', target: 'C', weight: 1 },
    { source: 'C', target: 'D', weight: 3 },
    { source: 'D', target: 'A', weight: 1 }
  ]
};

const viz = new BasicNetworkViz('#network-container', networkData);
```

### Intermediate: Hierarchical Network

#### Tree Visualization with Collapsible Nodes
```javascript
class HierarchicalNetwork {
  constructor(container, data) {
    this.container = container;
    this.data = data;
    this.width = 1000;
    this.height = 800;
    this.margin = { top: 20, right: 20, bottom: 20, left: 20 };

    this.init();
  }

  init() {
    this.setupSVG();
    this.setupTree();
    this.render();
  }

  setupSVG() {
    this.svg = d3.select(this.container)
      .append('svg')
      .attr('width', this.width)
      .attr('height', this.height);

    this.g = this.svg.append('g')
      .attr('transform', `translate(${this.margin.left},${this.margin.top})`);

    this.innerWidth = this.width - this.margin.left - this.margin.right;
    this.innerHeight = this.height - this.margin.top - this.margin.bottom;
  }

  setupTree() {
    this.tree = d3.tree()
      .size([this.innerWidth, this.innerHeight]);

    this.root = d3.hierarchy(this.data);
    this.root.x0 = this.innerWidth / 2;
    this.root.y0 = 0;

    // Collapse all children initially except first level
    this.root.children.forEach(d => this.collapse(d));
  }

  collapse(d) {
    if (d.children) {
      d._children = d.children;
      d._children.forEach(child => this.collapse(child));
      d.children = null;
    }
  }

  expand(d) {
    if (d._children) {
      d.children = d._children;
      d._children = null;
    }
  }

  render() {
    const treeData = this.tree(this.root);
    const nodes = treeData.descendants();
    const links = treeData.descendants().slice(1);

    // Update node positions
    nodes.forEach((d, i) => {
      d.y = d.depth * 180;
    });

    this.updateNodes(nodes);
    this.updateLinks(links);
  }

  updateNodes(nodes) {
    const node = this.g.selectAll('.node')
      .data(nodes, d => d.id || (d.id = ++this.nodeCounter));

    // Enter new nodes
    const nodeEnter = node.enter().append('g')
      .attr('class', 'node')
      .attr('transform', d => `translate(${this.root.x0},${this.root.y0})`)
      .on('click', (event, d) => this.toggleNode(d));

    // Add circles for nodes
    nodeEnter.append('circle')
      .attr('r', 1e-6)
      .style('fill', d => d._children ? '#lightsteelblue' : '#fff')
      .style('stroke', 'steelblue')
      .style('stroke-width', '3px');

    // Add labels
    nodeEnter.append('text')
      .attr('dy', '.35em')
      .attr('x', d => d.children || d._children ? -13 : 13)
      .style('text-anchor', d => d.children || d._children ? 'end' : 'start')
      .text(d => d.data.name)
      .style('font-size', '14px')
      .style('fill-opacity', 1e-6);

    // Update existing nodes
    const nodeUpdate = nodeEnter.merge(node);

    nodeUpdate.transition()
      .duration(750)
      .attr('transform', d => `translate(${d.x},${d.y})`);

    nodeUpdate.select('circle')
      .transition()
      .duration(750)
      .attr('r', 10)
      .style('fill', d => d._children ? '#lightsteelblue' : '#fff');

    nodeUpdate.select('text')
      .transition()
      .duration(750)
      .style('fill-opacity', 1);

    // Remove exiting nodes
    const nodeExit = node.exit().transition()
      .duration(750)
      .attr('transform', d => `translate(${this.root.x},${this.root.y})`)
      .remove();

    nodeExit.select('circle')
      .attr('r', 1e-6);

    nodeExit.select('text')
      .style('fill-opacity', 1e-6);
  }

  updateLinks(links) {
    const diagonal = d3.linkHorizontal()
      .x(d => d.x)
      .y(d => d.y);

    const link = this.g.selectAll('.link')
      .data(links, d => d.id);

    // Enter new links
    const linkEnter = link.enter().insert('path', 'g')
      .attr('class', 'link')
      .style('fill', 'none')
      .style('stroke', '#ccc')
      .style('stroke-width', '2px')
      .attr('d', d => {
        const o = { x: this.root.x0, y: this.root.y0 };
        return diagonal({ source: o, target: o });
      });

    // Update existing links
    const linkUpdate = linkEnter.merge(link);

    linkUpdate.transition()
      .duration(750)
      .attr('d', d => diagonal({ source: d.parent, target: d }));

    // Remove exiting links
    link.exit().transition()
      .duration(750)
      .attr('d', d => {
        const o = { x: this.root.x, y: this.root.y };
        return diagonal({ source: o, target: o });
      })
      .remove();
  }

  toggleNode(d) {
    if (d.children) {
      d._children = d.children;
      d.children = null;
    } else {
      d.children = d._children;
      d._children = null;
    }

    this.render();
  }
}

// Usage
const hierarchicalData = {
  name: "Root",
  children: [
    {
      name: "Branch 1",
      children: [
        { name: "Leaf 1.1" },
        { name: "Leaf 1.2" },
        {
          name: "Sub-branch 1.3",
          children: [
            { name: "Leaf 1.3.1" },
            { name: "Leaf 1.3.2" }
          ]
        }
      ]
    },
    {
      name: "Branch 2",
      children: [
        { name: "Leaf 2.1" },
        { name: "Leaf 2.2" }
      ]
    }
  ]
};

const hierarchicalViz = new HierarchicalNetwork('#tree-container', hierarchicalData);
```

### Advanced: Multi-Layer Network Analysis

#### Complex Network with Community Detection
```javascript
class MultiLayerNetworkAnalyzer {
  constructor(container, config) {
    this.container = container;
    this.config = config;
    this.layers = config.layers;
    this.width = config.width || 1200;
    this.height = config.height || 800;

    this.currentLayer = 0;
    this.communities = new Map();
    this.nodeMetrics = new Map();

    this.init();
  }

  init() {
    this.setupDOM();
    this.setupAnalytics();
    this.setupVisualization();
    this.calculateMetrics();
    this.render();
  }

  setupDOM() {
    this.wrapper = d3.select(this.container)
      .append('div')
      .attr('class', 'network-analyzer');

    // Control panel
    this.controls = this.wrapper.append('div')
      .attr('class', 'controls')
      .style('display', 'flex')
      .style('align-items', 'center')
      .style('margin-bottom', '20px');

    // Layer selector
    this.layerSelect = this.controls.append('select')
      .on('change', (event) => this.switchLayer(event.target.value));

    this.layerSelect.selectAll('option')
      .data(this.layers)
      .enter().append('option')
      .attr('value', (d, i) => i)
      .text(d => d.name);

    // Metrics panel
    this.metricsPanel = this.controls.append('div')
      .style('margin-left', '20px');

    // Main visualization
    this.svg = this.wrapper.append('svg')
      .attr('width', this.width)
      .attr('height', this.height)
      .attr('viewBox', `0 0 ${this.width} ${this.height}`);

    this.setupZoom();
    this.g = this.svg.append('g');
  }

  setupZoom() {
    this.zoom = d3.zoom()
      .scaleExtent([0.1, 10])
      .on('zoom', (event) => {
        this.g.attr('transform', event.transform);
      });

    this.svg.call(this.zoom);
  }

  setupAnalytics() {
    this.analytics = {
      centrality: new CentralityAnalyzer(),
      community: new CommunityDetector(),
      clustering: new ClusteringAnalyzer(),
      pathfinding: new PathfindingAnalyzer()
    };
  }

  setupVisualization() {
    this.colorScale = d3.scaleOrdinal(d3.schemeCategory10);

    this.simulation = d3.forceSimulation()
      .force('link', d3.forceLink().id(d => d.id))
      .force('charge', d3.forceManyBody().strength(-300))
      .force('center', d3.forceCenter(this.width / 2, this.height / 2))
      .force('collision', d3.forceCollide().radius(20));
  }

  calculateMetrics() {
    this.layers.forEach((layer, index) => {
      const graph = this.buildGraphFromLayer(layer);

      // Calculate centrality measures
      const centrality = this.analytics.centrality.calculate(graph);

      // Detect communities
      const communities = this.analytics.community.detect(graph);

      // Calculate clustering coefficient
      const clustering = this.analytics.clustering.calculate(graph);

      layer.metrics = {
        centrality: centrality,
        communities: communities,
        clustering: clustering,
        density: this.calculateDensity(graph),
        diameter: this.calculateDiameter(graph)
      };

      // Store community assignments
      communities.forEach((community, nodeId) => {
        if (!this.communities.has(nodeId)) {
          this.communities.set(nodeId, []);
        }
        this.communities.get(nodeId)[index] = community;
      });
    });
  }

  buildGraphFromLayer(layer) {
    const nodeMap = new Map();
    layer.nodes.forEach(node => nodeMap.set(node.id, node));

    const adjacencyList = new Map();
    layer.nodes.forEach(node => adjacencyList.set(node.id, []));

    layer.edges.forEach(edge => {
      adjacencyList.get(edge.source).push(edge.target);
      if (!edge.directed) {
        adjacencyList.get(edge.target).push(edge.source);
      }
    });

    return { nodes: layer.nodes, edges: layer.edges, adjacencyList };
  }

  switchLayer(layerIndex) {
    this.currentLayer = parseInt(layerIndex);
    this.render();
    this.updateMetricsDisplay();
  }

  render() {
    const layer = this.layers[this.currentLayer];

    // Update simulation
    this.simulation
      .nodes(layer.nodes)
      .force('link')
      .links(layer.edges);

    this.renderEdges(layer.edges);
    this.renderNodes(layer.nodes);
    this.renderCommunities();

    this.simulation.alpha(1).restart();
  }

  renderEdges(edges) {
    this.edges = this.g.selectAll('.edge')
      .data(edges, d => `${d.source.id}-${d.target.id}`);

    this.edges.exit().remove();

    const edgesEnter = this.edges.enter()
      .append('line')
      .attr('class', 'edge')
      .style('stroke', '#999')
      .style('stroke-opacity', 0.6);

    this.edges = edgesEnter.merge(this.edges)
      .style('stroke-width', d => Math.sqrt(d.weight || 1));
  }

  renderNodes(nodes) {
    this.nodes = this.g.selectAll('.node')
      .data(nodes, d => d.id);

    this.nodes.exit().remove();

    const nodesEnter = this.nodes.enter()
      .append('g')
      .attr('class', 'node')
      .call(this.dragBehavior());

    nodesEnter.append('circle')
      .attr('r', d => this.getNodeRadius(d))
      .style('fill', d => this.getNodeColor(d))
      .style('stroke', '#fff')
      .style('stroke-width', 2);

    nodesEnter.append('text')
      .attr('dy', 3)
      .style('text-anchor', 'middle')
      .style('font-size', '10px')
      .style('pointer-events', 'none')
      .text(d => d.label);

    this.nodes = nodesEnter.merge(this.nodes);

    // Update node appearance based on metrics
    this.nodes.select('circle')
      .style('fill', d => this.getNodeColor(d))
      .attr('r', d => this.getNodeRadius(d));
  }

  renderCommunities() {
    const layer = this.layers[this.currentLayer];
    const communities = layer.metrics.communities;

    // Group nodes by community
    const communityGroups = new Map();
    layer.nodes.forEach(node => {
      const community = communities.get(node.id);
      if (!communityGroups.has(community)) {
        communityGroups.set(community, []);
      }
      communityGroups.get(community).push(node);
    });

    // Calculate convex hulls for communities
    const hulls = [];
    communityGroups.forEach((nodes, community) => {
      if (nodes.length > 2) {
        const points = nodes.map(d => [d.x, d.y]);
        const hull = d3.polygonHull(points);
        if (hull) {
          hulls.push({
            community: community,
            hull: hull,
            color: this.colorScale(community)
          });
        }
      }
    });

    // Render community hulls
    this.communityHulls = this.g.selectAll('.community-hull')
      .data(hulls);

    this.communityHulls.exit().remove();

    this.communityHulls.enter()
      .append('path')
      .attr('class', 'community-hull')
      .merge(this.communityHulls)
      .attr('d', d => `M${d.hull.join('L')}Z`)
      .style('fill', d => d.color)
      .style('fill-opacity', 0.1)
      .style('stroke', d => d.color)
      .style('stroke-width', 2)
      .style('stroke-opacity', 0.3);
  }

  getNodeColor(node) {
    const layer = this.layers[this.currentLayer];
    const community = layer.metrics.communities.get(node.id);
    return this.colorScale(community);
  }

  getNodeRadius(node) {
    const layer = this.layers[this.currentLayer];
    const centrality = layer.metrics.centrality.betweenness.get(node.id) || 0;
    return 5 + Math.sqrt(centrality) * 10;
  }

  updateMetricsDisplay() {
    const layer = this.layers[this.currentLayer];
    const metrics = layer.metrics;

    this.metricsPanel.html(`
      <div>
        <strong>Network Metrics:</strong><br>
        Density: ${metrics.density.toFixed(3)}<br>
        Diameter: ${metrics.diameter}<br>
        Communities: ${new Set(metrics.communities.values()).size}<br>
        Avg Clustering: ${d3.mean(Array.from(metrics.clustering.values())).toFixed(3)}
      </div>
    `);
  }

  dragBehavior() {
    return d3.drag()
      .on('start', (event, d) => {
        if (!event.active) this.simulation.alphaTarget(0.3).restart();
        d.fx = d.x;
        d.fy = d.y;
      })
      .on('drag', (event, d) => {
        d.fx = event.x;
        d.fy = event.y;
      })
      .on('end', (event, d) => {
        if (!event.active) this.simulation.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      });
  }

  // Update positions during simulation
  updatePositions() {
    this.simulation.on('tick', () => {
      this.edges
        .attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y);

      this.nodes
        .attr('transform', d => `translate(${d.x},${d.y})`);

      this.renderCommunities();
    });
  }
}

// Analytics classes (simplified implementations)
class CentralityAnalyzer {
  calculate(graph) {
    return {
      degree: this.calculateDegree(graph),
      betweenness: this.calculateBetweenness(graph),
      closeness: this.calculateCloseness(graph),
      pagerank: this.calculatePageRank(graph)
    };
  }

  calculateDegree(graph) {
    const degree = new Map();
    graph.nodes.forEach(node => {
      degree.set(node.id, graph.adjacencyList.get(node.id).length);
    });
    return degree;
  }

  calculateBetweenness(graph) {
    // Simplified betweenness centrality calculation
    const betweenness = new Map();
    graph.nodes.forEach(node => {
      betweenness.set(node.id, Math.random()); // Placeholder
    });
    return betweenness;
  }

  calculateCloseness(graph) {
    // Simplified closeness centrality calculation
    const closeness = new Map();
    graph.nodes.forEach(node => {
      closeness.set(node.id, Math.random()); // Placeholder
    });
    return closeness;
  }

  calculatePageRank(graph) {
    // Simplified PageRank calculation
    const pagerank = new Map();
    graph.nodes.forEach(node => {
      pagerank.set(node.id, Math.random()); // Placeholder
    });
    return pagerank;
  }
}

class CommunityDetector {
  detect(graph) {
    // Simplified community detection (random assignment)
    const communities = new Map();
    const numCommunities = Math.max(1, Math.floor(graph.nodes.length / 10));

    graph.nodes.forEach(node => {
      communities.set(node.id, Math.floor(Math.random() * numCommunities));
    });

    return communities;
  }
}

class ClusteringAnalyzer {
  calculate(graph) {
    const clustering = new Map();

    graph.nodes.forEach(node => {
      const neighbors = graph.adjacencyList.get(node.id);
      if (neighbors.length < 2) {
        clustering.set(node.id, 0);
        return;
      }

      let triangles = 0;
      const possibleTriangles = neighbors.length * (neighbors.length - 1) / 2;

      // Count triangles (simplified)
      for (let i = 0; i < neighbors.length; i++) {
        for (let j = i + 1; j < neighbors.length; j++) {
          const neighbor1 = neighbors[i];
          const neighbor2 = neighbors[j];
          if (graph.adjacencyList.get(neighbor1).includes(neighbor2)) {
            triangles++;
          }
        }
      }

      clustering.set(node.id, triangles / possibleTriangles);
    });

    return clustering;
  }
}

// Usage
const multiLayerConfig = {
  width: 1200,
  height: 800,
  layers: [
    {
      name: "Social Layer",
      nodes: [...], // Node data
      edges: [...]  // Edge data
    },
    {
      name: "Professional Layer",
      nodes: [...],
      edges: [...]
    },
    {
      name: "Communication Layer",
      nodes: [...],
      edges: [...]
    }
  ]
};

const analyzer = new MultiLayerNetworkAnalyzer('#network-analyzer', multiLayerConfig);
```

## Best Practices

### Design Guidelines

#### Visual Clarity
- **Node Size Encoding**: Use size to represent node importance or attributes
- **Edge Weight Visualization**: Vary line thickness for edge weights
- **Color Consistency**: Maintain consistent color schemes across views
- **Label Management**: Show/hide labels based on zoom level and importance

#### Layout Optimization
- **Algorithm Selection**: Choose appropriate layout based on graph structure
- **Parameter Tuning**: Adjust force simulation parameters for stability
- **Performance Scaling**: Use LOD techniques for large networks
- **Interactive Refinement**: Allow manual node positioning for fine-tuning

### Data Management

#### Graph Data Structures
```javascript
class OptimizedGraphData {
  constructor() {
    this.nodes = new Map();
    this.edges = new Map();
    this.adjacencyList = new Map();
    this.nodeIndex = new QuadTree();
  }

  addNode(node) {
    this.nodes.set(node.id, node);
    this.adjacencyList.set(node.id, new Set());
    this.nodeIndex.insert(node);
  }

  addEdge(edge) {
    const edgeId = `${edge.source}-${edge.target}`;
    this.edges.set(edgeId, edge);

    this.adjacencyList.get(edge.source).add(edge.target);
    if (!edge.directed) {
      this.adjacencyList.get(edge.target).add(edge.source);
    }
  }

  getNeighbors(nodeId) {
    return Array.from(this.adjacencyList.get(nodeId) || []);
  }

  getNodesInRegion(bounds) {
    return this.nodeIndex.query(bounds);
  }
}
```

#### Memory Optimization
- **Lazy Loading**: Load graph data progressively
- **Data Compression**: Use efficient data structures
- **Garbage Collection**: Clean up unused references
- **Streaming Updates**: Handle real-time data efficiently

### Performance Guidelines

#### Rendering Optimization
- **Canvas for Large Graphs**: Use Canvas API for >1000 nodes
- **WebGL for Massive Graphs**: GPU acceleration for >10000 nodes
- **SVG for Small Graphs**: DOM manipulation for <1000 nodes
- **Hybrid Approaches**: Combine techniques based on graph regions

#### Interaction Performance
- **Debounced Events**: Prevent excessive event handling
- **Efficient Hit Testing**: Use spatial indexing for click detection
- **Smooth Animations**: Optimize transition performance
- **Progressive Loading**: Load details on demand

### Accessibility Implementation

#### Screen Reader Support
```javascript
class AccessibleNetwork {
  constructor(svg, graph) {
    this.svg = svg;
    this.graph = graph;
    this.setupAccessibility();
  }

  setupAccessibility() {
    // Add role and labels
    this.svg
      .attr('role', 'img')
      .attr('aria-labelledby', 'network-title')
      .attr('aria-describedby', 'network-description');

    // Create text alternatives
    this.createTextAlternatives();

    // Setup keyboard navigation
    this.setupKeyboardNavigation();
  }

  createTextAlternatives() {
    const description = this.generateNetworkDescription();

    d3.select(this.svg.node().parentNode)
      .insert('div', ':first-child')
      .attr('id', 'network-description')
      .attr('class', 'sr-only')
      .text(description);
  }

  generateNetworkDescription() {
    const nodeCount = this.graph.nodes.length;
    const edgeCount = this.graph.edges.length;
    const components = this.calculateComponents();

    return `Network visualization with ${nodeCount} nodes and ${edgeCount} connections. The network has ${components} separate components.`;
  }
}
```

#### Keyboard Navigation
- **Tab Order**: Logical navigation sequence
- **Arrow Keys**: Spatial navigation between connected nodes
- **Enter/Space**: Selection and activation
- **Escape**: Reset selection and return to overview

## Troubleshooting

### Common Issues

#### Layout Problems

**Symptoms**: Poor node positioning, overlapping elements, unstable layouts
**Causes**:
- Inappropriate algorithm selection
- Poor parameter tuning
- Insufficient simulation time
- Graph structure issues

**Solutions**:
```javascript
// Adaptive parameter tuning
function tuneForceParameters(graph) {
  const nodeCount = graph.nodes.length;
  const edgeCount = graph.edges.length;
  const density = (2 * edgeCount) / (nodeCount * (nodeCount - 1));

  return {
    linkDistance: density > 0.1 ? 50 : 100,
    chargeStrength: -300 / Math.sqrt(nodeCount),
    alphaDecay: nodeCount > 1000 ? 0.05 : 0.0228,
    velocityDecay: density > 0.05 ? 0.6 : 0.4
  };
}
```

#### Performance Issues

**Symptoms**: Slow rendering, browser freezing, memory leaks
**Causes**:
- Large graph size without optimization
- Inefficient event handling
- Memory leaks from simulation
- Excessive DOM manipulation

**Solutions**:
```javascript
// Performance monitoring
class PerformanceMonitor {
  constructor(threshold = 16) {
    this.threshold = threshold; // 60 FPS
    this.frameCount = 0;
    this.lastTime = performance.now();
  }

  tick() {
    const currentTime = performance.now();
    const frameTime = currentTime - this.lastTime;

    if (frameTime > this.threshold) {
      console.warn(`Slow frame: ${frameTime.toFixed(2)}ms`);
      this.onSlowFrame(frameTime);
    }

    this.lastTime = currentTime;
    this.frameCount++;
  }

  onSlowFrame(frameTime) {
    // Reduce quality or switch to simpler rendering
    this.adaptQuality(frameTime);
  }

  adaptQuality(frameTime) {
    if (frameTime > 50) {
      // Switch to canvas or reduce detail
      this.switchToLowQuality();
    }
  }
}
```

#### Data Loading Problems

**Symptoms**: Missing nodes/edges, incorrect relationships, format errors
**Causes**:
- Malformed data files
- Incorrect parsing logic
- Missing node references
- Data type mismatches

**Solutions**:
```javascript
// Data validation
function validateGraphData(data) {
  const errors = [];

  // Validate nodes
  if (!Array.isArray(data.nodes)) {
    errors.push('Nodes must be an array');
  } else {
    data.nodes.forEach((node, index) => {
      if (!node.id) {
        errors.push(`Node at index ${index} missing ID`);
      }
    });
  }

  // Validate edges
  if (!Array.isArray(data.edges)) {
    errors.push('Edges must be an array');
  } else {
    const nodeIds = new Set(data.nodes.map(n => n.id));
    data.edges.forEach((edge, index) => {
      if (!nodeIds.has(edge.source)) {
        errors.push(`Edge at index ${index} references unknown source: ${edge.source}`);
      }
      if (!nodeIds.has(edge.target)) {
        errors.push(`Edge at index ${index} references unknown target: ${edge.target}`);
      }
    });
  }

  return errors;
}
```

### Debugging Strategies

#### Visual Debugging
- **Force Visualization**: Show force vectors and node velocities
- **Spatial Index Overlay**: Display quadtree or spatial structures
- **Performance Overlay**: Show frame rate and render times
- **Data Inspector**: Interactive exploration of node/edge data

#### Development Tools
- **Browser DevTools**: Performance profiling and memory analysis
- **D3 Selection Inspector**: Examine D3 selections and data binding
- **Network Analysis Tools**: Validate graph properties and metrics
- **Accessibility Testing**: Screen reader and keyboard navigation testing

## Learning Resources

### Foundational Knowledge

#### Graph Theory
- **"Introduction to Graph Theory" by Richard Trudeau**: Accessible introduction
- **"Graph Theory with Applications" by Bondy and Murty**: Comprehensive reference
- **"Networks, Crowds, and Markets" by Easley and Kleinberg**: Applied network analysis
- **MIT OpenCourseWare: Graph Theory**: Free online course materials

#### Network Analysis
- **"Networks: An Introduction" by Mark Newman**: Comprehensive network science
- **"Social Network Analysis" by Wasserman and Faust**: Classical reference
- **"Linked" by Albert-László Barabási**: Popular introduction to network science
- **"The Structure and Dynamics of Networks" by Newman, Barabási, and Watts**: Collected papers

### Technical Implementation

#### D3.js and Web Development
- **"D3.js in Action" by Elijah Meeks**: Comprehensive D3.js guide
- **"Interactive Data Visualization for the Web" by Scott Murray**: Beginner-friendly introduction
- **Observable Notebooks**: Interactive D3.js examples and tutorials
- **D3.js API Documentation**: Official reference and examples

#### Specialized Libraries
- **Cytoscape.js Documentation**: Comprehensive API reference
- **Vis.js Network Documentation**: Examples and tutorials
- **Sigma.js Examples**: Performance-oriented network visualization
- **Three.js Documentation**: 3D and WebGL network visualization

### Online Courses

#### Network Visualization
- **"Information Visualization" (University of Edinburgh)**: Coursera course
- **"Applied Plotting, Charting & Data Representation in Python"**: University of Michigan
- **"Social Network Analysis" (University of California, Davis)**: Coursera specialization
- **"Network Analysis in Systems Biology"**: Cytoscape tutorials

#### Web Development
- **"D3.js Data Visualization Fundamentals"**: Pluralsight course
- **"Interactive Data Visualization with D3.js"**: Frontend Masters workshop
- **"SVG Essentials & Animation"**: Various online platforms
- **"Canvas API for Graphics"**: Mozilla Developer Network

### Communities and Forums

#### Professional Networks
- **Network Science Society**: Academic community
- **International Network for Social Network Analysis (INSNA)**: Research community
- **IEEE Visualization Community**: Technical visualization focus
- **ACM SIGCHI**: Human-computer interaction research

#### Developer Communities
- **D3.js Community**: GitHub discussions and Stack Overflow
- **Observable Community**: Collaborative notebook platform
- **Reddit r/dataviz**: Visualization showcase and discussions
- **Visualization Twitter Community**: Real-time discussions and examples

### Tools and Datasets

#### Development Tools
- **Observable**: Interactive development environment
- **CodePen**: Quick prototyping and sharing
- **JSFiddle**: Online code editor
- **GitHub Pages**: Free hosting for visualization projects

#### Practice Datasets
- **Stanford Large Network Dataset Collection**: Academic research datasets
- **NetworkRepository**: Comprehensive network data repository
- **Gephi Dataset Collection**: Ready-to-use network files
- **Facebook Social Network Data**: Anonymized social network datasets
- **Citation Networks**: Academic paper citation data

#### Software Tools
- **Gephi**: Desktop network analysis and visualization
- **Cytoscape**: Biological network analysis platform
- **NodeXL**: Excel plugin for network analysis
- **NetworkX**: Python library for network analysis
- **igraph**: R and Python library for network analysis

This comprehensive guide provides the foundation for creating sophisticated network and graph visualizations using NPL-FIM approaches. The combination of structured prompting, advanced algorithms, and interactive design creates powerful tools for exploring and understanding complex relational data.
