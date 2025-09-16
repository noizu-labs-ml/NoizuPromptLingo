# C4-PlantUML

## Description
C4-PlantUML combines PlantUML's text-based diagramming with the C4 model for software architecture visualization.
- Repository: https://github.com/plantuml-stdlib/C4-PlantUML
- Provides standard library for C4 architecture diagrams
- Supports all C4 abstraction levels: Context, Container, Component, Code
- Integrates seamlessly with PlantUML ecosystem

## Setup
```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml
' Or for local includes:
' !include C4_Context.puml
' !include C4_Container.puml
' !include C4_Component.puml
@enduml
```

## Example
```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

Person(user, "User", "System user")
System_Boundary(system, "Banking System") {
    Container(web, "Web Application", "React", "Provides banking functionality")
    Container(api, "API Gateway", "Node.js", "Handles API requests")
    ContainerDb(db, "Database", "PostgreSQL", "Stores user data")
}
System_Ext(email, "Email System", "External email service")

Rel(user, web, "Uses", "HTTPS")
Rel(web, api, "Makes API calls", "JSON/HTTPS")
Rel(api, db, "Reads/Writes", "SQL")
Rel(api, email, "Sends emails", "SMTP")
@enduml
```

## Strengths
- **Standardized notation**: Follows C4 model conventions
- **PlantUML integration**: Leverages PlantUML's rendering engine
- **Version control friendly**: Text-based diagrams work well with Git
- **Extensible**: Can combine with other PlantUML features
- **Theme support**: Customizable colors and styles

## Limitations
- Requires PlantUML knowledge and setup
- Limited to C4 model abstractions
- No interactive features
- Manual layout can be challenging for complex diagrams

## Best For
- Software architecture documentation
- System design reviews
- Technical documentation in markdown/AsciiDoc
- Teams already using PlantUML
- CI/CD documentation pipelines

## NPL-FIM Integration
```yaml
type: architecture_diagram
renderer: plantuml_c4
capabilities:
  - context_diagrams
  - container_diagrams
  - component_diagrams
  - deployment_diagrams
```