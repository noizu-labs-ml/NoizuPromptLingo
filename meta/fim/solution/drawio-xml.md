# Draw.io XML Format
Comprehensive guide to diagrams.net (draw.io) XML format for creating professional technical diagrams, architectural visualizations, and collaborative documentation. [Official Docs](https://www.drawio.com/doc) | [GitHub Examples](https://github.com/jgraph/drawio-diagrams) | [API Reference](https://desk.draw.io/support/solutions/articles/16000042494)

## Table of Contents
1. [Installation & Setup](#installation--setup)
2. [Core XML Structure](#core-xml-structure)
3. [Advanced Features](#advanced-features)
4. [Shape Libraries & Templates](#shape-libraries--templates)
5. [Styling & Theming](#styling--theming)
6. [Enterprise Features](#enterprise-features)
7. [API & Automation](#api--automation)
8. [Integration Patterns](#integration-patterns)
9. [Complex Examples](#complex-examples)
10. [Performance & Optimization](#performance--optimization)
11. [Troubleshooting](#troubleshooting)
12. [Best Practices](#best-practices)

## Installation & Setup

### Desktop Applications
```bash
# Windows
winget install JGraph.Draw.io

# macOS
brew install --cask drawio

# Linux (AppImage)
wget https://github.com/jgraph/drawio-desktop/releases/latest/download/drawio-x86_64.AppImage
chmod +x drawio-x86_64.AppImage

# Snap package
sudo snap install drawio
```

### VS Code Integration
```bash
# Primary extension
ext install hediet.vscode-drawio

# Alternative with enhanced features
ext install eightHundredIQ.vscode-drawio-plugin-mermaid

# Configuration in settings.json
{
  "hediet.vscode-drawio.resizeImages": null,
  "hediet.vscode-drawio.theme": "atlas",
  "hediet.vscode-drawio.codeLinkActivated": true,
  "hediet.vscode-drawio.localStorageEnabled": true
}
```

### JetBrains IDEs
```bash
# IntelliJ IDEA, WebStorm, PyCharm
# Install "Diagrams.net Integration" plugin from marketplace
```

### Programmatic Tools
```bash
# Core libraries
npm install drawio-export @mxgraph/mxgraph

# CLI tools
npm install -g @jgraph/drawio-export
pip install drawio-exporter

# Docker container
docker pull jgraph/export-server:latest
```

## Core XML Structure

### Basic File Format
```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2024-01-15T10:30:00.000Z" agent="5.0" etag="uniqueHash" version="22.1.16">
  <diagram name="Main Diagram" id="main-id">
    <mxGraphModel dx="1422" dy="754" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- Diagram elements here -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Multi-page Documents
```xml
<mxfile host="app.diagrams.net">
  <diagram name="System Overview" id="page1">
    <mxGraphModel>
      <!-- Page 1 content -->
    </mxGraphModel>
  </diagram>
  <diagram name="Database Schema" id="page2">
    <mxGraphModel>
      <!-- Page 2 content -->
    </mxGraphModel>
  </diagram>
  <diagram name="API Flows" id="page3">
    <mxGraphModel>
      <!-- Page 3 content -->
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Shape Definitions
```xml
<!-- Rectangle with advanced styling -->
<mxCell id="shape1" value="API Gateway"
       style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;strokeWidth=2;fontFamily=Helvetica;fontSize=12;fontColor=#333333;gradientColor=#ffffff;gradientDirection=north;"
       vertex="1" parent="1">
  <mxGeometry x="200" y="100" width="160" height="80" as="geometry"/>
</mxCell>

<!-- Custom shape with icon -->
<mxCell id="shape2" value="&lt;img src=&quot;data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQi...&quot; width=&quot;24&quot; height=&quot;24&quot;&gt;&lt;br&gt;Database"
       style="shape=image;verticalLabelPosition=bottom;labelBackgroundColor=default;verticalAlign=top;aspect=fixed;imageAspect=0;"
       vertex="1" parent="1">
  <mxGeometry x="400" y="100" width="80" height="80" as="geometry"/>
</mxCell>

<!-- Connection with waypoints -->
<mxCell id="edge1" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;strokeColor=#d6b656;fillColor=#fff2cc;"
       edge="1" parent="1" source="shape1" target="shape2">
  <mxGeometry relative="1" as="geometry">
    <Array as="points">
      <mxPoint x="320" y="140"/>
      <mxPoint x="440" y="140"/>
    </Array>
  </mxGeometry>
</mxCell>
```

## Advanced Features

### Layers and Grouping
```xml
<!-- Layer definition -->
<mxCell id="layer1" value="Infrastructure Layer" style="group;fontStyle=1;fontSize=14;" vertex="1" collapsed="0" parent="1">
  <mxGeometry x="50" y="50" width="700" height="400" as="geometry"/>
</mxCell>

<!-- Grouped elements -->
<mxCell id="group1" value="" style="group;" vertex="1" connectable="0" parent="layer1">
  <mxGeometry x="100" y="100" width="200" height="150" as="geometry"/>
</mxCell>

<mxCell id="grouped-item1" value="Load Balancer" style="rounded=1;" vertex="1" parent="group1">
  <mxGeometry width="200" height="60" as="geometry"/>
</mxCell>

<mxCell id="grouped-item2" value="Health Check" style="rounded=1;" vertex="1" parent="group1">
  <mxGeometry y="90" width="200" height="60" as="geometry"/>
</mxCell>
```

### Custom Shapes and Stencils
```xml
<!-- Custom stencil definition -->
<shapes>
  <shape name="customServer" h="100" w="100" aspect="variable" strokewidth="inherit">
    <connections>
      <constraint x="0.5" y="0" perimeter="0" name="top"/>
      <constraint x="0.5" y="1" perimeter="0" name="bottom"/>
      <constraint x="0" y="0.5" perimeter="0" name="left"/>
      <constraint x="1" y="0.5" perimeter="0" name="right"/>
    </connections>
    <background>
      <rect x="10" y="10" w="80" h="80" stroke="#333" fill="#f0f0f0"/>
      <rect x="20" y="20" w="60" h="8" fill="#4CAF50"/>
      <rect x="20" y="35" w="60" h="8" fill="#FF9800"/>
      <rect x="20" y="50" w="60" h="8" fill="#2196F3"/>
    </background>
  </shape>
</shapes>
```

### Embedded Links and Metadata
```xml
<mxCell id="linked-shape" value="User Service"
       style="rounded=1;whiteSpace=wrap;html=1;"
       vertex="1" parent="1">
  <mxGeometry x="200" y="200" width="120" height="60" as="geometry"/>
  <!-- Embedded link -->
  <mxCell id="link1" style="shape=link;" edge="1" parent="linked-shape">
    <mxGeometry relative="1" as="geometry">
      <mxPoint as="sourcePoint"/>
      <mxPoint as="targetPoint"/>
    </mxGeometry>
    <mxCell id="linkData" value="https://docs.example.com/user-service" style="text;" vertex="1" parent="link1">
      <mxGeometry relative="1" as="geometry"/>
    </mxCell>
  </mxCell>
  <!-- Custom metadata -->
  <UserObject id="metadata" version="2.1.0" owner="team-backend" criticality="high"/>
</mxCell>
```

## Shape Libraries & Templates

### AWS Architecture Shapes
```xml
<!-- AWS VPC -->
<mxCell id="vpc" value="Production VPC&#xa;10.0.0.0/16"
       style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=none;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_vpc;strokeColor=#248814;fillColor=none;verticalAlign=top;align=left;spacingLeft=30;fontColor=#248814;dashed=0;"
       vertex="1" parent="1">
  <mxGeometry x="80" y="80" width="800" height="600" as="geometry"/>
</mxCell>

<!-- AWS EC2 Instance -->
<mxCell id="ec2" value="Web Server&#xa;t3.medium"
       style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.ec2;fillColor=#F58534;gradientColor=none;"
       vertex="1" parent="vpc">
  <mxGeometry x="300" y="200" width="78" height="78" as="geometry"/>
</mxCell>

<!-- AWS RDS -->
<mxCell id="rds" value="PostgreSQL&#xa;db.t3.micro"
       style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.rds;fillColor=#3F48CC;gradientColor=none;"
       vertex="1" parent="vpc">
  <mxGeometry x="500" y="400" width="78" height="78" as="geometry"/>
</mxCell>
```

### UML Class Diagrams
```xml
<!-- UML Class -->
<mxCell id="user-class" value="&lt;p style=&quot;margin:0px;margin-top:4px;text-align:center;&quot;&gt;&lt;b&gt;User&lt;/b&gt;&lt;/p&gt;&lt;hr size=&quot;1&quot;&gt;&lt;p style=&quot;margin:0px;margin-left:4px;&quot;&gt;- id: Long&lt;/p&gt;&lt;p style=&quot;margin:0px;margin-left:4px;&quot;&gt;- email: String&lt;/p&gt;&lt;p style=&quot;margin:0px;margin-left:4px;&quot;&gt;- passwordHash: String&lt;/p&gt;&lt;p style=&quot;margin:0px;margin-left:4px;&quot;&gt;- createdAt: DateTime&lt;/p&gt;&lt;hr size=&quot;1&quot;&gt;&lt;p style=&quot;margin:0px;margin-left:4px;&quot;&gt;+ authenticate(password: String): Boolean&lt;/p&gt;&lt;p style=&quot;margin:0px;margin-left:4px;&quot;&gt;+ updateProfile(data: Map): void&lt;/p&gt;&lt;p style=&quot;margin:0px;margin-left:4px;&quot;&gt;+ getPermissions(): List&amp;lt;Permission&amp;gt;&lt;/p&gt;"
       style="verticalAlign=top;align=left;overflow=fill;fontSize=12;fontFamily=Helvetica;html=1;fillColor=#f8cecc;strokeColor=#b85450;"
       vertex="1" parent="1">
  <mxGeometry x="200" y="200" width="280" height="160" as="geometry"/>
</mxCell>

<!-- UML Association -->
<mxCell id="association" style="endArrow=none;html=1;edgeStyle=orthogonalEdgeStyle;strokeWidth=2;" edge="1" parent="1" source="user-class" target="role-class">
  <mxGeometry relative="1" as="geometry"/>
  <mxCell id="multiplicity1" value="1" style="resizable=0;html=1;align=left;verticalAlign=bottom;" connectable="0" vertex="1" parent="association">
    <mxGeometry x="-1" relative="1" as="geometry"/>
  </mxCell>
  <mxCell id="multiplicity2" value="*" style="resizable=0;html=1;align=right;verticalAlign=bottom;" connectable="0" vertex="1" parent="association">
    <mxGeometry x="1" relative="1" as="geometry"/>
  </mxCell>
</mxCell>
```

### Network Topology Shapes
```xml
<!-- Network Switch -->
<mxCell id="switch" value="Core Switch&#xa;Cisco 9300"
       style="fontColor=#0066CC;verticalAlign=top;verticalLabelPosition=bottom;labelPosition=center;align=center;html=1;outlineConnect=0;fillColor=#CCCCCC;strokeColor=#6881B3;gradientColor=none;gradientDirection=north;strokeWidth=2;shape=mxgraph.networks.switch;"
       vertex="1" parent="1">
  <mxGeometry x="300" y="200" width="100" height="30" as="geometry"/>
</mxCell>

<!-- Firewall -->
<mxCell id="firewall" value="Perimeter Firewall&#xa;FortiGate 600E"
       style="fontColor=#0066CC;verticalAlign=top;verticalLabelPosition=bottom;labelPosition=center;align=center;html=1;outlineConnect=0;fillColor=#FFD966;strokeColor=#B3A712;gradientColor=none;strokeWidth=2;shape=mxgraph.networks.firewall;"
       vertex="1" parent="1">
  <mxGeometry x="100" y="200" width="80" height="40" as="geometry"/>
</mxCell>

<!-- Network Connection with bandwidth label -->
<mxCell id="network-conn" style="html=1;strokeWidth=3;strokeColor=#4CAF50;" edge="1" parent="1" source="firewall" target="switch">
  <mxGeometry relative="1" as="geometry"/>
  <mxCell id="bandwidth-label" value="1 Gbps" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];fontSize=10;fontColor=#4CAF50;" vertex="1" connectable="0" parent="network-conn">
    <mxGeometry x="0.1" y="-1" relative="1" as="geometry">
      <mxPoint as="offset"/>
    </mxGeometry>
  </mxCell>
</mxCell>
```

## Styling & Theming

### Custom Color Palettes
```xml
<!-- Define custom color scheme -->
<UserObject label="Color Palette" id="colors">
  <mxCell style="shape=rectangle;fillColor=#E3F2FD;strokeColor=#1976D2;" vertex="1" parent="1">
    <mxGeometry as="geometry"/>
  </mxCell>
  <!-- Primary colors -->
  <color name="primary" value="#1976D2"/>
  <color name="primaryLight" value="#42A5F5"/>
  <color name="primaryDark" value="#0D47A1"/>
  <!-- Secondary colors -->
  <color name="secondary" value="#388E3C"/>
  <color name="secondaryLight" value="#66BB6A"/>
  <color name="secondaryDark" value="#1B5E20"/>
  <!-- Status colors -->
  <color name="success" value="#4CAF50"/>
  <color name="warning" value="#FF9800"/>
  <color name="error" value="#F44336"/>
  <color name="info" value="#2196F3"/>
</UserObject>

<!-- Apply themed styles -->
<mxCell id="themed-shape" value="API Service"
       style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E3F2FD;strokeColor=#1976D2;strokeWidth=2;fontColor=#0D47A1;fontSize=12;fontFamily=Roboto,Helvetica,Arial,sans-serif;"
       vertex="1" parent="1">
  <mxGeometry x="200" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

### Responsive Design Patterns
```xml
<!-- Mobile-responsive layout -->
<mxCell id="mobile-container" value="" style="swimlane;fontStyle=0;childLayout=stackLayout;horizontal=1;startSize=30;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;fontSize=14;" vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="320" height="568" as="geometry"/>
</mxCell>

<!-- Header -->
<mxCell id="header" value="Mobile App Header" style="text;strokeColor=none;fillColor=#1976D2;align=center;verticalAlign=middle;spacingLeft=4;spacingRight=4;overflow=hidden;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;rotatable=0;fontColor=#FFFFFF;fontSize=16;fontStyle=1;" vertex="1" parent="mobile-container">
  <mxGeometry y="30" width="320" height="60" as="geometry"/>
</mxCell>

<!-- Content area -->
<mxCell id="content" value="Main Content Area&#xa;&#xa;• Feature 1&#xa;• Feature 2&#xa;• Feature 3" style="text;strokeColor=none;fillColor=#F5F5F5;align=left;verticalAlign=top;spacingLeft=20;spacingRight=4;overflow=hidden;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;rotatable=0;" vertex="1" parent="mobile-container">
  <mxGeometry y="90" width="320" height="418" as="geometry"/>
</mxCell>

<!-- Navigation -->
<mxCell id="navigation" value="Bottom Navigation" style="text;strokeColor=none;fillColor=#EEEEEE;align=center;verticalAlign=middle;spacingLeft=4;spacingRight=4;overflow=hidden;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;rotatable=0;" vertex="1" parent="mobile-container">
  <mxGeometry y="508" width="320" height="60" as="geometry"/>
</mxCell>
```

### Dark Mode Support
```xml
<!-- Dark theme styles -->
<style name="dark-theme">
  <add as="background" value="#121212"/>
  <add as="foreground" value="#FFFFFF"/>
  <add as="gridColor" value="#333333"/>
  <add as="defaultVertex" value="rounded=1;whiteSpace=wrap;html=1;fillColor=#1E1E1E;strokeColor=#616161;fontColor=#FFFFFF;"/>
  <add as="defaultEdge" value="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#757575;"/>
</style>

<!-- Dark mode shape -->
<mxCell id="dark-shape" value="Dark Mode Component"
       style="rounded=1;whiteSpace=wrap;html=1;fillColor=#1E1E1E;strokeColor=#616161;fontColor=#FFFFFF;gradientColor=#424242;gradientDirection=north;"
       vertex="1" parent="1">
  <mxGeometry x="200" y="200" width="140" height="60" as="geometry"/>
</mxCell>
```

## Enterprise Features

### Confluence Integration
```xml
<!-- Confluence-compatible diagram -->
<mxfile host="confluence" modified="2024-01-15T10:30:00.000Z" agent="Confluence" version="22.1.16">
  <diagram name="Enterprise Architecture" id="enterprise">
    <mxGraphModel dx="1422" dy="754" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Enterprise service -->
        <mxCell id="service" value="&lt;b&gt;Customer Service&lt;/b&gt;&lt;br&gt;&lt;br&gt;Endpoints:&lt;br&gt;• GET /customers&lt;br&gt;• POST /customers&lt;br&gt;• PUT /customers/{id}&lt;br&gt;&lt;br&gt;Dependencies:&lt;br&gt;• Auth Service&lt;br&gt;• Payment Service"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="1">
          <mxGeometry x="200" y="100" width="200" height="150" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Team Collaboration Features
```xml
<!-- Comment system -->
<mxCell id="reviewed-component" value="Payment Gateway" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1">
  <mxGeometry x="200" y="200" width="120" height="60" as="geometry"/>

  <!-- Embedded comments -->
  <UserObject label="Comments" id="comments">
    <comment id="c1" author="john.doe@company.com" timestamp="2024-01-15T10:30:00Z" resolved="false">
      Need to add error handling for timeout scenarios
    </comment>
    <comment id="c2" author="jane.smith@company.com" timestamp="2024-01-15T11:00:00Z" resolved="true">
      Consider using circuit breaker pattern here
    </comment>
  </UserObject>
</mxCell>

<!-- Version tracking -->
<UserObject label="Version Info" version="2.1.0" author="architecture-team" lastModified="2024-01-15T12:00:00Z">
  <changelog>
    <entry version="2.1.0" date="2024-01-15" author="john.doe">Added payment gateway integration</entry>
    <entry version="2.0.0" date="2024-01-10" author="jane.smith">Migrated to microservices architecture</entry>
    <entry version="1.5.0" date="2024-01-05" author="bob.wilson">Added authentication flow</entry>
  </changelog>
</UserObject>
```

### Access Control and Permissions
```xml
<!-- Role-based access control -->
<UserObject label="Access Control" id="acl">
  <permissions>
    <role name="architect" level="edit" shapes="all" layers="all"/>
    <role name="developer" level="view" shapes="implementation" layers="logical,physical"/>
    <role name="stakeholder" level="view" shapes="business" layers="business"/>
  </permissions>
</UserObject>

<!-- Protected diagram section -->
<mxCell id="sensitive-area" value="Security Infrastructure"
       style="swimlane;startSize=20;horizontal=0;fillColor=#f8cecc;strokeColor=#b85450;"
       vertex="1" parent="1">
  <mxGeometry x="400" y="100" width="300" height="200" as="geometry"/>
  <UserObject label="Security" classification="confidential" requiredRole="security-team"/>
</mxCell>
```

## API & Automation

### REST API Integration
```bash
# Export diagram using REST API
curl -X POST \
  'https://export.diagrams.net/export' \
  -H 'Content-Type: application/json' \
  -d '{
    "xml": "<mxfile>...</mxfile>",
    "format": "png",
    "w": 1000,
    "h": 800,
    "bg": "#ffffff",
    "scale": 2
  }'

# Batch export multiple formats
curl -X POST \
  'https://export.diagrams.net/export' \
  -H 'Content-Type: application/json' \
  -d '{
    "xml": "<mxfile>...</mxfile>",
    "format": "multi",
    "formats": ["png", "svg", "pdf"],
    "filename": "architecture-diagram"
  }'
```

### Node.js Automation
```javascript
const { exportDrawio } = require('drawio-export');
const fs = require('fs');
const path = require('path');

// Programmatic diagram generation
async function generateDiagram() {
  const xmlContent = `
    <mxfile host="nodejs">
      <diagram name="Generated" id="auto">
        <mxGraphModel>
          <root>
            <mxCell id="0"/>
            <mxCell id="1" parent="0"/>

            <!-- Dynamically generated shapes -->
            ${generateServiceShapes()}
            ${generateConnections()}
          </root>
        </mxGraphModel>
      </diagram>
    </mxfile>
  `;

  // Export to multiple formats
  const formats = ['png', 'svg', 'pdf'];

  for (const format of formats) {
    const output = await exportDrawio(xmlContent, {
      format: format,
      width: 1200,
      height: 800,
      background: '#ffffff',
      scale: 2
    });

    fs.writeFileSync(`diagram.${format}`, output);
  }
}

function generateServiceShapes() {
  const services = ['user-service', 'payment-service', 'notification-service'];

  return services.map((service, index) => `
    <mxCell id="${service}" value="${service.replace('-', ' ').toUpperCase()}"
           style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;"
           vertex="1" parent="1">
      <mxGeometry x="${200 + index * 150}" y="200" width="120" height="60" as="geometry"/>
    </mxCell>
  `).join('');
}

// CI/CD Integration
async function updateDiagramsInPipeline() {
  const diagramFiles = fs.readdirSync('./diagrams')
    .filter(file => file.endsWith('.drawio'));

  for (const file of diagramFiles) {
    const xmlContent = fs.readFileSync(path.join('./diagrams', file), 'utf8');

    // Export to documentation directory
    const pngOutput = await exportDrawio(xmlContent, { format: 'png' });
    fs.writeFileSync(`./docs/images/${file.replace('.drawio', '.png')}`, pngOutput);

    // Export SVG for web
    const svgOutput = await exportDrawio(xmlContent, { format: 'svg' });
    fs.writeFileSync(`./docs/images/${file.replace('.drawio', '.svg')}`, svgOutput);
  }
}
```

### Python Integration
```python
import xml.etree.ElementTree as ET
import requests
import base64
from pathlib import Path

class DrawioGenerator:
    def __init__(self):
        self.export_url = "https://export.diagrams.net/export"

    def create_system_diagram(self, services):
        """Generate system architecture diagram from service list"""
        root = ET.Element('mxfile', host="python-generator")
        diagram = ET.SubElement(root, 'diagram', name="System Architecture", id="system")
        model = ET.SubElement(diagram, 'mxGraphModel', dx="1422", dy="754", grid="1")
        graph_root = ET.SubElement(model, 'root')

        # Root cells
        ET.SubElement(graph_root, 'mxCell', id="0")
        ET.SubElement(graph_root, 'mxCell', id="1", parent="0")

        # Generate service shapes
        for i, service in enumerate(services):
            self._add_service_shape(graph_root, service, i)

        # Generate connections
        self._add_connections(graph_root, services)

        return ET.tostring(root, encoding='unicode')

    def _add_service_shape(self, parent, service, index):
        """Add service shape to diagram"""
        shape_id = f"service_{index}"
        x = 200 + (index % 3) * 200
        y = 200 + (index // 3) * 150

        cell = ET.SubElement(parent, 'mxCell',
            id=shape_id,
            value=service['name'],
            style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;",
            vertex="1",
            parent="1"
        )

        ET.SubElement(cell, 'mxGeometry',
            x=str(x), y=str(y), width="150", height="80", **{"as": "geometry"}
        )

    def export_diagram(self, xml_content, format='png', **options):
        """Export diagram to specified format"""
        payload = {
            'xml': xml_content,
            'format': format,
            **options
        }

        response = requests.post(self.export_url, json=payload)
        return response.content

    def generate_documentation(self, config_file):
        """Generate complete documentation set"""
        with open(config_file) as f:
            config = json.load(f)

        diagrams = {}

        # Generate system overview
        system_xml = self.create_system_diagram(config['services'])
        diagrams['system-overview'] = {
            'xml': system_xml,
            'png': self.export_diagram(system_xml, 'png', w=1200, h=800),
            'svg': self.export_diagram(system_xml, 'svg')
        }

        # Generate API flows
        for api in config['apis']:
            api_xml = self.create_api_flow_diagram(api)
            diagrams[f"api-{api['name']}"] = {
                'xml': api_xml,
                'png': self.export_diagram(api_xml, 'png')
            }

        return diagrams

# Usage example
generator = DrawioGenerator()
services = [
    {'name': 'User Service', 'type': 'microservice'},
    {'name': 'Payment Service', 'type': 'microservice'},
    {'name': 'Database', 'type': 'storage'}
]

xml_diagram = generator.create_system_diagram(services)
png_output = generator.export_diagram(xml_diagram, 'png', w=1000, h=600)

with open('system_architecture.png', 'wb') as f:
    f.write(png_output)
```

## Integration Patterns

### GitLab CI/CD Pipeline
```yaml
# .gitlab-ci.yml
stages:
  - validate
  - export
  - deploy

validate_diagrams:
  stage: validate
  image: node:16
  before_script:
    - npm install -g drawio-export
  script:
    - |
      for file in diagrams/*.drawio; do
        echo "Validating $file"
        drawio-export --check "$file"
      done
  only:
    changes:
      - "diagrams/*.drawio"

export_diagrams:
  stage: export
  image: node:16
  before_script:
    - npm install -g drawio-export
  script:
    - mkdir -p exported/png exported/svg exported/pdf
    - |
      for file in diagrams/*.drawio; do
        filename=$(basename "$file" .drawio)
        echo "Exporting $filename"

        # Export PNG for documentation
        drawio-export --format png --width 1200 --output "exported/png/${filename}.png" "$file"

        # Export SVG for web
        drawio-export --format svg --output "exported/svg/${filename}.svg" "$file"

        # Export PDF for printing
        drawio-export --format pdf --output "exported/pdf/${filename}.pdf" "$file"
      done
  artifacts:
    paths:
      - exported/
    expire_in: 30 days
  only:
    changes:
      - "diagrams/*.drawio"

deploy_documentation:
  stage: deploy
  dependencies:
    - export_diagrams
  script:
    - |
      # Copy exported diagrams to documentation site
      cp exported/png/* docs/static/images/
      cp exported/svg/* docs/static/images/

      # Update documentation index
      python scripts/update_diagram_index.py

      # Deploy to GitHub Pages
      npm run deploy
  only:
    - main
```

### GitHub Actions Workflow
```yaml
# .github/workflows/diagrams.yml
name: Diagram Processing

on:
  push:
    paths:
      - 'diagrams/**/*.drawio'
  pull_request:
    paths:
      - 'diagrams/**/*.drawio'

jobs:
  process-diagrams:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install drawio-export
        run: npm install -g drawio-export

      - name: Export diagrams
        run: |
          mkdir -p docs/images
          for file in diagrams/*.drawio; do
            filename=$(basename "$file" .drawio)
            echo "Processing $filename"

            # Export multiple formats
            drawio-export --format png --width 1200 --output "docs/images/${filename}.png" "$file"
            drawio-export --format svg --output "docs/images/${filename}.svg" "$file"
          done

      - name: Commit exported diagrams
        if: github.event_name == 'push'
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add docs/images/
          git diff --staged --quiet || git commit -m "Auto-export diagrams [skip ci]"
          git push
```

### Confluence Automation
```javascript
// confluence-sync.js
const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

class ConfluenceSync {
  constructor(baseUrl, auth) {
    this.baseUrl = baseUrl;
    this.auth = auth;
    this.api = axios.create({
      baseURL: `${baseUrl}/rest/api`,
      auth: auth
    });
  }

  async syncDiagram(pageId, diagramFile, attachmentName) {
    // Read diagram file
    const diagramContent = fs.readFileSync(diagramFile);

    // Upload as attachment
    const form = new FormData();
    form.append('file', diagramContent, {
      filename: attachmentName,
      contentType: 'application/xml'
    });

    const uploadResponse = await this.api.post(
      `/content/${pageId}/child/attachment`,
      form,
      { headers: form.getHeaders() }
    );

    // Update page content to embed diagram
    const pageResponse = await this.api.get(`/content/${pageId}?expand=body.storage,version`);
    const currentContent = pageResponse.data.body.storage.value;

    const diagramMacro = `
      <ac:structured-macro ac:name="drawio">
        <ac:parameter ac:name="attachment">${attachmentName}</ac:parameter>
        <ac:parameter ac:name="aspect">1</ac:parameter>
      </ac:structured-macro>
    `;

    const updatedContent = currentContent + diagramMacro;

    await this.api.put(`/content/${pageId}`, {
      id: pageId,
      type: 'page',
      title: pageResponse.data.title,
      body: {
        storage: {
          value: updatedContent,
          representation: 'storage'
        }
      },
      version: {
        number: pageResponse.data.version.number + 1
      }
    });

    return uploadResponse.data;
  }

  async bulkSync(mappings) {
    const results = [];

    for (const mapping of mappings) {
      try {
        const result = await this.syncDiagram(
          mapping.pageId,
          mapping.diagramFile,
          mapping.attachmentName
        );
        results.push({ ...mapping, success: true, result });
      } catch (error) {
        results.push({ ...mapping, success: false, error: error.message });
      }
    }

    return results;
  }
}

// Usage
const sync = new ConfluenceSync('https://company.atlassian.net/wiki', {
  username: process.env.CONFLUENCE_USERNAME,
  password: process.env.CONFLUENCE_TOKEN
});

const mappings = [
  {
    pageId: '123456789',
    diagramFile: './diagrams/system-architecture.drawio',
    attachmentName: 'system-architecture.drawio'
  },
  {
    pageId: '987654321',
    diagramFile: './diagrams/api-flows.drawio',
    attachmentName: 'api-flows.drawio'
  }
];

sync.bulkSync(mappings).then(results => {
  console.log('Sync results:', results);
});
```

## Complex Examples

### Microservices Architecture
```xml
<mxfile host="app.diagrams.net">
  <diagram name="Microservices Architecture" id="microservices">
    <mxGraphModel dx="2074" dy="1114" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1600" pageHeight="1200">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Load Balancer -->
        <mxCell id="load-balancer" value="&lt;b&gt;Application Load Balancer&lt;/b&gt;&lt;br&gt;&lt;br&gt;• SSL Termination&lt;br&gt;• Health Checks&lt;br&gt;• Auto Scaling&lt;br&gt;• Blue/Green Deployment"
               style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.application_load_balancer;fillColor=#F58534;gradientColor=none;labelPosition=center;"
               vertex="1" parent="1">
          <mxGeometry x="700" y="50" width="78" height="78" as="geometry"/>
        </mxCell>

        <!-- API Gateway -->
        <mxCell id="api-gateway" value="&lt;b&gt;API Gateway&lt;/b&gt;&lt;br&gt;&lt;br&gt;• Rate Limiting&lt;br&gt;• Authentication&lt;br&gt;• Request Routing&lt;br&gt;• Response Caching&lt;br&gt;• API Versioning"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;strokeWidth=2;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="1">
          <mxGeometry x="650" y="200" width="180" height="120" as="geometry"/>
        </mxCell>

        <!-- Service Mesh -->
        <mxCell id="service-mesh" value="Service Mesh (Istio)"
               style="swimlane;startSize=20;horizontal=0;fillColor=#fff2cc;strokeColor=#d6b656;fontStyle=1;"
               vertex="1" parent="1">
          <mxGeometry x="100" y="400" width="1400" height="600" as="geometry"/>
        </mxCell>

        <!-- User Service -->
        <mxCell id="user-service" value="&lt;b&gt;User Service&lt;/b&gt;&lt;br&gt;&lt;br&gt;Responsibilities:&lt;br&gt;• User Registration&lt;br&gt;• Authentication&lt;br&gt;• Profile Management&lt;br&gt;• Password Reset&lt;br&gt;&lt;br&gt;Technology Stack:&lt;br&gt;• Node.js + Express&lt;br&gt;• MongoDB&lt;br&gt;• Redis (Cache)&lt;br&gt;• JWT Authentication"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="50" y="50" width="200" height="200" as="geometry"/>
        </mxCell>

        <!-- Product Service -->
        <mxCell id="product-service" value="&lt;b&gt;Product Service&lt;/b&gt;&lt;br&gt;&lt;br&gt;Responsibilities:&lt;br&gt;• Product Catalog&lt;br&gt;• Inventory Management&lt;br&gt;• Price Management&lt;br&gt;• Search &amp;amp; Filtering&lt;br&gt;&lt;br&gt;Technology Stack:&lt;br&gt;• Java + Spring Boot&lt;br&gt;• PostgreSQL&lt;br&gt;• Elasticsearch&lt;br&gt;• Apache Kafka"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="300" y="50" width="200" height="200" as="geometry"/>
        </mxCell>

        <!-- Order Service -->
        <mxCell id="order-service" value="&lt;b&gt;Order Service&lt;/b&gt;&lt;br&gt;&lt;br&gt;Responsibilities:&lt;br&gt;• Order Processing&lt;br&gt;• Order History&lt;br&gt;• Order Status Tracking&lt;br&gt;• Saga Orchestration&lt;br&gt;&lt;br&gt;Technology Stack:&lt;br&gt;• Python + FastAPI&lt;br&gt;• PostgreSQL&lt;br&gt;• Apache Kafka&lt;br&gt;• Temporal.io"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="550" y="50" width="200" height="200" as="geometry"/>
        </mxCell>

        <!-- Payment Service -->
        <mxCell id="payment-service" value="&lt;b&gt;Payment Service&lt;/b&gt;&lt;br&gt;&lt;br&gt;Responsibilities:&lt;br&gt;• Payment Processing&lt;br&gt;• Refund Management&lt;br&gt;• Fraud Detection&lt;br&gt;• PCI Compliance&lt;br&gt;&lt;br&gt;Technology Stack:&lt;br&gt;• Go + Gin&lt;br&gt;• PostgreSQL&lt;br&gt;• Stripe API&lt;br&gt;• HashiCorp Vault"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="800" y="50" width="200" height="200" as="geometry"/>
        </mxCell>

        <!-- Notification Service -->
        <mxCell id="notification-service" value="&lt;b&gt;Notification Service&lt;/b&gt;&lt;br&gt;&lt;br&gt;Responsibilities:&lt;br&gt;• Email Notifications&lt;br&gt;• SMS Notifications&lt;br&gt;• Push Notifications&lt;br&gt;• Notification Templates&lt;br&gt;&lt;br&gt;Technology Stack:&lt;br&gt;• Node.js + NestJS&lt;br&gt;• Redis&lt;br&gt;• SendGrid API&lt;br&gt;• Firebase FCM"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="1050" y="50" width="200" height="200" as="geometry"/>
        </mxCell>

        <!-- Databases -->
        <mxCell id="user-db" value="User DB&lt;br&gt;MongoDB"
               style="shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#d5e8d4;strokeColor=#82b366;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="100" y="300" width="100" height="80" as="geometry"/>
        </mxCell>

        <mxCell id="product-db" value="Product DB&lt;br&gt;PostgreSQL"
               style="shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#dae8fc;strokeColor=#6c8ebf;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="350" y="300" width="100" height="80" as="geometry"/>
        </mxCell>

        <mxCell id="order-db" value="Order DB&lt;br&gt;PostgreSQL"
               style="shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#f8cecc;strokeColor=#b85450;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="600" y="300" width="100" height="80" as="geometry"/>
        </mxCell>

        <mxCell id="payment-db" value="Payment DB&lt;br&gt;PostgreSQL"
               style="shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#ffe6cc;strokeColor=#d79b00;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="850" y="300" width="100" height="80" as="geometry"/>
        </mxCell>

        <!-- Message Broker -->
        <mxCell id="kafka" value="&lt;b&gt;Apache Kafka&lt;/b&gt;&lt;br&gt;&lt;br&gt;Topics:&lt;br&gt;• user.events&lt;br&gt;• product.events&lt;br&gt;• order.events&lt;br&gt;• payment.events&lt;br&gt;• notification.events"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f0f0f0;strokeColor=#666666;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="service-mesh">
          <mxGeometry x="500" y="450" width="250" height="100" as="geometry"/>
        </mxCell>

        <!-- Service Connections -->
        <mxCell id="lb-to-gateway" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;strokeColor=#1976D2;" edge="1" parent="1" source="load-balancer" target="api-gateway">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <mxCell id="gateway-to-services" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=1;strokeColor=#666666;entryX=0.5;entryY=0;" edge="1" parent="1" source="api-gateway" target="service-mesh">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Database connections -->
        <mxCell id="user-to-db" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;strokeColor=#82b366;" edge="1" parent="service-mesh" source="user-service" target="user-db">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <mxCell id="product-to-db" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;strokeColor=#6c8ebf;" edge="1" parent="service-mesh" source="product-service" target="product-db">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <mxCell id="order-to-db" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;strokeColor=#b85450;" edge="1" parent="service-mesh" source="order-service" target="order-db">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <mxCell id="payment-to-db" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;strokeColor=#d79b00;" edge="1" parent="service-mesh" source="payment-service" target="payment-db">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Kafka connections -->
        <mxCell id="services-to-kafka" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=1;strokeColor=#666666;entryX=0.5;entryY=0;" edge="1" parent="service-mesh" source="order-service" target="kafka">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Cloud Infrastructure Diagram
```xml
<!-- AWS Multi-Region Architecture -->
<mxfile host="app.diagrams.net">
  <diagram name="AWS Multi-Region Architecture" id="aws-multi-region">
    <mxGraphModel dx="2500" dy="1400" grid="1" gridSize="10">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Region 1: US-East-1 -->
        <mxCell id="region-1" value="&lt;b&gt;AWS US-East-1 (Primary)&lt;/b&gt;"
               style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=none;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_region;strokeColor=#147EBA;fillColor=none;verticalAlign=top;align=left;spacingLeft=30;fontColor=#147EBA;dashed=0;"
               vertex="1" parent="1">
          <mxGeometry x="100" y="100" width="1000" height="800" as="geometry"/>
        </mxCell>

        <!-- VPC -->
        <mxCell id="vpc-1" value="Production VPC&lt;br&gt;10.0.0.0/16"
               style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=none;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_vpc;strokeColor=#248814;fillColor=none;verticalAlign=top;align=left;spacingLeft=30;fontColor=#248814;dashed=0;"
               vertex="1" parent="region-1">
          <mxGeometry x="50" y="50" width="900" height="700" as="geometry"/>
        </mxCell>

        <!-- Public Subnet AZ-1a -->
        <mxCell id="public-subnet-1a" value="Public Subnet 1a&lt;br&gt;10.0.1.0/24"
               style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=#7ea6e0;gradientDirection=north;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_availability_zone;strokeColor=#248814;fillColor=#d5e8d4;verticalAlign=top;align=left;spacingLeft=30;fontColor=#248814;dashed=0;"
               vertex="1" parent="vpc-1">
          <mxGeometry x="50" y="50" width="400" height="280" as="geometry"/>
        </mxCell>

        <!-- Application Load Balancer -->
        <mxCell id="alb" value="Application&lt;br&gt;Load Balancer"
               style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.application_load_balancer;fillColor=#F58534;gradientColor=none;"
               vertex="1" parent="public-subnet-1a">
          <mxGeometry x="160" y="50" width="78" height="78" as="geometry"/>
        </mxCell>

        <!-- NAT Gateway -->
        <mxCell id="nat-gateway" value="NAT Gateway"
               style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.nat_gateway;fillColor=#F58534;gradientColor=none;"
               vertex="1" parent="public-subnet-1a">
          <mxGeometry x="50" y="180" width="78" height="78" as="geometry"/>
        </mxCell>

        <!-- Private Subnet AZ-1a -->
        <mxCell id="private-subnet-1a" value="Private Subnet 1a&lt;br&gt;10.0.10.0/24"
               style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=#7ea6e0;gradientDirection=north;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_availability_zone;strokeColor=#147EBA;fillColor=#dddddd;verticalAlign=top;align=left;spacingLeft=30;fontColor=#147EBA;dashed=0;"
               vertex="1" parent="vpc-1">
          <mxGeometry x="50" y="380" width="400" height="280" as="geometry"/>
        </mxCell>

        <!-- ECS Cluster -->
        <mxCell id="ecs-cluster" value="ECS Cluster&lt;br&gt;Web Tier"
               style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.ecs;fillColor=#F58534;gradientColor=none;"
               vertex="1" parent="private-subnet-1a">
          <mxGeometry x="50" y="50" width="78" height="78" as="geometry"/>
        </mxCell>

        <!-- EC2 Auto Scaling Group -->
        <mxCell id="asg" value="Auto Scaling&lt;br&gt;Group"
               style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.auto_scaling2;fillColor=#F58534;gradientColor=none;"
               vertex="1" parent="private-subnet-1a">
          <mxGeometry x="200" y="50" width="78" height="78" as="geometry"/>
        </mxCell>

        <!-- RDS -->
        <mxCell id="rds-primary" value="RDS Primary&lt;br&gt;PostgreSQL"
               style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.rds;fillColor=#3F48CC;gradientColor=none;"
               vertex="1" parent="private-subnet-1a">
          <mxGeometry x="50" y="180" width="78" height="78" as="geometry"/>
        </mxCell>

        <!-- ElastiCache -->
        <mxCell id="elasticache" value="ElastiCache&lt;br&gt;Redis"
               style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.elasticache;fillColor=#3F48CC;gradientColor=none;"
               vertex="1" parent="private-subnet-1a">
          <mxGeometry x="200" y="180" width="78" height="78" as="geometry"/>
        </mxCell>

        <!-- Public Subnet AZ-1b -->
        <mxCell id="public-subnet-1b" value="Public Subnet 1b&lt;br&gt;10.0.2.0/24"
               style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=#7ea6e0;gradientDirection=north;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_availability_zone;strokeColor=#248814;fillColor=#d5e8d4;verticalAlign=top;align=left;spacingLeft=30;fontColor=#248814;dashed=0;"
               vertex="1" parent="vpc-1">
          <mxGeometry x="500" y="50" width="350" height="280" as="geometry"/>
        </mxCell>

        <!-- Private Subnet AZ-1b -->
        <mxCell id="private-subnet-1b" value="Private Subnet 1b&lt;br&gt;10.0.20.0/24"
               style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=#7ea6e0;gradientDirection=north;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_availability_zone;strokeColor=#147EBA;fillColor=#dddddd;verticalAlign=top;align=left;spacingLeft=30;fontColor=#147EBA;dashed=0;"
               vertex="1" parent="vpc-1">
          <mxGeometry x="500" y="380" width="350" height="280" as="geometry"/>
        </mxCell>

        <!-- RDS Read Replica -->
        <mxCell id="rds-replica" value="RDS Read Replica&lt;br&gt;PostgreSQL"
               style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws4.rds;fillColor=#3F48CC;gradientColor=none;"
               vertex="1" parent="private-subnet-1b">
          <mxGeometry x="50" y="180" width="78" height="78" as="geometry"/>
        </mxCell>

        <!-- Region 2: US-West-2 -->
        <mxCell id="region-2" value="&lt;b&gt;AWS US-West-2 (DR)&lt;/b&gt;"
               style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=none;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_region;strokeColor=#FF6B35;fillColor=none;verticalAlign=top;align=left;spacingLeft=30;fontColor=#FF6B35;dashed=0;"
               vertex="1" parent="1">
          <mxGeometry x="1300" y="100" width="800" height="600" as="geometry"/>
        </mxCell>

        <!-- DR VPC -->
        <mxCell id="vpc-dr" value="DR VPC&lt;br&gt;10.1.0.0/16"
               style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=none;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_vpc;strokeColor=#248814;fillColor=none;verticalAlign=top;align=left;spacingLeft=30;fontColor=#248814;dashed=0;"
               vertex="1" parent="region-2">
          <mxGeometry x="50" y="50" width="700" height="500" as="geometry"/>
        </mxCell>

        <!-- Cross-region replication -->
        <mxCell id="cross-region-replication" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=3;strokeColor=#FF6B35;dashed=1;" edge="1" parent="1" source="region-1" target="region-2">
          <mxGeometry relative="1" as="geometry">
            <mxCell id="replication-label" value="Cross-Region&lt;br&gt;Replication" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];fontColor=#FF6B35;fontSize=12;fontStyle=1;" vertex="1" connectable="0" parent="cross-region-replication">
              <mxGeometry x="0.1" y="-1" relative="1" as="geometry">
                <mxPoint as="offset"/>
              </mxGeometry>
            </mxCell>
          </mxGeometry>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

## Performance & Optimization

### Large Diagram Optimization
```xml
<!-- Optimized structure for large diagrams -->
<mxfile host="app.diagrams.net" compressed="true">
  <diagram name="Optimized Large Diagram" id="optimized">
    <mxGraphModel dx="4000" dy="2000" grid="1" gridSize="10" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Use groups for better performance -->
        <mxCell id="infrastructure-group" value="Infrastructure Layer" style="group;fontStyle=1;" vertex="1" collapsed="1" parent="1">
          <mxGeometry x="100" y="100" width="800" height="600" as="geometry"/>
        </mxCell>

        <!-- Lazy loading for complex shapes -->
        <UserObject label="Complex Component" load="lazy" id="complex-component">
          <mxCell style="shape=image;verticalLabelPosition=bottom;aspect=fixed;imageAspect=0;image=data:image/svg+xml,base64,..." vertex="1" parent="infrastructure-group">
            <mxGeometry x="200" y="200" width="100" height="100" as="geometry"/>
          </mxCell>
        </UserObject>

        <!-- Simplified connections for performance -->
        <mxCell id="simplified-edge" style="edgeStyle=straight;html=1;strokeWidth=1;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="300" y="250" as="sourcePoint"/>
            <mxPoint x="500" y="250" as="targetPoint"/>
          </mxGeometry>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Memory Optimization Strategies
```javascript
// Optimize diagram loading
function optimizeDiagramLoading() {
  // Enable diagram compression
  const compressionSettings = {
    enableCompression: true,
    compressionLevel: 6,
    minifyXML: true,
    removeUnusedStyles: true
  };

  // Implement lazy loading for images
  const imageOptimization = {
    lazyLoadImages: true,
    imageQuality: 0.8,
    maxImageSize: 1024,
    useWebP: true
  };

  // Optimize connection rendering
  const connectionOptimization = {
    useSimpleEdges: true,
    limitWaypoints: 10,
    enableEdgeCaching: true
  };

  return {
    ...compressionSettings,
    ...imageOptimization,
    ...connectionOptimization
  };
}

// Performance monitoring
class DiagramPerformanceMonitor {
  constructor() {
    this.metrics = {
      loadTime: 0,
      renderTime: 0,
      memoryUsage: 0,
      elementCount: 0
    };
  }

  startMeasurement(operation) {
    this.startTime = performance.now();
    this.startMemory = performance.memory?.usedJSHeapSize || 0;
  }

  endMeasurement(operation) {
    this.metrics[`${operation}Time`] = performance.now() - this.startTime;
    this.metrics.memoryUsage = (performance.memory?.usedJSHeapSize || 0) - this.startMemory;
  }

  getReport() {
    return {
      performance: this.metrics,
      recommendations: this.generateRecommendations()
    };
  }

  generateRecommendations() {
    const recommendations = [];

    if (this.metrics.loadTime > 5000) {
      recommendations.push("Consider enabling diagram compression");
    }

    if (this.metrics.elementCount > 1000) {
      recommendations.push("Use layers and grouping to improve performance");
    }

    if (this.metrics.memoryUsage > 50 * 1024 * 1024) {
      recommendations.push("Optimize images and reduce diagram complexity");
    }

    return recommendations;
  }
}
```

## Troubleshooting

### Common Issues and Solutions

#### File Corruption Issues
```bash
# Validate XML structure
xmllint --noout diagram.drawio
echo $?  # Should return 0 for valid XML

# Repair corrupted diagrams
python3 << 'EOF'
import xml.etree.ElementTree as ET
import re

def repair_drawio_file(filename):
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()

        # Fix common encoding issues
        content = content.replace('&nbsp;', '&#160;')
        content = re.sub(r'&(?!amp;|lt;|gt;|quot;|apos;|#\d+;|#x[\da-fA-F]+;)', '&amp;', content)

        # Validate and reformat XML
        root = ET.fromstring(content)

        # Write repaired file
        with open(f"{filename}.repaired", 'w', encoding='utf-8') as f:
            f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
            f.write(ET.tostring(root, encoding='unicode'))

        print(f"Repaired file saved as {filename}.repaired")

    except Exception as e:
        print(f"Error repairing file: {e}")

repair_drawio_file('corrupted_diagram.drawio')
EOF
```

#### Performance Debugging
```javascript
// Diagram performance analyzer
function analyzeDiagramPerformance(xmlContent) {
  const parser = new DOMParser();
  const doc = parser.parseFromString(xmlContent, 'text/xml');

  const analysis = {
    fileSize: new Blob([xmlContent]).size,
    elementCount: doc.querySelectorAll('mxCell').length,
    imageCount: doc.querySelectorAll('mxCell[style*="image"]').length,
    connectionCount: doc.querySelectorAll('mxCell[edge="1"]').length,
    layerCount: doc.querySelectorAll('mxCell[style*="group"]').length
  };

  // Performance recommendations
  const recommendations = [];

  if (analysis.fileSize > 5 * 1024 * 1024) {
    recommendations.push("Large file size - consider splitting into multiple diagrams");
  }

  if (analysis.elementCount > 500) {
    recommendations.push("High element count - use layers and grouping");
  }

  if (analysis.imageCount > 50) {
    recommendations.push("Many images - optimize image sizes and formats");
  }

  if (analysis.connectionCount > 200) {
    recommendations.push("Many connections - simplify edge styles");
  }

  return { analysis, recommendations };
}

// Usage
const result = analyzeDiagramPerformance(diagramXML);
console.log('Performance Analysis:', result);
```

#### Export Issues
```bash
# Debug export problems
export DEBUG=drawio-export

# Test different export formats
for format in png svg pdf; do
  echo "Testing $format export..."
  drawio-export --format $format --output "test.$format" diagram.drawio

  if [ $? -eq 0 ]; then
    echo "✓ $format export successful"
  else
    echo "✗ $format export failed"
  fi
done

# Check system requirements
echo "System Information:"
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "Available memory: $(free -h | grep Mem | awk '{print $7}')"
echo "Disk space: $(df -h . | tail -1 | awk '{print $4}')"

# Validate dependencies
npm list drawio-export
npm list @mxgraph/mxgraph
```

#### Integration Problems
```yaml
# Troubleshooting CI/CD integration
name: Debug Diagram Processing
on: [push]

jobs:
  debug:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: System Information
        run: |
          echo "OS: $(uname -a)"
          echo "Node: $(node --version)"
          echo "NPM: $(npm --version)"
          echo "Memory: $(free -h)"
          echo "Disk: $(df -h)"

      - name: Install Dependencies
        run: |
          npm install -g drawio-export
          npm list -g drawio-export

      - name: Test Basic Export
        run: |
          echo '<mxfile><diagram name="Test"><mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/></root></mxGraphModel></diagram></mxfile>' > test.drawio
          drawio-export --format png --output test.png test.drawio
          ls -la test.*

      - name: Test Problematic File
        run: |
          if [ -f "problematic.drawio" ]; then
            echo "Testing problematic file..."
            drawio-export --verbose --format png --output debug.png problematic.drawio || echo "Export failed with code $?"
          fi
```

## Best Practices

### Diagram Organization
```xml
<!-- Well-structured diagram template -->
<mxfile host="app.diagrams.net" modified="2024-01-15T10:30:00.000Z" version="22.1.16">
  <!-- Metadata section -->
  <UserObject label="Diagram Metadata"
             title="System Architecture Overview"
             version="2.1.0"
             author="Architecture Team"
             reviewedBy="Tech Lead"
             lastReview="2024-01-15"
             nextReview="2024-04-15"
             classification="internal"
             tags="architecture,microservices,aws">
  </UserObject>

  <diagram name="System Architecture" id="main">
    <mxGraphModel dx="1422" dy="754" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1169" pageHeight="827">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Legend -->
        <mxCell id="legend" value="&lt;b&gt;Legend&lt;/b&gt;&lt;br&gt;&lt;br&gt;🟢 Active Service&lt;br&gt;🟡 Planned Service&lt;br&gt;🔴 Legacy Service&lt;br&gt;➡️ Synchronous Call&lt;br&gt;⤴️ Asynchronous Event"
               style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f0f0f0;strokeColor=#666666;align=left;verticalAlign=top;spacingLeft=10;spacingTop=10;"
               vertex="1" parent="1">
          <mxGeometry x="50" y="50" width="200" height="150" as="geometry"/>
        </mxCell>

        <!-- Layer 1: Presentation -->
        <mxCell id="presentation-layer" value="Presentation Layer"
               style="swimlane;startSize=20;horizontal=0;fillColor=#e1d5e7;strokeColor=#9673a6;fontStyle=1;"
               vertex="1" parent="1">
          <mxGeometry x="300" y="50" width="800" height="150" as="geometry"/>
        </mxCell>

        <!-- Layer 2: Business Logic -->
        <mxCell id="business-layer" value="Business Logic Layer"
               style="swimlane;startSize=20;horizontal=0;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;"
               vertex="1" parent="1">
          <mxGeometry x="300" y="220" width="800" height="200" as="geometry"/>
        </mxCell>

        <!-- Layer 3: Data Access -->
        <mxCell id="data-layer" value="Data Access Layer"
               style="swimlane;startSize=20;horizontal=0;fillColor=#d5e8d4;strokeColor=#82b366;fontStyle=1;"
               vertex="1" parent="1">
          <mxGeometry x="300" y="440" width="800" height="150" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>

  <!-- Detailed views for each layer -->
  <diagram name="Presentation Layer Details" id="presentation-details">
    <!-- Detailed presentation layer diagram -->
  </diagram>

  <diagram name="Business Logic Details" id="business-details">
    <!-- Detailed business logic diagram -->
  </diagram>

  <diagram name="Data Layer Details" id="data-details">
    <!-- Detailed data layer diagram -->
  </diagram>
</mxfile>
```

### Version Control Integration
```bash
#!/bin/bash
# git-diagram-hooks.sh - Git hooks for diagram management

# Pre-commit hook to export diagrams
export_diagrams_pre_commit() {
  echo "Exporting diagrams before commit..."

  # Find changed .drawio files
  changed_diagrams=$(git diff --cached --name-only --diff-filter=ACM | grep '\.drawio$')

  if [ -n "$changed_diagrams" ]; then
    for diagram in $changed_diagrams; do
      echo "Exporting $diagram..."

      # Export PNG for documentation
      drawio-export --format png --output "${diagram%.drawio}.png" "$diagram"

      # Export SVG for web
      drawio-export --format svg --output "${diagram%.drawio}.svg" "$diagram"

      # Add exported files to commit
      git add "${diagram%.drawio}.png" "${diagram%.drawio}.svg"
    done
  fi
}

# Post-merge hook to validate diagrams
validate_diagrams_post_merge() {
  echo "Validating diagrams after merge..."

  # Find all .drawio files
  find . -name "*.drawio" -type f | while read -r diagram; do
    # Basic XML validation
    if ! xmllint --noout "$diagram" 2>/dev/null; then
      echo "ERROR: Invalid XML in $diagram"
      exit 1
    fi

    # Check for merge conflicts in XML
    if grep -q "<<<<<<< HEAD\|=======" "$diagram"; then
      echo "ERROR: Merge conflicts detected in $diagram"
      exit 1
    fi
  done
}

# Install hooks
if [ "$1" = "install" ]; then
  echo "Installing diagram Git hooks..."

  # Create pre-commit hook
  cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
source "$(git rev-parse --show-toplevel)/scripts/git-diagram-hooks.sh"
export_diagrams_pre_commit
EOF

  # Create post-merge hook
  cat > .git/hooks/post-merge << 'EOF'
#!/bin/bash
source "$(git rev-parse --show-toplevel)/scripts/git-diagram-hooks.sh"
validate_diagrams_post_merge
EOF

  chmod +x .git/hooks/pre-commit .git/hooks/post-merge
  echo "Git hooks installed successfully!"
fi
```

### Documentation Integration
```markdown
<!-- diagram-template.md -->
# Architecture Documentation Template

## System Overview
![System Architecture](diagrams/system-overview.png)

**Source:** [system-overview.drawio](diagrams/system-overview.drawio)
**Last Updated:** 2024-01-15
**Version:** 2.1.0

### Key Components
- **API Gateway**: Routes requests and handles authentication
- **Microservices**: Business logic implementation
- **Message Queue**: Asynchronous communication
- **Database**: Data persistence layer

## API Flow Diagrams

### User Registration Flow
![User Registration](diagrams/user-registration-flow.png)

**Description**: Complete user registration process including validation, email verification, and account activation.

**Source:** [user-registration-flow.drawio](diagrams/user-registration-flow.drawio)

### Payment Processing Flow
![Payment Processing](diagrams/payment-processing-flow.png)

**Description**: Secure payment processing workflow with fraud detection and compliance checks.

**Source:** [payment-processing-flow.drawio](diagrams/payment-processing-flow.drawio)

## Infrastructure Diagrams

### AWS Production Environment
![AWS Production](diagrams/aws-production.png)

**Source:** [aws-production.drawio](diagrams/aws-production.drawio)
**Environment**: Production
**Region**: us-east-1 (primary), us-west-2 (DR)

## Maintenance

### Updating Diagrams
1. Edit the `.drawio` source file using [diagrams.net](https://app.diagrams.net)
2. Export updated PNG/SVG files
3. Update this documentation if structure changes
4. Commit all changes together

### Diagram Standards
- Use consistent color coding (see legend in each diagram)
- Include version information and metadata
- Follow naming conventions: `feature-diagram-type.drawio`
- Maintain both source files and exported images in version control
```

### Collaboration Guidelines
```xml
<!-- Team collaboration template -->
<UserObject label="Collaboration Standards">
  <standards>
    <naming-convention>
      <files>feature-type-version.drawio</files>
      <shapes>descriptive-noun-phrases</shapes>
      <layers>functional-groupings</layers>
    </naming-convention>

    <style-guide>
      <colors>
        <primary>#1976D2</primary>
        <secondary>#388E3C</secondary>
        <accent>#F57C00</accent>
        <error>#D32F2F</error>
        <warning>#FBC02D</warning>
        <success>#388E3C</success>
      </colors>

      <fonts>
        <primary>Helvetica, Arial, sans-serif</primary>
        <monospace>Monaco, Consolas, monospace</monospace>
      </fonts>

      <shapes>
        <services>rounded rectangles with 8px radius</services>
        <databases>cylinder shapes</databases>
        <external-systems>dashed borders</external-systems>
        <user-interfaces>rectangles with user icons</user-interfaces>
      </shapes>
    </style-guide>

    <review-process>
      <creation>Create diagram with metadata and legend</creation>
      <review>Technical lead review required</review>
      <approval>Architecture team approval for system diagrams</approval>
      <updates>Version increment for structural changes</updates>
    </review-process>
  </standards>
</UserObject>
```

## Best For
`enterprise-architecture`, `system-documentation`, `collaborative-design`, `technical-communication`, `process-modeling`, `infrastructure-visualization`, `api-documentation`, `compliance-reporting`, `stakeholder-communication`, `knowledge-transfer`