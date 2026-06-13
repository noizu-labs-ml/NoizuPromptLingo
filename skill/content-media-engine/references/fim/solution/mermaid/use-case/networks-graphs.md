# Mermaid Networks & Graphs - NPL-FIM Implementation Guide

## Overview
Mermaid provides powerful network and graph visualization capabilities through declarative text syntax, enabling creation of complex system architecture diagrams, network topologies, dependency graphs, and relationship mappings. This guide provides comprehensive implementation patterns for NPL-FIM artifact generation.

## Quick Start Templates

### Basic Network Topology
```mermaid
graph TB
    subgraph "DMZ"
        FW[Firewall]
        LB[Load Balancer]
    end

    subgraph "Application Tier"
        WEB1[Web Server 1]
        WEB2[Web Server 2]
        APP1[App Server 1]
        APP2[App Server 2]
    end

    subgraph "Data Tier"
        DB1[(Primary DB)]
        DB2[(Replica DB)]
        CACHE[Redis Cache]
    end

    FW --> LB
    LB --> WEB1
    LB --> WEB2
    WEB1 --> APP1
    WEB2 --> APP2
    APP1 --> DB1
    APP2 --> DB1
    DB1 --> DB2
    APP1 --> CACHE
    APP2 --> CACHE
```

### Service Mesh Architecture
```mermaid
graph LR
    subgraph "Frontend"
        UI[React UI]
        MOBILE[Mobile App]
    end

    subgraph "API Gateway"
        GATEWAY[Kong Gateway]
        AUTH[Auth Service]
    end

    subgraph "Microservices"
        USER[User Service]
        ORDER[Order Service]
        PAYMENT[Payment Service]
        INVENTORY[Inventory Service]
        NOTIFICATION[Notification Service]
    end

    subgraph "Data Stores"
        USERDB[(User DB)]
        ORDERDB[(Order DB)]
        PAYMENTDB[(Payment DB)]
        INVENTORYDB[(Inventory DB)]
        MESSAGEQ[Message Queue]
    end

    UI --> GATEWAY
    MOBILE --> GATEWAY
    GATEWAY --> AUTH
    GATEWAY --> USER
    GATEWAY --> ORDER
    GATEWAY --> PAYMENT
    GATEWAY --> INVENTORY

    USER --> USERDB
    ORDER --> ORDERDB
    ORDER --> MESSAGEQ
    PAYMENT --> PAYMENTDB
    PAYMENT --> MESSAGEQ
    INVENTORY --> INVENTORYDB
    INVENTORY --> MESSAGEQ
    MESSAGEQ --> NOTIFICATION
```

## NPL-FIM Configuration

### Standard Network Diagram Configuration
```npl
@fim:mermaid {
  diagram_type: "graph"
  direction: "TB|LR|RL|BT"
  subgraph_clustering: true
  node_styling: {
    servers: "rect",
    databases: "cylinder",
    services: "rounded",
    external: "cloud"
  }
  edge_styling: {
    primary: "solid",
    backup: "dotted",
    async: "dashed"
  }
  color_scheme: "network_topology"
  layout_engine: "dagre"
  auto_sizing: true
}
```

### Advanced Graph Configuration
```npl
@fim:mermaid {
  diagram_type: "graph"
  interactive: true
  clustering: {
    enabled: true,
    auto_group: true,
    max_depth: 3
  }
  styling: {
    theme: "neutral",
    node_spacing: 50,
    rank_spacing: 100,
    curve: "basis"
  }
  labels: {
    show_on_edges: true,
    font_size: "12px",
    max_length: 20
  }
  export_options: {
    format: ["svg", "png"],
    background: "transparent"
  }
}
```

## Complete Implementation Examples

