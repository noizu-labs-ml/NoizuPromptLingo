# Mermaid Diagram Generation - Comprehensive NPL-FIM Implementation Guide

## Overview
Mermaid is a powerful JavaScript library that enables declarative diagram creation using simple markdown-inspired text syntax. This comprehensive guide provides complete NPL-FIM integration patterns for generating professional diagrams without false starts or incomplete implementations.

**Core Advantage**: Transform text descriptions into publication-ready diagrams with zero design overhead, perfect for technical documentation, system architecture, and process visualization.

## NPL-FIM Direct Unramp

### Immediate Start Configuration
```npl
@fim:mermaid {
  diagram_type: "flowchart" | "sequence" | "gantt" | "class" | "state" | "er" | "journey" | "gitgraph" | "pie" | "requirement" | "c4"
  auto_layout: true
  theme: "default" | "dark" | "forest" | "neutral" | "base"
  export_format: "svg" | "png" | "pdf"
  interactive_nodes: boolean
  live_editor: boolean
  validation: "strict" | "permissive"
  output_path: "./diagrams/"
  naming_convention: "kebab-case" | "snake_case" | "camelCase"
}
```

### Quick Start Template (Copy-Paste Ready)
```html
<!DOCTYPE html>
<html>
<head>
    <title>Mermaid Diagram Generator</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10.6.1/dist/mermaid.min.js"></script>
    <style>
        .diagram-container {
            width: 100%;
            height: auto;
            text-align: center;
            margin: 20px 0;
        }
        .controls {
            margin: 20px;
            text-align: center;
        }
        button {
            padding: 10px 20px;
            margin: 5px;
            background: #0366d6;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="controls">
        <button onclick="generateFlowchart()">Generate Flowchart</button>
        <button onclick="generateSequence()">Generate Sequence</button>
        <button onclick="generateGantt()">Generate Gantt</button>
        <button onclick="exportSVG()">Export SVG</button>
    </div>
    <div id="diagram-container" class="diagram-container"></div>

    <script>
        // NPL-FIM Mermaid Configuration
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose',
            flowchart: {
                useMaxWidth: true,
                htmlLabels: true,
                curve: 'basis'
            },
            sequence: {
                diagramMarginX: 50,
                diagramMarginY: 10,
                actorMargin: 50,
                width: 150,
                height: 65,
                boxMargin: 10,
                boxTextMargin: 5,
                noteMargin: 10,
                messageMargin: 35
            },
            gantt: {
                titleTopMargin: 25,
                barHeight: 20,
                fontSizeFactor: 1,
                fontSize: 11,
                gridLineStartPadding: 35,
                bottomPadding: 25,
                rightPadding: 75
            }
        });

        // Ready-to-use diagram generators
        async function generateFlowchart() {
            const definition = `
                flowchart TD
                    A[📋 Start Process] --> B{🤔 Decision Point}
                    B -->|✅ Approved| C[🚀 Execute Action]
                    B -->|❌ Rejected| D[🔄 Alternative Path]
                    C --> E[📊 Generate Report]
                    D --> F[📝 Request Revision]
                    E --> G[✅ Complete]
                    F --> B

                    style A fill:#e1f5fe
                    style G fill:#c8e6c9
                    style B fill:#fff3e0
            `;
            await renderDiagram(definition);
        }

        async function generateSequence() {
            const definition = `
                sequenceDiagram
                    participant U as User
                    participant API as API Gateway
                    participant DB as Database
                    participant Cache as Redis Cache

                    U->>API: Request Data
                    API->>Cache: Check Cache
                    alt Cache Hit
                        Cache-->>API: Return Cached Data
                    else Cache Miss
                        API->>DB: Query Database
                        DB-->>API: Return Data
                        API->>Cache: Store in Cache
                    end
                    API-->>U: Return Response
            `;
            await renderDiagram(definition);
        }

        async function generateGantt() {
            const definition = `
                gantt
                    title Project Development Timeline
                    dateFormat YYYY-MM-DD
                    section Planning
                    Requirements Analysis    :done, req, 2024-01-01, 2024-01-15
                    System Design          :done, design, after req, 10d
                    section Development
                    Backend Development     :active, backend, 2024-01-20, 30d
                    Frontend Development    :frontend, after design, 25d
                    Testing                :testing, after backend, 15d
                    section Deployment
                    Production Setup       :prod, after testing, 5d
                    Go Live               :milestone, golive, after prod, 1d
            `;
            await renderDiagram(definition);
        }

        async function renderDiagram(definition) {
            const { svg } = await mermaid.render('diagram-' + Date.now(), definition);
            document.getElementById('diagram-container').innerHTML = svg;
        }

        function exportSVG() {
            const svg = document.querySelector('#diagram-container svg');
            if (svg) {
                const blob = new Blob([svg.outerHTML], { type: 'image/svg+xml' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = 'diagram.svg';
                a.click();
                URL.revokeObjectURL(url);
            }
        }
    </script>
</body>
</html>
```

