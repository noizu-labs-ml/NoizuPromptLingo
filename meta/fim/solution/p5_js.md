# p5.js
Creative coding library for interactive graphics and animations. [Docs](https://p5js.org/reference/) | [Examples](https://p5js.org/examples/)

## Install/Setup
```bash
npm install p5  # Node.js
# Or CDN for browser
<script src="https://cdn.jsdelivr.net/npm/p5@1.9.0/lib/p5.min.js"></script>
# Or online editor: https://editor.p5js.org/
```

## Basic Usage
```javascript
function setup() {
  createCanvas(400, 400);
}

function draw() {
  background(220);
  fill(255, 0, 0);
  circle(mouseX, mouseY, 50);

  // Data visualization example
  for(let i = 0; i < data.length; i++) {
    rect(i * 40, height - data[i], 35, data[i]);
  }
}
```

## Strengths
- Immediate mode rendering for animations
- Built-in physics and particle systems
- Easy mouse/touch interaction handling
- WebGL support for 3D graphics
- Sound and video manipulation capabilities

## Limitations
- Not optimized for large datasets
- Limited chart types compared to dedicated libraries
- Performance overhead for simple static visualizations

## Best For
`generative-art`, `data-art`, `interactive-installations`, `educational-visualizations`, `creative-coding`