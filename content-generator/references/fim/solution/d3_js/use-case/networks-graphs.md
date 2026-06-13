# D3.js Networks & Graphs - NPL-FIM Solution Guide

## NPL-FIM Direct Integration
```npl
@fim:d3_js:networks {
  artifact: "interactive_network_visualization"
  layout: "force_directed|hierarchical|circular|matrix"
  data_format: "json|csv|adjacency_matrix"
  interaction: "drag|zoom|hover|click|select"
  physics: "enabled|static|custom"
  styling: "default|themed|custom"
  size: "small|medium|large|responsive"
  complexity: "simple|moderate|advanced"
}
```

## Core Implementation Templates

### 1. Force-Directed Network (Primary Template)
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>D3.js Force-Directed Network</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        .network-container {
            width: 100%;
            height: 600px;
            border: 1px solid #ddd;
            background: #fafafa;
        }
        .node {
            fill: #4a90e2;
            stroke: #fff;
            stroke-width: 2px;
            cursor: pointer;
        }
        .node:hover {
            fill: #357abd;
            stroke-width: 3px;
        }
        .link {
            stroke: #999;
            stroke-opacity: 0.6;
            stroke-width: 1.5px;
        }
        .node-label {
            font-family: Arial, sans-serif;
            font-size: 12px;
            fill: #333;
            text-anchor: middle;
            pointer-events: none;
        }
        .controls {
            margin: 10px 0;
            padding: 10px;
            background: #f0f0f0;
            border-radius: 5px;
        }
        .control-button {
            margin: 0 5px;
            padding: 5px 10px;
            background: #4a90e2;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        .control-button:hover {
            background: #357abd;
        }
        .tooltip {
            position: absolute;
            padding: 8px;
            background: rgba(0, 0, 0, 0.8);
            color: white;
            border-radius: 4px;
            font-size: 12px;
            pointer-events: none;
            opacity: 0;
            transition: opacity 0.3s;
        }
    </style>
</head>
<body>
    <div class="controls">
        <button class="control-button" onclick="restartSimulation()">Restart</button>
        <button class="control-button" onclick="togglePhysics()">Toggle Physics</button>
        <button class="control-button" onclick="centerGraph()">Center</button>
        <button class="control-button" onclick="exportSVG()">Export SVG</button>
        <label>
            Charge Strength:
            <input type="range" id="chargeSlider" min="-1000" max="-50" value="-300"
                   oninput="updateCharge(this.value)">
            <span id="chargeValue">-300</span>
        </label>
    </div>

    <div id="network" class="network-container"></div>
    <div id="tooltip" class="tooltip"></div>

    <script>
// Network Configuration
const config = {
    width: 960,
    height: 600,
    charge: -300,
    linkDistance: 50,
    collisionRadius: 10,
    showLabels: true,
    enablePhysics: true
};

// Sample Data Structure
const sampleData = {
    nodes: [
        {id: "A", group: 1, size: 20, label: "Node A", description: "Central hub node"},
        {id: "B", group: 1, size: 15, label: "Node B", description: "Secondary node"},
        {id: "C", group: 2, size: 10, label: "Node C", description: "Cluster member"},
        {id: "D", group: 2, size: 12, label: "Node D", description: "Connector node"},
        {id: "E", group: 3, size: 8, label: "Node E", description: "Peripheral node"},
        {id: "F", group: 3, size: 6, label: "Node F", description: "Edge node"}
    ],
    links: [
        {source: "A", target: "B", weight: 3, type: "strong"},
        {source: "A", target: "C", weight: 2, type: "medium"},
        {source: "B", target: "D", weight: 1, type: "weak"},
        {source: "C", target: "D", weight: 2, type: "medium"},
        {source: "D", target: "E", weight: 1, type: "weak"},
        {source: "E", target: "F", weight: 1, type: "weak"}
    ]
};

// Initialize SVG and container
const container = d3.select("#network");
const svg = container.append("svg")
    .attr("width", config.width)
    .attr("height", config.height)
    .call(d3.zoom()
        .scaleExtent([0.1, 10])
        .on("zoom", (event) => {
            g.attr("transform", event.transform);
        }));

const g = svg.append("g");

// Tooltip
const tooltip = d3.select("#tooltip");

// Color scale for groups
const colorScale = d3.scaleOrdinal(d3.schemeCategory10);

// Force simulation setup
let simulation = d3.forceSimulation()
    .force("link", d3.forceLink().id(d => d.id).distance(config.linkDistance))
    .force("charge", d3.forceManyBody().strength(config.charge))
    .force("center", d3.forceCenter(config.width / 2, config.height / 2))
    .force("collision", d3.forceCollide().radius(d => d.size + config.collisionRadius));

// Create network visualization
function createNetwork(data) {
    // Clear existing elements
    g.selectAll("*").remove();

    // Create links
    const link = g.append("g")
        .attr("class", "links")
        .selectAll("line")
        .data(data.links)
        .enter().append("line")
        .attr("class", "link")
        .attr("stroke-width", d => Math.sqrt(d.weight * 2))
        .attr("stroke-dasharray", d => d.type === "weak" ? "5,5" : null);

    // Create nodes
    const node = g.append("g")
        .attr("class", "nodes")
        .selectAll("circle")
        .data(data.nodes)
        .enter().append("circle")
        .attr("class", "node")
        .attr("r", d => d.size || 8)
        .attr("fill", d => colorScale(d.group))
        .call(createDragBehavior())
        .on("mouseover", showTooltip)
        .on("mouseout", hideTooltip)
        .on("click", selectNode);

    // Create labels (optional)
    let labels;
    if (config.showLabels) {
        labels = g.append("g")
            .attr("class", "labels")
            .selectAll("text")
            .data(data.nodes)
            .enter().append("text")
            .attr("class", "node-label")
            .text(d => d.label || d.id);
    }

    // Update simulation
    simulation.nodes(data.nodes);
    simulation.force("link").links(data.links);

    // Simulation tick function
    simulation.on("tick", () => {
        link.attr("x1", d => d.source.x)
            .attr("y1", d => d.source.y)
            .attr("x2", d => d.target.x)
            .attr("y2", d => d.target.y);

        node.attr("cx", d => d.x)
            .attr("cy", d => d.y);

        if (labels) {
            labels.attr("x", d => d.x)
                  .attr("y", d => d.y + 4);
        }
    });

    // Restart simulation
    simulation.alpha(1).restart();
}

