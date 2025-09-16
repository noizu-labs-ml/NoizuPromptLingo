# Draw.io XML Format
XML-based format for diagrams.net (draw.io) with WYSIWYG editing. [Docs](https://www.drawio.com/doc) | [Examples](https://github.com/jgraph/drawio-diagrams)

## Install/Setup
```bash
# VS Code extension
ext install hediet.vscode-drawio

# Desktop app
# Download from https://github.com/jgraph/drawio-desktop/releases

# Web app (no install)
# https://app.diagrams.net

# npm library for programmatic use
npm install drawio-export
```

## Basic Usage
```xml
<mxfile host="app.diagrams.net">
  <diagram name="Flow" id="1">
    <mxGraphModel dx="1422" dy="754" grid="1">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Start node -->
        <mxCell id="2" value="Start" style="ellipse;whiteSpace=wrap;html=1;fillColor=#d5e8d4;" vertex="1" parent="1">
          <mxGeometry x="160" y="80" width="120" height="60" as="geometry"/>
        </mxCell>

        <!-- Process node -->
        <mxCell id="3" value="Process" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#dae8fc;" vertex="1" parent="1">
          <mxGeometry x="160" y="200" width="120" height="60" as="geometry"/>
        </mxCell>

        <!-- Connection -->
        <mxCell id="4" style="edgeStyle=orthogonalEdgeStyle;" edge="1" parent="1" source="2" target="3">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

## Strengths
- Full WYSIWYG editor with drag-and-drop
- Extensive shape libraries (AWS, Azure, UML, etc.)
- Real-time collaboration features
- Export to multiple formats (PNG, SVG, PDF, HTML)
- Version control integration with compressed XML

## Limitations
- XML format not human-readable for direct editing
- Large file sizes for complex diagrams
- Requires GUI for effective editing
- Limited programmatic manipulation options

## Best For
`architecture-diagrams`, `flowcharts`, `network-topology`, `ui-mockups`, `collaborative-design`