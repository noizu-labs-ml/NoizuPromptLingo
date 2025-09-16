# A-Frame - Web VR/AR Framework

## Installation
```bash
npm install aframe
```

## CDN
```html
<script src="https://aframe.io/releases/1.5.0/aframe.min.js"></script>
```

## Basic Scene
```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://aframe.io/releases/1.5.0/aframe.min.js"></script>
</head>
<body>
  <a-scene>
    <!-- Environment -->
    <a-sky color="#ECECEC"></a-sky>

    <!-- Primitives -->
    <a-box position="-1 0.5 -3" rotation="0 45 0" color="#4CC3D9"></a-box>
    <a-sphere position="0 1.25 -5" radius="1.25" color="#EF2D5E"></a-sphere>
    <a-cylinder position="1 0.75 -3" radius="0.5" height="1.5" color="#FFC65D"></a-cylinder>
    <a-plane position="0 0 -4" rotation="-90 0 0" width="4" height="4" color="#7BC8A4"></a-plane>

    <!-- Camera with controls -->
    <a-entity camera look-controls wasd-controls position="0 1.6 0"></a-entity>
  </a-scene>
</body>
</html>
```

## JavaScript Integration
```javascript
// Create entity programmatically
const scene = document.querySelector('a-scene');
const box = document.createElement('a-box');
box.setAttribute('position', '0 2 -5');
box.setAttribute('animation', 'property: rotation; to: 0 360 0; loop: true; dur: 2000');
scene.appendChild(box);

// Component system
AFRAME.registerComponent('spin', {
  tick: function() {
    this.el.object3D.rotation.y += 0.01;
  }
});
```

## Strengths
- Declarative HTML syntax
- Built-in VR/AR support
- Large component ecosystem
- Easy to learn
- Works on all VR headsets

## Limitations
- Performance overhead from entity-component system
- Limited for non-VR desktop experiences
- Less control over rendering pipeline

## Best Use Cases
- VR/AR experiences
- 360° content viewers
- Educational simulations
- Rapid prototyping
- WebXR applications