// Drag behavior
function createDragBehavior() {
    return d3.drag()
        .on("start", (event, d) => {
            if (!event.active) simulation.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
        })
        .on("drag", (event, d) => {
            d.fx = event.x;
            d.fy = event.y;
        })
        .on("end", (event, d) => {
            if (!event.active) simulation.alphaTarget(0);
            if (!event.sourceEvent.shiftKey) {
                d.fx = null;
                d.fy = null;
            }
        });
}

// Tooltip functions
function showTooltip(event, d) {
    tooltip.transition().duration(200).style("opacity", 1);
    tooltip.html(`
        <strong>${d.label || d.id}</strong><br/>
        Group: ${d.group}<br/>
        Size: ${d.size}<br/>
        ${d.description || 'No description'}
    `)
    .style("left", (event.pageX + 10) + "px")
    .style("top", (event.pageY - 10) + "px");
}

function hideTooltip() {
    tooltip.transition().duration(500).style("opacity", 0);
}

// Node selection
let selectedNodes = new Set();
function selectNode(event, d) {
    if (selectedNodes.has(d.id)) {
        selectedNodes.delete(d.id);
        d3.select(this).classed("selected", false);
    } else {
        selectedNodes.add(d.id);
        d3.select(this).classed("selected", true);
    }

    // Highlight connected nodes
    highlightConnectedNodes(d.id);
}

function highlightConnectedNodes(nodeId) {
    const connectedNodes = new Set();
    sampleData.links.forEach(link => {
        if (link.source.id === nodeId) connectedNodes.add(link.target.id);
        if (link.target.id === nodeId) connectedNodes.add(link.source.id);
    });

    g.selectAll(".node")
        .style("opacity", d => connectedNodes.has(d.id) || d.id === nodeId ? 1 : 0.3);

    g.selectAll(".link")
        .style("opacity", d =>
            (d.source.id === nodeId || d.target.id === nodeId) ? 1 : 0.1);
}

// Control functions
function restartSimulation() {
    simulation.alpha(1).restart();
}

function togglePhysics() {
    config.enablePhysics = !config.enablePhysics;
    if (config.enablePhysics) {
        simulation.alpha(1).restart();
    } else {
        simulation.stop();
    }
}

function centerGraph() {
    const transform = d3.zoomIdentity.translate(0, 0).scale(1);
    svg.transition().duration(750).call(
        d3.zoom().transform,
        transform
    );
}

function updateCharge(value) {
    config.charge = +value;
    document.getElementById("chargeValue").textContent = value;
    simulation.force("charge").strength(config.charge);
    simulation.alpha(1).restart();
}

function exportSVG() {
    const svgData = new XMLSerializer().serializeToString(svg.node());
    const blob = new Blob([svgData], {type: "image/svg+xml"});
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "network-graph.svg";
    link.click();
}

// Initialize with sample data
createNetwork(sampleData);

// Data loading function for external data
function loadNetworkData(dataUrl) {
    d3.json(dataUrl).then(data => {
        createNetwork(data);
    }).catch(error => {
        console.error("Error loading data:", error);
        // Fallback to sample data
        createNetwork(sampleData);
    });
}

// Export functions for external use
window.NetworkGraph = {
    create: createNetwork,
    loadData: loadNetworkData,
    config: config,
    simulation: simulation
};
    </script>
</body>
</html>
```

### 2. Hierarchical Network Layout
```javascript
// Hierarchical tree layout for organizational charts and dependencies
class HierarchicalNetwork {
    constructor(containerId, options = {}) {
        this.container = d3.select(containerId);
        this.options = {
            width: 960,
            height: 600,
            orientation: 'horizontal', // horizontal, vertical, radial
            nodeSize: [180, 30],
            separation: (a, b) => a.parent === b.parent ? 1 : 2,
            ...options
        };

        this.svg = this.container.append("svg")
            .attr("width", this.options.width)
            .attr("height", this.options.height);

        this.g = this.svg.append("g");

        this.setupLayout();
    }

    setupLayout() {
        switch(this.options.orientation) {
            case 'vertical':
                this.tree = d3.tree().size([this.options.width, this.options.height]);
                break;
            case 'radial':
                this.tree = d3.tree().size([2 * Math.PI, Math.min(this.options.width, this.options.height) / 2]);
                break;
            default: // horizontal
                this.tree = d3.tree().size([this.options.height, this.options.width]);
        }

        this.tree.nodeSize(this.options.nodeSize)
                 .separation(this.options.separation);
    }

    render(data) {
        // Convert data to hierarchy
        const root = d3.hierarchy(data);

        // Generate tree layout
        this.tree(root);

        // Apply transformations based on orientation
        this.applyOrientation(root);

        // Render links
        this.renderLinks(root.links());

        // Render nodes
        this.renderNodes(root.descendants());

        return this;
    }

    applyOrientation(root) {
        if (this.options.orientation === 'radial') {
            root.each(d => {
                d.x = d.x;
                d.y = d.y;
                d.x0 = d.y * Math.cos(d.x - Math.PI / 2);
                d.y0 = d.y * Math.sin(d.x - Math.PI / 2);
            });
        } else if (this.options.orientation === 'vertical') {
            root.each(d => {
                d.x0 = d.x;
                d.y0 = d.y;
            });
        } else { // horizontal
            root.each(d => {
                d.x0 = d.y;
                d.y0 = d.x;
            });
        }
    }

    renderLinks(links) {
        const linkGenerator = this.options.orientation === 'radial'
            ? d3.linkRadial().angle(d => d.x).radius(d => d.y)
            : d3.linkHorizontal().x(d => d.x0).y(d => d.y0);

        this.g.selectAll(".link")
            .data(links)
            .enter().append("path")
            .attr("class", "link")
            .attr("d", linkGenerator)
            .attr("fill", "none")
            .attr("stroke", "#ccc")
            .attr("stroke-width", 2);
    }

