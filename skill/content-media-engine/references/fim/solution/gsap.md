# GSAP (GreenSock) Animation Platform

Professional-grade animation library for complex animations.

## Core Features
- High-performance tweening
- Timeline sequencing
- Plugin ecosystem
- ScrollTrigger integration

## Basic Setup
```javascript
// CDN: https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
gsap.registerPlugin(ScrollTrigger);
```

## Animation Examples
```javascript
// Basic tween
gsap.to(".box", {
  x: 200,
  rotation: 360,
  duration: 2,
  ease: "power2.inOut"
});

// Timeline sequence
const tl = gsap.timeline({ repeat: -1, yoyo: true });
tl.to(".el1", { x: 100, duration: 1 })
  .to(".el2", { y: 100, duration: 1 }, "-=0.5")
  .to(".el3", { rotation: 180, duration: 1 }, "<");

// ScrollTrigger animation
gsap.to(".parallax", {
  scrollTrigger: {
    trigger: ".parallax",
    start: "top bottom",
    end: "bottom top",
    scrub: true
  },
  y: -200
});

// Stagger animation
gsap.to(".grid-item", {
  scale: 1.5,
  duration: 0.5,
  stagger: {
    amount: 1.5,
    grid: [5, 5],
    from: "center"
  }
});

// Text animation
gsap.fromTo(".text",
  { opacity: 0, y: 50 },
  { opacity: 1, y: 0, duration: 1, stagger: 0.1 }
);
```

## NPL-FIM Integration
```javascript
// Advanced animation controller
const gsapController = {
  reveal: (element) => gsap.fromTo(element, { autoAlpha: 0, y: 50 }, { autoAlpha: 1, y: 0, duration: 1 }),
  morph: (from, to) => gsap.to(from, { morphSVG: to, duration: 2 }),
  drawSVG: (path) => gsap.fromTo(path, { drawSVG: "0%" }, { drawSVG: "100%", duration: 2 })
};
```

## Key Methods
- to(): Animate to values
- from(): Animate from values
- fromTo(): Define start and end
- set(): Instantly set properties
- timeline(): Create sequences