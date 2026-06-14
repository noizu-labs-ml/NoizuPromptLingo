# Three.js
JavaScript 3D library for WebGL graphics. [Docs](https://threejs.org/docs/) | [Examples](https://threejs.org/examples/)

## Install/Setup
```bash
npm install three  # v0.169.0
# or CDN
<script type="module">
  import * as THREE from 'https://cdn.jsdelivr.net/npm/three@0.169.0/build/three.module.js';
</script>
```

## Basic Usage
```javascript
// Minimal rotating cube
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

const geometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
const cube = new THREE.Mesh(geometry, material);
scene.add(cube);
camera.position.z = 5;

function animate() {
  requestAnimationFrame(animate);
  cube.rotation.x += 0.01;
  cube.rotation.y += 0.01;
  renderer.render(scene, camera);
}
animate();
```

## Strengths
- Full 3D graphics capabilities
- WebGL, WebGL2, WebGPU support
- Extensive material and lighting system
- VR/AR support
- Large ecosystem and community

## Limitations
- Complex API for simple tasks
- Performance overhead for 2D
- Large library size (600KB+)
- Requires 3D graphics knowledge

## Best For
`3d-data-visualization`, `interactive-3d-models`, `vr-experiences`, `game-graphics`, `scientific-simulations`