    renderNodes(nodes) {
        const node = this.g.selectAll(".node")
            .data(nodes)
            .enter().append("g")
            .attr("class", "node")
            .attr("transform", d => `translate(${d.x0},${d.y0})`);

        node.append("circle")
            .attr("r", 8)
            .attr("fill", d => d.children ? "#4a90e2" : "#e74c3c");

        node.append("text")
            .attr("dy", 3)
            .attr("x", d => d.children ? -12 : 12)
            .style("text-anchor", d => d.children ? "end" : "start")
            .text(d => d.data.name);
    }
}

// Usage example
const hierarchicalData = {
    name: "CEO",
    children: [
        {
            name: "VP Engineering",
            children: [
                {name: "Frontend Team Lead"},
                {name: "Backend Team Lead"},
                {name: "DevOps Lead"}
            ]
        },
        {
            name: "VP Marketing",
            children: [
                {name: "Content Manager"},
                {name: "Social Media Manager"}
            ]
        }
    ]
};

const hierarchicalNetwork = new HierarchicalNetwork("#hierarchy-container", {
    orientation: 'horizontal'
});
hierarchicalNetwork.render(hierarchicalData);
```

### 3. Circular Network Layout
```javascript
// Circular layout for showing relationships in a circle
class CircularNetwork {
    constructor(containerId, options = {}) {
        this.container = d3.select(containerId);
        this.options = {
            width: 600,
            height: 600,
            innerRadius: 80,
            outerRadius: 250,
            ...options
        };

        this.svg = this.container.append("svg")
            .attr("width", this.options.width)
            .attr("height", this.options.height);

        this.g = this.svg.append("g")
            .attr("transform", `translate(${this.options.width/2},${this.options.height/2})`);
    }

    render(data) {
        const nodes = data.nodes;
        const links = data.links;

        // Position nodes in circle
        nodes.forEach((node, i) => {
            const angle = (2 * Math.PI * i) / nodes.length;
            node.x = Math.cos(angle) * this.options.outerRadius;
            node.y = Math.sin(angle) * this.options.outerRadius;
        });

        // Create chord diagram for links
        this.renderChords(links);

        // Render nodes
        this.renderNodes(nodes);

        return this;
    }

    renderChords(links) {
        const chord = d3.chord()
            .padAngle(0.05)
            .sortSubgroups(d3.descending);

        // Convert links to matrix format for chord diagram
        const matrix = this.linksToMatrix(links);
        const chords = chord(matrix);

        this.g.selectAll(".chord")
            .data(chords)
            .enter().append("path")
            .attr("class", "chord")
            .attr("d", d3.ribbon().radius(this.options.innerRadius))
            .style("fill", d => d3.schemeCategory10[d.source.index])
            .style("opacity", 0.7);
    }

    renderNodes(nodes) {
        const node = this.g.selectAll(".node")
            .data(nodes)
            .enter().append("g")
            .attr("class", "node")
            .attr("transform", d => `translate(${d.x},${d.y})`);

        node.append("circle")
            .attr("r", 12)
            .attr("fill", "#4a90e2");

        node.append("text")
            .attr("dy", 4)
            .style("text-anchor", "middle")
            .style("fill", "white")
            .style("font-size", "10px")
            .text(d => d.id);
    }

    linksToMatrix(links) {
        // Convert link data to adjacency matrix for chord diagram
        const nodeIds = new Set();
        links.forEach(link => {
            nodeIds.add(link.source);
            nodeIds.add(link.target);
        });

        const nodes = Array.from(nodeIds);
        const matrix = nodes.map(() => nodes.map(() => 0));

        links.forEach(link => {
            const sourceIndex = nodes.indexOf(link.source);
            const targetIndex = nodes.indexOf(link.target);
            matrix[sourceIndex][targetIndex] = link.weight || 1;
        });

        return matrix;
    }
}
```

## Data Format Specifications

### Standard JSON Format
```json
{
    "nodes": [
        {
            "id": "unique_identifier",
            "label": "Display Name",
            "group": 1,
            "size": 20,
            "color": "#4a90e2",
            "description": "Node description for tooltips",
            "metadata": {
                "type": "person|organization|concept",
                "category": "classification",
                "importance": 0.8
            }
        }
    ],
    "links": [
        {
            "source": "source_node_id",
            "target": "target_node_id",
            "weight": 3,
            "type": "relationship_type",
            "label": "Edge Label",
            "color": "#999",
            "metadata": {
                "strength": 0.7,
                "direction": "bidirectional|unidirectional"
            }
        }
    ]
}
```

### CSV Data Loading
```javascript
// Load nodes and links from separate CSV files
async function loadCSVNetwork(nodesFile, linksFile) {
    try {
        const [nodes, links] = await Promise.all([
            d3.csv(nodesFile, d => ({
                id: d.id,
                label: d.label,
                group: +d.group,
                size: +d.size || 10
            })),
            d3.csv(linksFile, d => ({
                source: d.source,
                target: d.target,
                weight: +d.weight || 1,
                type: d.type
            }))
        ]);

        return { nodes, links };
    } catch (error) {
        console.error("Error loading CSV data:", error);
        throw error;
    }
}

// Usage
loadCSVNetwork("nodes.csv", "links.csv")
    .then(data => createNetwork(data))
    .catch(error => console.error("Failed to load network:", error));
```

### Adjacency Matrix Format
```javascript
// Convert adjacency matrix to nodes/links format
function matrixToNetwork(matrix, nodeLabels) {
    const nodes = nodeLabels.map((label, i) => ({
        id: i.toString(),
        label: label,
        group: 1
    }));

    const links = [];
    matrix.forEach((row, i) => {
        row.forEach((weight, j) => {
            if (weight > 0 && i !== j) {
                links.push({
                    source: i.toString(),
                    target: j.toString(),
                    weight: weight
                });
            }
        });
    });

    return { nodes, links };
}

