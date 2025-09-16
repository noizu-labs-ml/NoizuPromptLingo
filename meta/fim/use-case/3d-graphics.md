# 3D Graphics
WebGL scenes, 3D data visualization, and volumetric rendering.
[Documentation](https://threejs.org/docs/)

## WWHW
**What**: Creating interactive 3D scenes, volumetric visualizations, and immersive graphics experiences.
**Why**: Represent complex spatial data, create engaging user experiences, and visualize 3D concepts.
**How**: Using Three.js, WebGL, or specialized 3D libraries with NPL-FIM for data-driven 3D content.
**When**: Scientific visualization, CAD previews, gaming interfaces, architectural walkthroughs.

## When to Use
- Visualizing scientific or medical data in three dimensions
- Creating interactive product showcases or CAD previews
- Building immersive data exploration environments
- Developing WebGL games or simulations
- Rendering architectural or engineering models

## Key Outputs
`webgl`, `gltf-models`, `canvas-3d`, `shader-code`

## Quick Example
```javascript
// Three.js scene with NPL-FIM data integration
import * as THREE from 'three';

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer();

// Create data-driven 3D visualization
const geometry = new THREE.BoxGeometry();
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

## Extended Reference
- [Three.js Documentation](https://threejs.org/docs/index.html) - 3D JavaScript library
- [WebGL Fundamentals](https://webglfundamentals.org/) - Low-level 3D graphics
- [A-Frame](https://aframe.io/) - Web VR framework
- [Babylon.js](https://www.babylonjs.com/) - 3D engine for web
- [D3.js 3D Examples](https://bl.ocks.org/vasturiano/02affe306ce445e423f992faeea13521) - Data-driven 3D
- [WebGL2 Samples](https://www.khronos.org/webgl/wiki/WebGL2) - Advanced techniques