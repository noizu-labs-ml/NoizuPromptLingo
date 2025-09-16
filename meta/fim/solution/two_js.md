# Two.js 2D Drawing Library

Unified API for SVG, Canvas, and WebGL rendering.

## Core Features
- Renderer agnostic
- Scene graph
- Animation loop
- Shape primitives

## Basic Setup
```javascript
// CDN: https://cdn.jsdelivr.net/npm/two.js@latest/build/two.min.js
import Two from 'two.js';
const two = new Two({ width: 640, height: 480 }).appendTo(document.body);
```

## Drawing Examples
```javascript
// Basic shapes
const circle = two.makeCircle(70, 100, 50);
circle.fill = '#FF8000';
circle.stroke = 'orangered';
circle.linewidth = 5;

const rect = two.makeRectangle(213, 100, 100, 100);
rect.fill = 'rgba(0, 200, 255, 0.75)';
rect.noStroke();

// Line and polygon
const line = two.makeLine(50, 50, 150, 150);
line.stroke = 'rgba(255, 0, 0, 0.5)';
line.linewidth = 10;

const star = two.makeStar(200, 200, 50, 80, 5);
star.fill = '#FFD700';

// Group transformation
const group = two.makeGroup(circle, rect);
group.translation.set(100, 100);
group.rotation = Math.PI / 4;
group.scale = 0.75;

// Path drawing
const anchors = [
  new Two.Anchor(0, 0),
  new Two.Anchor(60, 40),
  new Two.Anchor(60, 100),
  new Two.Anchor(0, 60)
];
const path = two.makePath(anchors, true);
path.curved = true;
path.fill = '#2196F3';

// Animation
two.bind('update', function(frameCount) {
  circle.rotation += 0.01;
  rect.scale = Math.sin(frameCount * 0.01) * 0.5 + 1;
  star.translation.x = 200 + Math.sin(frameCount * 0.03) * 50;
});

two.play(); // Start animation

// Text
const text = two.makeText("Hello Two.js", 320, 240);
text.size = 24;
text.fill = '#333';
text.family = 'Arial, sans-serif';
```

## NPL-FIM Integration
```javascript
// Two.js graphics controller
const twoController = {
  particleSystem: (two, count) => {
    const particles = [];
    for (let i = 0; i < count; i++) {
      const particle = two.makeCircle(
        Math.random() * two.width,
        Math.random() * two.height,
        2
      );
      particle.fill = `hsl(${Math.random() * 360}, 100%, 50%)`;
      particle.velocity = new Two.Vector(
        Math.random() * 2 - 1,
        Math.random() * 2 - 1
      );
      particles.push(particle);
    }

    two.bind('update', () => {
      particles.forEach(p => {
        p.translation.add(p.velocity);
        if (p.translation.x > two.width) p.translation.x = 0;
        if (p.translation.y > two.height) p.translation.y = 0;
      });
    });
    return particles;
  }
};
```

## Key Methods
- make[Shape]: Create shapes
- makeGroup: Group objects
- bind/unbind: Event handling
- play/pause: Animation control
- update/render: Frame updates