# npl-fim-config

**Type**: Script
**Category**: scripts
**Status**: Utility

## Purpose

`npl-fim-config` is a configuration and query tool for the NPL-FIM (Fill-in-the-Middle) agent that helps select appropriate visualization tools for specific tasks. It manages a tool-task compatibility matrix, provides natural language querying capabilities, handles local project overrides, and delegates to `npl-load` for loading FIM metadata. The script enables developers to quickly discover which visualization libraries (D3.js, Plotly, Mermaid, etc.) are best suited for tasks like data visualization, network graphs, diagrams, or 3D graphics.

The tool operates across a hierarchical metadata system (project → user → system) and supports project-specific customization through local override files without modifying system defaults.

## Key Capabilities

- **Natural language tool discovery** - Query compatibility matrix using plain English descriptions
- **Tool-task compatibility matrix** - Maintains mappings between 40+ tools and 8 use case categories
- **Preferred solution recommendations** - Returns ranked recommendations per use case
- **Local override management** - Create, edit, patch, or replace project-specific configurations
- **Metadata delegation** - Seamlessly delegates to `npl-load` for loading FIM metadata entries
- **Artifact path management** - Configures output directories for generated visualizations

## Usage & Integration

**Triggered by**: NPL-FIM agent when selecting visualization tools; developers during discovery or configuration
**Outputs to**: Console (recommendations, paths, commands); local override files in `.npl/meta/fim/`
**Complements**: `npl-load` (metadata loading), NPL-FIM agent (visualization generation)

## Core Operations

### Query for tools
```bash
npl-fim-config --query "interactive org chart for React"
```

### Get preferred solutions
```bash
npl-fim-config network-graphs --preferred-solution
```

### Generate style guide command
```bash
npl-fim-config d3_js.data-visualization --style-guide
# Output: npl-load -s fim.d3_js.data-visualization
```

### Load FIM metadata
```bash
npl-fim-config d3_js.charts --load --verbose
```

### Manage local overrides
```bash
npl-fim-config solution.mermaid.diagram --local --edit
npl-fim-config solution.d3_js.charts --local --patch --prompt "Use dark theme"
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `NPL_FIM_ARTIFACTS` | Artifact output directory | `./artifacts` | Where generated visuals are saved |
| `NPL_META` | Metadata search path | `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta` | Hierarchical resolution |
| `EDITOR` | Editor for `--edit` | `vi` | Used for interactive override editing |
| `--query <text>` | Natural language query | - | Keyword-based scoring algorithm |
| `--load [ENTRY]` | Delegate to npl-load | - | Derives entries from item if ENTRY omitted |
| `--local` | Enable override mode | - | Requires item argument |

## Integration Points

- **Upstream dependencies**: NPL-FIM agent planning phase; requires `npl-load` in PATH for `--load` operations
- **Downstream consumers**: NPL-FIM agent uses query results to select tools; `npl-load` processes delegated metadata loads
- **Related utilities**: `npl-load` (metadata loader), `npl-persona` (persona definitions), `dump-files` (codebase exploration)

## Tool-Task Compatibility Matrix

| Use Case | Preferred Tools | All Tools |
|----------|-----------------|-----------|
| data-visualization | plotly_js, d3_js | chart_js, vega-lite, matplotlib, seaborn, apache-echarts |
| network-graphs | cytoscape_js, d3_js | sigma_js, vis_js, networkx, graphviz |
| diagram-generation | mermaid, plantuml | graphviz, drawio-xml, nomnoml, yuml |
| 3d-graphics | three_js | babylon_js, a-frame, vtk_js, cesium_js |
| music-notation | vexflow | osmd, abcjs, lilypond, alphatab |
| mathematical-scientific | latex, mathjax | katex, tikz-pgf, matplotlib, sympy |
| geospatial-mapping | leaflet_js, mapbox-gl-js | deck_gl, cesium_js, folium |
| prototyping | react, html | vue, tailwind, bootstrap |

## Limitations & Constraints

- Keyword matching only (not semantic understanding) - queries rely on predefined keyword categories
- Static compatibility matrix - tool mappings are hardcoded; extend via local overrides
- Project-local overrides only - checks `./.npl/meta/fim/` but not user/system paths for overrides
- `--skip` flag behavior issue - passes boolean `True` to npl-load instead of skip list
- Limited tool descriptions - only 10 tools have detailed descriptions; others show generic text

## Success Indicators

- Query returns relevant tools ranked by score
- `--load` successfully delegates to npl-load with correct entry paths
- Local overrides created/edited without errors and persist across sessions
- Exit code 0 for successful operations; non-zero codes map to specific error conditions

---
**Generated from**: worktrees/main/docs/scripts/npl-fim-config.md, worktrees/main/docs/scripts/npl-fim-config.detailed.md