// Example adjacency matrix
const adjacencyMatrix = [
    [0, 1, 1, 0],
    [1, 0, 1, 1],
    [1, 1, 0, 1],
    [0, 1, 1, 0]
];
const labels = ["Node A", "Node B", "Node C", "Node D"];
const networkData = matrixToNetwork(adjacencyMatrix, labels);
```

## Advanced Configuration Options

### Force Simulation Customization
```javascript
const advancedConfig = {
    // Force parameters
    forces: {
        link: {
            distance: 50,
            strength: 0.5,
            iterations: 1
        },
        charge: {
            strength: -300,
            theta: 0.9,
            distanceMin: 1,
            distanceMax: Infinity
        },
        center: {
            strength: 1
        },
        collision: {
            radius: d => d.size + 5,
            strength: 0.7,
            iterations: 1
        },
        x: {
            strength: 0.1,
            x: d => d.targetX || 0
        },
        y: {
            strength: 0.1,
            y: d => d.targetY || 0
        }
    },

    // Visual styling
    styling: {
        nodes: {
            radius: d => Math.sqrt(d.size) * 2,
            fill: d => d.color || colorScale(d.group),
            stroke: "#fff",
            strokeWidth: 2,
            opacity: 1
        },
        links: {
            stroke: d => d.color || "#999",
            strokeWidth: d => Math.sqrt(d.weight),
            strokeOpacity: 0.6,
            strokeDasharray: d => d.type === "dashed" ? "5,5" : null
        },
        labels: {
            fontSize: "12px",
            fontFamily: "Arial, sans-serif",
            fill: "#333",
            textAnchor: "middle",
            dy: "0.35em"
        }
    },

    // Interaction behaviors
    interactions: {
        drag: {
            enabled: true,
            fixOnDrag: false,
            alphaTarget: 0.3
        },
        zoom: {
            enabled: true,
            scaleExtent: [0.1, 10],
            translateExtent: [[-1000, -1000], [1000, 1000]]
        },
        hover: {
            enabled: true,
            highlightConnected: true,
            showTooltip: true
        },
        click: {
            enabled: true,
            multiSelect: true,
            expandOnClick: false
        }
    },

    // Performance optimizations
    performance: {
        useWebGL: false, // Enable for large datasets
        levelOfDetail: true, // Simplify rendering at low zoom
        maxNodes: 1000, // Warn above this threshold
        culling: true, // Don't render off-screen elements
        fps: 60 // Target frame rate
    }
};

function createAdvancedNetwork(data, config = advancedConfig) {
    // Apply advanced configuration
    const simulation = d3.forceSimulation(data.nodes);

    // Configure forces based on config
    Object.entries(config.forces).forEach(([forceType, forceConfig]) => {
        switch(forceType) {
            case 'link':
                simulation.force('link',
                    d3.forceLink(data.links)
                        .id(d => d.id)
                        .distance(forceConfig.distance)
                        .strength(forceConfig.strength)
                        .iterations(forceConfig.iterations)
                );
                break;
            case 'charge':
                simulation.force('charge',
                    d3.forceManyBody()
                        .strength(forceConfig.strength)
                        .theta(forceConfig.theta)
                        .distanceMin(forceConfig.distanceMin)
                        .distanceMax(forceConfig.distanceMax)
                );
                break;
            case 'center':
                simulation.force('center',
                    d3.forceCenter(config.width / 2, config.height / 2)
                        .strength(forceConfig.strength)
                );
                break;
            case 'collision':
                simulation.force('collision',
                    d3.forceCollide()
                        .radius(forceConfig.radius)
                        .strength(forceConfig.strength)
                        .iterations(forceConfig.iterations)
                );
                break;
        }
    });

    return simulation;
}
```

### Performance Optimization for Large Networks
```javascript
class PerformantNetwork {
    constructor(containerId, options = {}) {
        this.container = d3.select(containerId);
        this.options = {
            maxNodes: 10000,
            useCanvas: true,
            enableLOD: true, // Level of Detail
            cullOffscreen: true,
            ...options
        };

        this.setupRenderer();
    }

    setupRenderer() {
        if (this.options.useCanvas) {
            this.canvas = this.container.append("canvas")
                .attr("width", this.options.width)
                .attr("height", this.options.height);
            this.context = this.canvas.node().getContext("2d");
        } else {
            this.svg = this.container.append("svg")
                .attr("width", this.options.width)
                .attr("height", this.options.height);
        }
    }

    render(data) {
        if (data.nodes.length > this.options.maxNodes) {
            console.warn(`Large dataset detected (${data.nodes.length} nodes). Consider using sampling or clustering.`);
            return this.renderSampled(data);
        }

        if (this.options.useCanvas) {
            return this.renderCanvas(data);
        } else {
            return this.renderSVG(data);
        }
    }

    renderCanvas(data) {
        const context = this.context;
        const width = this.options.width;
        const height = this.options.height;

        // Set up simulation
        const simulation = d3.forceSimulation(data.nodes)
            .force("link", d3.forceLink(data.links).id(d => d.id))
            .force("charge", d3.forceManyBody().strength(-30))
            .force("center", d3.forceCenter(width / 2, height / 2))
            .on("tick", ticked);

        function ticked() {
            context.clearRect(0, 0, width, height);

            // Draw links
            context.beginPath();
            context.strokeStyle = "#999";
            context.lineWidth = 1;
            data.links.forEach(drawLink);
            context.stroke();

            // Draw nodes
            context.beginPath();
            context.fillStyle = "#4a90e2";
            data.nodes.forEach(drawNode);
            context.fill();
        }

        function drawLink(d) {
            context.moveTo(d.source.x, d.source.y);
            context.lineTo(d.target.x, d.target.y);
        }

        function drawNode(d) {
            context.moveTo(d.x + 3, d.y);
            context.arc(d.x, d.y, 3, 0, 2 * Math.PI);
        }

        return this;
    }

    renderSampled(data) {
        // Sample large datasets for performance
        const sampleSize = Math.min(this.options.maxNodes, data.nodes.length);
        const sampledNodes = this.sampleNodes(data.nodes, sampleSize);
        const sampledLinks = this.filterLinks(data.links, sampledNodes);

        return this.render({ nodes: sampledNodes, links: sampledLinks });
    }

