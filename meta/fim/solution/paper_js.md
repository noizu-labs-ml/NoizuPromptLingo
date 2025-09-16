# Paper.js Vector Graphics Framework

Vector graphics scripting framework for Canvas.

## Core Features
- Scene graph model
- Vector paths
- Boolean operations
- Mouse interactions

## Basic Setup
```javascript
// CDN: https://cdnjs.cloudflare.com/ajax/libs/paper.js/0.12.17/paper-full.min.js
import paper from 'paper';
paper.setup('myCanvas');
```

## Graphics Examples
```javascript
// Basic shapes
const circle = new paper.Path.Circle({
  center: [80, 50],
  radius: 30,
  fillColor: 'red'
});

const rectangle = new paper.Path.Rectangle({
  point: [100, 20],
  size: [100, 50],
  strokeColor: 'black',
  fillColor: 'blue'
});

// Complex path
const path = new paper.Path();
path.strokeColor = 'black';
path.add(new paper.Point(30, 75));
path.add(new paper.Point(60, 25));
path.add(new paper.Point(90, 75));
path.smooth();

// Compound paths
const donut = new paper.CompoundPath({
  children: [
    new paper.Path.Circle({ center: [50, 50], radius: 50 }),
    new paper.Path.Circle({ center: [50, 50], radius: 30 })
  ],
  fillColor: 'red'
});

// Boolean operations
const circle1 = new paper.Path.Circle({ center: [50, 50], radius: 40 });
const circle2 = new paper.Path.Circle({ center: [80, 50], radius: 40 });
const union = circle1.unite(circle2);
union.fillColor = 'green';

// Animation
paper.view.onFrame = function(event) {
  for (let i = 0; i < paper.project.activeLayer.children.length; i++) {
    const item = paper.project.activeLayer.children[i];
    item.rotate(1);
    item.scale(0.99 + Math.sin(event.count * 0.05) * 0.01);
  }
};

// Interactive drawing
const tool = new paper.Tool();
let path;

tool.onMouseDown = function(event) {
  path = new paper.Path();
  path.strokeColor = 'black';
  path.add(event.point);
};

tool.onMouseDrag = function(event) {
  path.add(event.point);
};
```

## NPL-FIM Integration
```javascript
// Paper.js controller
const paperController = {
  createPattern: () => {
    const group = new paper.Group();
    for (let i = 0; i < 10; i++) {
      const circle = new paper.Path.Circle({
        center: [i * 20, Math.sin(i) * 20 + 50],
        radius: 10,
        fillColor: new paper.Color(i / 10, 0, 1 - i / 10)
      });
      group.addChild(circle);
    }
    return group;
  }
};
```

## Key Classes
- Path: Vector paths
- Group: Object containers
- Tool: User interaction
- Symbol: Reusable graphics
- Raster: Bitmap images