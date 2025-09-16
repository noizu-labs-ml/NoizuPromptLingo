# PlayCanvas - 3D Web Apps Engine

## Installation
```bash
npm install playcanvas
```

## CDN
```html
<script src="https://code.playcanvas.com/playcanvas-stable.min.js"></script>
```

## Basic Scene
```javascript
// Create canvas and application
const canvas = document.getElementById('application');
const app = new pc.Application(canvas);

// Set canvas fill mode and resolution
app.setCanvasFillMode(pc.FILLMODE_FILL_WINDOW);
app.setCanvasResolution(pc.RESOLUTION_AUTO);

// Start the application
app.start();

// Create camera
const camera = new pc.Entity('camera');
camera.addComponent('camera', {
  clearColor: new pc.Color(0.5, 0.6, 0.9)
});
camera.setPosition(0, 2, 5);
camera.lookAt(0, 0, 0);
app.root.addChild(camera);

// Create light
const light = new pc.Entity('light');
light.addComponent('light', {
  type: 'directional',
  color: new pc.Color(1, 1, 1),
  intensity: 1
});
light.setEulerAngles(45, 30, 0);
app.root.addChild(light);

// Create box with material
const box = new pc.Entity('cube');
box.addComponent('model', {
  type: 'box'
});
box.addComponent('material', {
  material: new pc.StandardMaterial()
});
box.material.material.diffuse = new pc.Color(1, 0, 0);
box.material.material.update();

// Add rotation script
box.addComponent('script');
box.script.create('rotate', {
  attributes: {
    speed: 30
  }
});
app.root.addChild(box);

// Update loop
app.on('update', (dt) => {
  box.rotate(0, 30 * dt, 0);
});
```

## Strengths
- Lightweight and performant
- Built-in editor (cloud-based)
- WebGL 2.0 support
- Real-time collaboration features
- Excellent mobile performance

## Limitations
- Smaller community compared to Three.js
- Editor-centric workflow may not suit all projects
- Limited third-party plugins

## Best Use Cases
- HTML5 games
- Product visualizations
- Interactive advertisements
- Mobile web experiences
- Real-time collaborative 3D projects