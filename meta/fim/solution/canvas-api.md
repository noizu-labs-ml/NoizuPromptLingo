# HTML5 Canvas API

Native browser API for 2D graphics and animations.

## Core Features
- 2D drawing context
- Pixel manipulation
- Path drawing
- Transformations

## Basic Setup
```javascript
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
canvas.width = 800;
canvas.height = 600;
```

## Canvas Drawing Examples
```javascript
// Basic shapes
ctx.fillStyle = 'red';
ctx.fillRect(10, 10, 100, 100);

ctx.strokeStyle = 'blue';
ctx.lineWidth = 5;
ctx.strokeRect(150, 10, 100, 100);

// Circles and arcs
ctx.beginPath();
ctx.arc(100, 200, 50, 0, Math.PI * 2);
ctx.fillStyle = 'green';
ctx.fill();
ctx.stroke();

// Paths
ctx.beginPath();
ctx.moveTo(300, 100);
ctx.lineTo(400, 150);
ctx.lineTo(350, 200);
ctx.closePath();
ctx.fillStyle = 'orange';
ctx.fill();

// Text
ctx.font = '30px Arial';
ctx.fillStyle = 'black';
ctx.fillText('Hello Canvas', 50, 300);
ctx.strokeText('Outlined Text', 50, 350);

// Gradients
const gradient = ctx.createLinearGradient(0, 0, 200, 0);
gradient.addColorStop(0, 'red');
gradient.addColorStop(0.5, 'yellow');
gradient.addColorStop(1, 'green');
ctx.fillStyle = gradient;
ctx.fillRect(400, 200, 200, 100);

// Patterns
const img = new Image();
img.onload = function() {
  const pattern = ctx.createPattern(img, 'repeat');
  ctx.fillStyle = pattern;
  ctx.fillRect(0, 0, 300, 300);
};
img.src = 'pattern.png';

// Transformations
ctx.save();
ctx.translate(100, 100);
ctx.rotate(Math.PI / 4);
ctx.fillRect(-50, -50, 100, 100);
ctx.restore();

// Image manipulation
const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
const data = imageData.data;
for (let i = 0; i < data.length; i += 4) {
  data[i] = 255 - data[i];     // Red
  data[i + 1] = 255 - data[i + 1]; // Green
  data[i + 2] = 255 - data[i + 2]; // Blue
}
ctx.putImageData(imageData, 0, 0);

// Animation loop
function animate() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Draw animated content
  const x = Math.sin(Date.now() * 0.001) * 100 + 200;
  ctx.beginPath();
  ctx.arc(x, 200, 30, 0, Math.PI * 2);
  ctx.fill();

  requestAnimationFrame(animate);
}
animate();
```

## NPL-FIM Integration
```javascript
// Canvas utility patterns
const canvasUtils = {
  drawParticles: (ctx, particles) => {
    particles.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fillStyle = p.color;
      ctx.fill();
    });
  },

  drawWave: (ctx, amplitude, frequency, phase) => {
    ctx.beginPath();
    for (let x = 0; x < ctx.canvas.width; x++) {
      const y = ctx.canvas.height / 2 + amplitude * Math.sin((x * frequency) + phase);
      if (x === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.stroke();
  },

  fadeEffect: (ctx, alpha = 0.1) => {
    ctx.fillStyle = `rgba(0, 0, 0, ${alpha})`;
    ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
  }
};
```

## Key Methods
- fillRect/strokeRect: Rectangles
- arc(): Circles and arcs
- beginPath/closePath: Path control
- save/restore: State management
- getImageData/putImageData: Pixel access