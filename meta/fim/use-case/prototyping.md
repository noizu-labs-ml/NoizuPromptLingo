# Prototyping
Generate mockups, wireframes, and interactive prototypes for rapid design iteration.
[Figma API](https://www.figma.com/developers/api) | [Excalidraw](https://excalidraw.com/)

## WWHW
**What**: Create visual mockups, wireframes, and interactive prototype code
**Why**: Rapid design iteration, stakeholder communication, user testing
**How**: Generate HTML/CSS prototypes, SVG wireframes, component patterns
**When**: Early design phase, user research, design validation, developer handoff

## When to Use
- Rapid UI concept validation
- Interactive prototype development
- Design system component creation
- User flow visualization
- Stakeholder presentations

## Key Outputs
`html-prototypes`, `svg-wireframes`, `component-patterns`, `figma-plugins`

## Quick Example
```html
<!-- Universal wireframe prototype pattern -->
<!DOCTYPE html>
<style>
  .wire { border: 2px solid #ccc; margin: 10px; padding: 20px; }
  .block { background: #f0f0f0; padding: 10px; margin: 5px 0; }
</style>
<div class="wire">
  <div class="block" style="height:60px">Header</div>
  <div class="block" style="height:40px">Navigation</div>
  <div style="display:flex">
    <div class="block" style="flex:1; min-height:200px">Content</div>
    <div class="block" style="width:200px">Sidebar</div>
  </div>
</div>
```

```pseudo
// Universal component prototype pattern
Component(title, content, actions) {
  container {
    header: title
    body: content
    footer: actions.map(action => Button(action))
  }
  state: { expanded: false, selected: null }
  behavior: { toggle(), select(), render() }
}
```