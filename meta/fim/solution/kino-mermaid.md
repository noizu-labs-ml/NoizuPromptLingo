# Kino.Mermaid

Kino.Mermaid provides Mermaid diagram rendering for Elixir LiveBook notebooks, enabling creation of flowcharts, sequence diagrams, and other visual documentation directly in interactive notebooks.

## Links
- [Hex Package](https://hex.pm/packages/kino_mermaid)
- [GitHub Repository](https://github.com/livebook-dev/kino_mermaid)
- [Mermaid Documentation](https://mermaid.js.org/)
- [LiveBook](https://livebook.dev/)

## Mix Setup
```elixir
{:kino_mermaid, "~> 0.1.0"}
```

## Basic Flowchart Example
```elixir
graph_definition = """
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Process]
    B -->|No| D[Alternative]
    C --> E[End]
    D --> E
"""

Kino.Mermaid.new(graph_definition)
```

## Sequence Diagram Example
```elixir
sequence_diagram = """
sequenceDiagram
    participant User
    participant LiveBook
    participant Kino.Mermaid

    User->>LiveBook: Create cell
    LiveBook->>Kino.Mermaid: Render diagram
    Kino.Mermaid->>User: Display result
"""

Kino.Mermaid.new(sequence_diagram)
```

## Strengths
- **Easy Integration**: Simple setup in LiveBook notebooks
- **Live Rendering**: Interactive diagram updates during development
- **Standard Syntax**: Uses standard Mermaid syntax
- **Documentation Ready**: Perfect for notebook-based documentation
- **No JavaScript**: Pure Elixir integration with LiveBook

## Limitations
- **LiveBook Only**: Limited to LiveBook notebook environment
- **Static Output**: No interactive diagram features
- **Limited Styling**: Basic styling options compared to full Mermaid
- **Elixir Dependency**: Requires Elixir/LiveBook environment

## Best For
- **Technical Documentation**: System architecture and process flows
- **Notebook Presentations**: Interactive technical demonstrations
- **Learning Materials**: Educational content with visual diagrams
- **Prototyping**: Quick diagram creation during development
- **Team Collaboration**: Shared notebook documentation

## NPL-FIM Integration
**Intent**: `visual_documentation` for LiveBook-based diagram rendering
**Syntax**: Standard Mermaid syntax within LiveBook cells
**Output**: Rendered SVG diagrams in notebook interface
**Context**: Elixir development and documentation workflows

```npl
⟪kino_mermaid_integration⟫ ↦ {
  environment: "livebook_notebook",
  syntax: "mermaid_standard",
  output_format: "interactive_svg",
  use_case: "documentation_and_prototyping"
}
```

## Usage Pattern
1. Add dependency to LiveBook notebook
2. Define Mermaid diagram syntax as string
3. Call `Kino.Mermaid.new/1` with diagram definition
4. View rendered diagram in notebook cell output
5. Iterate on diagram design with live updates

Ideal for Elixir developers creating visual documentation and presentations within the LiveBook ecosystem.