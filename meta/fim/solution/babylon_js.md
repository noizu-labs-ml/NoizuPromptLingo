# Babylon.js - Powerful 3D Engine

## Installation
```bash
npm install babylonjs babylonjs-loaders
```

## CDN
```html
<script src="https://cdn.babylonjs.com/babylon.js"></script>
<script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>
```

## Basic Scene
```javascript
// Create canvas and engine
const canvas = document.getElementById("renderCanvas");
const engine = new BABYLON.Engine(canvas, true);

// Create scene
const scene = new BABYLON.Scene(engine);

// Add camera
const camera = new BABYLON.UniversalCamera("camera",
  new BABYLON.Vector3(0, 5, -10), scene);
camera.setTarget(BABYLON.Vector3.Zero());
camera.attachControl(canvas, true);

// Add light
const light = new BABYLON.HemisphericLight("light",
  new BABYLON.Vector3(0, 1, 0), scene);

// Create box
const box = BABYLON.MeshBuilder.CreateBox("box", {size: 2}, scene);
box.material = new BABYLON.StandardMaterial("mat", scene);
box.material.diffuseColor = new BABYLON.Color3(0, 1, 0);

// Render loop
engine.runRenderLoop(() => {
  scene.render();
});

// Handle resize
window.addEventListener("resize", () => {
  engine.resize();
});
```

## Strengths
- Full-featured 3D engine with PBR, physics, particles
- Excellent documentation and playground
- WebGPU support
- Built-in inspector and debugging tools
- Large asset library

## Limitations
- Larger file size (2MB+ core)
- Steeper learning curve for beginners
- Overkill for simple 3D visualizations

## Best Use Cases
- Complex 3D games and simulations
- Product configurators
- Architectural visualization
- Scientific data visualization
- VR/AR applications