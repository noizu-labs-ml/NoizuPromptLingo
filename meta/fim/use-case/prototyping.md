# Prototyping
Generate mockups, wireframes, and interactive prototypes for rapid design iteration.
[Figma API](https://www.figma.com/developers/api) | [Excalidraw](https://excalidraw.com/)

## WWHW
**What**: Create visual mockups, wireframes, and interactive prototype code
**Why**: Rapid design iteration, stakeholder communication, user testing preparation
**How**: Generate HTML/CSS prototypes, SVG wireframes, React components
**When**: Early design phase, user research, design validation, developer handoff

## When to Use
- Rapid UI concept validation
- Interactive prototype development
- Design system component creation
- User flow visualization
- Stakeholder design presentations

## Key Outputs
`html-prototypes`, `svg-wireframes`, `react-components`, `figma-plugins`

## Quick Example
```html
<!-- Quick wireframe prototype -->
<!DOCTYPE html>
<html>
<head>
    <style>
        .wireframe { border: 2px solid #ccc; margin: 10px; padding: 20px; }
        .header { height: 60px; background: #f0f0f0; }
        .nav { height: 40px; background: #e0e0e0; }
        .content { min-height: 300px; background: #f8f8f8; }
        .sidebar { width: 200px; float: right; background: #eee; }
    </style>
</head>
<body>
    <div class="wireframe">
        <div class="header">Header Section</div>
        <div class="nav">Navigation</div>
        <div class="sidebar">Sidebar</div>
        <div class="content">Main Content Area</div>
    </div>
</body>
</html>
```

```jsx
// React prototype component
const PrototypeCard = ({ title, content, actions }) => (
  <div className="prototype-card">
    <h3>{title}</h3>
    <p>{content}</p>
    <div className="actions">
      {actions.map(action =>
        <button key={action.id} onClick={action.handler}>
          {action.label}
        </button>
      )}
    </div>
  </div>
);
```

## Extended Reference
- [Storybook Documentation](https://storybook.js.org/docs)
- [Framer Motion](https://www.framer.com/motion/)
- [React Prototype Tools](https://react-proto.github.io/react-proto/)
- [Don't Make Me Think by Steve Krug](https://www.amazon.com/Dont-Make-Think-Revisited-Usability/dp/0321965515)
- [Atomic Design by Brad Frost](https://atomicdesign.bradfrost.com/)