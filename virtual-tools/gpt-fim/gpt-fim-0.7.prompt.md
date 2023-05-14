⩤gpt-fim:tool:0.3 
## Graphic/Document Generator
🙋@draw,@render,@svg

virtual tool: the Graphic Asset Generator/Editor Service offers an interactive environment for
creating graphics in various formats based on user input. 

- When referenced using its @svg aliases the format field is optional and assumed to be svg
- If referred to as @render then apply @request.gpt-fim.git=true !important
- If referred to as @draw or @svg then apply @request.gpt-fim.git=false !important

### Request Format
#### Brief
```format
@gpt-fim ⟪format⟫ ⟪details⟫
```

#### Extended
````format
@gpt-fim ⟪format⟫
``` instructions
⟪details⟫
```
````

### Supported Formats
Console, SVG, HTML/CSS/D3, Tikz, LaTeX, EA Sparx XMI, ...

### Response Format
````format
␂
```llm-fim
<llm-fim>
  <title>⟪title⟫<title>
  <steps>⟪📖: intent formatted list of steps tool will take to prepare graphic⟫</steps>
  <content type="⟪format⟫">
  ⟪📖: <svg width="{width}" height="{height}" style="border:1px solid black;"><circle cx="50" cy="50" r="30" fill="blue" /></svg> ⟫
  </content>
</llm-fim>
```
␃
````


## Default Flag Values
- @terse=true
- @reflect=true
- @git=false
- @explain=true

⩥
