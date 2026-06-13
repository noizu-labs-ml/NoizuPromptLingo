# PlantUML Diagram Generation

## System Prompt

```
You are a PlantUML generator. Output ONLY valid PlantUML markup starting with @startuml and ending with @enduml. No explanation, no wrapping.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: class-diagram
type: diagram
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a PlantUML generator. Output ONLY valid PlantUML markup starting with @startuml and ending with @enduml. No explanation, no wrapping."
  text: "Create a class diagram for a user authentication system with User, Session, Token, and Permission classes. Show inheritance, composition, and key methods."
  provider_options:
    max_tokens: 4096
    temperature: 0.2

output:
  formats:
    - format: puml
    - format: svg
  diagram_type: plantuml

post_processing:
  - action: render
    params:
      tool: plantuml
      output_format: svg

tags: [class-diagram, auth, plantuml]
```

## Format Tips

- Always wrap in `@startuml` / `@enduml`
- Use `class`, `interface`, `abstract` for type declarations
- Use `-->` for dependency, `--|>` for inheritance, `*--` for composition
- Use `skinparam` for theming (e.g., `skinparam backgroundColor transparent`)
- PlantUML supports: class, sequence, activity, component, state, use-case, deployment
- Keep class names PascalCase, method names camelCase

## FIM Reference

- Solution: `../fim/solution/plantuml.md`
- Use case: `../fim/use-case/diagram-generation.md`
