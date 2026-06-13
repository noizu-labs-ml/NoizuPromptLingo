# Velocity.js Animation Engine

High-performance animation engine with jQuery-like syntax.

## Core Features
- Hardware acceleration
- Color animations
- SVG support
- Scroll animations

## Basic Setup
```javascript
// CDN: https://cdnjs.cloudflare.com/ajax/libs/velocity/2.0.6/velocity.min.js
import Velocity from 'velocity-animate';
```

## Animation Examples
```javascript
// Basic animation
Velocity(document.querySelector('.element'), {
  translateX: '200px',
  rotateZ: '45deg',
  opacity: 0.5
}, {
  duration: 1000,
  easing: 'easeInOutQuad'
});

// Chained animations
Velocity(element, { opacity: 1, scale: 1.2 }, 500)
  .then(() => Velocity(element, { scale: 1 }, 300))
  .then(() => Velocity(element, 'reverse', 200));

// Pre-defined effects
Velocity(element, 'fadeIn', { duration: 1500 });
Velocity(element, 'slideUp', { duration: 800 });
Velocity(element, 'transition.flipXIn', { duration: 600 });

// Color animation
Velocity(element, {
  backgroundColor: '#ff0000',
  color: '#ffffff',
  borderColor: '#00ff00'
}, 1000);

// SVG animation
Velocity(svgElement, {
  strokeDashoffset: 0,
  fill: '#ff6600',
  strokeWidth: 3
}, 2000);

// Scroll animation
Velocity(element, 'scroll', {
  duration: 800,
  offset: -50,
  easing: 'easeOutQuart'
});

// Loop animation
Velocity(element, {
  translateY: '20px'
}, {
  loop: true,
  duration: 1000
});
```

## NPL-FIM Integration
```javascript
// Velocity animation controller
const velocityController = {
  entrance: (el) => Velocity(el, 'transition.slideUpIn', { duration: 600 }),

  exit: (el) => Velocity(el, 'transition.slideDownOut', { duration: 400 }),

  attention: (el) => Velocity(el, { scale: [1.1, 1] }, { duration: 300 })
    .then(() => Velocity(el, { scale: 1 }, { duration: 300 })),

  sequence: (elements) => {
    elements.forEach((el, i) => {
      Velocity(el, 'transition.fadeIn', {
        delay: i * 100,
        duration: 500
      });
    });
  }
};
```

## Key Features
- duration: Animation length
- easing: Timing functions
- loop: Repeat count
- delay: Start delay
- queue: Animation queue control