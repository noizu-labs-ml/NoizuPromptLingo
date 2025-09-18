# SVG.js Vector Graphics Library

Lightweight library for manipulating and animating SVG.

## Core Features
- SVG DOM manipulation
- Animation support
- Event handling
- Plugin system

## Basic Setup
```javascript
// CDN: https://cdn.jsdelivr.net/npm/@svgdotjs/svg.js@3.0/dist/svg.min.js
import { SVG } from '@svgdotjs/svg.js';
const draw = SVG().addTo('#drawing').size(300, 300);
```

## SVG Manipulation Examples
```javascript
// Basic shapes
const rect = draw.rect(100, 100).fill('#f06');
const circle = draw.circle(100).fill('#f09').move(50, 50);
const ellipse = draw.ellipse(200, 100).fill('#fd0');

// Styling
rect.stroke({ color: '#000', width: 2, linecap: 'round' });
circle.fill({ color: '#06f', opacity: 0.6 });

// Grouping
const group = draw.group();
group.add(rect);
group.add(circle);
group.rotate(45);

// Path drawing
const path = draw.path('M 100 50 L 200 150 L 100 150 Z');
path.fill('#fc0').stroke({ width: 1, color: '#333' });

// Text
const text = draw.text('SVG.js');
text.font({
  family: 'Helvetica',
  size: 42,
  anchor: 'middle'
}).move(150, 100);

// Gradients
const gradient = draw.gradient('linear', function(add) {
  add.stop(0, '#333');
  add.stop(1, '#fff');
});
rect.fill(gradient);

// Patterns
const pattern = draw.pattern(20, 20, function(add) {
  add.rect(20, 20).fill('#f06');
  add.rect(10, 10).fill('#0f9');
});
circle.fill(pattern);

// Animation
rect.animate(1000).move(100, 100).rotate(45);

circle.animate({
  duration: 2000,
  delay: 500,
  when: 'now',
  swing: true
}).fill('#f06').scale(2);

// Timeline animation
const timeline = new SVG.Timeline();
rect.timeline(timeline);
circle.timeline(timeline);

timeline.time(1000);

// Events
rect.on('click', function() {
  this.fill({ color: '#f06' });
});

// Masks and clips
const mask = draw.mask();
mask.add(draw.circle(100).fill('#fff').center(150, 150));
rect.maskWith(mask);
```

## NPL-FIM Integration
```javascript
// SVG.js controller patterns
const svgController = {
  createIcon: (draw, type) => {
    const icon = draw.group();
    switch(type) {
      case 'star':
        const star = draw.polygon('50,15 61,35 82,35 67,50 73,71 50,59 27,71 33,50 18,35 39,35');
        star.fill('#ffd700').stroke({ width: 2, color: '#ffa500' });
        icon.add(star);
        break;
      case 'heart':
        const heart = draw.path('M20,30 C20,10 10,10 10,20 C10,10 0,10 0,20 Q0,30 10,40 Q20,30 20,30z');
        heart.fill('#ff0066');
        icon.add(heart);
        break;
    }
    return icon;
  },

  animateAlongPath: (element, pathData) => {
    const path = draw.path(pathData).fill('none');
    const length = path.length();

    element.animate(3000).during(function(pos) {
      const point = path.pointAt(pos * length);
      this.center(point.x, point.y);
    }).loop();
  }
};
```

## Key Methods
- addTo(): Attach to DOM
- move()/center(): Position elements
- animate(): Create animations
- on(): Event handling
- transform(): Apply transformations