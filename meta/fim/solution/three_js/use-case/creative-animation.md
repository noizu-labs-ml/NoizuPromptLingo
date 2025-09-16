# Three.js Creative Animation Use Case

## Overview
Three.js enables sophisticated creative animations with particle systems, procedural generation, and shader programming for artistic and interactive experiences.

## NPL-FIM Integration
```npl
@fim:three_js {
  animation_type: "particle_system"
  particle_count: 10000
  physics_simulation: true
  shader_effects: ["vertex_displacement", "fragment_glow"]
  audio_reactive: true
}
```

## Common Implementation
```javascript
// Create particle animation system
const particleCount = 10000;
const particles = new THREE.BufferGeometry();
const positions = new Float32Array(particleCount * 3);
const velocities = new Float32Array(particleCount * 3);

for (let i = 0; i < particleCount * 3; i += 3) {
  positions[i] = (Math.random() - 0.5) * 100;
  positions[i + 1] = (Math.random() - 0.5) * 100;
  positions[i + 2] = (Math.random() - 0.5) * 100;

  velocities[i] = (Math.random() - 0.5) * 0.1;
  velocities[i + 1] = (Math.random() - 0.5) * 0.1;
  velocities[i + 2] = (Math.random() - 0.5) * 0.1;
}

particles.setAttribute('position', new THREE.BufferAttribute(positions, 3));
particles.setAttribute('velocity', new THREE.BufferAttribute(velocities, 3));

const material = new THREE.ShaderMaterial({
  vertexShader: `
    attribute vec3 velocity;
    uniform float time;
    void main() {
      vec3 pos = position + velocity * time;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
      gl_PointSize = 2.0;
    }
  `,
  fragmentShader: `
    void main() {
      gl_FragColor = vec4(1.0, 0.5, 0.0, 0.8);
    }
  `
});

const particleSystem = new THREE.Points(particles, material);
scene.add(particleSystem);
```

## Use Cases
- Interactive art installations
- Music visualization and audio-reactive content
- Brand experiences and marketing campaigns
- Educational simulations and demonstrations
- Creative coding and generative art

## NPL-FIM Benefits
- Simplified particle system configuration
- Automated shader compilation
- Performance optimization for large particle counts
- Audio analysis integration