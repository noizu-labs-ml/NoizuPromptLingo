# Creative Animation
Generative art, procedural graphics, and dynamic visual experiences.
[Documentation](https://p5js.org/reference/)

## WWHW
**What**: Creating dynamic, animated graphics through code including generative art and motion graphics.
**Why**: Produce unique visual experiences, explore algorithmic creativity, and create engaging interfaces.
**How**: Using P5.js, Canvas API, or WebGL with NPL-FIM for data-responsive creative coding.
**When**: Digital art projects, interactive installations, UI animations, creative data visualization.

## When to Use
- Building interactive art installations or digital exhibitions
- Creating unique visual identities through algorithmic design
- Developing engaging UI animations and micro-interactions
- Exploring data through creative and artistic visualization
- Prototyping generative design systems for branding

## Key Outputs
`canvas-animation`, `svg-motion`, `shader-art`, `interactive-sketches`

## Quick Example
```javascript
// P5.js generative art with NPL-FIM data
function setup() {
    createCanvas(800, 600);
    colorMode(HSB, 360, 100, 100);
}

function draw() {
    background(220, 20, 95);

    // Data-driven generative pattern
    for (let i = 0; i < 50; i++) {
        let x = noise(i * 0.1, frameCount * 0.01) * width;
        let y = noise(i * 0.1 + 1000, frameCount * 0.01) * height;
        let hue = (frameCount + i * 10) % 360;

        fill(hue, 80, 90, 0.7);
        noStroke();
        ellipse(x, y, 20, 20);
    }
}

// Responsive to data changes
function updateVisualization(newData) {
    // NPL-FIM integration point
    dataPoints = newData;
    redraw();
}
```

## Extended Reference
- [P5.js Reference](https://p5js.org/reference/) - Creative coding library
- [OpenProcessing](https://openprocessing.org/) - Creative coding community
- [Shader Park](https://shaderpark.com/) - 3D shader art platform
- [Canvas API](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API) - 2D graphics
- [Creative Coding Books](https://mitpress.mit.edu/books/generative-design) - Design methodology
- [Observable Creative Coding](https://observablehq.com/@makio135/creative-coding) - Interactive examples