### Enterprise Network Architecture
```mermaid
graph TB
    subgraph "Internet"
        INTERNET((Internet))
    end

    subgraph "Edge Layer"
        CDN[CDN/CloudFlare]
        WAF[Web Application Firewall]
    end

    subgraph "DMZ"
        ROUTER[Border Router]
        FW[Next-Gen Firewall]
        LB[F5 Load Balancer]
    end

    subgraph "Web Tier"
        WEB1[Nginx Web Server 1]
        WEB2[Nginx Web Server 2]
        WEB3[Nginx Web Server 3]
    end

    subgraph "Application Tier"
        APP1[Node.js App 1]
        APP2[Node.js App 2]
        APP3[Python API]
        APP4[Java Microservice]
    end

    subgraph "Data Tier"
        MYSQL[(MySQL Primary)]
        MYSQL_REPLICA[(MySQL Replica)]
        REDIS[Redis Cluster]
        ELASTIC[Elasticsearch]
        S3[(S3 Storage)]
    end

    subgraph "Management"
        MONITOR[Prometheus]
        GRAFANA[Grafana]
        LOGS[ELK Stack]
    end

    INTERNET --> CDN
    CDN --> WAF
    WAF --> ROUTER
    ROUTER --> FW
    FW --> LB

    LB --> WEB1
    LB --> WEB2
    LB --> WEB3

    WEB1 --> APP1
    WEB2 --> APP2
    WEB3 --> APP3
    WEB1 --> APP4

    APP1 --> MYSQL
    APP2 --> MYSQL
    APP3 --> MYSQL
    APP4 --> MYSQL

    MYSQL --> MYSQL_REPLICA

    APP1 --> REDIS
    APP2 --> REDIS
    APP3 --> ELASTIC
    APP4 --> S3

    APP1 --> MONITOR
    APP2 --> MONITOR
    APP3 --> MONITOR
    APP4 --> MONITOR

    MONITOR --> GRAFANA
    MONITOR --> LOGS

    classDef internet fill:#ff6b6b,stroke:#c92a2a,color:#fff
    classDef edge fill:#4ecdc4,stroke:#26a69a,color:#fff
    classDef dmz fill:#45b7d1,stroke:#2196f3,color:#fff
    classDef web fill:#96ceb4,stroke:#4caf50,color:#fff
    classDef app fill:#feca57,stroke:#ff9800,color:#fff
    classDef data fill:#ff9ff3,stroke:#e91e63,color:#fff
    classDef mgmt fill:#dda0dd,stroke:#9c27b0,color:#fff

    class INTERNET internet
    class CDN,WAF edge
    class ROUTER,FW,LB dmz
    class WEB1,WEB2,WEB3 web
    class APP1,APP2,APP3,APP4 app
    class MYSQL,MYSQL_REPLICA,REDIS,ELASTIC,S3 data
    class MONITOR,GRAFANA,LOGS mgmt
```

### Cloud Architecture Diagram
```mermaid
graph TB
    subgraph "AWS Cloud"
        subgraph "VPC"
            subgraph "Public Subnet"
                ALB[Application Load Balancer]
                NAT[NAT Gateway]
            end

            subgraph "Private Subnet A"
                EC2A1[EC2 Instance]
                EC2A2[EC2 Instance]
                LAMBDA1[Lambda Function]
            end

            subgraph "Private Subnet B"
                EC2B1[EC2 Instance]
                EC2B2[EC2 Instance]
                LAMBDA2[Lambda Function]
            end
        end

        subgraph "Managed Services"
            RDS[(RDS MySQL)]
            REDIS[ElastiCache Redis]
            S3[(S3 Bucket)]
            SQS[SQS Queue]
            SNS[SNS Topic]
        end

        subgraph "Monitoring"
            CW[CloudWatch]
            XRAY[X-Ray]
        end
    end

    subgraph "External"
        USER[Users]
        ROUTE53[Route 53]
    end

    USER --> ROUTE53
    ROUTE53 --> ALB
    ALB --> EC2A1
    ALB --> EC2A2
    ALB --> EC2B1
    ALB --> EC2B2

    EC2A1 --> RDS
    EC2A2 --> RDS
    EC2B1 --> RDS
    EC2B2 --> RDS

    EC2A1 --> REDIS
    EC2A2 --> REDIS
    EC2B1 --> REDIS
    EC2B2 --> REDIS

    LAMBDA1 --> SQS
    LAMBDA2 --> SQS
    SQS --> SNS

    EC2A1 --> S3
    EC2B1 --> S3
    LAMBDA1 --> S3
    LAMBDA2 --> S3

    EC2A1 --> CW
    EC2A2 --> CW
    EC2B1 --> CW
    EC2B2 --> CW
    LAMBDA1 --> CW
    LAMBDA2 --> CW

    EC2A1 --> XRAY
    LAMBDA1 --> XRAY
```

