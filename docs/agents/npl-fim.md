# npl-fim

Fill-in-the-middle code generation agent for visualizations and artifacts across 150+ frameworks.

## Purpose

Generates implementation-ready code for data visualizations, diagrams, charts, 3D graphics, and creative animations. Loads framework-specific metadata before generation to ensure correct output patterns.

## Capabilities

- Data visualization (D3.js, Chart.js, Plotly.js, Vega/Vega-Lite)
- Network graphs (Cytoscape.js, Sigma.js, GO.js)
- Diagram generation (Mermaid, PlantUML, Graphviz)
- 3D graphics (Three.js, Babylon.js, A-Frame)
- Creative coding (P5.js, Paper.js)
- Music notation, LaTeX/TikZ, geospatial mapping

## Usage

```bash
# Load metadata then generate
npl-fim-config d3_js.network.graph
@npl-fim "create a force-directed network diagram"

# Chart visualization
@npl-fim "bar chart showing quarterly revenue" --library=chart

# 3D scene
@npl-fim "particle system with 10K points" --library=three
```

Output goes to artifact directory with structure:
```
{artifact-path}/{slug}/
  fml.md        # implementation plan
  index.html    # generated artifact
  review.md     # validation notes
```

## Workflow Integration

```bash
# Chain with grader for quality check
@npl-fim "D3 network viz" && @npl-grader evaluate output.html

# Use thinker for complex requirements
@npl-thinker "analyze data structure" && @npl-fim create --guided

# Template reuse
@npl-templater "convert to template" && @npl-fim --apply="my-template"
```

## See Also

- Core definition: `core/agents/npl-fim.md`
- Framework metadata: `npl-fim-config --list`
