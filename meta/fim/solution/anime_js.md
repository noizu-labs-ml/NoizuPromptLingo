# Anime.js Animation Library

Lightweight JavaScript animation library with simple API.

## Core Features
- CSS properties animation
- SVG animation support
- Timeline control
- Staggering effects

## Basic Setup
```javascript
// CDN: https://cdn.jsdelivr.net/npm/animejs@3.2.1/lib/anime.min.js
import anime from 'animejs/lib/anime.es.js';
```

## Animation Examples
```javascript
// Basic animation
anime({
  targets: '.box',
  translateX: 250,
  rotate: '1turn',
  duration: 800,
  easing: 'easeInOutSine'
});

// Timeline with multiple animations
const timeline = anime.timeline({
  easing: 'easeOutExpo',
  duration: 750
});

timeline
  .add({ targets: '.el1', translateX: 250 })
  .add({ targets: '.el2', translateX: 250 }, '-=600')
  .add({ targets: '.el3', translateX: 250 }, '-=400');

// SVG path animation
anime({
  targets: '.path',
  strokeDashoffset: [anime.setDashoffset, 0],
  easing: 'easeInOutSine',
  duration: 1500,
  loop: true
});

// Staggering
anime({
  targets: '.stagger-demo .el',
  translateX: 270,
  delay: anime.stagger(100, {start: 500})
});
```

## NPL-FIM Integration
```javascript
// Animation controller pattern
const animationController = {
  fadeIn: (target) => anime({ targets: target, opacity: [0, 1], duration: 1000 }),
  slideIn: (target) => anime({ targets: target, translateX: [-100, 0], duration: 800 }),
  bounce: (target) => anime({ targets: target, translateY: [0, -30, 0], duration: 600, easing: 'easeInOutQuad' })
};
```

## Key Properties
- targets: CSS selector, DOM node, or object
- duration: Animation length in ms
- delay: Start delay in ms
- easing: Timing function
- loop: true/false/number