## Complete Diagram Type Implementations

### 1. Flowchart Diagrams
**Use Case**: Process flows, decision trees, system workflows

```javascript
// NPL-FIM Flowchart Generator
class FlowchartGenerator {
    constructor(config = {}) {
        this.config = {
            direction: 'TD', // TD, TB, BT, RL, LR
            nodeStyles: true,
            linkStyles: true,
            subgraphs: true,
            ...config
        };
    }

    generateProcessFlow(steps) {
        let diagram = `flowchart ${this.config.direction}\n`;

        steps.forEach((step, index) => {
            const nodeId = `step${index + 1}`;
            const nodeType = this.getNodeType(step.type);
            diagram += `    ${nodeId}${nodeType}[${step.label}]\n`;

            if (index < steps.length - 1) {
                diagram += `    ${nodeId} --> step${index + 2}\n`;
            }
        });

        if (this.config.nodeStyles) {
            diagram += this.generateStyles(steps);
        }

        return diagram;
    }

    getNodeType(type) {
        const types = {
            'start': '',
            'process': '',
            'decision': '{',
            'end': '((',
            'data': '[/',
            'document': '[[',
            'subprocess': '[['
        };
        return types[type] || '';
    }

    generateStyles(steps) {
        let styles = '\n';
        steps.forEach((step, index) => {
            const nodeId = `step${index + 1}`;
            const color = this.getColorForType(step.type);
            styles += `    style ${nodeId} fill:${color}\n`;
        });
        return styles;
    }

    getColorForType(type) {
        const colors = {
            'start': '#c8e6c9',
            'process': '#e1f5fe',
            'decision': '#fff3e0',
            'end': '#ffcdd2',
            'data': '#f3e5f5',
            'document': '#e8f5e8'
        };
        return colors[type] || '#f5f5f5';
    }
}

// Usage Example
const flowchartGen = new FlowchartGenerator();
const processSteps = [
    { type: 'start', label: 'User Login Request' },
    { type: 'process', label: 'Validate Credentials' },
    { type: 'decision', label: 'Valid?' },
    { type: 'process', label: 'Generate JWT Token' },
    { type: 'end', label: 'Return Success' }
];

const flowchartDefinition = flowchartGen.generateProcessFlow(processSteps);
```

### 2. Sequence Diagrams
**Use Case**: API interactions, message flows, protocol documentation

```javascript
// NPL-FIM Sequence Diagram Generator
class SequenceGenerator {
    constructor(config = {}) {
        this.config = {
            actorStyle: 'box',
            showActivations: true,
            showNumbers: false,
            ...config
        };
    }

    generateAPIFlow(participants, interactions) {
        let diagram = 'sequenceDiagram\n';

        // Add participants
        participants.forEach(participant => {
            diagram += `    participant ${participant.id} as ${participant.name}\n`;
        });

        diagram += '\n';

        // Add interactions
        interactions.forEach(interaction => {
            const arrow = this.getArrowType(interaction.type);
            diagram += `    ${interaction.from}${arrow}${interaction.to}: ${interaction.message}\n`;

            if (interaction.note) {
                diagram += `    Note over ${interaction.to}: ${interaction.note}\n`;
            }

            if (interaction.activation) {
                diagram += `    activate ${interaction.to}\n`;
            }

            if (interaction.deactivation) {
                diagram += `    deactivate ${interaction.from}\n`;
            }
        });

        return diagram;
    }

    getArrowType(type) {
        const arrows = {
            'sync': '->>',
            'async': '-->>',
            'response': '-->>',
            'self': '->>+',
            'destroy': '->>-'
        };
        return arrows[type] || '->';
    }
}

// Complete API Documentation Example
const apiParticipants = [
    { id: 'Client', name: '🖥️ Web Client' },
    { id: 'Gateway', name: '🌐 API Gateway' },
    { id: 'Auth', name: '🔐 Auth Service' },
    { id: 'DB', name: '🗄️ Database' },
    { id: 'Cache', name: '⚡ Redis Cache' }
];

const apiInteractions = [
    { from: 'Client', to: 'Gateway', type: 'sync', message: 'POST /api/login' },
    { from: 'Gateway', to: 'Auth', type: 'sync', message: 'validate(credentials)' },
    { from: 'Auth', to: 'DB', type: 'sync', message: 'SELECT user WHERE email=?' },
    { from: 'DB', to: 'Auth', type: 'response', message: 'user_data' },
    { from: 'Auth', to: 'Cache', type: 'async', message: 'SET session_token' },
    { from: 'Auth', to: 'Gateway', type: 'response', message: 'JWT token' },
    { from: 'Gateway', to: 'Client', type: 'response', message: '200 OK + token' }
];

const seqGen = new SequenceGenerator();
const sequenceDefinition = seqGen.generateAPIFlow(apiParticipants, apiInteractions);
```

