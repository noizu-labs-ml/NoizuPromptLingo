# npl-fim

Fill-in-the-middle code generation agent for visualizations and artifacts across 150+ frameworks.

**Detailed reference**: [npl-fim.detailed.md](npl-fim.detailed.md)

## Purpose

Transforms natural language into implementation-ready code for data visualizations, diagrams, 3D graphics, and creative animations. Loads framework-specific metadata before generation to ensure correct output patterns.

## Capabilities

| Category | Frameworks | Details |
|:---------|:-----------|:--------|
| Data Visualization | D3.js, Chart.js, Plotly.js, Vega-Lite | [Framework Categories](npl-fim.detailed.md#data-visualization) |
| Network Graphs | Cytoscape.js, Sigma.js, GO.js | [Network Graphs](npl-fim.detailed.md#network-graphs) |
| Diagram Generation | Mermaid, PlantUML, Graphviz | [Diagram Generation](npl-fim.detailed.md#diagram-generation) |
| 3D Graphics | Three.js, Babylon.js, A-Frame | [3D Graphics](npl-fim.detailed.md#3d-graphics) |
| Music Notation | VexFlow, OSMD, LilyPond | [Music Notation](npl-fim.detailed.md#music-notation) |
| Mathematical/Scientific | LaTeX/TikZ, MathJax, Matplotlib | [Mathematical/Scientific](npl-fim.detailed.md#mathematicalscientific) |
| Geospatial Mapping | Leaflet, Mapbox GL, Deck.gl | [Geospatial Mapping](npl-fim.detailed.md#geospatial-mapping) |

## Quick Start

```bash
# Load metadata then generate
npl-fim-config d3_js.network.graph --load
@npl-fim "create a force-directed network diagram"

# Chart visualization
@npl-fim "bar chart showing quarterly revenue" --library=chart_js

# 3D scene
@npl-fim "particle system with 10K points" --library=three_js

# Query for tool recommendations
npl-fim-config --query "interactive org chart for React"
```

See [Commands Reference](npl-fim.detailed.md#commands-reference) for all options.

## Output Structure

```
{artifact-path}/{slug}/
  fml.md        # Implementation plan
  index.html    # Generated artifact
  review.md     # Validation notes
```

See [Output Structure](npl-fim.detailed.md#output-structure) for details.

## Configuration

| Variable | Default | Description |
|:---------|:--------|:------------|
| `NPL_FIM_ARTIFACTS` | `./artifacts` | Output directory |
| `NPL_META` | (search paths) | Metadata location |

See [Configuration Options](npl-fim.detailed.md#configuration-options) for complete list.

## Integration

```bash
# Chain with grader for quality check
@npl-fim "D3 network viz" && @grader evaluate output.html

# Use thinker for complex requirements
@npl-thinker "analyze data structure" && @npl-fim create --guided

# Template reuse
@npl-templater "convert to template" && @npl-fim --apply="my-template"
```

See [Integration Patterns](npl-fim.detailed.md#integration-patterns) for more examples.

## See Also

- [Best Practices](npl-fim.detailed.md#best-practices)
- [Limitations](npl-fim.detailed.md#limitations)
- [Response Process](npl-fim.detailed.md#response-process)
- Core definition: `core/agents/npl-fim.md`
- Framework metadata: `npl-fim-config --list`
