# Diagram Generation
UML diagrams, flowcharts, and technical documentation diagrams.
[Documentation](https://mermaid.js.org/intro/)

## WWHW
**What**: Programmatically generating technical diagrams, flowcharts, and UML representations.
**Why**: Automate documentation, ensure consistency, and maintain diagrams as code alongside projects.
**How**: Using Mermaid.js, PlantUML, or SVG generation with NPL-FIM for dynamic diagram creation.
**When**: Software documentation, system design, process flows, architecture documentation.

## When to Use
- Documenting software architecture and system design
- Creating flowcharts for business processes or algorithms
- Generating UML diagrams from code or specifications
- Building interactive process documentation
- Maintaining diagrams as code in version control

## Key Outputs
`svg`, `png`, `mermaid-syntax`, `plantuml-code`

## Quick Example
```mermaid
// Mermaid flowchart with NPL-FIM integration
graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Process A]
    B -->|No| D[Process B]
    C --> E[End]
    D --> E

    classDef startEnd fill:#e1f5fe
    classDef decision fill:#fff3e0
    class A,E startEnd
    class B decision
```

```javascript
// Dynamic diagram generation
const diagramCode = `
sequenceDiagram
    participant Client
    participant API
    participant Database
    Client->>API: Request
    API->>Database: Query
    Database-->>API: Result
    API-->>Client: Response
`;
mermaid.render('diagram', diagramCode);
```

## Extended Reference
- [Mermaid.js Documentation](https://mermaid.js.org/) - Diagrams as code
- [PlantUML](https://plantuml.com/) - UML diagram generator
- [Draw.io Integration](https://www.diagrams.net/doc/) - Programmatic diagram creation
- [Graphviz](https://graphviz.org/) - Graph visualization software
- [Nomnoml](https://nomnoml.com/) - Simple UML diagrams
- [C4 Model](https://c4model.com/) - Software architecture diagrams