### Database Relationship Network
```mermaid
graph LR
    subgraph "User Domain"
        USERS[(Users)]
        PROFILES[(User Profiles)]
        PREFERENCES[(Preferences)]
    end

    subgraph "Commerce Domain"
        PRODUCTS[(Products)]
        CATEGORIES[(Categories)]
        ORDERS[(Orders)]
        ORDER_ITEMS[(Order Items)]
        PAYMENTS[(Payments)]
    end

    subgraph "Inventory Domain"
        INVENTORY[(Inventory)]
        WAREHOUSES[(Warehouses)]
        SUPPLIERS[(Suppliers)]
    end

    subgraph "Analytics Domain"
        EVENTS[(Events)]
        METRICS[(Metrics)]
        REPORTS[(Reports)]
    end

    USERS --> PROFILES
    USERS --> PREFERENCES
    USERS --> ORDERS

    ORDERS --> ORDER_ITEMS
    ORDERS --> PAYMENTS
    ORDER_ITEMS --> PRODUCTS
    PRODUCTS --> CATEGORIES
    PRODUCTS --> INVENTORY

    INVENTORY --> WAREHOUSES
    WAREHOUSES --> SUPPLIERS

    USERS --> EVENTS
    ORDERS --> EVENTS
    PRODUCTS --> EVENTS
    EVENTS --> METRICS
    METRICS --> REPORTS

    classDef domain1 fill:#e1f5fe,stroke:#0277bd
    classDef domain2 fill:#f3e5f5,stroke:#7b1fa2
    classDef domain3 fill:#e8f5e8,stroke:#2e7d32
    classDef domain4 fill:#fff3e0,stroke:#ef6c00

    class USERS,PROFILES,PREFERENCES domain1
    class PRODUCTS,CATEGORIES,ORDERS,ORDER_ITEMS,PAYMENTS domain2
    class INVENTORY,WAREHOUSES,SUPPLIERS domain3
    class EVENTS,METRICS,REPORTS domain4
```

## Node Types and Styling

### Node Shape Reference
```mermaid
graph TB
    A[Rectangle - Default]
    B(Round edges)
    C([Stadium-shaped])
    D[[Subroutine]]
    E[(Database)]
    F((Circle))
    G>Flag shape]
    H{Diamond}
    I{{Hexagon}}
    J[/Parallelogram/]
    K[\Parallelogram alt\]
    L[/Trapezoid\]
    M[\Trapezoid alt/]
```

### Edge Types and Patterns
```mermaid
graph LR
    A -->|Solid Arrow| B
    C -.->|Dotted Arrow| D
    E ==>|Thick Arrow| F
    G ---|Solid Link| H
    I -.-|Dotted Link| J
    K ===|Thick Link| L
    M -->|Multi-word<br/>Label| N
    O ---|"Label with quotes"| P
```

