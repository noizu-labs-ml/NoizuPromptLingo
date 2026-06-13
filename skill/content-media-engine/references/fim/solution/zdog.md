# Zdog - Pseudo-3D Engine

## Installation
```bash
npm install zdog
```

## CDN
```html
<script src="https://unpkg.com/zdog@1/dist/zdog.dist.min.js"></script>
```

## Basic Scene
```javascript
// Create illustration
const illo = new Zdog.Illustration({
  element: '.zdog-canvas',
  zoom: 4,
  dragRotate: true,
});

// Create a box
const box = new Zdog.Box({
  addTo: illo,
  width: 100,
  height: 100,
  depth: 100,
  stroke: false,
  color: '#C25',
  leftFace: '#EA0',
  rightFace: '#E62',
  topFace: '#ED0',
  bottomFace: '#636',
});

// Create a circle
const circle = new Zdog.Ellipse({
  addTo: illo,
  diameter: 80,
  translate: { z: 100 },
  stroke: 20,
  color: '#636',
});

// Create grouped shapes
const group = new Zdog.Group({
  addTo: illo,
  translate: { x: 100 },
});

const cone = new Zdog.Cone({
  addTo: group,
  diameter: 70,
  length: 90,
  stroke: false,
  color: '#663',
});

// Animation loop
function animate() {
  // Rotate
  illo.rotate.y += 0.01;
  box.rotate.x += 0.01;
  box.rotate.z += 0.01;

  // Update and render
  illo.updateRenderGraph();
  requestAnimationFrame(animate);
}
animate();
```

## SVG Rendering
```javascript
// Use SVG instead of canvas
const illoSVG = new Zdog.Illustration({
  element: '.zdog-svg',
  zoom: 4,
});

// Create flat shapes
const shape = new Zdog.Shape({
  addTo: illoSVG,
  path: [
    { x: 0, y: -40 },
    { x: 40, y: 40 },
    { x: -40, y: 40 },
  ],
  closed: true,
  stroke: 20,
  color: '#E62',
});
```

## Advanced Shapes
```javascript
// Custom path
const star = new Zdog.Shape({
  addTo: illo,
  path: [
    { x: 0, y: -50 },
    { x: 14, y: -20 },
    { x: 47, y: -15 },
    { x: 23, y: 7 },
    { x: 29, y: 40 },
    { x: 0, y: 25 },
    { x: -29, y: 40 },
    { x: -23, y: 7 },
    { x: -47, y: -15 },
    { x: -14, y: -20 },
  ],
  closed: true,
  stroke: 4,
  fill: true,
  color: '#FD0',
});

// Hemisphere
const dome = new Zdog.Hemisphere({
  addTo: illo,
  diameter: 80,
  stroke: false,
  color: '#C25',
  backface: '#EA0',
});
```

## Strengths
- Tiny file size (8KB min+gzip)
- Simple, friendly API
- Works with canvas and SVG
- Flat-shaded aesthetic
- No dependencies

## Limitations
- Not true 3D (no perspective projection)
- Limited to simple geometries
- No textures or complex materials
- No lighting system
- Performance limits with many objects

## Best Use Cases
- Logos and icons with 3D look
- Simple interactive illustrations
- Data visualization with depth
- Loading animations
- Retro/stylized 3D graphics