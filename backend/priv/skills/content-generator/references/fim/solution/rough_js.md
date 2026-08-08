# Rough.js Hand-Drawn Graphics

Library for creating sketchy, hand-drawn-style graphics.

## Core Features
- Hand-drawn aesthetics
- SVG and Canvas support
- Customizable roughness
- Fill patterns

## Basic Setup
```javascript
// CDN: https://unpkg.com/roughjs/bundled/rough.js
import rough from 'roughjs';
const rc = rough.canvas(document.getElementById('canvas'));
// Or for SVG: const rc = rough.svg(svgElement);
```

## Drawing Examples
```javascript
// Basic shapes with rough style
rc.rectangle(10, 10, 200, 100); // x, y, width, height
rc.circle(80, 120, 50); // centerX, centerY, diameter
rc.ellipse(300, 100, 150, 80); // centerX, centerY, width, height
rc.line(60, 60, 190, 60); // x1, y1, x2, y2

// Custom styling
rc.rectangle(20, 20, 100, 100, {
  fill: 'red',
  fillStyle: 'hachure', // solid, hachure, zigzag, cross-hatch, dots
  fillWeight: 3,
  hachureAngle: 60,
  hachureGap: 8,
  roughness: 2,
  stroke: 'blue',
  strokeWidth: 2
});

// Polygon
rc.polygon([
  [10, 10],
  [100, 20],
  [90, 100],
  [20, 90]
], {
  fill: 'rgba(255, 0, 0, 0.3)',
  fillStyle: 'cross-hatch',
  stroke: 'green'
});

// Path/curve
rc.path('M10 10 L90 10 L90 90 Q50 90 10 50 Z', {
  fill: 'blue',
  fillStyle: 'zigzag',
  stroke: 'black'
});

// Arc
rc.arc(350, 200, 100, 100, Math.PI, Math.PI * 1.5, true, {
  stroke: 'red',
  strokeWidth: 2,
  fill: 'yellow',
  fillStyle: 'solid'
});

// Combining shapes
const generator = rough.generator();
const rect = generator.rectangle(10, 10, 100, 100);
const circle = generator.circle(60, 60, 80);
rc.draw(rect);
rc.draw(circle);

// SVG example
const svg = document.getElementById('svg');
const rcSvg = rough.svg(svg);
const node = rcSvg.rectangle(10, 10, 200, 100, {
  fill: 'red',
  fillStyle: 'dots',
  stroke: 'blue'
});
svg.appendChild(node);
```

## NPL-FIM Integration
```javascript
// Rough.js sketchy patterns
const roughPatterns = {
  sketchyChart: (canvas, data) => {
    const rc = rough.canvas(canvas);
    const barWidth = canvas.width / data.length;

    data.forEach((value, i) => {
      rc.rectangle(
        i * barWidth + 10,
        canvas.height - value,
        barWidth - 20,
        value,
        { fill: `hsl(${i * 30}, 70%, 50%)`, fillStyle: 'hachure' }
      );
    });
  },

  handDrawnDiagram: (rc) => {
    // Node connections
    rc.circle(100, 100, 40, { fill: 'lightblue' });
    rc.circle(200, 150, 40, { fill: 'lightgreen' });
    rc.line(120, 110, 180, 140, { strokeWidth: 2 });
  }
};
```

## Style Options
- roughness: Sketch roughness (0-10)
- bowing: Line bowing amount
- fillStyle: Fill pattern type
- fillWeight: Fill line thickness
- hachureGap: Gap between fill lines
- strokeWidth: Outline thickness