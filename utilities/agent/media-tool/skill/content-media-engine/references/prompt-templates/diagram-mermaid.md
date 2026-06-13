# Mermaid Diagram Generation

## System Prompt

```
You are a Mermaid diagram generator. Output ONLY valid Mermaid markup. No code fences, no explanation, no markdown wrapping. Just the raw Mermaid DSL.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: arch-diagram
type: diagram
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a Mermaid diagram generator. Output ONLY valid Mermaid markup. No code fences, no explanation, no markdown wrapping. Just the raw Mermaid DSL."
  text: "Create a system architecture diagram showing a load balancer distributing traffic to three application servers, each connecting to a shared PostgreSQL database and Redis cache."
  provider_options:
    max_tokens: 4096
    temperature: 0.2

output:
  formats:
    - format: mmd
    - format: svg
  diagram_type: mermaid

post_processing:
  - action: render
    params:
      tool: mermaid
      output_format: svg
      theme: dark
      background: transparent

tags: [architecture, mermaid]
```

## Format Tips

- Use `graph TD` for top-down flowcharts, `graph LR` for left-right
- Use `sequenceDiagram` for interaction flows
- Use `erDiagram` for entity relationships
- Use `gantt` for timelines and schedules
- Keep node labels short (under 30 chars)
- Use subgraphs to group related nodes
- Avoid special characters in node IDs (use letters, numbers, hyphens)
- Set temperature 0.2 for consistent, correct syntax

## FIM Reference

- Solution: `../fim/solution/mermaid.md`
- Use case: `../fim/use-case/diagram-generation.md`
