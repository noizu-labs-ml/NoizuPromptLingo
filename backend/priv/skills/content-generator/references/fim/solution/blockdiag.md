# Blockdiag
Simple block diagram generator from text descriptions. [Docs](http://blockdiag.com) | [Interactive Demo](http://interactive.blockdiag.com)

## Install/Setup
```bash
# Python installation
pip install blockdiag

# With additional diagram types
pip install blockdiag[pdf]  # PDF support
pip install actdiag         # Activity diagrams
pip install nwdiag          # Network diagrams
pip install seqdiag         # Sequence diagrams
```

## Basic Usage
```blockdiag
blockdiag {
  // Define nodes
  browser [label = "Web Browser"];
  webserver [label = "Web Server"];
  database [label = "Database"];

  // Define relationships
  browser -> webserver [label = "HTTP"];
  webserver -> database [label = "SQL"];

  // Group nodes
  group {
    label = "Backend";
    webserver;
    database;
  }
}
```

## Strengths
- Minimal, intuitive syntax
- Automatic layout and spacing
- Built-in node shapes and styles
- Group and lane support
- Multiple output formats (PNG, SVG, PDF)

## Limitations
- Limited styling customization
- Basic layout algorithms only
- No advanced positioning control
- Limited to block/box diagrams
- Less active development

## Best For
`system-architecture`, `network-topology`, `component-diagrams`, `simple-workflows`, `infrastructure-maps`

## NPL-FIM Integration
```yaml
fim_type: blockdiag
fim_version: 1.0
description: "Block diagram generation from text"
category: architecture
output_formats: [png, svg, pdf]
```