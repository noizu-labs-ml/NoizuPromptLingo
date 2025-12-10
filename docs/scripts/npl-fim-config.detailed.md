# npl-fim-config - Detailed Reference

Configuration and query tool for NPL-FIM (Fill-in-the-Middle) agent. Provides solution recommendations, tool-task compatibility queries, and local override management for visualization tasks.

## Synopsis

```bash
npl-fim-config [item] [options]
```

## Environment Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `NPL_FIM_ARTIFACTS` | Output directory for generated artifacts | `./artifacts` |
| `NPL_META` | Base path for metadata files | `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta` |
| `EDITOR` | Editor for `--edit` operations | `vi` |

### Metadata Search Order

The tool searches for FIM metadata in this order:

1. `$NPL_META/fim` (if set)
2. `./.npl/meta/fim` (project)
3. `~/.npl/meta/fim` (user)
4. `/etc/npl/meta/fim` (system)

---

## Command Reference

### Positional Argument

**item**
: Optional identifier in dot notation. Format varies by operation:
- `solution.use-case` - For `--load`, `--style-guide`
- `use-case` - For `--preferred-solution`
- `solution.tool.task` - For `--local` operations
- `scope` - For filtering `--overrides` or `--table`

---

## Query Operations

### --query, -q

Natural language query for solution recommendations. Uses keyword matching against a compatibility matrix.

```bash
npl-fim-config --query "interactive org chart for React website"
```

Output:
```
Recommended solutions for: interactive org chart for React website
--------------------------------------------------
- mermaid: Markdown-based diagram generation
  ✓ Excellent for organizational charts
- d3_js: Data-driven documents for custom visualizations
  ✓ Works well with React
- go_js
```

**Keyword Categories**:

| Keywords | Maps to Use Case |
|:---------|:-----------------|
| org, organization, hierarchy, chart | diagram-generation |
| network, graph, connection, node | network-graphs |
| 3d, three, dimension, webgl | 3d-graphics |
| map, geographic, location, spatial | geospatial-mapping |
| music, note, score, sheet | music-notation |
| math, equation, formula, latex | mathematical-scientific |
| react, component, jsx | Boosts d3_js, plotly_js scores |
| interactive, clickable, dynamic | data-visualization |
| web, website, embed, html | data-visualization |

**Scoring Behavior**:
- Base score: +1 per matching keyword category
- Special boost: "react" adds +2 to d3_js, +1 to plotly_js
- Special boost: "org" + "chart" adds +3 to mermaid, +2 to go_js
- Returns top 5 matches sorted by score

---

### --table

Display the tool-task compatibility matrix. Can be filtered by item.

```bash
# Full matrix
npl-fim-config --table

# Filter by tool (second dot-segment)
npl-fim-config solution.d3_js --table

# Filter by task (third dot-segment)
npl-fim-config solution.*.network-graphs --table
```

Output:
```
NPL-FIM Tool-Task Compatibility Matrix
================================================================================

data-visualization:
  - d3_js: Data-driven documents for custom visualizations
  - plotly_js: Interactive scientific and 3D charts
  - chart_js: Simple, flexible charting library
  - vega-lite
  - matplotlib
  - seaborn
  - apache-echarts
[...]
```

---

### --artifact-path

Print the artifact output directory path.

```bash
npl-fim-config --artifact-path
# Output: ./artifacts
```

---

### --preferred-solution

Get preferred (recommended) solutions for a use case.

```bash
npl-fim-config network-graphs --preferred-solution
```

Output:
```
Preferred solutions for network-graphs:
  - cytoscape_js
  - d3_js
```

**Preferred Solutions Matrix**:

| Use Case | Preferred Solutions |
|:---------|:--------------------|
| data-visualization | plotly_js, d3_js |
| network-graphs | cytoscape_js, d3_js |
| diagram-generation | mermaid, plantuml |
| 3d-graphics | three_js |
| music-notation | vexflow |
| mathematical-scientific | latex, mathjax |
| geospatial-mapping | leaflet_js, mapbox-gl-js |
| prototyping | react, html |

---

### --style-guide

Generate the `npl-load` command for loading a solution's style guide.

```bash
npl-fim-config d3_js.data-visualization --style-guide
# Output: npl-load -s fim.d3_js.data-visualization
```