### 3. Gantt Charts
**Use Case**: Project timelines, resource planning, milestone tracking

```javascript
// NPL-FIM Gantt Chart Generator
class GanttGenerator {
    constructor(config = {}) {
        this.config = {
            dateFormat: 'YYYY-MM-DD',
            axisFormat: '%m/%d',
            todayMarker: true,
            ...config
        };
    }

    generateProjectTimeline(project) {
        let diagram = `gantt\n`;
        diagram += `    title ${project.title}\n`;
        diagram += `    dateFormat ${this.config.dateFormat}\n`;

        if (this.config.axisFormat) {
            diagram += `    axisFormat ${this.config.axisFormat}\n`;
        }

        project.sections.forEach(section => {
            diagram += `\n    section ${section.name}\n`;

            section.tasks.forEach(task => {
                const taskLine = this.generateTaskLine(task);
                diagram += `    ${taskLine}\n`;
            });
        });

        return diagram;
    }

    generateTaskLine(task) {
        let line = task.name.padEnd(20);

        if (task.milestone) {
            line += `:milestone, ${task.id}`;
        } else {
            line += `:${task.status || ''}, ${task.id}`;
        }

        if (task.dependencies) {
            line += `, after ${task.dependencies.join(' ')}`;
        } else if (task.startDate) {
            line += `, ${task.startDate}`;
        }

        if (task.duration && !task.milestone) {
            line += `, ${task.duration}`;
        } else if (task.endDate && !task.milestone) {
            line += `, ${task.endDate}`;
        }

        return line;
    }
}

// Complete Project Example
const projectData = {
    title: "E-commerce Platform Development",
    sections: [
        {
            name: "Planning Phase",
            tasks: [
                { name: "Requirements Gathering", id: "req", status: "done", startDate: "2024-01-01", duration: "10d" },
                { name: "Architecture Design", id: "arch", status: "done", dependencies: ["req"], duration: "15d" },
                { name: "UI/UX Design", id: "design", status: "done", dependencies: ["req"], duration: "20d" }
            ]
        },
        {
            name: "Development Phase",
            tasks: [
                { name: "Database Setup", id: "db", status: "active", dependencies: ["arch"], duration: "5d" },
                { name: "Backend API", id: "backend", status: "", dependencies: ["db"], duration: "30d" },
                { name: "Frontend Development", id: "frontend", status: "", dependencies: ["design"], duration: "35d" },
                { name: "Integration Testing", id: "integration", dependencies: ["backend", "frontend"], duration: "10d" }
            ]
        },
        {
            name: "Deployment",
            tasks: [
                { name: "Production Setup", id: "prod", dependencies: ["integration"], duration: "5d" },
                { name: "Go Live", id: "golive", milestone: true, dependencies: ["prod"] },
                { name: "Monitoring Setup", id: "monitor", dependencies: ["golive"], duration: "3d" }
            ]
        }
    ]
};

const ganttGen = new GanttGenerator();
const ganttDefinition = ganttGen.generateProjectTimeline(projectData);
```

### 4. Class Diagrams
**Use Case**: System architecture, OOP design, database schemas

