# Structurizr DSL

Text-based domain-specific language for creating C4 model software architecture diagrams.

## Description
[Structurizr DSL](https://structurizr.com/dsl) provides a way to create software architecture diagrams using the C4 model (Context, Containers, Components, Code) through text definitions. It enables version-controlled, collaborative architecture documentation.

## Installation
```bash
# CLI installation
npm install -g structurizr-cli

# Docker
docker pull structurizr/cli
docker run -v $(pwd):/workspace structurizr/cli export -workspace workspace.dsl -format plantuml
```

## Basic Example
```dsl
workspace "System Architecture" {
    model {
        user = person "User" "End user of the system"

        softwareSystem = softwareSystem "Software System" {
            webapp = container "Web Application" "React" {
                tags "Web Browser"
            }
            api = container "API" "Node.js/Express"
            database = container "Database" "PostgreSQL"
        }

        user -> webapp "Uses"
        webapp -> api "Makes API calls"
        api -> database "Reads/writes"
    }

    views {
        systemContext softwareSystem {
            include *
            autolayout lr
        }

        container softwareSystem {
            include *
            autolayout tb
        }
    }
}
```

## Strengths
- **C4 Model Native**: Built specifically for C4 architecture diagrams
- **Version Control**: Text-based format works perfectly with Git
- **Multiple Exports**: Generate PlantUML, Mermaid, or web visualizations
- **Consistency**: Enforces architectural standards across diagrams
- **Documentation**: Integrates descriptions and documentation

## Limitations
- **Learning Curve**: Requires understanding C4 model concepts
- **Paid Hosting**: Cloud workspace requires subscription for teams
- **Diagram Types**: Focused on software architecture, not general diagrams

## Best For
- Software architecture documentation
- C4 model diagrams (Context, Container, Component, Code)
- Version-controlled architecture decisions
- Teams needing consistent architecture diagrams
- Architecture-as-code workflows

## NPL-FIM Integration
```npl
@external-visualization structurizr
  type: "architecture"
  format: "dsl"
  exports: ["plantuml", "mermaid", "json"]
  c4-levels: ["context", "container", "component", "code"]
  version-control: true