Requires item in `solution.use-case` format.

---

### --overrides

List local override files. Optionally filter by scope.

```bash
# All overrides
npl-fim-config --overrides

# Filter by scope
npl-fim-config solution --overrides
```

Output:
```
Local overrides for solution:
  - solution/d3_js/charts.local.md
  - solution/mermaid/diagram.local.md
```

---

## Local Override Management

Local overrides customize FIM behavior per-project without modifying system defaults.

### --local

Flag indicating local override operations. Requires `item` argument.

### --edit

Open the local override file in `$EDITOR` (default: vi). Creates the file with a template if it does not exist.

```bash
npl-fim-config solution.mermaid.diagram --local --edit
```

**Template created for new files**:
```markdown
# Local Override: solution.mermaid.diagram

## Additional Instructions

## Corrections
```

---

### --patch

Append content to an existing local override file. Creates the file if it does not exist.

```bash
npl-fim-config solution.d3_js.charts --local --patch \
  --prompt "## Custom Settings\nPrefer dark theme."
```

Appends with a patch marker:
```markdown
<!-- PATCH: username -->
## Custom Settings
Prefer dark theme.
```

---

### --replace

Replace (overwrite) the local override file.

```bash
npl-fim-config solution.plotly.defaults --local --replace \
  --prompt-file my-plotly-config.md
```

---

### --prompt

Inline content for `--patch` or `--replace` operations.

```bash
npl-fim-config item --local --patch --prompt "Content here"
```

---

### --prompt-file

Path to file containing content for `--patch` or `--replace` operations.

```bash
npl-fim-config item --local --replace --prompt-file ./override-content.md
```

---

### Local Override File Structure

Override files are stored in `./.npl/meta/fim/` with `.local.md` extension.

**Item to path conversion**:
- `solution.tool.use-case.task` becomes `solution/tool/use-case/task.local.md`
- `single-item` becomes `single-item.local.md`

**Directory structure example**:
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

---

## Delegation to npl-load

### --load [ENTRY]

Delegate to `npl-load` for loading FIM metadata entries.

**With explicit entry**:
```bash
npl-fim-config --load "fim.solution.mermaid"
```

Executes:
```bash
npl-load m fim.solution.mermaid
```

**With comma/space-separated entries**:
```bash
npl-fim-config --load "fim.solution.d3_js, fim.use-case.charts"
```

Executes:
```bash
npl-load m fim.solution.d3_js m fim.use-case.charts
```

**Derived from item** (when ENTRY omitted):
```bash
npl-fim-config d3_js.data-visualization --load
```

Derives and loads:
```bash
npl-load m fim.solution.d3_js m fim.use-case.data-visualization m fim.solution.d3_js.use-case.data-visualization
```

**Derivation rules**:

| Item Pattern | Derived Entries |
|:-------------|:----------------|
| `single` | `fim.solution.single`, `fim.use-case.single` |
| `solution.use-case` | `fim.solution.<solution>`, `fim.use-case.<use-case>`, `fim.solution.<solution>.use-case.<use-case>` |
| `a.b.c.d...` | All above plus `fim.solution.a.use-case.b.c`, `fim.solution.a.use-case.b.c.d`, etc. |

---

### --verbose, -v

Forward verbose flag to `npl-load`.

```bash
npl-fim-config d3_js.charts --load --verbose
```

---

### --skip

Forward `--skip` flag to `npl-load` for tracking loaded items.

```bash
npl-fim-config d3_js.charts --load --skip "fim.solution.d3_js"
```

---

## Tool-Task Compatibility Matrix

### Use Cases

| Category | Description |
|:---------|:------------|
| data-visualization | Charts, graphs, data displays |
| network-graphs | Node-edge visualizations, network diagrams |
| diagram-generation | UML, flowcharts, structural diagrams |
| 3d-graphics | WebGL and 3D rendering |
| music-notation | Sheet music and score rendering |
| mathematical-scientific | Equations, formulas, scientific visualizations |
| geospatial-mapping | Maps and geographic data |
| prototyping | UI components and web interfaces |

### Tools by Category