```javascript
// NPL-FIM Class Diagram Generator
class ClassDiagramGenerator {
    constructor(config = {}) {
        this.config = {
            showMethods: true,
            showProperties: true,
            showVisibility: true,
            showTypes: true,
            ...config
        };
    }

    generateSystemArchitecture(classes, relationships) {
        let diagram = 'classDiagram\n';

        // Generate class definitions
        classes.forEach(cls => {
            diagram += this.generateClassDefinition(cls);
        });

        // Generate relationships
        relationships.forEach(rel => {
            diagram += `    ${rel.from} ${this.getRelationshipSymbol(rel.type)} ${rel.to}`;
            if (rel.label) {
                diagram += ` : ${rel.label}`;
            }
            diagram += '\n';
        });

        return diagram;
    }

    generateClassDefinition(cls) {
        let definition = `    class ${cls.name} {\n`;

        if (this.config.showProperties && cls.properties) {
            cls.properties.forEach(prop => {
                definition += `        ${this.formatProperty(prop)}\n`;
            });
        }

        if (this.config.showMethods && cls.methods) {
            cls.methods.forEach(method => {
                definition += `        ${this.formatMethod(method)}\n`;
            });
        }

        definition += '    }\n';
        return definition;
    }

    formatProperty(prop) {
        let formatted = '';
        if (this.config.showVisibility) {
            formatted += this.getVisibilitySymbol(prop.visibility);
        }
        formatted += prop.name;
        if (this.config.showTypes && prop.type) {
            formatted += ` : ${prop.type}`;
        }
        return formatted;
    }

    formatMethod(method) {
        let formatted = '';
        if (this.config.showVisibility) {
            formatted += this.getVisibilitySymbol(method.visibility);
        }
        formatted += method.name + '(';
        if (method.parameters) {
            formatted += method.parameters.map(p => `${p.name}: ${p.type}`).join(', ');
        }
        formatted += ')';
        if (this.config.showTypes && method.returnType) {
            formatted += ` : ${method.returnType}`;
        }
        return formatted;
    }

    getVisibilitySymbol(visibility) {
        const symbols = {
            'public': '+',
            'private': '-',
            'protected': '#',
            'package': '~'
        };
        return symbols[visibility] || '';
    }

    getRelationshipSymbol(type) {
        const symbols = {
            'inheritance': '<|--',
            'composition': '*--',
            'aggregation': 'o--',
            'association': '--',
            'dependency': '..>',
            'realization': '..|>'
        };
        return symbols[type] || '--';
    }
}

// Complete System Architecture Example
const systemClasses = [
    {
        name: 'User',
        properties: [
            { name: 'id', type: 'string', visibility: 'private' },
            { name: 'email', type: 'string', visibility: 'private' },
            { name: 'name', type: 'string', visibility: 'public' }
        ],
        methods: [
            { name: 'authenticate', parameters: [{ name: 'password', type: 'string' }], returnType: 'boolean', visibility: 'public' },
            { name: 'updateProfile', parameters: [{ name: 'data', type: 'ProfileData' }], returnType: 'void', visibility: 'public' }
        ]
    },
    {
        name: 'UserService',
        properties: [
            { name: 'repository', type: 'UserRepository', visibility: 'private' }
        ],
        methods: [
            { name: 'createUser', parameters: [{ name: 'userData', type: 'CreateUserRequest' }], returnType: 'User', visibility: 'public' },
            { name: 'findById', parameters: [{ name: 'id', type: 'string' }], returnType: 'User', visibility: 'public' }
        ]
    },
    {
        name: 'UserRepository',
        methods: [
            { name: 'save', parameters: [{ name: 'user', type: 'User' }], returnType: 'void', visibility: 'public' },
            { name: 'findById', parameters: [{ name: 'id', type: 'string' }], returnType: 'User', visibility: 'public' }
        ]
    }
];

const systemRelationships = [
    { from: 'UserService', to: 'UserRepository', type: 'composition', label: 'uses' },
    { from: 'UserService', to: 'User', type: 'dependency', label: 'creates' }
];

const classGen = new ClassDiagramGenerator();
const classDefinition = classGen.generateSystemArchitecture(systemClasses, systemRelationships);
```

## Advanced Configuration Options

### Theme Customization
```javascript
// NPL-FIM Theme Configuration
const customTheme = {
    theme: 'base',
    themeVariables: {
        primaryColor: '#ff6b6b',
        primaryTextColor: '#2c3e50',
        primaryBorderColor: '#34495e',
        lineColor: '#7f8c8d',
        sectionBkgColor: '#ecf0f1',
        altSectionBkgColor: '#bdc3c7',
        gridColor: '#95a5a6',
        secondaryColor: '#3498db',
        tertiaryColor: '#2ecc71'
    }
};

mermaid.initialize({
    startOnLoad: true,
    ...customTheme,
    fontFamily: 'Arial, sans-serif',
    fontSize: '16px'
});
```

### Export Configurations
```javascript
// NPL-FIM Export Utilities
class DiagramExporter {
    constructor() {
        this.formats = ['svg', 'png', 'pdf'];
    }

    async exportAsSVG(diagramId) {
        const svg = document.querySelector(`#${diagramId} svg`);
        const svgData = new XMLSerializer().serializeToString(svg);
        const blob = new Blob([svgData], { type: 'image/svg+xml;charset=utf-8' });
        this.downloadBlob(blob, 'diagram.svg');
    }

    async exportAsPNG(diagramId, scale = 2) {
        const svg = document.querySelector(`#${diagramId} svg`);
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');

        const img = new Image();
        const svgBlob = new Blob([svg.outerHTML], { type: 'image/svg+xml;charset=utf-8' });
        const url = URL.createObjectURL(svgBlob);

        return new Promise((resolve) => {
            img.onload = () => {
                canvas.width = img.width * scale;
                canvas.height = img.height * scale;
                ctx.scale(scale, scale);
                ctx.drawImage(img, 0, 0);

                canvas.toBlob((blob) => {
                    this.downloadBlob(blob, 'diagram.png');
                    URL.revokeObjectURL(url);
                    resolve();
                }, 'image/png');
            };
            img.src = url;
        });
    }

    downloadBlob(blob, filename) {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }
}