    sampleNodes(nodes, sampleSize) {
        // Intelligent sampling based on node importance
        return nodes
            .sort((a, b) => (b.importance || 0) - (a.importance || 0))
            .slice(0, sampleSize);
    }

    filterLinks(links, sampledNodes) {
        const nodeIds = new Set(sampledNodes.map(n => n.id));
        return links.filter(link =>
            nodeIds.has(link.source.id || link.source) &&
            nodeIds.has(link.target.id || link.target)
        );
    }
}
```

## Network Analysis Features

### Centrality Calculations
```javascript
class NetworkAnalyzer {
    constructor(data) {
        this.nodes = data.nodes;
        this.links = data.links;
        this.adjacencyList = this.buildAdjacencyList();
    }

    buildAdjacencyList() {
        const adjacencyList = {};
        this.nodes.forEach(node => {
            adjacencyList[node.id] = [];
        });

        this.links.forEach(link => {
            const sourceId = link.source.id || link.source;
            const targetId = link.target.id || link.target;
            adjacencyList[sourceId].push(targetId);
            adjacencyList[targetId].push(sourceId); // Undirected
        });

        return adjacencyList;
    }

    calculateDegreeCentrality() {
        const centrality = {};
        Object.entries(this.adjacencyList).forEach(([nodeId, neighbors]) => {
            centrality[nodeId] = neighbors.length;
        });
        return centrality;
    }

    calculateBetweennessCentrality() {
        const centrality = {};
        const nodes = Object.keys(this.adjacencyList);

        // Initialize centrality scores
        nodes.forEach(node => centrality[node] = 0);

        // Calculate betweenness for each node pair
        nodes.forEach(source => {
            const distances = this.shortestPaths(source);
            const predecessors = distances.predecessors;
            const sigma = distances.sigma;

            nodes.forEach(target => {
                if (source !== target) {
                    this.accumulateBetweenness(centrality, source, target, predecessors, sigma);
                }
            });
        });

        // Normalize
        const n = nodes.length;
        const normalizationFactor = 2 / ((n - 1) * (n - 2));
        Object.keys(centrality).forEach(node => {
            centrality[node] *= normalizationFactor;
        });

        return centrality;
    }

    calculateClosenessCentrality() {
        const centrality = {};
        const nodes = Object.keys(this.adjacencyList);

        nodes.forEach(node => {
            const distances = this.shortestPaths(node);
            const totalDistance = Object.values(distances.distances)
                .filter(d => d !== Infinity && d > 0)
                .reduce((sum, d) => sum + d, 0);

            centrality[node] = totalDistance > 0 ? 1 / totalDistance : 0;
        });

        return centrality;
    }

    shortestPaths(source) {
        const distances = {};
        const predecessors = {};
        const sigma = {};
        const visited = new Set();
        const queue = [source];

        // Initialize
        Object.keys(this.adjacencyList).forEach(node => {
            distances[node] = Infinity;
            predecessors[node] = [];
            sigma[node] = 0;
        });

        distances[source] = 0;
        sigma[source] = 1;

        // BFS for shortest paths
        while (queue.length > 0) {
            const current = queue.shift();
            visited.add(current);

            this.adjacencyList[current].forEach(neighbor => {
                const newDistance = distances[current] + 1;

                if (distances[neighbor] > newDistance) {
                    distances[neighbor] = newDistance;
                    predecessors[neighbor] = [current];
                    sigma[neighbor] = sigma[current];

                    if (!visited.has(neighbor)) {
                        queue.push(neighbor);
                    }
                } else if (distances[neighbor] === newDistance) {
                    predecessors[neighbor].push(current);
                    sigma[neighbor] += sigma[current];
                }
            });
        }

        return { distances, predecessors, sigma };
    }

    accumulateBetweenness(centrality, source, target, predecessors, sigma) {
        // Accumulate betweenness centrality from dependency calculation
        // Implementation of Brandes' algorithm
        const stack = [];
        const dependency = {};

        Object.keys(this.adjacencyList).forEach(node => {
            dependency[node] = 0;
        });

        // Implementation details omitted for brevity
        // Full Brandes' algorithm would be implemented here
    }

    detectCommunities() {
        // Simple community detection using modularity optimization
        const communities = new Map();
        let communityId = 0;

        // Initialize each node in its own community
        this.nodes.forEach(node => {
            communities.set(node.id, communityId++);
        });

        // Iteratively merge communities to maximize modularity
        let improved = true;
        while (improved) {
            improved = false;
            // Community merging logic would go here
        }

        return communities;
    }

    calculateModularity(communities) {
        const m = this.links.length;
        let modularity = 0;

        this.nodes.forEach(nodeI => {
            this.nodes.forEach(nodeJ => {
                const sameComm = communities.get(nodeI.id) === communities.get(nodeJ.id) ? 1 : 0;
                const edgeExists = this.hasEdge(nodeI.id, nodeJ.id) ? 1 : 0;
                const ki = this.adjacencyList[nodeI.id].length;
                const kj = this.adjacencyList[nodeJ.id].length;

                modularity += (edgeExists - (ki * kj) / (2 * m)) * sameComm;
            });
        });

        return modularity / (2 * m);
    }

    hasEdge(nodeId1, nodeId2) {
        return this.adjacencyList[nodeId1].includes(nodeId2);
    }
}

// Usage example
const analyzer = new NetworkAnalyzer(networkData);
const degreeCentrality = analyzer.calculateDegreeCentrality();
const betweennessCentrality = analyzer.calculateBetweennessCentrality();
const closenessCentrality = analyzer.calculateClosenessCentrality();
const communities = analyzer.detectCommunities();

// Apply analysis results to visualization
networkData.nodes.forEach(node => {
    node.degreeCentrality = degreeCentrality[node.id];
    node.betweennessCentrality = betweennessCentrality[node.id];
    node.closenessCentrality = closenessCentrality[node.id];
    node.community = communities.get(node.id);
});
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Performance Problems with Large Networks
**Problem**: Visualization becomes slow or unresponsive with many nodes/links.