### Advanced Styling Options
```mermaid
graph TB
    subgraph "Styling Examples"
        A[Default Node]
        B[Primary Node]
        C[Secondary Node]
        D[Success Node]
        E[Warning Node]
        F[Error Node]
    end

    classDef default fill:#f9f9f9,stroke:#333,stroke-width:2px
    classDef primary fill:#007bff,stroke:#0056b3,stroke-width:3px,color:#fff
    classDef secondary fill:#6c757d,stroke:#495057,stroke-width:2px,color:#fff
    classDef success fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#fff
    classDef warning fill:#ffc107,stroke:#d39e00,stroke-width:2px,color:#000
    classDef error fill:#dc3545,stroke:#bd2130,stroke-width:3px,color:#fff

    class A default
    class B primary
    class C secondary
    class D success
    class E warning
    class F error
```

## Interactive Features

### Clickable Nodes with Actions
```mermaid
graph TD
    A[Web Server] --> B[Application Server]
    B --> C[Database]

    click A "https://example.com/web-server-docs" "Web Server Documentation"
    click B "https://example.com/app-server-docs" "Application Server Documentation"
    click C "https://example.com/database-docs" "Database Documentation"
```

### Subgraph Linking
```mermaid
graph TB
    subgraph cluster1 ["Frontend Cluster"]
        A[React App]
        B[Vue App]
    end

    subgraph cluster2 ["Backend Cluster"]
        C[API Gateway]
        D[Auth Service]
        E[Data Service]
    end

    subgraph cluster3 ["Data Cluster"]
        F[(Primary DB)]
        G[(Cache)]
    end

    A --> C
    B --> C
    C --> D
    C --> E
    D --> F
    E --> F
    E --> G
```

## Configuration Variations

### Horizontal vs Vertical Layouts
```mermaid
graph LR
    %% Horizontal flow for process diagrams
    A[Start] --> B[Process 1]
    B --> C[Process 2]
    C --> D[End]
```

```mermaid
graph TB
    %% Vertical flow for hierarchical structures
    A[CEO]
    A --> B[CTO]
    A --> C[CMO]
    B --> D[Dev Team]
    C --> E[Marketing Team]
```

### Complex Network Topologies
```mermaid
graph TB
    subgraph "Region 1"
        subgraph "AZ-1A"
            WEB1[Web-1A]
            APP1[App-1A]
        end
        subgraph "AZ-1B"
            WEB2[Web-1B]
            APP2[App-1B]
        end
        LB1[Load Balancer 1]
    end

    subgraph "Region 2"
        subgraph "AZ-2A"
            WEB3[Web-2A]
            APP3[App-2A]
        end
        subgraph "AZ-2B"
            WEB4[Web-2B]
            APP4[App-2B]
        end
        LB2[Load Balancer 2]
    end

    subgraph "Global"
        GLB[Global Load Balancer]
        DB[(Global Database)]
    end

    GLB --> LB1
    GLB --> LB2

    LB1 --> WEB1
    LB1 --> WEB2
    WEB1 --> APP1
    WEB2 --> APP2

    LB2 --> WEB3
    LB2 --> WEB4
    WEB3 --> APP3
    WEB4 --> APP4

    APP1 --> DB
    APP2 --> DB
    APP3 --> DB
    APP4 --> DB
```

## Environment Setup

### Dependencies
```bash
# Node.js environment
npm install mermaid
npm install @mermaid-js/mermaid-cli

# Python environment
pip install mermaid-python
pip install mermaidjs

# Browser integration
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
```

### HTML Integration
```html
<!DOCTYPE html>
<html>
<head>
    <title>Network Diagrams</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
</head>
<body>
    <div class="mermaid">
        graph TB
            A[Load Balancer] --> B[Web Server 1]
            A --> C[Web Server 2]
            B --> D[Database]
            C --> D
    </div>

    <script>
        mermaid.initialize({
            startOnLoad: true,
            theme: 'neutral',
            flowchart: {
                useMaxWidth: true,
                htmlLabels: true,
                curve: 'cardinal'
            }
        });
    </script>
</body>
</html>
```