| Category | Tools |
|:---------|:------|
| data-visualization | d3_js, plotly_js, chart_js, vega-lite, matplotlib, seaborn, apache-echarts |
| network-graphs | cytoscape_js, d3_js, sigma_js, vis_js, networkx, graphviz |
| diagram-generation | mermaid, plantuml, graphviz, drawio-xml, nomnoml, yuml |
| 3d-graphics | three_js, babylon_js, a-frame, vtk_js, cesium_js |
| music-notation | vexflow, osmd, abcjs, lilypond, alphatab |
| mathematical-scientific | latex, mathjax, katex, tikz-pgf, matplotlib, sympy |
| geospatial-mapping | leaflet_js, mapbox-gl-js, deck_gl, cesium_js, folium |
| prototyping | react, vue, html, tailwind, bootstrap |

### Tool Descriptions

| Tool | Description |
|:-----|:------------|
| d3_js | Data-driven documents for custom visualizations |
| plotly_js | Interactive scientific and 3D charts |
| chart_js | Simple, flexible charting library |
| mermaid | Markdown-based diagram generation |
| plantuml | Text-based UML diagrams |
| three_js | JavaScript 3D graphics library |
| cytoscape_js | Graph/network visualization |
| vexflow | Music notation rendering |
| leaflet_js | Mobile-friendly interactive maps |
| latex | Professional typesetting system |

---

## Exit Codes

| Code | Meaning |
|:-----|:--------|
| 0 | Success |
| 1 | Invalid arguments or missing required content |
| 2 | Invalid item specification for --load |
| 127 | npl-load not found in PATH |

---

## Examples

### Solution Discovery Workflow

```bash
# 1. Query for recommendations
npl-fim-config --query "network visualization with clustering"

# 2. Check preferred solution
npl-fim-config network-graphs --preferred-solution

# 3. Get style guide command
npl-fim-config cytoscape_js.network-graphs --style-guide

# 4. Load the metadata
npl-fim-config cytoscape_js.network-graphs --load --verbose
```

### Project Customization Workflow

```bash
# 1. List current overrides
npl-fim-config --overrides

# 2. Create/edit override for mermaid diagrams
npl-fim-config solution.mermaid.diagrams --local --edit

# 3. Patch additional instructions
npl-fim-config solution.mermaid.diagrams --local --patch \
  --prompt "## Theme\nUse dark theme for all diagrams."

# 4. Replace with complete configuration
npl-fim-config solution.mermaid.diagrams --local --replace \
  --prompt-file project-mermaid-config.md
```

### Integration with npl-load

```bash
# Load solution metadata directly
npl-fim-config --load "fim.solution.d3_js"

# Load derived entries from item
npl-fim-config plotly_js.data-visualization --load

# Load with skip tracking
npl-fim-config d3_js.charts --load --skip "fim.solution.d3_js"
```

---

## Implementation Notes

### Query Algorithm

The `--query` option uses a keyword-based scoring algorithm:

1. Parse query into lowercase tokens
2. Match tokens against predefined keyword categories
3. Map matched categories to use cases
4. Add all tools from matched use cases to score map
5. Apply special scoring boosts (React compatibility, org chart detection)
6. Sort by score descending and return top 5

### Local Override Resolution

The `find_local_override` method:

1. Converts dot notation to path segments
2. Appends `.local.md` extension
3. Checks `./.npl/meta/fim/` first (project-local)
4. Returns path if found, None otherwise

### --load Entry Derivation

When `--load` is called without explicit ENTRY:

1. Strip `fim.` prefix if present
2. Split by `.` into parts
3. If single part: return both `fim.solution.<part>` and `fim.use-case.<part>`
4. If two+ parts: build chain of increasingly specific entries

---

## Limitations

1. **Keyword matching only**: The `--query` feature uses simple keyword matching, not semantic understanding
2. **Static compatibility matrix**: Tool-task mappings are hardcoded; extend via local overrides
3. **No tool descriptions for all tools**: Only 10 tools have descriptions; others show generic text
4. **Single project scope**: Local overrides only checked in `./.npl/meta/fim/`, not in user/system paths
5. **--skip argument handling**: The `--skip` flag is passed to npl-load but `args.skip` is boolean, causing incorrect behavior (passes `True` instead of skip list)

---

## See Also

- [npl-fim-config.md](./npl-fim-config.md) - Quick reference
- [npl-load](./npl-load.md) - NPL component loader
- [NPL-FIM Agent](../agents/npl-fim.md) - FIM agent definition
