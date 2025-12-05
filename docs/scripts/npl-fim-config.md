# npl-fim-config

A configuration and query tool for the NPL-FIM (Fill-in-the-Middle) agent, providing solution recommendations and local override management for visualization tasks.

## Synopsis

```bash
npl-fim-config [item] [options]
```

## Description

`npl-fim-config` helps select appropriate visualization tools for different use cases, manage local override configurations, and query the tool-task compatibility matrix. It integrates with `npl-load` for loading FIM-related metadata.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NPL_FIM_ARTIFACTS` | Output directory for generated artifacts | `./artifacts` |
| `NPL_META` | Path for metadata files | `./.npl/meta/fim` |

## Commands and Options

### Query Operations

| Option | Description |
|--------|-------------|
| `--query`, `-q` | Natural language query for solution recommendations |
| `--table` | Display the tool-task compatibility matrix |
| `--artifact-path` | Show the artifact output directory |
| `--preferred-solution` | Get preferred solutions for a use case |
| `--style-guide` | Get style guide command for a solution.use-case |
| `--overrides` | List local override files |

### Local Override Management

| Option | Description |
|--------|-------------|
| `--local` | Work with local overrides (requires `item`) |
| `--patch` | Patch (append to) local override file |
| `--replace` | Replace local override file |
| `--edit` | Open local override in editor |
| `--prompt` | Content for patch/replace operation |
| `--prompt-file` | File containing content for patch/replace |

### Delegation Options

| Option | Description |
|--------|-------------|
| `--load [ENTRY]` | Delegate to `npl-load` with derived entries |
| `--verbose`, `-v` | Enable verbose output (forwarded to npl-load) |
| `--skip` | Forward --skip flag to npl-load |

## Tool-Task Categories

### Supported Use Cases

| Category | Description |
|----------|-------------|
| `data-visualization` | Charts, graphs, and data displays |
| `network-graphs` | Node-edge visualizations and network diagrams |
| `diagram-generation` | UML, flowcharts, and structural diagrams |
| `3d-graphics` | WebGL and 3D rendering |
| `music-notation` | Sheet music and score rendering |
| `mathematical-scientific` | Equations, formulas, and scientific visualizations |
| `geospatial-mapping` | Maps and geographic data |
| `prototyping` | UI components and web interfaces |

### Recommended Tools by Category

| Category | Tools |
|----------|-------|
| data-visualization | d3_js, plotly_js, chart_js, vega-lite |
| network-graphs | cytoscape_js, d3_js, sigma_js, vis_js |
| diagram-generation | mermaid, plantuml, graphviz |
| 3d-graphics | three_js, babylon_js, a-frame |
| music-notation | vexflow, osmd, abcjs |
| mathematical-scientific | latex, mathjax, katex |
| geospatial-mapping | leaflet_js, mapbox-gl-js, deck_gl |
| prototyping | react, vue, html, tailwind |

## Examples

### Query for Solution Recommendations

```bash
# Natural language query
npl-fim-config --query "interactive org chart for React website"

# Output:
# Recommended solutions for: interactive org chart for React website
# --------------------------------------------------
# - mermaid: Markdown-based diagram generation
#   ✓ Excellent for organizational charts
# - d3_js: Data-driven documents for custom visualizations
#   ✓ Works well with React
```

### Display Compatibility Matrix

```bash
# Show full matrix
npl-fim-config --table

# Filter by use case
npl-fim-config diagram-generation --table
```

### Get Preferred Solutions

```bash
npl-fim-config network-graphs --preferred-solution
# Output:
# Preferred solutions for network-graphs:
#   - cytoscape_js
#   - d3_js
```

### Get Style Guide Command

```bash
npl-fim-config d3_js.data-visualization --style-guide
# Output: npl-load -s fim.d3_js.data-visualization
```

### Work with Local Overrides

```bash
# List all local overrides
npl-fim-config --overrides

# List overrides for specific scope
npl-fim-config solution --overrides

# Edit a local override (opens in $EDITOR)
npl-fim-config solution.mermaid.diagram --local --edit

# Patch an existing override
npl-fim-config solution.d3_js.charts --local --patch \
  --prompt "## Custom Settings\nPrefer dark theme for all charts."

# Replace an override
npl-fim-config solution.plotly.defaults --local --replace \
  --prompt-file my-plotly-config.md
```

### Delegate to npl-load

```bash
# Load FIM metadata for a solution
npl-fim-config d3_js.data-visualization --load

# Load with explicit entry
npl-fim-config --load "fim.solution.mermaid"

# Load with verbose output
npl-fim-config d3_js.charts --load --verbose
```

## Local Override Structure

Local overrides allow project-specific customization of FIM behavior without modifying system defaults.

### File Location

Overrides are stored in `./.npl/meta/fim/` with `.local.md` extension:

```
.npl/meta/fim/
├── solution/
│   ├── d3_js/
│   │   └── charts.local.md
│   └── mermaid/
│       └── diagram.local.md
└── use-case/
    └── data-visualization.local.md
```

### Override Template

When editing a new override, the following template is created:

```markdown
# Local Override: <item>

## Additional Instructions

## Corrections
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Invalid arguments or missing required content |
| 2 | Invalid item specification |
| 127 | npl-load not found in PATH |

## See Also

- [npl-load](./npl-load.md) - Load NPL components, metadata, and style guides
- [NPL-FIM Agent](../agents/npl-fim.md) - FIM agent definition