### JavaScript Integration
```javascript
// Basic initialization
import mermaid from 'mermaid';

mermaid.initialize({
    startOnLoad: true,
    theme: 'default',
    securityLevel: 'loose',
    flowchart: {
        useMaxWidth: true,
        htmlLabels: true
    }
});

// Dynamic diagram generation
function createNetworkDiagram(nodes, edges) {
    let diagram = 'graph TB\n';

    // Add nodes
    nodes.forEach(node => {
        diagram += `    ${node.id}[${node.label}]\n`;
    });

    // Add edges
    edges.forEach(edge => {
        diagram += `    ${edge.from} --> ${edge.to}\n`;
    });

    return diagram;
}

// Render diagram
const element = document.getElementById('networkDiagram');
mermaid.render('network-id', createNetworkDiagram(nodes, edges), element);
```

### Python Integration
```python
# Using mermaid-python package
from mermaid import Mermaid

def generate_network_diagram(topology_data):
    mm = Mermaid()

    # Start graph
    mm.graph_tb()

    # Add subgraphs
    for layer in topology_data['layers']:
        with mm.subgraph(layer['name']):
            for node in layer['nodes']:
                mm.node(node['id'], node['label'], node.get('shape', 'rect'))

    # Add connections
    for connection in topology_data['connections']:
        mm.edge(connection['from'], connection['to'],
               connection.get('label', ''),
               connection.get('style', 'solid'))

    return mm.render()

# Usage
topology = {
    'layers': [
        {'name': 'Frontend', 'nodes': [
            {'id': 'web', 'label': 'Web Server'},
            {'id': 'mobile', 'label': 'Mobile App'}
        ]},
        {'name': 'Backend', 'nodes': [
            {'id': 'api', 'label': 'API Gateway'},
            {'id': 'auth', 'label': 'Auth Service'}
        ]}
    ],
    'connections': [
        {'from': 'web', 'to': 'api'},
        {'from': 'mobile', 'to': 'api'},
        {'from': 'api', 'to': 'auth'}
    ]
}

diagram = generate_network_diagram(topology)
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Diagram Not Rendering
```javascript
// Issue: Diagram doesn't appear
// Solution: Check initialization
mermaid.initialize({
    startOnLoad: true,
    theme: 'default'
});

// Ensure proper HTML structure
<div class="mermaid">
    graph TD
        A --> B
</div>
```

#### Syntax Errors
```mermaid
%% Common syntax issues and fixes

%% Wrong: Missing direction
graph
    A --> B

%% Correct: Include direction
graph TD
    A --> B

%% Wrong: Invalid node shape
A[[[Invalid shape]]]

%% Correct: Use valid shapes
A[Rectangle]
B(Round)
C[(Database)]
```

#### Performance Issues
```javascript
// For large diagrams, optimize performance
mermaid.initialize({
    startOnLoad: false,  // Manual initialization
    maxTextSize: 50000,
    maxEdges: 500,
    flowchart: {
        htmlLabels: false,  // Use SVG labels for performance
        useMaxWidth: false
    }
});

// Lazy loading for multiple diagrams
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            mermaid.init(undefined, entry.target);
        }
    });
});

document.querySelectorAll('.mermaid').forEach(el => {
    observer.observe(el);
});
```

#### Styling Conflicts
```css
/* Prevent CSS conflicts */
.mermaid {
    font-family: 'trebuchet ms', verdana, arial, sans-serif !important;
    font-size: 16px !important;
}

/* Custom theme overrides */
.mermaid .node rect {
    stroke-width: 2px !important;
}

.mermaid .edgePath .path {
    stroke-width: 2px !important;
}
```

## Advanced Patterns

### Dynamic Node Generation
```javascript
class NetworkDiagramBuilder {
    constructor() {
        this.nodes = new Map();
        this.edges = [];
        this.subgraphs = new Map();
    }

    addNode(id, label, shape = 'rect', subgraph = null) {
        this.nodes.set(id, { label, shape, subgraph });
        return this;
    }

    addEdge(from, to, label = '', style = 'solid') {
        this.edges.push({ from, to, label, style });
        return this;
    }

