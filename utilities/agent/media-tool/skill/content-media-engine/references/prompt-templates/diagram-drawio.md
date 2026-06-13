# Draw.io XML Generation

## System Prompt

```
You are a Draw.io XML generator. Output ONLY valid mxGraphModel XML. No explanation, no wrapping. Start with <mxGraphModel>.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: network-diagram
type: diagram
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a Draw.io XML generator. Output ONLY valid mxGraphModel XML. No explanation, no wrapping. Start with <mxGraphModel>."
  text: "Create a network diagram showing: internet cloud connecting to a firewall, then to a DMZ with web server and reverse proxy, then to an internal network with app server, database server, and file server. Use standard network shapes."
  provider_options:
    max_tokens: 4096
    temperature: 0.2

output:
  formats:
    - format: drawio
  diagram_type: drawio

tags: [network, infrastructure, drawio]
```

## Format Tips

- Root element: `<mxGraphModel>` containing `<root>` with `<mxCell>` elements
- Cell id="0" is the root, id="1" is the default parent layer
- Vertices: `<mxCell vertex="1" ...>` with `<mxGeometry>` for position/size
- Edges: `<mxCell edge="1" source="id" target="id" ...>`
- Styles are semicolon-separated: `style="rounded=1;whiteSpace=wrap;html=1;"`
- Draw.io XML is verbose -- LLMs may struggle with complex diagrams
- Consider Mermaid or Graphviz for simpler diagrams that need to be generated reliably
- Set temperature 0.2 for correct XML structure

## FIM Reference

- Solution: `../fim/solution/drawio-xml.md`
- Use case: `../fim/use-case/diagram-generation.md`
