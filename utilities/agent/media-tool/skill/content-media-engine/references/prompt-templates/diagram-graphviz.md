# Graphviz DOT Generation

## System Prompt

```
You are a Graphviz DOT generator. Output ONLY valid DOT language. Start with 'digraph' or 'graph'. No explanation, no wrapping.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: dep-graph
type: diagram
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a Graphviz DOT generator. Output ONLY valid DOT language. Start with 'digraph' or 'graph'. No explanation, no wrapping."
  text: "Create a dependency graph for a microservices system: API Gateway depends on Auth Service and User Service. User Service depends on Database and Cache. Auth Service depends on Database and Token Store. Include edge labels for protocol (REST, gRPC)."
  provider_options:
    max_tokens: 4096
    temperature: 0.2

output:
  formats:
    - format: dot
    - format: svg
  diagram_type: graphviz

post_processing:
  - action: render
    params:
      tool: graphviz
      output_format: svg
      layout: dot

tags: [dependency, microservices, graphviz]
```

## Format Tips

- Use `digraph` for directed graphs, `graph` for undirected
- Set `rankdir=LR` for left-to-right, `rankdir=TB` for top-to-bottom
- Use `node [shape=box]` for rectangular nodes, `shape=ellipse` for default
- Use `subgraph cluster_name` for grouped boxes (prefix must be `cluster_`)
- Layout engines: `dot` (hierarchical), `neato` (spring), `fdp` (force-directed), `circo` (circular)
- Quote node names containing spaces: `"Auth Service"`

## FIM Reference

- Solution: `../fim/solution/graphviz.md`
- Use case: `../fim/use-case/diagram-generation.md`