    addSubgraph(id, title) {
        this.subgraphs.set(id, { title, nodes: [] });
        return this;
    }

    build() {
        let diagram = 'graph TB\n';

        // Add subgraphs
        for (const [sgId, sgData] of this.subgraphs) {
            diagram += `    subgraph "${sgData.title}"\n`;

            for (const [nodeId, nodeData] of this.nodes) {
                if (nodeData.subgraph === sgId) {
                    const shape = this.getNodeShape(nodeData.shape);
                    diagram += `        ${nodeId}${shape.start}${nodeData.label}${shape.end}\n`;
                }
            }

            diagram += '    end\n\n';
        }

        // Add standalone nodes
        for (const [nodeId, nodeData] of this.nodes) {
            if (!nodeData.subgraph) {
                const shape = this.getNodeShape(nodeData.shape);
                diagram += `    ${nodeId}${shape.start}${nodeData.label}${shape.end}\n`;
            }
        }

        // Add edges
        for (const edge of this.edges) {
            const arrow = this.getArrowStyle(edge.style);
            const label = edge.label ? `|${edge.label}|` : '';
            diagram += `    ${edge.from} ${arrow}${label} ${edge.to}\n`;
        }

        return diagram;
    }

    getNodeShape(shape) {
        const shapes = {
            'rect': { start: '[', end: ']' },
            'round': { start: '(', end: ')' },
            'stadium': { start: '([', end: '])' },
            'database': { start: '[(', end: ')]' },
            'circle': { start: '((', end: '))' },
            'diamond': { start: '{', end: '}' }
        };
        return shapes[shape] || shapes['rect'];
    }

    getArrowStyle(style) {
        const styles = {
            'solid': '-->',
            'dotted': '-.->',
            'thick': '==>',
            'line': '---'
        };
        return styles[style] || styles['solid'];
    }
}

// Usage example
const builder = new NetworkDiagramBuilder()
    .addSubgraph('frontend', 'Frontend Layer')
    .addSubgraph('backend', 'Backend Services')
    .addSubgraph('data', 'Data Layer')
    .addNode('web', 'Web Client', 'rect', 'frontend')
    .addNode('mobile', 'Mobile App', 'rect', 'frontend')
    .addNode('api', 'API Gateway', 'round', 'backend')
    .addNode('auth', 'Auth Service', 'round', 'backend')
    .addNode('db', 'Database', 'database', 'data')
    .addEdge('web', 'api', 'HTTPS')
    .addEdge('mobile', 'api', 'HTTPS')
    .addEdge('api', 'auth', 'Internal')
    .addEdge('auth', 'db', 'SQL');

const diagram = builder.build();
```

### Theme Customization
```javascript
// Custom theme configuration
const customTheme = {
    primaryColor: '#0066cc',
    primaryTextColor: '#ffffff',
    primaryBorderColor: '#004499',
    lineColor: '#666666',
    secondaryColor: '#f0f0f0',
    tertiaryColor: '#ffffff',
    background: '#ffffff',
    mainBkg: '#0066cc',
    secondBkg: '#f0f0f0',
    tertiaryBkg: '#ffffff'
};

mermaid.initialize({
    theme: 'base',
    themeVariables: customTheme,
    flowchart: {
        useMaxWidth: true,
        htmlLabels: true,
        curve: 'cardinal'
    }
});
```

## Export and Integration Options

### SVG Export
```javascript
// Generate SVG for high-quality output
async function exportToSVG(diagramText, elementId) {
    const { svg } = await mermaid.render(elementId, diagramText);

    // Create download link
    const blob = new Blob([svg], { type: 'image/svg+xml' });
    const url = URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = url;
    link.download = `network-diagram-${elementId}.svg`;
    link.click();

    URL.revokeObjectURL(url);
}
```

### PNG Export via CLI
```bash
# Using mermaid-cli for PNG export
npx mmdc -i network-diagram.mmd -o network-diagram.png -t neutral -b white

