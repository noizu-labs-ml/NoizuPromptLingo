# Mo.js Motion Graphics Library

Declarative motion graphics library for web animations.

## Core Features
- Shape morphing
- Custom shapes
- Motion paths
- Burst effects

## Basic Setup
```javascript
// CDN: https://cdn.jsdelivr.net/npm/@mojs/core
import mojs from '@mojs/core';
```

## Animation Examples
```javascript
// Basic shape animation
const circle = new mojs.Shape({
  shape: 'circle',
  scale: { 0: 1 },
  duration: 1000,
  easing: 'elastic.out'
}).play();

// Burst effect
const burst = new mojs.Burst({
  radius: { 0: 100 },
  count: 5,
  children: {
    shape: 'circle',
    fill: { '#ff0000': '#ffff00' },
    duration: 2000
  }
}).play();

// Timeline with multiple shapes
const timeline = new mojs.Timeline({
  repeat: 3
});

timeline.add(
  new mojs.Shape({
    shape: 'rect',
    fill: 'none',
    stroke: '#00ff00',
    strokeWidth: { 10: 0 },
    radius: { 0: 50 },
    duration: 600
  })
);

// Custom shape
class Heart extends mojs.CustomShape {
  getShape() {
    return '<path d="M92.5,7.5c-16.6,0-30,13.4-30,30c0,30,30,60,30,60s30-30,30-60C122.5,20.9,109.1,7.5,92.5,7.5z"/>';
  }
}
mojs.addShape('heart', Heart);

const heart = new mojs.Shape({
  shape: 'heart',
  fill: '#ff0066',
  scale: { 0: 2 },
  duration: 1000
}).play();

// Motion path
const motionPath = new mojs.Shape({
  shape: 'circle',
  fill: '#00ffff',
  path: document.querySelector('#path'),
  duration: 3000,
  easing: 'linear'
}).play();
```

## NPL-FIM Integration
```javascript
// Motion graphics controller
const mojsController = {
  explode: (x, y) => new mojs.Burst({
    left: x, top: y,
    count: 10,
    radius: { 0: 150 },
    children: { fill: ['#ff0000', '#00ff00', '#0000ff'] }
  }).play(),

  trail: (element) => new mojs.Shape({
    parent: element,
    shape: 'circle',
    fill: 'transparent',
    stroke: '#ffffff',
    strokeWidth: { 20: 0 },
    scale: { 0: 1.5 },
    duration: 700
  }).play()
};
```

## Key Components
- Shape: Basic shape animations
- Burst: Particle explosions
- Timeline: Sequence control
- CustomShape: Custom SVG shapes
- Html: HTML element animations