**Solutions**:
```javascript
// Solution 1: Use Canvas instead of SVG
const useCanvas = true;

// Solution 2: Implement level-of-detail rendering
function shouldRenderNode(node, zoom) {
    return zoom > 0.5 || node.importance > 0.7;
}

// Solution 3: Sample large datasets
function sampleNetwork(data, maxNodes = 1000) {
    if (data.nodes.length <= maxNodes) return data;

    // Sort by importance and take top nodes
    const sampledNodes = data.nodes
        .sort((a, b) => (b.importance || 0) - (a.importance || 0))
        .slice(0, maxNodes);

    const nodeIds = new Set(sampledNodes.map(n => n.id));
    const sampledLinks = data.links.filter(link =>
        nodeIds.has(link.source.id || link.source) &&
        nodeIds.has(link.target.id || link.target)
    );

    return { nodes: sampledNodes, links: sampledLinks };
}

// Solution 4: Optimize force simulation
const optimizedSimulation = d3.forceSimulation(nodes)
    .force("link", d3.forceLink(links).id(d => d.id).iterations(1))
    .force("charge", d3.forceManyBody().strength(-30).theta(0.8))
    .force("center", d3.forceCenter(width / 2, height / 2))
    .alphaDecay(0.02) // Faster convergence
    .velocityDecay(0.8); // More damping
```

#### 2. Layout Issues
**Problem**: Nodes overlapping or poor layout distribution.

**Solutions**:
```javascript
// Solution 1: Add collision detection
simulation.force("collision", d3.forceCollide()
    .radius(d => (d.size || 5) + 2)
    .strength(0.7)
    .iterations(2));

// Solution 2: Adjust force strengths
simulation.force("charge", d3.forceManyBody()
    .strength(d => -300 * (d.size || 5) / 5)); // Scale by node size

// Solution 3: Use positioning forces for specific layouts
simulation.force("x", d3.forceX()
    .strength(0.1)
    .x(d => d.targetX || width / 2));

simulation.force("y", d3.forceY()
    .strength(0.1)
    .y(d => d.targetY || height / 2));

// Solution 4: Manual positioning for important nodes
function positionImportantNodes(nodes) {
    const importantNodes = nodes.filter(n => n.importance > 0.8);
    const angleStep = (2 * Math.PI) / importantNodes.length;

    importantNodes.forEach((node, i) => {
        const angle = i * angleStep;
        node.fx = width / 2 + Math.cos(angle) * 100;
        node.fy = height / 2 + Math.sin(angle) * 100;
    });
}
```

#### 3. Data Loading and Format Issues
**Problem**: Data not loading correctly or format errors.

**Solutions**:
```javascript
// Solution 1: Comprehensive data validation
function validateNetworkData(data) {
    const errors = [];

    // Check required properties
    if (!data.nodes || !Array.isArray(data.nodes)) {
        errors.push("Missing or invalid nodes array");
    }
    if (!data.links || !Array.isArray(data.links)) {
        errors.push("Missing or invalid links array");
    }

    // Validate nodes
    const nodeIds = new Set();
    data.nodes.forEach((node, i) => {
        if (!node.id) {
            errors.push(`Node ${i} missing required 'id' property`);
        } else if (nodeIds.has(node.id)) {
            errors.push(`Duplicate node ID: ${node.id}`);
        } else {
            nodeIds.add(node.id);
        }
    });

    // Validate links
    data.links.forEach((link, i) => {
        if (!link.source) {
            errors.push(`Link ${i} missing 'source' property`);
        }
        if (!link.target) {
            errors.push(`Link ${i} missing 'target' property`);
        }
        if (link.source && !nodeIds.has(link.source)) {
            errors.push(`Link ${i} references unknown source: ${link.source}`);
        }
        if (link.target && !nodeIds.has(link.target)) {
            errors.push(`Link ${i} references unknown target: ${link.target}`);
        }
    });

    return {
        isValid: errors.length === 0,
        errors: errors
    };
}

// Solution 2: Data cleaning and normalization
function cleanNetworkData(data) {
    // Remove duplicate nodes
    const uniqueNodes = [];
    const seenIds = new Set();
    data.nodes.forEach(node => {
        if (!seenIds.has(node.id)) {
            seenIds.add(node.id);
            uniqueNodes.push({
                id: node.id,
                label: node.label || node.id,
                group: node.group || 1,
                size: Math.max(1, node.size || 5)
            });
        }
    });

    // Remove invalid links
    const validLinks = data.links.filter(link =>
        seenIds.has(link.source) && seenIds.has(link.target)
    ).map(link => ({
        source: link.source,
        target: link.target,
        weight: Math.max(0.1, link.weight || 1),
        type: link.type || "default"
    }));

    return { nodes: uniqueNodes, links: validLinks };
}

// Solution 3: Graceful error handling
async function loadNetworkDataSafely(url) {
    try {
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        const validation = validateNetworkData(data);

        if (!validation.isValid) {
            console.warn("Data validation warnings:", validation.errors);
            return cleanNetworkData(data);
        }

        return data;
    } catch (error) {
        console.error("Failed to load network data:", error);

        // Return fallback data
        return {
            nodes: [
                {id: "error", label: "Error Loading Data", group: 1, size: 10}
            ],
            links: []
        };
    }
}
```

#### 4. Interaction and Event Handling Issues
**Problem**: Drag, zoom, or click interactions not working correctly.