# Batch export multiple diagrams
for file in *.mmd; do
    npx mmdc -i "$file" -o "${file%.mmd}.png" -t neutral -b white
done
```

### Integration with Documentation
```markdown
<!-- Markdown integration -->
```mermaid
graph TB
    A[Documentation] --> B[Mermaid Diagram]
    B --> C[Rendered Output]
```

<!-- HTML integration -->
<div class="mermaid">
graph TB
    A[Documentation] --> B[Mermaid Diagram]
    B --> C[Rendered Output]
</div>
```

## Performance Optimization

### Large Diagram Handling
```javascript
// Optimize for large networks
mermaid.initialize({
    startOnLoad: false,
    maxTextSize: 100000,
    maxEdges: 1000,
    flowchart: {
        htmlLabels: false,  // Better performance
        useMaxWidth: false,
        rankSpacing: 75,
        nodeSpacing: 50
    },
    gantt: {
        numberSectionStyles: 2
    }
});

// Progressive rendering for very large diagrams
function renderLargeDiagram(diagramText, containerId) {
    const container = document.getElementById(containerId);

    // Show loading indicator
    container.innerHTML = '<div class="loading">Rendering diagram...</div>';

    setTimeout(() => {
        mermaid.render('large-diagram', diagramText)
            .then(result => {
                container.innerHTML = result.svg;
            })
            .catch(error => {
                container.innerHTML = `<div class="error">Error rendering diagram: ${error}</div>`;
            });
    }, 100);
}
```

### Memory Management
```javascript
// Clean up rendered diagrams
function cleanupDiagrams() {
    // Remove old SVG elements
    document.querySelectorAll('.mermaid svg').forEach(svg => {
        if (!svg.isConnected) {
            svg.remove();
        }
    });

    // Clear mermaid cache if available
    if (mermaid.clearCache) {
        mermaid.clearCache();
    }
}

// Call cleanup periodically for SPA applications
setInterval(cleanupDiagrams, 60000); // Every minute
```

## Best Practices

### Diagram Organization
1. **Use consistent naming conventions** for node IDs
2. **Group related nodes** in subgraphs for clarity
3. **Limit diagram complexity** - break large networks into multiple diagrams
4. **Use meaningful labels** that describe function, not just names
5. **Apply consistent styling** across related diagrams

### Performance Guidelines
1. **Minimize HTML labels** for large diagrams
2. **Use appropriate layout directions** (TB for hierarchies, LR for processes)
3. **Limit subgraph nesting** to 3 levels maximum
4. **Optimize node and edge counts** (< 50 nodes, < 100 edges per diagram)
5. **Use lazy loading** for multiple diagrams on one page

### Accessibility Considerations
1. **Provide alternative text** descriptions for screen readers
2. **Use high contrast colors** for better visibility
3. **Include text descriptions** of diagram content
4. **Ensure keyboard navigation** works with interactive elements
5. **Test with assistive technologies** regularly

## NPL-FIM Advantages

### Rapid Prototyping
- **Text-based definitions** enable version control and diff tracking
- **Declarative syntax** reduces learning curve compared to graphical tools
- **Live preview** capabilities for immediate feedback
- **Template-based generation** for consistent diagram patterns

### Integration Benefits
- **Documentation as code** - diagrams live with source code
- **Automated generation** from infrastructure definitions
- **CI/CD pipeline integration** for diagram validation
- **Cross-platform compatibility** without proprietary tools

### Maintenance Advantages
- **Single source of truth** for network documentation
- **Bulk updates** through search and replace
- **Consistent styling** across all diagrams
- **Collaborative editing** through standard text editors

This comprehensive guide provides all necessary components for NPL-FIM to generate sophisticated Mermaid network and graph diagrams without false starts, covering complete implementation patterns, configuration options, troubleshooting, and best practices for professional network visualization.