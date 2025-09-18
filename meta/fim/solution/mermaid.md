# Mermaid
Text-based diagramming tool for flowcharts, sequences, and more. [Docs](https://mermaid.js.org/) | [Live Editor](https://mermaid.live/)

## Install/Setup
```bash
npm install mermaid  # For Node.js
# Or CDN for browser
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
# Or use in Markdown with GitHub/GitLab support
```

## Basic Usage
```javascript
// In HTML
<div class="mermaid">
graph LR
    A[Start] --> B{Decision}
    B -->|Yes| C[Process]
    B -->|No| D[End]
    C --> D
</div>

// JavaScript initialization
mermaid.initialize({ startOnLoad: true });
```

## Strengths
- Native Markdown integration (GitHub, GitLab, Notion)
- No external dependencies for basic diagrams
- Version control friendly (plain text)
- Quick prototyping without design tools

## Limitations
- Limited styling customization
- Layout algorithms sometimes produce suboptimal results
- No interactive features beyond basic tooltips

## Best For
`documentation`, `flowcharts`, `sequence-diagrams`, `gantt-charts`, `git-workflows`