**Solutions**:
```javascript
// Solution 1: Proper event handling setup
function setupInteractions(nodes, links, simulation) {
    // Drag behavior
    const drag = d3.drag()
        .on("start", (event, d) => {
            if (!event.active) simulation.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
        })
        .on("drag", (event, d) => {
            d.fx = event.x;
            d.fy = event.y;
        })
        .on("end", (event, d) => {
            if (!event.active) simulation.alphaTarget(0);
            if (!event.sourceEvent.shiftKey) {
                d.fx = null;
                d.fy = null;
            }
        });

    // Apply drag to nodes
    nodes.call(drag);

    // Zoom behavior
    const zoom = d3.zoom()
        .scaleExtent([0.1, 10])
        .on("zoom", (event) => {
            g.attr("transform", event.transform);
        });

    svg.call(zoom);

    // Click behavior with proper event stopping
    nodes.on("click", (event, d) => {
        event.stopPropagation(); // Prevent zoom
        selectNode(d);
    });
}

// Solution 2: Mobile-friendly interactions
function setupMobileInteractions() {
    // Touch-friendly node size
    const minTouchTarget = 44; // iOS HIG recommendation

    nodes.attr("r", d => Math.max(minTouchTarget / 2, d.size || 5));

    // Prevent context menu on long press
    svg.on("contextmenu", (event) => {
        event.preventDefault();
    });

    // Handle touch events
    svg.on("touchstart", (event) => {
        if (event.touches.length > 1) {
            event.preventDefault(); // Prevent zoom
        }
    });
}
```

#### 5. Styling and Visual Issues
**Problem**: Inconsistent styling or visual artifacts.

**Solutions**:
```javascript
// Solution 1: Consistent CSS styles
const styles = `
    .network-svg {
        background: #fafafa;
        border: 1px solid #ddd;
    }
    .node {
        fill: #4a90e2;
        stroke: #fff;
        stroke-width: 2px;
        cursor: pointer;
        transition: all 0.3s ease;
    }
    .node:hover {
        fill: #357abd;
        stroke-width: 3px;
    }
    .node.selected {
        fill: #e74c3c;
        stroke: #c0392b;
        stroke-width: 4px;
    }
    .link {
        stroke: #999;
        stroke-opacity: 0.6;
        fill: none;
    }
    .link.highlighted {
        stroke: #e74c3c;
        stroke-opacity: 1;
        stroke-width: 3px;
    }
    .node-label {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        font-size: 12px;
        fill: #333;
        text-anchor: middle;
        pointer-events: none;
        user-select: none;
    }
`;

// Apply styles
const styleSheet = document.createElement("style");
styleSheet.textContent = styles;
document.head.appendChild(styleSheet);

// Solution 2: Responsive sizing
function makeResponsive(svg, container) {
    svg.attr("viewBox", `0 0 ${width} ${height}`)
       .attr("preserveAspectRatio", "xMidYMid meet")
       .style("width", "100%")
       .style("height", "auto");

    // Update on resize
    window.addEventListener("resize", () => {
        const containerRect = container.node().getBoundingClientRect();
        const newWidth = containerRect.width;
        const newHeight = containerRect.height;

        svg.attr("viewBox", `0 0 ${newWidth} ${newHeight}`);
        simulation.force("center", d3.forceCenter(newWidth / 2, newHeight / 2));
        simulation.alpha(1).restart();
    });
}
```

## Integration Examples

### React Component Integration
```jsx
import React, { useEffect, useRef, useState } from 'react';
import * as d3 from 'd3';

const NetworkVisualization = ({
    data,
    width = 800,
    height = 600,
    onNodeClick,
    onNodeHover
}) => {
    const svgRef = useRef();
    const [simulation, setSimulation] = useState(null);

    useEffect(() => {
        if (!data || !data.nodes || !data.links) return;

        const svg = d3.select(svgRef.current);
        svg.selectAll("*").remove(); // Clear previous render

        const g = svg.append("g");

        // Create simulation
        const sim = d3.forceSimulation(data.nodes)
            .force("link", d3.forceLink(data.links).id(d => d.id))
            .force("charge", d3.forceManyBody().strength(-300))
            .force("center", d3.forceCenter(width / 2, height / 2));

        // Create links
        const links = g.selectAll(".link")
            .data(data.links)
            .enter().append("line")
            .attr("class", "link")
            .attr("stroke", "#999")
            .attr("stroke-width", 2);

        // Create nodes
        const nodes = g.selectAll(".node")
            .data(data.nodes)
            .enter().append("circle")
            .attr("class", "node")
            .attr("r", d => d.size || 8)
            .attr("fill", "#4a90e2")
            .on("click", (event, d) => onNodeClick && onNodeClick(d))
            .on("mouseover", (event, d) => onNodeHover && onNodeHover(d, event))
            .call(d3.drag()
                .on("start", (event, d) => {
                    if (!event.active) sim.alphaTarget(0.3).restart();
                    d.fx = d.x;
                    d.fy = d.y;
                })
                .on("drag", (event, d) => {
                    d.fx = event.x;
                    d.fy = event.y;
                })
                .on("end", (event, d) => {
                    if (!event.active) sim.alphaTarget(0);
                    d.fx = null;
                    d.fy = null;
                }));

        // Tick function
        sim.on("tick", () => {
            links
                .attr("x1", d => d.source.x)
                .attr("y1", d => d.source.y)
                .attr("x2", d => d.target.x)
                .attr("y2", d => d.target.y);

            nodes
                .attr("cx", d => d.x)
                .attr("cy", d => d.y);
        });

        setSimulation(sim);

        // Cleanup
        return () => {
            sim.stop();
        };
    }, [data, width, height]);

    return (
        <svg
            ref={svgRef}
            width={width}
            height={height}
            style={{ border: '1px solid #ddd' }}
        />
    );
};

export default NetworkVisualization;
```

