# Pts.js Creative Coding Library

Visualization and creative coding library for canvas and SVG.

## Core Features
- Point-based geometry
- Physics simulations
- Creative math utilities
- Canvas/SVG rendering

## Basic Setup
```javascript
// CDN: https://unpkg.com/pts/dist/pts.min.js
import { CanvasSpace, Pt, Group, Circle, Line } from 'pts';
```

## Creative Examples
```javascript
// Basic setup
const space = new CanvasSpace("#canvas").setup({ bgcolor: "#000" });
const form = space.getForm();

space.add({
  animate: (time, ftime) => {
    // Draw circle at mouse position
    let circle = Circle.fromCenter(space.pointer, 50);
    form.fillOnly("#fff").circle(circle);
  }
});

space.play();

// Particle system
space.add({
  particles: [],

  start: (space) => {
    for (let i = 0; i < 100; i++) {
      this.particles.push(new Pt(Math.random() * space.size.x, Math.random() * space.size.y));
    }
  },

  animate: (time) => {
    this.particles.forEach(p => {
      p.add(Math.random() - 0.5, Math.random() - 0.5);
      form.fillOnly("#ff0").point(p, 2);
    });
  }
});

// Wave visualization
space.add({
  animate: (time) => {
    let pts = [];
    for (let x = 0; x < space.size.x; x += 10) {
      let y = space.center.y + Math.sin(x * 0.02 + time * 0.001) * 100;
      pts.push(new Pt(x, y));
    }
    form.strokeOnly("#0ff", 2).line(pts);
  }
});

// Physics simulation
const world = new World(space.bound, 0.99, new Pt(0, 500));
space.add({
  bodies: [],

  start: () => {
    for (let i = 0; i < 20; i++) {
      let body = Body.fromGroup(
        Polygon.fromCenter(space.pointer.clone().add(i * 20, 0), 20, 6)
      );
      this.bodies.push(body);
      world.add(body);
    }
  },

  animate: (time) => {
    world.update(ftime);
    this.bodies.forEach(b => {
      form.fillOnly("#f06").polygon(b);
    });
  }
});
```

## NPL-FIM Integration
```javascript
// Creative patterns with Pts
const ptsPatterns = {
  spiral: (space, form) => {
    let center = space.center;
    let pts = [];
    for (let i = 0; i < 500; i++) {
      let angle = i * 0.1;
      let radius = i * 0.5;
      pts.push(center.clone().toAngle(angle, radius));
    }
    form.strokeOnly("#fff").line(pts);
  },

  voronoi: (space, form, points) => {
    let triangles = Delaunay.fromPoints(points).voronoi([0, 0, space.width, space.height]);
    triangles.forEach(t => {
      form.strokeOnly("#09f").polygon(t);
    });
  }
};
```

## Key Concepts
- Pt: Point in space
- Group: Collection of points
- Form: Drawing context
- Space: Canvas container
- Op: Geometry operations