// Usage
const exporter = new DiagramExporter();
// exporter.exportAsSVG('my-diagram');
// exporter.exportAsPNG('my-diagram', 3); // 3x scale for high-res
```

## Node.js/Server-Side Implementation

### Complete Server Setup
```javascript
// server.js - NPL-FIM Server-side Diagram Generation
const express = require('express');
const { createRequire } = require('module');
const require = createRequire(import.meta.url);
const puppeteer = require('puppeteer');
const fs = require('fs').promises;
const path = require('path');

class ServerDiagramGenerator {
    constructor() {
        this.app = express();
        this.app.use(express.json());
        this.setupRoutes();
    }

    setupRoutes() {
        this.app.post('/generate-diagram', async (req, res) => {
            try {
                const { definition, format = 'svg', theme = 'default' } = req.body;
                const result = await this.generateDiagram(definition, format, theme);

                res.setHeader('Content-Type', this.getContentType(format));
                res.send(result);
            } catch (error) {
                res.status(500).json({ error: error.message });
            }
        });

        this.app.get('/health', (req, res) => {
            res.json({ status: 'healthy', timestamp: new Date().toISOString() });
        });
    }

    async generateDiagram(definition, format, theme) {
        const browser = await puppeteer.launch({ headless: true });
        const page = await browser.newPage();

        const html = this.createDiagramHTML(definition, theme);
        await page.setContent(html);
        await page.waitForSelector('#diagram svg');

        let result;
        if (format === 'png') {
            const element = await page.$('#diagram');
            result = await element.screenshot({ type: 'png' });
        } else if (format === 'pdf') {
            result = await page.pdf({ format: 'A4', printBackground: true });
        } else {
            result = await page.$eval('#diagram svg', el => el.outerHTML);
        }

        await browser.close();
        return result;
    }

    createDiagramHTML(definition, theme) {
        return `
<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10.6.1/dist/mermaid.min.js"></script>
    <style>
        body { margin: 0; padding: 20px; font-family: Arial, sans-serif; }
        #diagram { text-align: center; }
    </style>
</head>
<body>
    <div id="diagram">
        <div class="mermaid">${definition}</div>
    </div>
    <script>
        mermaid.initialize({
            startOnLoad: true,
            theme: '${theme}',
            securityLevel: 'loose'
        });
    </script>
</body>
</html>`;
    }

    getContentType(format) {
        const types = {
            'svg': 'image/svg+xml',
            'png': 'image/png',
            'pdf': 'application/pdf'
        };
        return types[format] || 'text/plain';
    }

    start(port = 3000) {
        this.app.listen(port, () => {
            console.log(`NPL-FIM Mermaid Server running on port ${port}`);
        });
    }
}

// Start server
const generator = new ServerDiagramGenerator();
generator.start();

// Client usage example
async function generateServerDiagram(definition) {
    const response = await fetch('/generate-diagram', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            definition,
            format: 'svg',
            theme: 'default'
        })
    });

    return await response.text();
}
```

## CLI Tool Implementation

### Complete Command-Line Interface
```bash
#!/bin/bash
# mermaid-cli.sh - NPL-FIM CLI Tool

setup_mermaid_cli() {
    npm install -g @mermaid-js/mermaid-cli
    echo "Mermaid CLI installed successfully"
}

generate_diagram() {
    local input_file="$1"
    local output_file="$2"
    local format="${3:-svg}"
    local theme="${4:-default}"
    local config_file="${5:-mermaid.config.json}"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found"
        return 1
    fi

    mmdc -i "$input_file" -o "$output_file" -t "$theme" -c "$config_file" -f "$format"
    echo "Diagram generated: $output_file"
}

