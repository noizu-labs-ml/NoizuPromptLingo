# Anime.js Animation Library

Anime.js is a lightweight JavaScript animation library with a simple but powerful API that works with CSS properties, SVG, DOM attributes, and JavaScript Objects. It's perfect for creating sophisticated animations with minimal code complexity.

**Official Documentation**: [https://animejs.com/](https://animejs.com/)
**GitHub Repository**: [https://github.com/juliangarnier/anime](https://github.com/juliangarnier/anime)
**License**: MIT License (Free for commercial and personal use)
**Current Version**: 3.2.1 (Latest stable release)

## Table of Contents
1. [Installation](#installation)
2. [Environment Requirements](#environment-requirements)
3. [Complete HTML Setup Examples](#complete-html-setup-examples)
4. [Core Features](#core-features)
5. [Strengths](#strengths)
6. [Limitations](#limitations)
7. [Basic Usage](#basic-usage)
8. [Advanced Animation Patterns](#advanced-animation-patterns)
9. [Timeline Management](#timeline-management)
10. [SVG Animations](#svg-animations)
11. [Staggering and Sequencing](#staggering-and-sequencing)
12. [Framework Integration](#framework-integration)
13. [NPL-FIM Integration Patterns](#npl-fim-integration-patterns)
14. [Performance Optimization](#performance-optimization)
15. [Troubleshooting](#troubleshooting)
16. [Best Practices](#best-practices)
17. [External Resources](#external-resources)

## Installation

### npm Installation
```bash
npm install animejs
```

```javascript
import anime from 'animejs/lib/anime.es.js';
```

### Yarn Installation
```bash
yarn add animejs
```

### CDN Installation
```html
<script src="https://cdn.jsdelivr.net/npm/animejs@3.2.1/lib/anime.min.js"></script>
```

### ES6 Module via CDN
```javascript
import anime from 'https://cdn.skypack.dev/animejs@3.2.1';
```

### Download and Self-Host
```html
<!-- Download from https://github.com/juliangarnier/anime/releases -->
<script src="./lib/anime.min.js"></script>
```

## Environment Requirements

### Browser Compatibility
- **Modern Browsers**: Chrome 24+, Firefox 29+, Safari 7.1+, Edge 12+
- **Mobile**: iOS Safari 7.1+, Android Browser 4.4+, Chrome Mobile 39+
- **Legacy Support**: IE 10+ with polyfills for requestAnimationFrame

### Node.js Environment
- **Node.js**: 12.0.0 or higher
- **npm**: 6.0.0 or higher
- **ES6 Module Support**: Required for modern import syntax

### Dependencies
- **Zero Dependencies**: Anime.js has no external dependencies
- **Size**: ~14KB minified, ~6KB gzipped
- **Framework Agnostic**: Works with vanilla JS, React, Vue, Angular, etc.

## Complete HTML Setup Examples

### Basic HTML Setup
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Anime.js Basic Setup</title>
    <style>
        .box {
            width: 100px;
            height: 100px;
            background-color: #3498db;
            margin: 50px;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="box"></div>

    <script src="https://cdn.jsdelivr.net/npm/animejs@3.2.1/lib/anime.min.js"></script>
    <script>
        anime({
            targets: '.box',
            translateX: 250,
            rotate: '1turn',
            duration: 2000,
            easing: 'easeInOutSine'
        });
    </script>
</body>
</html>
```

### Advanced Interactive Setup
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Anime.js Interactive Animation</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            text-align: center;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
            gap: 20px;
            margin: 50px 0;
        }

        .card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
        }

        .btn {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 25px;
            cursor: pointer;
            margin: 10px;
            font-size: 16px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Anime.js Interactive Demo</h1>
        <div class="controls">
            <button class="btn" onclick="animateCards()">Animate Cards</button>
            <button class="btn" onclick="resetAnimation()">Reset</button>
        </div>
        <div class="grid">
            <div class="card">Card 1</div>
            <div class="card">Card 2</div>
            <div class="card">Card 3</div>
            <div class="card">Card 4</div>
            <div class="card">Card 5</div>
            <div class="card">Card 6</div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/animejs@3.2.1/lib/anime.min.js"></script>
    <script>
        // Animation functions
        function animateCards() {
            anime({
                targets: '.card',
                scale: [0.8, 1],
                opacity: [0, 1],
                translateY: [50, 0],
                rotateY: [90, 0],
                delay: anime.stagger(100),
                duration: 800,
                easing: 'easeOutElastic(1, .8)'
            });
        }

        function resetAnimation() {
            anime({
                targets: '.card',
                scale: 0.8,
                opacity: 0,
                translateY: 50,
                rotateY: 90,
                duration: 400,
                easing: 'easeInBack'
            });
        }

        // Initialize on load
        window.addEventListener('load', animateCards);
    </script>
</body>
</html>
```

## Core Features

### CSS Properties Animation
- Transform properties (translate, rotate, scale, skew)
- Color properties (background-color, color, border-color)
- Layout properties (width, height, padding, margin)
- Visual properties (opacity, border-radius, box-shadow)

### SVG Animation Support
- Path drawing and morphing
- Stroke and fill animations
- Attribute animations (viewBox, transform)
- Complex shape transitions

### Timeline Control
- Sequential and parallel animations
- Precise timing control with offsets
- Play, pause, reverse, and seek functionality
- Event-driven animation triggers

### Staggering Effects
- Delay variations across multiple elements
- Grid-based staggering patterns
- Custom stagger functions
- Direction-based staggering (from center, edges, etc.)

### Property Animation Types
- Relative values (`+=100`, `-=50`)
- Function-based values
- From-to value arrays `[0, 100]`
- Keyframes for complex motion paths

## Strengths

### Performance Advantages
- **Optimized Rendering**: Uses requestAnimationFrame for smooth 60fps animations
- **Transform Optimization**: Leverages CSS transforms and GPU acceleration
- **Minimal DOM Manipulation**: Reduces layout thrashing and reflows
- **Lightweight Footprint**: Only 14KB minified, no dependencies

### Developer Experience
- **Intuitive API**: Consistent and predictable method chaining
- **Comprehensive Documentation**: Extensive examples and API reference
- **TypeScript Support**: Built-in type definitions available
- **Framework Agnostic**: Works seamlessly with any JavaScript framework

### Animation Capabilities
- **Rich Easing Functions**: 30+ built-in easing functions plus custom curves
- **SVG Integration**: First-class support for SVG path and shape animations
- **Timeline Management**: Complex sequence orchestration with precise timing
- **Property Flexibility**: Animate any numeric CSS property or DOM attribute

### Production Readiness
- **Battle Tested**: Used by major websites and applications worldwide
- **Stable API**: Mature codebase with consistent API evolution
- **Cross-Browser**: Comprehensive compatibility across modern browsers
- **Performance Monitoring**: Built-in animation performance tracking

## Limitations

### Browser Constraints
- **IE Support**: Limited support for Internet Explorer (IE 10+ only)
- **CSS Grid**: Some CSS Grid properties require modern browser support
- **Mobile Performance**: Complex animations may impact battery life on mobile devices
- **3D Transforms**: Advanced 3D animations limited by hardware acceleration support

### Animation Limitations
- **Physics Engine**: No built-in physics simulation (springs, gravity, collisions)
- **Canvas/WebGL**: Limited support for canvas-based or WebGL animations
- **Audio Sync**: No native audio synchronization capabilities
- **Gesture Integration**: Requires additional libraries for touch/gesture-based animations

### Development Considerations
- **Learning Curve**: Advanced features require understanding of animation principles
- **Memory Usage**: Large numbers of simultaneous animations can impact memory
- **Debugging**: Limited built-in debugging tools for complex animation sequences
- **Bundle Size**: May be overkill for simple fade/slide animations

### Framework Integration
- **React Lifecycle**: Requires careful integration with component lifecycle methods
- **Virtual DOM**: May conflict with framework virtual DOM optimizations
- **State Management**: Animation state not automatically synchronized with app state
- **SSR Compatibility**: Server-side rendering requires additional configuration

## Basic Usage

### Simple Property Animation
```javascript
// Basic movement animation
anime({
    targets: '.element',
    translateX: 250,
    duration: 1000,
    easing: 'easeInOutQuad'
});

// Multiple properties
anime({
    targets: '.box',
    translateX: 250,
    rotate: '1turn',
    scale: 1.5,
    backgroundColor: '#ff6b6b',
    duration: 2000,
    easing: 'easeInOutCubic'
});

// From-to values
anime({
    targets: '.fade-element',
    opacity: [0, 1],
    translateY: [-50, 0],
    duration: 1500,
    easing: 'easeOutElastic(1, .8)'
});
```

### Targeting Multiple Elements
```javascript
// CSS selector
anime({
    targets: '.item',
    scale: 1.2,
    duration: 800
});

// DOM node
const element = document.querySelector('.my-element');
anime({
    targets: element,
    rotate: 180,
    duration: 1000
});

// Array of elements
const elements = document.querySelectorAll('.card');
anime({
    targets: elements,
    translateY: [100, 0],
    delay: anime.stagger(100)
});

// Mixed targets
anime({
    targets: ['.class1', document.getElementById('id1'), elements[0]],
    scale: [0.8, 1],
    duration: 1200
});
```

### Property Types and Values
```javascript
// Relative values
anime({
    targets: '.element',
    translateX: '+=100px',  // Add 100px to current value
    rotate: '-=45deg',      // Subtract 45 degrees
    scale: '*=1.5'          // Multiply by 1.5
});

// Function-based values
anime({
    targets: '.grid-item',
    translateX: function(el, i) {
        return i * 50;  // 0, 50, 100, 150...
    },
    delay: function(el, i, l) {
        return i * 100;  // Stagger delay
    }
});

// Random values
anime({
    targets: '.particle',
    translateX: function() {
        return anime.random(-300, 300);
    },
    translateY: function() {
        return anime.random(-200, 200);
    },
    scale: function() {
        return anime.random(0.5, 1.5);
    }
});
```

## Advanced Animation Patterns

### Keyframes Animation
```javascript
// Complex motion path with keyframes
anime({
    targets: '.path-element',
    keyframes: [
        {translateX: 100, duration: 1000},
        {rotate: 180, duration: 500},
        {translateX: 0, duration: 1000},
        {rotate: 0, duration: 500}
    ],
    easing: 'easeInOutSine',
    loop: true
});

// Property-specific keyframes
anime({
    targets: '.complex-animation',
    translateX: [
        {value: 100, duration: 1000},
        {value: 200, duration: 2000, easing: 'easeInOutQuart'},
        {value: 0, duration: 1000}
    ],
    rotate: [
        {value: 90, duration: 1500},
        {value: 180, duration: 1500}
    ],
    scale: [
        {value: 1.5, duration: 1000, easing: 'easeInExpo'},
        {value: 1, duration: 2000, easing: 'easeOutExpo'}
    ]
});
```

### Morphing and Shape Transformations
```javascript
// SVG path morphing
anime({
    targets: '.morph-path',
    d: [
        {value: 'M12,2 L2,7 L12,12 L22,7 Z'},
        {value: 'M12,2 L2,17 L12,22 L22,17 Z'},
        {value: 'M12,2 L2,7 L12,12 L22,7 Z'}
    ],
    duration: 3000,
    easing: 'easeInOutQuart',
    loop: true
});

// CSS clip-path morphing
anime({
    targets: '.clip-element',
    clipPath: [
        {value: 'polygon(0% 0%, 100% 0%, 100% 100%, 0% 100%)'},
        {value: 'polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%)'},
        {value: 'polygon(0% 0%, 100% 0%, 100% 100%, 0% 100%)'}
    ],
    duration: 2000,
    easing: 'easeInOutCubic',
    direction: 'alternate',
    loop: true
});
```

### Spring and Physics-Like Animations
```javascript
// Spring-like bounce effect
anime({
    targets: '.spring-element',
    translateY: [
        {value: -100, duration: 300, easing: 'easeOutCubic'},
        {value: 0, duration: 800, easing: 'easeOutBounce'}
    ],
    scale: [
        {value: 1.1, duration: 300},
        {value: 1, duration: 800, easing: 'easeOutElastic(1, .6)'}
    ]
});

// Pendulum motion simulation
anime({
    targets: '.pendulum',
    rotate: [
        {value: -45, duration: 1000, easing: 'easeInOutSine'},
        {value: 45, duration: 2000, easing: 'easeInOutSine'},
        {value: 0, duration: 1000, easing: 'easeInOutSine'}
    ],
    transformOrigin: '50% 0%',
    loop: true
});
```

### Particle System Animations
```javascript
// Particle explosion effect
function createParticleExplosion() {
    const particles = [];
    const container = document.querySelector('.particle-container');

    // Create particle elements
    for (let i = 0; i < 50; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.cssText = `
            position: absolute;
            width: 4px;
            height: 4px;
            background: hsl(${anime.random(0, 360)}, 70%, 60%);
            border-radius: 50%;
            left: 50%;
            top: 50%;
        `;
        container.appendChild(particle);
        particles.push(particle);
    }

    // Animate particles
    anime({
        targets: particles,
        translateX: function() {
            return anime.random(-300, 300);
        },
        translateY: function() {
            return anime.random(-300, 300);
        },
        scale: [
            {value: 1, duration: 0},
            {value: 0, duration: 1500}
        ],
        opacity: [
            {value: 1, duration: 300},
            {value: 0, duration: 1200}
        ],
        duration: 1500,
        easing: 'easeOutExpo',
        complete: function() {
            particles.forEach(p => p.remove());
        }
    });
}
```

## Timeline Management

### Basic Timeline Creation
```javascript
// Create timeline instance
const tl = anime.timeline({
    easing: 'easeOutExpo',
    duration: 750,
    autoplay: false  // Manual control
});

// Add animations to timeline
tl.add({
    targets: '.timeline-1',
    translateX: 250
})
.add({
    targets: '.timeline-2',
    translateY: 250
}, '-=500')  // Start 500ms before previous animation ends
.add({
    targets: '.timeline-3',
    rotate: 180
}, 1000);  // Start at 1000ms absolute time
```

### Complex Timeline Orchestration
```javascript
// Advanced timeline with multiple sequences
const complexTimeline = anime.timeline({
    loop: true,
    direction: 'alternate'
});

complexTimeline
    // Scene 1: Elements enter
    .add({
        targets: '.scene-1 .element',
        translateX: [-100, 0],
        opacity: [0, 1],
        delay: anime.stagger(100),
        duration: 800,
        easing: 'easeOutElastic(1, .8)'
    })
    // Scene 2: Transformation
    .add({
        targets: '.scene-1 .element',
        rotate: [0, 360],
        scale: [1, 1.2, 1],
        duration: 1200,
        easing: 'easeInOutQuart'
    }, '-=400')
    // Scene 3: Exit
    .add({
        targets: '.scene-1 .element',
        translateY: [0, -50],
        opacity: [1, 0],
        delay: anime.stagger(50, {from: 'last'}),
        duration: 600,
        easing: 'easeInBack'
    }, '+=500');

// Timeline controls
complexTimeline.play();      // Start timeline
complexTimeline.pause();     // Pause timeline
complexTimeline.restart();   // Restart from beginning
complexTimeline.reverse();   // Reverse direction
complexTimeline.seek(2000);  // Jump to 2000ms
```

### Interactive Timeline Control
```javascript
// Timeline with user interaction
const interactiveTimeline = anime.timeline({
    autoplay: false,
    easing: 'easeInOutSine'
});

interactiveTimeline
    .add({
        targets: '.slider-content',
        translateX: [100, 0],
        opacity: [0, 1],
        duration: 800
    })
    .add({
        targets: '.slider-nav',
        scale: [0, 1],
        duration: 600
    }, '-=400');

// Control functions
function playTimeline() {
    interactiveTimeline.play();
}

function reverseTimeline() {
    interactiveTimeline.reverse();
}

function seekToProgress(progress) {
    interactiveTimeline.seek(interactiveTimeline.duration * progress);
}

// Progress tracking
interactiveTimeline.update = function() {
    const progress = this.progress;
    console.log(`Timeline progress: ${progress}%`);
};
```

## SVG Animations

### Path Drawing Animation
```javascript
// Animate SVG path drawing
anime({
    targets: '.svg-path',
    strokeDashoffset: [anime.setDashoffset, 0],
    easing: 'easeInOutSine',
    duration: 1500,
    delay: function(el, i) { return i * 250 }
});

// Complex path animation with multiple properties
anime({
    targets: '.complex-path',
    strokeDashoffset: [anime.setDashoffset, 0],
    stroke: [
        {value: '#3498db', duration: 500},
        {value: '#e74c3c', duration: 500},
        {value: '#2ecc71', duration: 500}
    ],
    strokeWidth: [1, 3, 1],
    duration: 1500,
    easing: 'easeInOutQuart'
});
```

### SVG Shape Morphing
```javascript
// Morph between different shapes
anime({
    targets: '.morph-shape',
    d: [
        {value: 'M50,50 L100,50 L100,100 L50,100 Z'},  // Square
        {value: 'M75,25 L125,75 L75,125 L25,75 Z'},    // Diamond
        {value: 'M50,25 A25,25 0 1,1 50,24 Z'}         // Circle
    ],
    duration: 2000,
    easing: 'easeInOutCubic',
    direction: 'alternate',
    loop: true
});

// Animate SVG attributes
anime({
    targets: '.svg-circle',
    r: [10, 30, 10],
    cx: [50, 100, 50],
    fill: [
        {value: '#3498db'},
        {value: '#e74c3c'},
        {value: '#2ecc71'}
    ],
    duration: 2000,
    easing: 'easeInOutSine',
    loop: true
});
```

### Complex SVG Animations
```javascript
// Logo animation with multiple elements
const logoTimeline = anime.timeline({
    easing: 'easeOutExpo',
    duration: 800
});

logoTimeline
    // Draw main path
    .add({
        targets: '.logo-path-1',
        strokeDashoffset: [anime.setDashoffset, 0],
        opacity: [0, 1]
    })
    // Animate secondary elements
    .add({
        targets: '.logo-path-2',
        strokeDashoffset: [anime.setDashoffset, 0],
        opacity: [0, 1],
        delay: anime.stagger(100)
    }, '-=600')
    // Final reveal
    .add({
        targets: '.logo-text',
        translateY: [20, 0],
        opacity: [0, 1],
        delay: anime.stagger(50)
    }, '-=400');
```

## Staggering and Sequencing

### Basic Staggering
```javascript
// Simple stagger delay
anime({
    targets: '.stagger-basic .item',
    translateY: [50, 0],
    opacity: [0, 1],
    delay: anime.stagger(100), // 100ms between each element
    duration: 800
});

// Stagger with start delay
anime({
    targets: '.stagger-start .item',
    scale: [0, 1],
    delay: anime.stagger(100, {start: 500}), // Start after 500ms
    duration: 600,
    easing: 'easeOutBack'
});
```

### Advanced Staggering Patterns
```javascript
// Stagger from center
anime({
    targets: '.grid .item',
    scale: [0.8, 1],
    opacity: [0, 1],
    delay: anime.stagger(50, {from: 'center'}),
    duration: 800,
    easing: 'easeOutElastic(1, .6)'
});

// Stagger from specific index
anime({
    targets: '.list .item',
    translateX: [-100, 0],
    delay: anime.stagger(75, {from: 5}), // Start from 5th element
    duration: 1000
});

// Direction-based staggering
anime({
    targets: '.matrix .cell',
    backgroundColor: [
        {value: '#3498db', duration: 300},
        {value: '#ffffff', duration: 300}
    ],
    delay: anime.stagger(50, {
        grid: [10, 10],  // 10x10 grid
        from: 'first',   // Start from first element
        direction: 'normal'
    }),
    easing: 'easeInOutQuad'
});
```

### Custom Stagger Functions
```javascript
// Wave effect staggering
anime({
    targets: '.wave .bar',
    scaleY: [0.2, 1, 0.2],
    delay: function(el, i) {
        return Math.sin(i * 0.5) * 200 + 100;
    },
    duration: function(el, i) {
        return 1000 + (i * 50);
    },
    easing: 'easeInOutSine',
    loop: true
});

// Spiral staggering pattern
anime({
    targets: '.spiral .point',
    scale: [0, 1],
    rotate: [0, 360],
    delay: function(el, i, l) {
        const angle = (i / l) * Math.PI * 2;
        return Math.sin(angle) * 200 + 300;
    },
    duration: 1200,
    easing: 'easeOutElastic(1, .8)'
});
```

## Framework Integration

### React Integration
```jsx
import React, { useEffect, useRef } from 'react';
import anime from 'animejs/lib/anime.es.js';

// Hook for anime.js animations
function useAnime(animationProps, dependencies = []) {
    const ref = useRef();

    useEffect(() => {
        const animation = anime({
            targets: ref.current,
            ...animationProps
        });

        return () => animation.pause();
    }, dependencies);

    return ref;
}

// Component with animation
function AnimatedCard({ children, delay = 0 }) {
    const ref = useAnime({
        translateY: [50, 0],
        opacity: [0, 1],
        delay,
        duration: 800,
        easing: 'easeOutCubic'
    }, [delay]);

    return (
        <div ref={ref} className="animated-card">
            {children}
        </div>
    );
}

// List component with staggered animations
function AnimatedList({ items }) {
    const listRef = useRef();

    useEffect(() => {
        anime({
            targets: listRef.current.children,
            translateX: [-100, 0],
            opacity: [0, 1],
            delay: anime.stagger(100),
            duration: 600,
            easing: 'easeOutExpo'
        });
    }, [items]);

    return (
        <ul ref={listRef}>
            {items.map((item, index) => (
                <li key={index}>{item}</li>
            ))}
        </ul>
    );
}
```

### Vue.js Integration
```vue
<template>
    <div>
        <div ref="animatedElement" class="animated-box">
            {{ content }}
        </div>
        <button @click="playAnimation">Animate</button>
    </div>
</template>

<script>
import anime from 'animejs/lib/anime.es.js';

export default {
    name: 'AnimatedComponent',
    data() {
        return {
            content: 'Animated Content'
        };
    },
    mounted() {
        // Auto-play entrance animation
        this.entranceAnimation();
    },
    methods: {
        entranceAnimation() {
            anime({
                targets: this.$refs.animatedElement,
                translateY: [50, 0],
                opacity: [0, 1],
                scale: [0.8, 1],
                duration: 1000,
                easing: 'easeOutElastic(1, .8)'
            });
        },
        playAnimation() {
            anime({
                targets: this.$refs.animatedElement,
                rotate: '1turn',
                scale: [1, 1.2, 1],
                duration: 800,
                easing: 'easeInOutBack'
            });
        }
    }
};
</script>
```

### Angular Integration
```typescript
import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import anime from 'animejs/lib/anime.es.js';

@Component({
    selector: 'app-animated',
    template: `
        <div #animatedElement class="animated-content">
            <h2>Animated Content</h2>
            <button (click)="triggerAnimation()">Animate</button>
        </div>
    `
})
export class AnimatedComponent implements OnInit {
    @ViewChild('animatedElement', { static: true })
    animatedElement!: ElementRef;

    ngOnInit() {
        this.initAnimation();
    }

    initAnimation() {
        anime({
            targets: this.animatedElement.nativeElement,
            translateY: [30, 0],
            opacity: [0, 1],
            duration: 800,
            easing: 'easeOutCubic'
        });
    }

    triggerAnimation() {
        anime({
            targets: this.animatedElement.nativeElement.children,
            translateX: [0, 20, 0],
            delay: anime.stagger(100),
            duration: 600,
            easing: 'easeInOutSine'
        });
    }
}
```

## NPL-FIM Integration Patterns

### Animation Controller Architecture
```javascript
// Centralized animation controller for NPL-FIM projects
class NPLAnimationController {
    constructor() {
        this.animations = new Map();
        this.defaultEasing = 'easeOutCubic';
        this.defaultDuration = 800;
    }

    // Standard entrance animations
    fadeIn(targets, options = {}) {
        const animation = anime({
            targets,
            opacity: [0, 1],
            translateY: [20, 0],
            duration: this.defaultDuration,
            easing: this.defaultEasing,
            ...options
        });

        this.registerAnimation('fadeIn', animation);
        return animation;
    }

    slideIn(targets, direction = 'left', options = {}) {
        const directions = {
            left: { translateX: [-100, 0] },
            right: { translateX: [100, 0] },
            up: { translateY: [-50, 0] },
            down: { translateY: [50, 0] }
        };

        const animation = anime({
            targets,
            ...directions[direction],
            opacity: [0, 1],
            duration: this.defaultDuration,
            easing: this.defaultEasing,
            ...options
        });

        this.registerAnimation('slideIn', animation);
        return animation;
    }

    // Interactive feedback animations
    emphasize(targets, options = {}) {
        return anime({
            targets,
            scale: [1, 1.05, 1],
            duration: 400,
            easing: 'easeInOutBack',
            ...options
        });
    }

    shake(targets, intensity = 10, options = {}) {
        return anime({
            targets,
            translateX: [
                { value: intensity, duration: 100 },
                { value: -intensity, duration: 100 },
                { value: intensity / 2, duration: 100 },
                { value: 0, duration: 100 }
            ],
            easing: 'easeInOutSine',
            ...options
        });
    }

    // State transition animations
    success(targets, options = {}) {
        return anime({
            targets,
            scale: [1, 1.1, 1],
            backgroundColor: [
                { value: '#2ecc71', duration: 200 },
                { value: 'inherit', duration: 600 }
            ],
            duration: 800,
            easing: 'easeOutElastic(1, .6)',
            ...options
        });
    }

    error(targets, options = {}) {
        const timeline = anime.timeline({ ...options });

        timeline
            .add({
                targets,
                translateX: [0, -10, 10, -5, 5, 0],
                duration: 500,
                easing: 'easeInOutSine'
            })
            .add({
                targets,
                backgroundColor: [
                    { value: '#e74c3c', duration: 200 },
                    { value: 'inherit', duration: 600 }
                ],
                duration: 800
            }, '-=500');

        return timeline;
    }

    // Utility methods
    registerAnimation(name, animation) {
        this.animations.set(name, animation);
    }

    getAnimation(name) {
        return this.animations.get(name);
    }

    pauseAll() {
        this.animations.forEach(animation => animation.pause());
    }

    resumeAll() {
        this.animations.forEach(animation => animation.play());
    }
}

// Global instance for NPL-FIM projects
const nplAnimations = new NPLAnimationController();
```

### Form Interaction Patterns
```javascript
// Enhanced form animations for NPL-FIM user interfaces
class NPLFormAnimations {
    static validateField(field, isValid) {
        if (isValid) {
            anime({
                targets: field,
                borderColor: '#2ecc71',
                scale: [1, 1.02, 1],
                duration: 400,
                easing: 'easeOutBack'
            });
        } else {
            anime({
                targets: field,
                borderColor: '#e74c3c',
                translateX: [0, -10, 10, -5, 5, 0],
                duration: 500,
                easing: 'easeInOutSine'
            });
        }
    }

    static submitProgress(button, steps = ['Submitting...', 'Processing...', 'Complete!']) {
        const timeline = anime.timeline({
            complete: () => button.textContent = 'Submit'
        });

        steps.forEach((text, index) => {
            timeline.add({
                targets: button,
                scale: [1, 0.95, 1],
                duration: 300,
                complete: () => button.textContent = text
            });
        });

        return timeline;
    }

    static fieldFocus(field) {
        anime({
            targets: field,
            scale: [1, 1.02],
            boxShadow: '0 0 0 3px rgba(52, 152, 219, 0.2)',
            duration: 200,
            easing: 'easeOutQuad'
        });
    }

    static fieldBlur(field) {
        anime({
            targets: field,
            scale: 1,
            boxShadow: 'none',
            duration: 200,
            easing: 'easeOutQuad'
        });
    }
}
```

### Page Transition System
```javascript
// Page transition system for NPL-FIM navigation
class NPLPageTransitions {
    static fadeTransition(outElement, inElement, options = {}) {
        const timeline = anime.timeline({
            easing: 'easeInOutCubic',
            ...options
        });

        timeline
            .add({
                targets: outElement,
                opacity: 0,
                translateY: -20,
                duration: 400
            })
            .add({
                targets: inElement,
                opacity: [0, 1],
                translateY: [20, 0],
                duration: 400
            }, '-=200');

        return timeline;
    }

    static slideTransition(outElement, inElement, direction = 'left') {
        const directions = {
            left: { out: -100, in: 100 },
            right: { out: 100, in: -100 }
        };

        const timeline = anime.timeline({
            easing: 'easeInOutExpo'
        });

        timeline
            .add({
                targets: outElement,
                translateX: directions[direction].out + '%',
                opacity: 0,
                duration: 500
            })
            .add({
                targets: inElement,
                translateX: [directions[direction].in + '%', '0%'],
                opacity: [0, 1],
                duration: 500
            }, '-=250');

        return timeline;
    }

    static morphTransition(outElement, inElement) {
        const timeline = anime.timeline({
            easing: 'easeInOutBack'
        });

        timeline
            .add({
                targets: outElement,
                scale: 0.8,
                rotate: -5,
                opacity: 0,
                duration: 600
            })
            .add({
                targets: inElement,
                scale: [0.8, 1],
                rotate: [5, 0],
                opacity: [0, 1],
                duration: 600
            }, '-=300');

        return timeline;
    }
}
```

## Performance Optimization

### Memory Management
```javascript
// Proper animation cleanup
class AnimationManager {
    constructor() {
        this.activeAnimations = [];
    }

    createAnimation(config) {
        const animation = anime(config);
        this.activeAnimations.push(animation);

        // Auto-cleanup on complete
        animation.complete = () => {
            this.removeAnimation(animation);
            if (config.complete) config.complete();
        };

        return animation;
    }

    removeAnimation(animation) {
        const index = this.activeAnimations.indexOf(animation);
        if (index > -1) {
            this.activeAnimations.splice(index, 1);
        }
    }

    pauseAll() {
        this.activeAnimations.forEach(anim => anim.pause());
    }

    destroyAll() {
        this.activeAnimations.forEach(anim => {
            anim.pause();
            anim = null;
        });
        this.activeAnimations = [];
    }
}

// Usage
const animManager = new AnimationManager();

// Create managed animations
animManager.createAnimation({
    targets: '.element',
    translateX: 250,
    duration: 1000
});
```

### GPU Acceleration Optimization
```javascript
// Force hardware acceleration for better performance
function optimizedTransformAnimation(targets, properties) {
    // Trigger hardware acceleration
    anime.set(targets, {
        translateZ: 0  // Force GPU layer
    });

    return anime({
        targets,
        ...properties,
        // Use transform properties for better performance
        complete: function() {
            // Reset hardware acceleration if not needed
            anime.set(targets, {
                translateZ: ''
            });
        }
    });
}

// Batch DOM reads and writes
function performantBatchAnimation(elements, configs) {
    // Batch read phase
    const initialStates = elements.map(el => ({
        element: el,
        rect: el.getBoundingClientRect(),
        computed: getComputedStyle(el)
    }));

    // Batch write phase
    return anime({
        targets: elements,
        ...configs,
        update: function(anim) {
            // Minimize layout thrashing
            requestAnimationFrame(() => {
                // Batch style updates
            });
        }
    });
}
```

### Large Dataset Handling
```javascript
// Efficient animation of large element collections
function animateLargeDataset(selector, animationConfig) {
    const elements = document.querySelectorAll(selector);
    const batchSize = 50;  // Animate in batches

    for (let i = 0; i < elements.length; i += batchSize) {
        const batch = Array.from(elements).slice(i, i + batchSize);

        setTimeout(() => {
            anime({
                targets: batch,
                ...animationConfig,
                delay: anime.stagger(50)
            });
        }, (i / batchSize) * 100);  // Stagger batch starts
    }
}

// Virtual scrolling animation optimization
function virtualScrollAnimation(visibleElements, animationConfig) {
    // Only animate visible elements
    const visibleBounds = {
        top: window.pageYOffset,
        bottom: window.pageYOffset + window.innerHeight
    };

    const elementsInView = visibleElements.filter(el => {
        const rect = el.getBoundingClientRect();
        return rect.top < visibleBounds.bottom && rect.bottom > visibleBounds.top;
    });

    return anime({
        targets: elementsInView,
        ...animationConfig
    });
}
```

## Troubleshooting

### Common Issues and Solutions

#### Animation Not Starting
```javascript
// Issue: Animation doesn't start
// Solution: Check target existence
function safeAnimate(targets, config) {
    const elements = document.querySelectorAll(targets);

    if (elements.length === 0) {
        console.warn(`No elements found for selector: ${targets}`);
        return null;
    }

    return anime({
        targets: elements,
        ...config
    });
}

// Issue: Timing conflicts
// Solution: Use promises for sequential animations
async function sequentialAnimations() {
    try {
        await new Promise(resolve => {
            anime({
                targets: '.first',
                translateX: 100,
                duration: 1000,
                complete: resolve
            });
        });

        await new Promise(resolve => {
            anime({
                targets: '.second',
                translateY: 100,
                duration: 1000,
                complete: resolve
            });
        });
    } catch (error) {
        console.error('Animation sequence failed:', error);
    }
}
```

#### Performance Issues
```javascript
// Issue: Janky animations
// Solution: Optimize for 60fps
function optimizeForPerformance() {
    // Use transform properties instead of layout properties
    anime({
        targets: '.element',
        translateX: 250,    // Good - composite layer
        // left: 250,       // Bad - triggers layout
        scale: 1.5,         // Good - composite layer
        // width: '150%',   // Bad - triggers layout
        opacity: 0.5,       // Good - composite layer
        duration: 1000
    });
}

// Issue: Memory leaks
// Solution: Proper cleanup
class AnimationController {
    constructor() {
        this.animations = [];
    }

    add(animation) {
        this.animations.push(animation);

        // Auto-cleanup
        const originalComplete = animation.complete || (() => {});
        animation.complete = () => {
            this.remove(animation);
            originalComplete();
        };
    }

    remove(animation) {
        const index = this.animations.indexOf(animation);
        if (index > -1) {
            this.animations.splice(index, 1);
        }
    }

    cleanup() {
        this.animations.forEach(anim => anim.pause());
        this.animations = [];
    }
}
```

#### Browser Compatibility
```javascript
// Issue: Cross-browser inconsistencies
// Solution: Feature detection and fallbacks
function crossBrowserAnimation(targets, config) {
    // Check for transform support
    const hasTransformSupport = 'transform' in document.documentElement.style;

    if (!hasTransformSupport) {
        // Fallback for older browsers
        return anime({
            targets,
            left: config.translateX ? '+=' + config.translateX : undefined,
            top: config.translateY ? '+=' + config.translateY : undefined,
            opacity: config.opacity,
            duration: config.duration || 1000
        });
    }

    return anime({
        targets,
        ...config
    });
}

// Polyfill for requestAnimationFrame
if (!window.requestAnimationFrame) {
    window.requestAnimationFrame = function(callback) {
        return setTimeout(callback, 1000 / 60);
    };
}
```

### Debugging Tools
```javascript
// Animation debugging utility
class AnimeDebugger {
    static logAnimation(animation) {
        console.group('Anime.js Animation Debug');
        console.log('Targets:', animation.animatables.map(a => a.target));
        console.log('Duration:', animation.duration + 'ms');
        console.log('Progress:', animation.progress + '%');
        console.log('Current time:', animation.currentTime + 'ms');
        console.log('Properties:', animation.animations);
        console.groupEnd();
    }

    static trackPerformance(animation) {
        const startTime = performance.now();
        let frameCount = 0;

        animation.update = function() {
            frameCount++;
            if (frameCount % 60 === 0) {
                const currentTime = performance.now();
                const fps = 60000 / (currentTime - startTime);
                console.log(`Animation FPS: ${fps.toFixed(2)}`);
            }
        };
    }

    static validateTargets(selector) {
        const elements = document.querySelectorAll(selector);

        if (elements.length === 0) {
            console.error(`No elements found for selector: ${selector}`);
            return false;
        }

        console.log(`Found ${elements.length} elements for: ${selector}`);
        return true;
    }
}

// Usage
const debugAnimation = anime({
    targets: '.debug-element',
    translateX: 250,
    duration: 2000,
    update: function() {
        AnimeDebugger.logAnimation(this);
    }
});

AnimeDebugger.trackPerformance(debugAnimation);
```

## Best Practices

### Code Organization
```javascript
// Centralized animation configuration
const ANIMATION_CONFIG = {
    durations: {
        fast: 300,
        normal: 600,
        slow: 1000
    },
    easings: {
        smooth: 'easeInOutCubic',
        bounce: 'easeOutElastic(1, .6)',
        sharp: 'easeInOutBack'
    },
    delays: {
        short: 100,
        normal: 200,
        long: 500
    }
};

// Reusable animation functions
const animations = {
    fadeIn: (targets, options = {}) => anime({
        targets,
        opacity: [0, 1],
        translateY: [20, 0],
        duration: ANIMATION_CONFIG.durations.normal,
        easing: ANIMATION_CONFIG.easings.smooth,
        ...options
    }),

    slideIn: (targets, direction = 'left', options = {}) => {
        const transforms = {
            left: { translateX: [-100, 0] },
            right: { translateX: [100, 0] },
            up: { translateY: [-50, 0] },
            down: { translateY: [50, 0] }
        };

        return anime({
            targets,
            ...transforms[direction],
            opacity: [0, 1],
            duration: ANIMATION_CONFIG.durations.normal,
            easing: ANIMATION_CONFIG.easings.smooth,
            ...options
        });
    }
};
```

### Accessibility Considerations
```javascript
// Respect user motion preferences
function createAccessibleAnimation(config) {
    // Check for reduced motion preference
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    if (prefersReducedMotion) {
        // Provide reduced motion alternative
        return anime({
            ...config,
            duration: 0,  // Instant transition
            easing: 'linear'
        });
    }

    return anime(config);
}

// Focus management during animations
function animateWithFocus(targets, config) {
    const animation = anime({
        ...config,
        targets,
        begin: function() {
            // Temporarily disable focusable elements
            targets.forEach(el => el.setAttribute('tabindex', '-1'));
        },
        complete: function() {
            // Restore focus capability
            targets.forEach(el => el.removeAttribute('tabindex'));
        }
    });

    return animation;
}
```

### Performance Guidelines
```javascript
// Animation performance checklist
const performanceGuidelines = {
    // DO: Use transform properties
    goodProperties: [
        'translateX', 'translateY', 'translateZ',
        'scale', 'scaleX', 'scaleY',
        'rotateX', 'rotateY', 'rotateZ',
        'opacity'
    ],

    // AVOID: Layout-triggering properties
    avoidProperties: [
        'width', 'height', 'padding', 'margin',
        'left', 'top', 'right', 'bottom',
        'border-width'
    ],

    // Optimal settings
    optimal: {
        duration: 300,  // Sweet spot for perceived performance
        easing: 'easeOutCubic',  // Natural feeling
        stagger: 50  // Sufficient visual separation
    }
};

// Performance monitoring
function monitorAnimationPerformance(animation) {
    let frameCount = 0;
    const startTime = performance.now();

    animation.update = function() {
        frameCount++;

        if (frameCount % 60 === 0) {
            const elapsed = performance.now() - startTime;
            const fps = (frameCount / elapsed) * 1000;

            if (fps < 55) {
                console.warn('Animation performance below 55fps:', fps);
            }
        }
    };
}
```

### Testing Animations
```javascript
// Animation testing utilities
class AnimationTester {
    static async testAnimationCompletion(animationConfig, timeout = 5000) {
        return new Promise((resolve, reject) => {
            const timer = setTimeout(() => {
                reject(new Error('Animation timeout'));
            }, timeout);

            const animation = anime({
                ...animationConfig,
                complete: function() {
                    clearTimeout(timer);
                    resolve(animation);
                }
            });
        });
    }

    static validateAnimationSmootness(animation, minFps = 55) {
        let frameCount = 0;
        let droppedFrames = 0;
        const startTime = performance.now();

        animation.update = function() {
            frameCount++;
            const elapsed = performance.now() - startTime;
            const currentFps = (frameCount / elapsed) * 1000;

            if (currentFps < minFps) {
                droppedFrames++;
            }
        };

        animation.complete = function() {
            const dropRate = (droppedFrames / frameCount) * 100;
            console.log(`Frame drop rate: ${dropRate.toFixed(2)}%`);
        };
    }

    static createTestSuite(animations) {
        const results = [];

        animations.forEach(async (config, index) => {
            try {
                const animation = await this.testAnimationCompletion(config);
                results.push({ index, status: 'passed', animation });
            } catch (error) {
                results.push({ index, status: 'failed', error });
            }
        });

        return results;
    }
}
```

## External Resources

### Official Documentation and Community
- **Official Website**: [https://animejs.com/](https://animejs.com/)
- **GitHub Repository**: [https://github.com/juliangarnier/anime](https://github.com/juliangarnier/anime)
- **API Documentation**: [https://animejs.com/documentation/](https://animejs.com/documentation/)
- **Release Notes**: [https://github.com/juliangarnier/anime/releases](https://github.com/juliangarnier/anime/releases)

### Learning Resources
- **CodePen Collection**: [Anime.js Examples](https://codepen.io/collection/XLebem)
- **Interactive Playground**: [https://animejs.com/documentation/#playground](https://animejs.com/documentation/#playground)
- **Video Tutorials**: [YouTube Anime.js Playlist](https://www.youtube.com/results?search_query=anime.js+tutorial)
- **Community Examples**: [https://github.com/juliangarnier/anime/wiki/Community-examples](https://github.com/juliangarnier/anime/wiki/Community-examples)

### Framework-Specific Resources
- **React Integration**: [React Anime.js Hook](https://github.com/hyperfuse/react-anime)
- **Vue.js Plugin**: [Vue Anime.js](https://github.com/BenAHammond/vue-anime)
- **Angular Integration**: [Angular Anime.js Service](https://www.npmjs.com/package/angular-anime)
- **Svelte Actions**: [Svelte Anime.js Actions](https://github.com/rajasegar/svelte-anime)

### Tools and Utilities
- **Easing Visualizer**: [https://easings.net/](https://easings.net/)
- **Bezier Curve Generator**: [https://cubic-bezier.com/](https://cubic-bezier.com/)
- **SVG Path Editor**: [https://yqnn.github.io/svg-path-editor/](https://yqnn.github.io/svg-path-editor/)
- **Animation Performance Tools**: [Chrome DevTools Animation Inspector](https://developers.google.com/web/tools/chrome-devtools/inspect-styles/animations)

### Related Libraries and Alternatives
- **GSAP**: [https://greensock.com/gsap/](https://greensock.com/gsap/) - Professional animation library
- **Framer Motion**: [https://www.framer.com/motion/](https://www.framer.com/motion/) - React animation library
- **Lottie**: [https://airbnb.design/lottie/](https://airbnb.design/lottie/) - After Effects animation player
- **Three.js**: [https://threejs.org/](https://threejs.org/) - 3D animations and graphics

### Performance and Optimization
- **Web Animation Performance**: [MDN Animation Performance Guide](https://developer.mozilla.org/en-US/docs/Web/Performance/Animation_performance_and_frame_rate)
- **CSS Triggers**: [https://csstriggers.com/](https://csstriggers.com/) - What CSS properties trigger layout/paint
- **Animation Guidelines**: [Google Web Fundamentals](https://web.dev/animations-guide/)
- **Performance Monitoring**: [Web Vitals](https://web.dev/vitals/)

---

*This comprehensive guide covers Anime.js from basic setup to advanced integration patterns. For the latest updates and community contributions, always refer to the official documentation and GitHub repository.*