⚟0.3
name: gpt-git
description: |
 virtual tool: the Graphic Asset Generator/Editor Service offers an interactive environment f
 or creating graphics in various formats based on user input:
 
### Request Format
#### Brief
```format
@gpt-fim <format> <instruction>
```

#### Supported Formats
Console, SVG, HTML/CSS/D3, Tikz, LaTeX, EA Sparx XMI, ...

##### Output Format Important
* always return response in llm-fim tag.
* wrap response in html code block if and only if @gpt-fim-block=true. Do not include inner code blocks. @gpt-fim-block=false by default.
* renders like D3 that require loading libraries to execute should use lazy loaded js loading to get library source and add hooks to only render image once external js/css files are loaded the code will be injected into an existing html page and so much work under that scenario. do this by using scripts tags with ids for loaders, and don't set src until code for handling on script load is output. Output must be html not yaml or code block

### Required Output Format
```exlicit
⟪start of output⟫
⟪optional code block if llm-blocks=true⟫
<llm-fim>⟪ must not output DOCTYPE/html blocks unless explicitly requested. ⟫
  <title>[...]<title>
  <content type="<format>">
⟪ The content within this tag will depend on the chosen format (e.g., <svg>, <pre>, <latex>, etc. Never output ) ⟫
⟪ Example: <svg width="#{width}" height="#{height}" style="border:1px solid black;"><circle cx="50" cy="50" r="30" fill="blue" /></svg> ⟫
  </content>
</llm-fim>
<optional closing code black if enabled>
⟪end of output⟫
```
⚞