batch_generate() {
    local input_dir="$1"
    local output_dir="$2"
    local format="${3:-svg}"

    mkdir -p "$output_dir"

    for file in "$input_dir"/*.mmd; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file" .mmd)
            generate_diagram "$file" "$output_dir/$filename.$format" "$format"
        fi
    done
}

create_config() {
    cat > mermaid.config.json << 'EOF'
{
  "theme": "default",
  "width": 1920,
  "height": 1080,
  "backgroundColor": "white",
  "configFile": "./mermaid.config.js"
}
EOF
    echo "Configuration file created: mermaid.config.json"
}

# Usage examples
case "$1" in
    "setup")
        setup_mermaid_cli
        ;;
    "generate")
        generate_diagram "$2" "$3" "$4" "$5" "$6"
        ;;
    "batch")
        batch_generate "$2" "$3" "$4"
        ;;
    "config")
        create_config
        ;;
    *)
        echo "Usage: $0 {setup|generate|batch|config}"
        echo "  setup                           - Install Mermaid CLI"
        echo "  generate <input> <output> [fmt] - Generate single diagram"
        echo "  batch <input_dir> <output_dir>  - Generate multiple diagrams"
        echo "  config                          - Create config file"
        ;;
esac
```

## Integration Patterns

### React Component Integration
```jsx
// MermaidDiagram.jsx - NPL-FIM React Component
import React, { useEffect, useRef, useState } from 'react';
import mermaid from 'mermaid';

const MermaidDiagram = ({
    definition,
    theme = 'default',
    config = {},
    onError = () => {},
    className = '',
    style = {}
}) => {
    const [isReady, setIsReady] = useState(false);
    const [error, setError] = useState(null);
    const elementRef = useRef(null);
    const idRef = useRef(`mermaid-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`);

    useEffect(() => {
        mermaid.initialize({
            startOnLoad: false,
            theme,
            securityLevel: 'loose',
            ...config
        });
        setIsReady(true);
    }, [theme, config]);

    useEffect(() => {
        if (!isReady || !definition || !elementRef.current) return;

        const renderDiagram = async () => {
            try {
                setError(null);
                const { svg } = await mermaid.render(idRef.current, definition);
                elementRef.current.innerHTML = svg;
            } catch (err) {
                setError(err.message);
                onError(err);
                elementRef.current.innerHTML = `<p>Error rendering diagram: ${err.message}</p>`;
            }
        };

        renderDiagram();
    }, [isReady, definition, onError]);

    return (
        <div
            ref={elementRef}
            className={`mermaid-diagram ${className}`}
            style={{ textAlign: 'center', ...style }}
        />
    );
};

// Usage Example
const App = () => {
    const [diagramType, setDiagramType] = useState('flowchart');

    const diagrams = {
        flowchart: `
            flowchart TD
                A[Start] --> B{Is it working?}
                B -->|Yes| C[Great!]
                B -->|No| D[Debug]
                D --> B
        `,
        sequence: `
            sequenceDiagram
                Alice->>Bob: Hello Bob!
                Bob-->>Alice: Hello Alice!
        `
    };

    return (
        <div>
            <select value={diagramType} onChange={(e) => setDiagramType(e.target.value)}>
                <option value="flowchart">Flowchart</option>
                <option value="sequence">Sequence</option>
            </select>

            <MermaidDiagram
                definition={diagrams[diagramType]}
                theme="default"
                onError={(error) => console.error('Diagram error:', error)}
                style={{ margin: '20px 0' }}
            />
        </div>
    );
};

export default App;
```

### Vue.js Integration
```vue
<!-- MermaidDiagram.vue - NPL-FIM Vue Component -->
<template>
  <div
    ref="diagramContainer"
    :class="['mermaid-diagram', className]"
    :style="containerStyle"
  />
</template>

<script>
import mermaid from 'mermaid';

export default {
  name: 'MermaidDiagram',
  props: {
    definition: {
      type: String,
      required: true
    },
    theme: {
      type: String,
      default: 'default'
    },
    config: {
      type: Object,
      default: () => ({})
    },
    className: {
      type: String,
      default: ''
    },
    style: {
      type: Object,
      default: () => ({})
    }
  },
  data() {
    return {
      isInitialized: false,
      diagramId: `mermaid-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    };
  },
  computed: {
    containerStyle() {
      return {
        textAlign: 'center',
        ...this.style
      };
    }
  },
  watch: {
    definition: {
      handler: 'renderDiagram',
      immediate: false
    },
    theme: {
      handler: 'initializeMermaid',
      immediate: false
    }
  },
  mounted() {
    this.initializeMermaid();
  },
  methods: {
    async initializeMermaid() {
      mermaid.initialize({
        startOnLoad: false,
        theme: this.theme,
        securityLevel: 'loose',
        ...this.config
      });
      this.isInitialized = true;
      await this.$nextTick();
      this.renderDiagram();
    },

    async renderDiagram() {
      if (!this.isInitialized || !this.definition) return;

      try {
        const { svg } = await mermaid.render(this.diagramId, this.definition);
        this.$refs.diagramContainer.innerHTML = svg;
        this.$emit('rendered', svg);
      } catch (error) {
        this.$refs.diagramContainer.innerHTML = `<p>Error: ${error.message}</p>`;
        this.$emit('error', error);
      }
    }
  }
};
</script>

<style scoped>
.mermaid-diagram {
  width: 100%;
  overflow-x: auto;
}
</style>
```

## Environment Setup & Dependencies

### Package.json Configuration
```json
{
  "name": "npl-fim-mermaid-generator",
  "version": "1.0.0",
  "description": "Complete NPL-FIM Mermaid diagram generation toolkit",
  "main": "index.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "build": "webpack --mode production",
    "test": "jest",
    "generate": "node cli.js"
  },
  "dependencies": {
    "mermaid": "^10.6.1",
    "express": "^4.18.2",
    "puppeteer": "^21.5.2",
    "@mermaid-js/mermaid-cli": "^10.6.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "webpack": "^5.89.0",
    "jest": "^29.7.0"
  }
}
```

### Docker Configuration
```dockerfile
# Dockerfile - NPL-FIM Mermaid Service
FROM node:18-alpine

# Install Chrome dependencies for Puppeteer
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Set Chrome path for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

USER node

CMD ["npm", "start"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  mermaid-generator:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    volumes:
      - ./diagrams:/app/diagrams
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - mermaid-generator
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Diagram Not Rendering
**Problem**: Blank or missing diagram output
**Solutions**:
```javascript
// Check for syntax errors
try {
    await mermaid.parse(definition);
    console.log('Syntax is valid');
} catch (error) {
    console.error('Syntax error:', error.message);
}

// Ensure proper initialization
mermaid.initialize({ startOnLoad: false });
await mermaid.init();

// Verify container exists
const container = document.getElementById('diagram-container');
if (!container) {
    console.error('Container element not found');
}
```

#### 2. Performance Issues with Large Diagrams
**Problem**: Slow rendering or browser freezing
**Solutions**:
```javascript
// Use virtualization for large diagrams
const renderWithVirtualization = async (definition) => {
    const worker = new Worker('mermaid-worker.js');
    return new Promise((resolve, reject) => {
        worker.postMessage({ definition });
        worker.onmessage = (e) => {
            if (e.data.error) reject(e.data.error);
            else resolve(e.data.svg);
        };
    });
};

// Optimize configuration for performance
mermaid.initialize({
    startOnLoad: false,
    maxTextSize: 50000,
    maxEdges: 500,
    flowchart: {
        useMaxWidth: false,
        htmlLabels: false
    }
});
```

#### 3. Export Quality Issues
**Problem**: Low-quality or blurry exports
**Solutions**:
```javascript
// High-quality PNG export
async function exportHighQualityPNG(diagramId, scale = 4) {
    const svg = document.querySelector(`#${diagramId} svg`);

    // Increase SVG dimensions
    const originalWidth = svg.getAttribute('width');
    const originalHeight = svg.getAttribute('height');

    svg.setAttribute('width', originalWidth * scale);
    svg.setAttribute('height', originalHeight * scale);

    // Create high-res canvas
    const canvas = document.createElement('canvas');
    canvas.width = originalWidth * scale;
    canvas.height = originalHeight * scale;

    const ctx = canvas.getContext('2d');
    ctx.imageSmoothingEnabled = true;
    ctx.imageSmoothingQuality = 'high';

    // Convert and download
    const img = new Image();
    const svgData = new XMLSerializer().serializeToString(svg);
    const blob = new Blob([svgData], { type: 'image/svg+xml' });
    const url = URL.createObjectURL(blob);

    img.onload = () => {
        ctx.drawImage(img, 0, 0);
        canvas.toBlob((blob) => {
            downloadBlob(blob, 'diagram-hq.png');
            // Restore original dimensions
            svg.setAttribute('width', originalWidth);
            svg.setAttribute('height', originalHeight);
        }, 'image/png');
    };

    img.src = url;
}
```

#### 4. Browser Compatibility
**Problem**: Diagrams not working in older browsers
**Solutions**:
```javascript
// Feature detection and fallbacks
const checkBrowserSupport = () => {
    const features = {
        svg: !!document.createElementNS,
        promise: typeof Promise !== 'undefined',
        fetch: typeof fetch !== 'undefined'
    };

    const unsupported = Object.keys(features).filter(f => !features[f]);

    if (unsupported.length > 0) {
        console.warn('Unsupported features:', unsupported);
        return false;
    }

    return true;
};

// Polyfill loading
if (!checkBrowserSupport()) {
    // Load polyfills
    const script = document.createElement('script');
    script.src = 'https://polyfill.io/v3/polyfill.min.js?features=Promise,fetch';
    document.head.appendChild(script);
}
```

### Performance Optimization

#### Lazy Loading Implementation
```javascript
// NPL-FIM Lazy Loading for Large Documents
class LazyMermaidLoader {
    constructor() {
        this.observer = new IntersectionObserver(
            this.handleIntersection.bind(this),
            { rootMargin: '50px' }
        );
        this.loadedDiagrams = new Set();
    }

    observe(element) {
        this.observer.observe(element);
    }

    async handleIntersection(entries) {
        for (const entry of entries) {
            if (entry.isIntersecting && !this.loadedDiagrams.has(entry.target)) {
                await this.loadDiagram(entry.target);
                this.loadedDiagrams.add(entry.target);
                this.observer.unobserve(entry.target);
            }
        }
    }

    async loadDiagram(element) {
        const definition = element.dataset.mermaid;
        const { svg } = await mermaid.render(
            `diagram-${Date.now()}`,
            definition
        );
        element.innerHTML = svg;
        element.classList.add('loaded');
    }
}

// Usage
const lazyLoader = new LazyMermaidLoader();
document.querySelectorAll('.lazy-mermaid').forEach(el => {
    lazyLoader.observe(el);
});
```

## Best Practices

### 1. Code Organization
```javascript
// NPL-FIM Project Structure
src/
├── components/
│   ├── MermaidDiagram.js
│   ├── DiagramControls.js
│   └── ExportTools.js
├── generators/
│   ├── FlowchartGenerator.js
│   ├── SequenceGenerator.js
│   └── GanttGenerator.js
├── utils/
│   ├── diagramValidator.js
│   ├── exportUtils.js
│   └── themeManager.js
├── config/
│   ├── mermaidConfig.js
│   └── themes.js
└── tests/
    ├── diagram.test.js
    └── export.test.js
```

### 2. Error Handling
```javascript
// Comprehensive error handling
class DiagramErrorHandler {
    static handleRenderError(error, definition) {
        const errorTypes = {
            'Parse error': 'Invalid syntax in diagram definition',
            'Maximum text size': 'Diagram too large, consider splitting',
            'Unknown diagram type': 'Unsupported diagram type specified'
        };

        const userMessage = Object.keys(errorTypes).find(key =>
            error.message.includes(key)
        );

        return {
            error: error.message,
            userMessage: userMessage ? errorTypes[userMessage] : 'Unknown error',
            definition,
            timestamp: new Date().toISOString()
        };
    }

    static logError(errorInfo) {
        console.error('Diagram Error:', errorInfo);
        // Send to monitoring service
    }
}
```

### 3. Testing Strategy
```javascript
// Jest tests for diagram generation
describe('NPL-FIM Mermaid Generators', () => {
    test('FlowchartGenerator creates valid syntax', () => {
        const generator = new FlowchartGenerator();
        const steps = [
            { type: 'start', label: 'Begin' },
            { type: 'process', label: 'Process' },
            { type: 'end', label: 'End' }
        ];

        const result = generator.generateProcessFlow(steps);
        expect(result).toContain('flowchart TD');
        expect(result).toContain('Begin');
        expect(result).toContain('-->');
    });

    test('SequenceGenerator handles API flows', () => {
        const generator = new SequenceGenerator();
        const participants = [
            { id: 'A', name: 'Client' },
            { id: 'B', name: 'Server' }
        ];
        const interactions = [
            { from: 'A', to: 'B', type: 'sync', message: 'Request' }
        ];

        const result = generator.generateAPIFlow(participants, interactions);
        expect(result).toContain('sequenceDiagram');
        expect(result).toContain('A->>B: Request');
    });
});
```

## Advantages and Limitations

### Mermaid Advantages for NPL-FIM
- **Text-based**: Version control friendly, easy to diff
- **Declarative**: Focus on content, not layout details
- **Comprehensive**: Supports 10+ diagram types
- **Themeable**: Built-in themes and customization
- **Lightweight**: No external dependencies beyond JavaScript
- **Export-ready**: Multiple output formats (SVG, PNG, PDF)
- **Integration-friendly**: Works with all major frameworks

### Limitations to Consider
- **Complex layouts**: Limited fine-grained positioning control
- **Large diagrams**: Performance degrades with >100 nodes
- **Custom shapes**: Restricted to predefined node types
- **Styling**: Limited CSS customization options
- **Print quality**: May require optimization for high-DPI displays
- **Browser dependency**: Requires JavaScript runtime

### NPL-FIM Mitigation Strategies
```javascript
// Address common limitations
const optimizationStrategies = {
    largeDatasets: 'Implement pagination and lazy loading',
    customShapes: 'Use subgraphs and styling workarounds',
    printQuality: 'Generate high-resolution exports programmatically',
    performance: 'Use web workers for complex diagram generation',
    styling: 'Combine with custom CSS post-processing'
};
```

This comprehensive guide provides everything needed for NPL-FIM to generate professional Mermaid diagrams without false starts. The implementation covers all major diagram types, configuration options, integration patterns, and troubleshooting scenarios, ensuring robust diagram generation capabilities across any development environment.