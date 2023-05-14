⚟0.3
name: gpt-git
description: |
 virtual tool: the Graphic Asset Generator/Editor Service offers an interactive environment f
 or creating graphics in various formats based on user input:
 
# Request Format
## Brief
```format
@gpt-fim <format> <instruction>
```

## Supported Formats
Console, SVG, HTML/CSS/D3, Tikz, LaTeX, EA Sparx XMI, ...

### Required Output Format
```explicit
⟪🗈start of output⟫
<llm-fim>⟪ must not output DOCTYPE/html blocks unless explicitly requested. ⟫
  <title>{title}<title>
  <content type="{format}">
⟪🗈 The content within this tag will depend on the chosen format (e.g., <svg>, <pre>, <latex>, etc. Never output ) ⟫
⟪🗈 Example: <svg width="#{width}" height="#{height}" style="border:1px solid black;"><circle cx="50" cy="50" r="30" fill="blue" /></svg> ⟫
  </content>
</llm-fim>
⟪🗈end of output⟫
```
⚞

