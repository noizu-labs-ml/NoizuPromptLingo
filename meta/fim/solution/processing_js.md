# Processing.js Creative Coding

JavaScript port of Processing language for creative coding.

## Core Features
- Processing syntax in JS
- 2D/3D graphics
- Interactive sketches
- Animation loops

## Basic Setup
```javascript
// CDN: https://cdnjs.cloudflare.com/ajax/libs/processing.js/1.6.6/processing.min.js
// Or use p5.js as modern alternative: https://cdn.jsdelivr.net/npm/p5@1.7.0/lib/p5.min.js
```

## Processing Sketches
```javascript
// Basic sketch (Processing syntax)
void setup() {
  size(640, 480);
  background(255);
  frameRate(30);
}

void draw() {
  fill(random(255), random(255), random(255), 50);
  ellipse(mouseX, mouseY, 50, 50);
}

// JavaScript mode with p5.js
function setup() {
  createCanvas(640, 480);
  background(220);
}

function draw() {
  if (mouseIsPressed) {
    fill(0);
  } else {
    fill(255);
  }
  ellipse(mouseX, mouseY, 80, 80);
}

// Generative art example
let particles = [];

function setup() {
  createCanvas(windowWidth, windowHeight);
  for (let i = 0; i < 100; i++) {
    particles.push({
      x: random(width),
      y: random(height),
      vx: random(-1, 1),
      vy: random(-1, 1)
    });
  }
}

function draw() {
  background(0, 10);
  stroke(255, 50);
  particles.forEach(p => {
    p.x += p.vx;
    p.y += p.vy;
    if (p.x < 0 || p.x > width) p.vx *= -1;
    if (p.y < 0 || p.y > height) p.vy *= -1;

    particles.forEach(other => {
      let d = dist(p.x, p.y, other.x, other.y);
      if (d < 100) {
        line(p.x, p.y, other.x, other.y);
      }
    });
  });
}

// 3D graphics
function setup() {
  createCanvas(640, 480, WEBGL);
}

function draw() {
  background(200);
  rotateX(frameCount * 0.01);
  rotateY(frameCount * 0.01);
  box(200);
}
```

## NPL-FIM Integration
```javascript
// Creative coding patterns
const processingPatterns = {
  perlinFlow: () => {
    let noiseScale = 0.02;
    for (let x = 0; x < width; x++) {
      let noiseVal = noise(x * noiseScale, millis() * 0.0001);
      stroke(0);
      line(x, height/2 + noiseVal * 100, x, height/2 - noiseVal * 100);
    }
  },

  mandala: (segments) => {
    push();
    translate(width/2, height/2);
    for (let i = 0; i < segments; i++) {
      rotate(TWO_PI / segments);
      line(0, 0, 100, 0);
      ellipse(100, 0, 20, 20);
    }
    pop();
  }
};
```

## Key Functions
- setup(): Initialize sketch
- draw(): Animation loop
- createCanvas(): Set dimensions
- background(): Clear screen
- fill/stroke: Set colors