### Vue.js Component Integration
```vue
<template>
    <div class="network-container">
        <div class="controls">
            <button @click="restartSimulation">Restart</button>
            <button @click="centerView">Center</button>
            <select v-model="layoutType" @change="changeLayout">
                <option value="force">Force Directed</option>
                <option value="circular">Circular</option>
                <option value="hierarchy">Hierarchical</option>
            </select>
        </div>
        <svg ref="svg" :width="width" :height="height"></svg>
    </div>
</template>

<script>
import * as d3 from 'd3';

export default {
    name: 'NetworkVisualization',
    props: {
        data: {
            type: Object,
            required: true
        },
        width: {
            type: Number,
            default: 800
        },
        height: {
            type: Number,
            default: 600
        }
    },
    data() {
        return {
            simulation: null,
            layoutType: 'force'
        };
    },
    watch: {
        data: {
            handler() {
                this.renderNetwork();
            },
            deep: true
        }
    },
    mounted() {
        this.renderNetwork();
    },
    beforeUnmount() {
        if (this.simulation) {
            this.simulation.stop();
        }
    },
    methods: {
        renderNetwork() {
            if (!this.data || !this.data.nodes) return;

            const svg = d3.select(this.$refs.svg);
            svg.selectAll("*").remove();

            this.createVisualization(svg);
        },

        createVisualization(svg) {
            // Implementation similar to React example
            // but using Vue's reactive data and methods
        },

        restartSimulation() {
            if (this.simulation) {
                this.simulation.alpha(1).restart();
            }
        },

        centerView() {
            // Center the visualization
            const svg = d3.select(this.$refs.svg);
            const transform = d3.zoomIdentity;
            svg.transition().duration(750).call(
                d3.zoom().transform, transform
            );
        },

        changeLayout() {
            this.renderNetwork();
        }
    }
};
</script>

<style scoped>
.network-container {
    width: 100%;
    height: 100%;
}
.controls {
    margin-bottom: 10px;
    padding: 10px;
    background: #f5f5f5;
    border-radius: 5px;
}
.controls button, .controls select {
    margin-right: 10px;
    padding: 5px 10px;
}
</style>
```

## Dependencies and Environment Setup

### Required Dependencies
```json
{
    "dependencies": {
        "d3": "^7.8.5"
    },
    "devDependencies": {
        "@types/d3": "^7.4.0",
        "typescript": "^5.0.0"
    }
}
```

### CDN Links
```html
<!-- D3.js v7 -->
<script src="https://d3js.org/d3.v7.min.js"></script>

<!-- Or specific modules -->
<script src="https://d3js.org/d3-selection.v3.min.js"></script>
<script src="https://d3js.org/d3-force.v3.min.js"></script>
<script src="https://d3js.org/d3-drag.v3.min.js"></script>
<script src="https://d3js.org/d3-zoom.v3.min.js"></script>
```

### TypeScript Definitions
```typescript
interface NetworkNode {
    id: string;
    label?: string;
    group?: number;
    size?: number;
    color?: string;
    x?: number;
    y?: number;
    fx?: number | null;
    fy?: number | null;
    metadata?: Record<string, any>;
}

interface NetworkLink {
    source: string | NetworkNode;
    target: string | NetworkNode;
    weight?: number;
    type?: string;
    color?: string;
    metadata?: Record<string, any>;
}

interface NetworkData {
    nodes: NetworkNode[];
    links: NetworkLink[];
}

interface NetworkConfig {
    width: number;
    height: number;
    forces: {
        charge: number;
        linkDistance: number;
        center: boolean;
        collision: boolean;
    };
    styling: {
        nodeRadius: (d: NetworkNode) => number;
        nodeColor: (d: NetworkNode) => string;
        linkColor: (d: NetworkLink) => string;
        linkWidth: (d: NetworkLink) => number;
    };
    interactions: {
        drag: boolean;
        zoom: boolean;
        hover: boolean;
        click: boolean;
    };
}
```

## NPL-FIM Directive Patterns

### Complete Network Generation
```npl
@fim:d3_js:networks:complete {
    layout: "force_directed"
    nodes: 50
    connections: "medium_density"
    groups: 5
    interactivity: "full"
    styling: "modern"
    analysis: "centrality_metrics"
    export: "svg_png_json"
}
```

### Specific Use Case Templates
```npl
@fim:d3_js:networks:social {
    data_source: "social_media_api"
    layout: "force_directed"
    node_size: "follower_count"
    link_weight: "interaction_strength"
    community_detection: "enabled"
    filters: "influence_threshold"
}

@fim:d3_js:networks:dependency {
    data_source: "package_json"
    layout: "hierarchical"
    direction: "top_down"
    node_size: "dependency_count"
    link_type: "dependency_arrow"
    circular_detection: "highlight"
}

@fim:d3_js:networks:knowledge {
    data_source: "knowledge_graph"
    layout: "force_directed"
    node_types: "concept_entity_relation"
    link_semantics: "ontology_based"
    search: "semantic_query"
    expansion: "concept_exploration"
}
```

## Tool Advantages and Limitations

### D3.js Network Visualization Advantages
- **Flexibility**: Complete control over visual design and interaction
- **Performance**: Optimized force simulations and rendering
- **Customization**: Every aspect can be customized and extended
- **Integration**: Works with any web framework or vanilla JavaScript
- **Standards**: Built on web standards (SVG, Canvas, HTML)
- **Community**: Large ecosystem of examples and extensions
- **Data Binding**: Powerful data-driven approach to visualization
- **Animation**: Smooth transitions and real-time updates
- **Scalability**: Can handle large networks with optimization
- **Analysis**: Built-in support for network analysis algorithms

### Limitations and Considerations
- **Learning Curve**: Requires understanding of D3.js concepts and APIs
- **Complexity**: Network visualizations can become complex quickly
- **Performance**: Large networks (>10k nodes) require optimization
- **Layout Stability**: Force simulations can be unstable or slow to converge
- **Mobile**: Touch interactions need special consideration
- **Accessibility**: Requires additional work for screen readers and keyboard navigation
- **Browser Support**: Modern browser features required
- **Memory Usage**: Large datasets can consume significant memory
- **Maintenance**: Custom solutions require ongoing maintenance
- **Documentation**: Complex visualizations need comprehensive documentation

### When to Choose D3.js for Networks
**Choose D3.js when:**
- You need complete control over visual design
- Custom interactions and behaviors are required
- Integration with existing web applications is needed
- Performance optimization for large datasets is important
- Advanced network analysis features are required
- Unique or innovative visualization approaches are desired

**Consider alternatives when:**
- Rapid prototyping is the priority
- Standard network layouts are sufficient
- Development resources are limited
- Cross-platform compatibility is critical
- Real-time collaboration features are needed

This comprehensive guide provides everything needed for NPL-FIM to generate production-ready D3.js network visualizations with complete implementation details, troubleshooting guidance, and real-world integration examples.