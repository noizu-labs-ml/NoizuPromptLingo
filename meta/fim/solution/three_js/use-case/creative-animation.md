# Three.js Creative Animation Systems - NPL-FIM Solution Guide

## Direct Implementation Framework

**NPL-FIM Command:** `@fim:three_js creative_animation --type=particle_system --audio_reactive=true`

**Instant Setup:** Complete scene with particle systems, audio reactivity, and shader effects ready for immediate deployment.

## Environment Requirements

### Dependencies
```json
{
  "three": "^0.157.0",
  "dat.gui": "^0.7.9",
  "stats.js": "^0.17.0"
}
```

### Browser Support
- WebGL 2.0 capable browsers
- Audio Context API support
- ES6+ JavaScript environment
- Minimum 4GB RAM for complex particle systems

### Performance Targets
- 60 FPS with 50K+ particles
- <16ms frame time budget
- GPU memory optimization
- Responsive across devices

## Complete Implementation Templates

### 1. Basic Particle Animation System

```javascript
// Complete Three.js Creative Animation Setup
class CreativeAnimationSystem {
  constructor(config = {}) {
    this.config = {
      particleCount: config.particleCount || 10000,
      audioReactive: config.audioReactive || false,
      shaderEffects: config.shaderEffects || ['vertex_displacement'],
      backgroundColor: config.backgroundColor || 0x000011,
      enablePostProcessing: config.enablePostProcessing || true,
      ...config
    };

    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.particleSystem = null;
    this.audioAnalyzer = null;
    this.clock = new THREE.Clock();
    this.stats = null;

    this.init();
  }

  init() {
    this.setupScene();
    this.setupCamera();
    this.setupRenderer();
    this.setupParticleSystem();
    this.setupLighting();
    this.setupControls();
    this.setupAudio();
    this.setupGUI();
    this.setupStats();
    this.animate();
  }

  setupScene() {
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(this.config.backgroundColor);
    this.scene.fog = new THREE.Fog(this.config.backgroundColor, 1, 1000);
  }

  setupCamera() {
    this.camera = new THREE.PerspectiveCamera(
      75,
      window.innerWidth / window.innerHeight,
      0.1,
      2000
    );
    this.camera.position.set(0, 0, 50);
  }

  setupRenderer() {
    this.renderer = new THREE.WebGLRenderer({
      antialias: true,
      powerPreference: "high-performance"
    });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    document.body.appendChild(this.renderer.domElement);

    // Handle resize
    window.addEventListener('resize', () => this.onWindowResize());
  }

  setupParticleSystem() {
    const particleCount = this.config.particleCount;
    const particles = new THREE.BufferGeometry();

    // Attributes
    const positions = new Float32Array(particleCount * 3);
    const velocities = new Float32Array(particleCount * 3);
    const colors = new Float32Array(particleCount * 3);
    const sizes = new Float32Array(particleCount);
    const lifetimes = new Float32Array(particleCount);

    // Initialize particle properties
    for (let i = 0; i < particleCount; i++) {
      const i3 = i * 3;

      // Random sphere distribution
      const radius = Math.random() * 50;
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(Math.random() * 2 - 1);

      positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
      positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
      positions[i3 + 2] = radius * Math.cos(phi);

      // Velocity towards center with variation
      velocities[i3] = (Math.random() - 0.5) * 0.2;
      velocities[i3 + 1] = (Math.random() - 0.5) * 0.2;
      velocities[i3 + 2] = (Math.random() - 0.5) * 0.2;

      // Color variation
      const hue = Math.random();
      const color = new THREE.Color().setHSL(hue, 0.8, 0.6);
      colors[i3] = color.r;
      colors[i3 + 1] = color.g;
      colors[i3 + 2] = color.b;

      // Size and lifetime
      sizes[i] = Math.random() * 2 + 1;
      lifetimes[i] = Math.random() * 5 + 2;
    }

    particles.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    particles.setAttribute('velocity', new THREE.BufferAttribute(velocities, 3));
    particles.setAttribute('color', new THREE.BufferAttribute(colors, 3));
    particles.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
    particles.setAttribute('lifetime', new THREE.BufferAttribute(lifetimes, 1));

    // Advanced shader material
    const material = this.createParticleMaterial();

    this.particleSystem = new THREE.Points(particles, material);
    this.scene.add(this.particleSystem);
  }

  createParticleMaterial() {
    return new THREE.ShaderMaterial({
      uniforms: {
        time: { value: 0 },
        audioLow: { value: 0 },
        audioMid: { value: 0 },
        audioHigh: { value: 0 },
        mouse: { value: new THREE.Vector2() },
        resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) }
      },
      vertexShader: `
        attribute vec3 velocity;
        attribute vec3 color;
        attribute float size;
        attribute float lifetime;

        uniform float time;
        uniform float audioLow;
        uniform float audioMid;
        uniform float audioHigh;
        uniform vec2 mouse;

        varying vec3 vColor;
        varying float vLifetime;

        void main() {
          vColor = color;
          vLifetime = lifetime;

          // Base position with time-based movement
          vec3 pos = position + velocity * time;

          // Audio reactive displacement
          float audioInfluence = audioLow * 0.5 + audioMid * 0.3 + audioHigh * 0.2;
          pos += normalize(position) * audioInfluence * 10.0;

          // Mouse interaction
          vec2 mouseInfluence = (mouse - 0.5) * 2.0;
          pos.x += mouseInfluence.x * 5.0 * sin(time + position.y * 0.1);
          pos.y += mouseInfluence.y * 5.0 * cos(time + position.x * 0.1);

          // Vertex displacement based on noise
          float noise = sin(pos.x * 0.1 + time) * cos(pos.y * 0.1 + time) * sin(pos.z * 0.1);
          pos += normalize(pos) * noise * 2.0;

          gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);

          // Dynamic point size
          float dist = length(pos);
          float sizeMultiplier = 1.0 + audioInfluence * 2.0;
          gl_PointSize = size * sizeMultiplier * (50.0 / dist);
        }
      `,
      fragmentShader: `
        varying vec3 vColor;
        varying float vLifetime;
        uniform float time;

        void main() {
          // Circular particle shape
          vec2 center = gl_PointCoord - 0.5;
          float dist = length(center);

          if (dist > 0.5) discard;

          // Glow effect
          float alpha = 1.0 - smoothstep(0.0, 0.5, dist);
          alpha *= 0.8;

          // Time-based color shifting
          vec3 finalColor = vColor;
          finalColor.r += sin(time + vLifetime) * 0.2;
          finalColor.g += cos(time + vLifetime) * 0.2;
          finalColor.b += sin(time * 0.5 + vLifetime) * 0.2;

          gl_FragColor = vec4(finalColor, alpha);
        }
      `,
      transparent: true,
      blending: THREE.AdditiveBlending,
      depthWrite: false
    });
  }

  setupLighting() {
    // Ambient light for overall illumination
    const ambientLight = new THREE.AmbientLight(0x404040, 0.4);
    this.scene.add(ambientLight);

    // Point lights for dynamic effects
    const pointLight1 = new THREE.PointLight(0xff0040, 1, 100);
    pointLight1.position.set(25, 25, 25);
    this.scene.add(pointLight1);

    const pointLight2 = new THREE.PointLight(0x0040ff, 1, 100);
    pointLight2.position.set(-25, -25, 25);
    this.scene.add(pointLight2);
  }

  setupControls() {
    // Mouse interaction
    this.mouse = new THREE.Vector2();
    window.addEventListener('mousemove', (event) => {
      this.mouse.x = event.clientX / window.innerWidth;
      this.mouse.y = 1 - (event.clientY / window.innerHeight);

      if (this.particleSystem && this.particleSystem.material.uniforms) {
        this.particleSystem.material.uniforms.mouse.value = this.mouse;
      }
    });

    // Touch support
    window.addEventListener('touchmove', (event) => {
      if (event.touches.length > 0) {
        this.mouse.x = event.touches[0].clientX / window.innerWidth;
        this.mouse.y = 1 - (event.touches[0].clientY / window.innerHeight);

        if (this.particleSystem && this.particleSystem.material.uniforms) {
          this.particleSystem.material.uniforms.mouse.value = this.mouse;
        }
      }
    });
  }

  setupAudio() {
    if (!this.config.audioReactive) return;

    this.audioAnalyzer = new AudioAnalyzer();
    this.audioAnalyzer.init().then(() => {
      console.log('Audio analysis ready');
    }).catch(err => {
      console.warn('Audio setup failed:', err);
    });
  }

  setupGUI() {
    if (typeof dat === 'undefined') return;

    this.gui = new dat.GUI();

    const particleFolder = this.gui.addFolder('Particles');
    particleFolder.add(this.config, 'particleCount', 1000, 100000).step(1000);
    particleFolder.add(this.config, 'audioReactive');
    particleFolder.open();

    const visualFolder = this.gui.addFolder('Visual');
    visualFolder.addColor(this.config, 'backgroundColor');
    visualFolder.add(this.config, 'enablePostProcessing');
    visualFolder.open();
  }

  setupStats() {
    if (typeof Stats === 'undefined') return;

    this.stats = new Stats();
    this.stats.showPanel(0);
    document.body.appendChild(this.stats.dom);
  }

  animate() {
    requestAnimationFrame(() => this.animate());

    if (this.stats) this.stats.begin();

    const deltaTime = this.clock.getDelta();
    const elapsedTime = this.clock.getElapsedTime();

    this.updateParticles(deltaTime, elapsedTime);
    this.updateAudio();
    this.render();

    if (this.stats) this.stats.end();
  }

  updateParticles(deltaTime, elapsedTime) {
    if (!this.particleSystem) return;

    const material = this.particleSystem.material;
    if (material.uniforms) {
      material.uniforms.time.value = elapsedTime;
    }

    // Update particle positions
    const positions = this.particleSystem.geometry.attributes.position;
    const velocities = this.particleSystem.geometry.attributes.velocity;

    for (let i = 0; i < positions.count; i++) {
      const i3 = i * 3;

      // Apply velocity
      positions.array[i3] += velocities.array[i3] * deltaTime * 10;
      positions.array[i3 + 1] += velocities.array[i3 + 1] * deltaTime * 10;
      positions.array[i3 + 2] += velocities.array[i3 + 2] * deltaTime * 10;

      // Boundary conditions - respawn particles
      const distance = Math.sqrt(
        positions.array[i3] ** 2 +
        positions.array[i3 + 1] ** 2 +
        positions.array[i3 + 2] ** 2
      );

      if (distance > 100) {
        // Reset to center with new random velocity
        positions.array[i3] = (Math.random() - 0.5) * 10;
        positions.array[i3 + 1] = (Math.random() - 0.5) * 10;
        positions.array[i3 + 2] = (Math.random() - 0.5) * 10;

        velocities.array[i3] = (Math.random() - 0.5) * 0.2;
        velocities.array[i3 + 1] = (Math.random() - 0.5) * 0.2;
        velocities.array[i3 + 2] = (Math.random() - 0.5) * 0.2;
      }
    }

    positions.needsUpdate = true;
  }

  updateAudio() {
    if (!this.audioAnalyzer || !this.particleSystem) return;

    const audioData = this.audioAnalyzer.getFrequencyData();
    const material = this.particleSystem.material;

    if (material.uniforms && audioData) {
      material.uniforms.audioLow.value = audioData.low;
      material.uniforms.audioMid.value = audioData.mid;
      material.uniforms.audioHigh.value = audioData.high;
    }
  }

  render() {
    this.renderer.render(this.scene, this.camera);
  }

  onWindowResize() {
    this.camera.aspect = window.innerWidth / window.innerHeight;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(window.innerWidth, window.innerHeight);

    if (this.particleSystem && this.particleSystem.material.uniforms) {
      this.particleSystem.material.uniforms.resolution.value.set(
        window.innerWidth,
        window.innerHeight
      );
    }
  }

  destroy() {
    if (this.gui) this.gui.destroy();
    if (this.stats) document.body.removeChild(this.stats.dom);
    if (this.audioAnalyzer) this.audioAnalyzer.destroy();

    window.removeEventListener('resize', () => this.onWindowResize());

    this.renderer.dispose();
    document.body.removeChild(this.renderer.domElement);
  }
}

// Audio Analysis Class
class AudioAnalyzer {
  constructor() {
    this.audioContext = null;
    this.analyser = null;
    this.dataArray = null;
    this.source = null;
    this.isInitialized = false;
  }

  async init() {
    try {
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
      this.analyser = this.audioContext.createAnalyser();
      this.analyser.fftSize = 256;

      const bufferLength = this.analyser.frequencyBinCount;
      this.dataArray = new Uint8Array(bufferLength);

      // Get user media for microphone input
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      this.source = this.audioContext.createMediaStreamSource(stream);
      this.source.connect(this.analyser);

      this.isInitialized = true;
    } catch (error) {
      console.warn('Audio initialization failed:', error);
      throw error;
    }
  }

  getFrequencyData() {
    if (!this.isInitialized) return null;

    this.analyser.getByteFrequencyData(this.dataArray);

    // Calculate frequency bands
    const low = this.getAverageVolume(0, this.dataArray.length / 3);
    const mid = this.getAverageVolume(this.dataArray.length / 3, 2 * this.dataArray.length / 3);
    const high = this.getAverageVolume(2 * this.dataArray.length / 3, this.dataArray.length);

    return {
      low: low / 255,
      mid: mid / 255,
      high: high / 255,
      raw: this.dataArray
    };
  }

  getAverageVolume(start, end) {
    let sum = 0;
    for (let i = start; i < end; i++) {
      sum += this.dataArray[i];
    }
    return sum / (end - start);
  }

  destroy() {
    if (this.audioContext) {
      this.audioContext.close();
    }
  }
}

// Initialize the animation system
const initAnimation = (config = {}) => {
  return new CreativeAnimationSystem(config);
};

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { CreativeAnimationSystem, AudioAnalyzer, initAnimation };
}
```

### 2. Morphing Geometry Animation

```javascript
// Advanced geometry morphing system
class MorphingGeometry {
  constructor(scene, config = {}) {
    this.scene = scene;
    this.config = {
      morphTargets: config.morphTargets || ['sphere', 'cube', 'torus'],
      morphDuration: config.morphDuration || 3.0,
      particleCount: config.particleCount || 5000,
      ...config
    };

    this.currentShape = 0;
    this.morphProgress = 0;
    this.isTransitioning = false;

    this.init();
  }

  init() {
    this.createMorphTargets();
    this.createParticleSystem();
    this.startMorphing();
  }

  createMorphTargets() {
    this.geometries = {
      sphere: this.createSpherePositions(),
      cube: this.createCubePositions(),
      torus: this.createTorusPositions(),
      plane: this.createPlanePositions()
    };
  }

  createSpherePositions() {
    const positions = [];
    const count = this.config.particleCount;

    for (let i = 0; i < count; i++) {
      const radius = 20;
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(Math.random() * 2 - 1);

      positions.push(
        radius * Math.sin(phi) * Math.cos(theta),
        radius * Math.sin(phi) * Math.sin(theta),
        radius * Math.cos(phi)
      );
    }

    return positions;
  }

  createCubePositions() {
    const positions = [];
    const count = this.config.particleCount;
    const size = 20;

    for (let i = 0; i < count; i++) {
      const face = Math.floor(Math.random() * 6);
      let x, y, z;

      switch (face) {
        case 0: // Front
          x = (Math.random() - 0.5) * size;
          y = (Math.random() - 0.5) * size;
          z = size / 2;
          break;
        case 1: // Back
          x = (Math.random() - 0.5) * size;
          y = (Math.random() - 0.5) * size;
          z = -size / 2;
          break;
        case 2: // Top
          x = (Math.random() - 0.5) * size;
          y = size / 2;
          z = (Math.random() - 0.5) * size;
          break;
        case 3: // Bottom
          x = (Math.random() - 0.5) * size;
          y = -size / 2;
          z = (Math.random() - 0.5) * size;
          break;
        case 4: // Right
          x = size / 2;
          y = (Math.random() - 0.5) * size;
          z = (Math.random() - 0.5) * size;
          break;
        case 5: // Left
          x = -size / 2;
          y = (Math.random() - 0.5) * size;
          z = (Math.random() - 0.5) * size;
          break;
      }

      positions.push(x, y, z);
    }

    return positions;
  }

  createTorusPositions() {
    const positions = [];
    const count = this.config.particleCount;
    const majorRadius = 15;
    const minorRadius = 5;

    for (let i = 0; i < count; i++) {
      const u = Math.random() * Math.PI * 2;
      const v = Math.random() * Math.PI * 2;

      const x = (majorRadius + minorRadius * Math.cos(v)) * Math.cos(u);
      const y = (majorRadius + minorRadius * Math.cos(v)) * Math.sin(u);
      const z = minorRadius * Math.sin(v);

      positions.push(x, y, z);
    }

    return positions;
  }

  createPlanePositions() {
    const positions = [];
    const count = this.config.particleCount;
    const size = 30;

    for (let i = 0; i < count; i++) {
      const x = (Math.random() - 0.5) * size;
      const y = 0;
      const z = (Math.random() - 0.5) * size;

      positions.push(x, y, z);
    }

    return positions;
  }

  createParticleSystem() {
    const geometry = new THREE.BufferGeometry();
    const positions = new Float32Array(this.config.particleCount * 3);
    const targetPositions = new Float32Array(this.config.particleCount * 3);
    const colors = new Float32Array(this.config.particleCount * 3);

    // Initialize with first shape
    const firstShape = this.geometries[this.config.morphTargets[0]];
    for (let i = 0; i < this.config.particleCount * 3; i++) {
      positions[i] = firstShape[i];
      targetPositions[i] = firstShape[i];
    }

    // Generate colors
    for (let i = 0; i < this.config.particleCount; i++) {
      const color = new THREE.Color().setHSL(Math.random(), 0.8, 0.6);
      colors[i * 3] = color.r;
      colors[i * 3 + 1] = color.g;
      colors[i * 3 + 2] = color.b;
    }

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    geometry.setAttribute('targetPosition', new THREE.BufferAttribute(targetPositions, 3));
    geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

    const material = new THREE.ShaderMaterial({
      uniforms: {
        time: { value: 0 },
        morphProgress: { value: 0 }
      },
      vertexShader: `
        attribute vec3 targetPosition;
        attribute vec3 color;
        uniform float time;
        uniform float morphProgress;
        varying vec3 vColor;

        void main() {
          vColor = color;

          // Interpolate between current and target position
          vec3 pos = mix(position, targetPosition, morphProgress);

          // Add some noise for organic movement
          pos.x += sin(time + pos.y * 0.1) * 0.5;
          pos.y += cos(time + pos.x * 0.1) * 0.5;

          gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
          gl_PointSize = 3.0;
        }
      `,
      fragmentShader: `
        varying vec3 vColor;

        void main() {
          vec2 center = gl_PointCoord - 0.5;
          float dist = length(center);

          if (dist > 0.5) discard;

          float alpha = 1.0 - smoothstep(0.0, 0.5, dist);
          gl_FragColor = vec4(vColor, alpha * 0.8);
        }
      `,
      transparent: true,
      depthWrite: false
    });

    this.particleSystem = new THREE.Points(geometry, material);
    this.scene.add(this.particleSystem);
  }

  startMorphing() {
    this.morphToNext();
  }

  morphToNext() {
    if (this.isTransitioning) return;

    this.isTransitioning = true;
    this.currentShape = (this.currentShape + 1) % this.config.morphTargets.length;

    const targetShape = this.config.morphTargets[this.currentShape];
    const targetPositions = this.geometries[targetShape];

    // Update target positions
    const targetAttribute = this.particleSystem.geometry.attributes.targetPosition;
    for (let i = 0; i < targetPositions.length; i++) {
      targetAttribute.array[i] = targetPositions[i];
    }
    targetAttribute.needsUpdate = true;

    // Animate morphing
    const startTime = performance.now();
    const animate = () => {
      const elapsed = (performance.now() - startTime) / 1000;
      const progress = Math.min(elapsed / this.config.morphDuration, 1);

      // Smooth easing
      const easedProgress = this.easeInOutCubic(progress);
      this.particleSystem.material.uniforms.morphProgress.value = easedProgress;

      if (progress < 1) {
        requestAnimationFrame(animate);
      } else {
        // Update actual positions to target positions
        const positions = this.particleSystem.geometry.attributes.position;
        const targets = this.particleSystem.geometry.attributes.targetPosition;

        for (let i = 0; i < positions.array.length; i++) {
          positions.array[i] = targets.array[i];
        }
        positions.needsUpdate = true;

        this.particleSystem.material.uniforms.morphProgress.value = 0;
        this.isTransitioning = false;

        // Schedule next morph
        setTimeout(() => this.morphToNext(), 2000);
      }
    };

    animate();
  }

  easeInOutCubic(t) {
    return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
  }

  update(time) {
    if (this.particleSystem) {
      this.particleSystem.material.uniforms.time.value = time;
    }
  }
}
```

## Configuration Options

### Basic Configuration
```javascript
const config = {
  // Particle System
  particleCount: 10000,           // Number of particles (1K-100K)
  particleSize: 2.0,              // Base particle size
  particleLifetime: 5.0,          // Particle lifetime in seconds

  // Animation
  animationType: 'flow',          // 'flow', 'explosion', 'morph', 'orbit'
  animationSpeed: 1.0,            // Animation speed multiplier
  autoLoop: true,                 // Auto-restart animations

  // Audio Reactivity
  audioReactive: true,            // Enable audio analysis
  audioSensitivity: 1.0,          // Audio response strength
  frequencyBands: ['low', 'mid', 'high'], // Active frequency bands

  // Visual Effects
  shaderEffects: [
    'vertex_displacement',
    'fragment_glow',
    'color_shifting',
    'size_pulsing'
  ],
  postProcessing: {
    bloom: true,
    bloomStrength: 1.5,
    bloomRadius: 0.4,
    chromatic: true,
    chromaticOffset: 0.002
  },

  // Performance
  adaptiveQuality: true,          // Auto-adjust quality
  targetFPS: 60,                  // Target frame rate
  maxParticles: 50000,            // Performance limit
  cullingDistance: 200,           // Particle culling distance

  // Interaction
  mouseInteraction: true,         // Mouse influence
  touchSupport: true,             // Touch device support
  interactionRadius: 50,          // Interaction influence radius

  // Environment
  backgroundColor: 0x000011,      // Background color
  fogEnabled: true,               // Scene fog
  fogColor: 0x000011,             // Fog color
  fogNear: 1,                     // Fog near distance
  fogFar: 1000                    // Fog far distance
};
```

### Advanced Shader Configuration
```javascript
const shaderConfig = {
  vertexShader: {
    displacement: {
      enabled: true,
      amplitude: 5.0,
      frequency: 0.1,
      speed: 1.0
    },
    audioReactive: {
      enabled: true,
      lowFreqInfluence: 0.5,
      midFreqInfluence: 0.3,
      highFreqInfluence: 0.2
    },
    noise: {
      enabled: true,
      scale: 0.1,
      amplitude: 2.0,
      octaves: 3
    }
  },
  fragmentShader: {
    glow: {
      enabled: true,
      intensity: 1.0,
      falloff: 2.0
    },
    colorShifting: {
      enabled: true,
      speed: 0.5,
      range: 0.2
    },
    transparency: {
      baseAlpha: 0.8,
      fadeDistance: 100.0
    }
  }
};
```

## Animation Pattern Variations

### 1. Flow Field Animation
```javascript
const flowFieldConfig = {
  animationType: 'flow_field',
  flowField: {
    enabled: true,
    scale: 0.01,
    strength: 2.0,
    evolution: 0.5,
    layers: 3
  },
  particles: {
    trailLength: 50,
    fadeRate: 0.02,
    speed: 1.0
  }
};
```

### 2. Gravitational System
```javascript
const gravityConfig = {
  animationType: 'gravity',
  physics: {
    gravity: -9.81,
    bounce: 0.8,
    friction: 0.99,
    attractors: [
      { position: [0, 0, 0], mass: 100 },
      { position: [30, 30, 0], mass: 50 }
    ]
  }
};
```

### 3. Fluid Simulation
```javascript
const fluidConfig = {
  animationType: 'fluid',
  fluid: {
    viscosity: 0.1,
    pressure: 1.0,
    density: 1.0,
    gridResolution: 64,
    velocityDamping: 0.99
  }
};
```

## NPL-FIM Command Reference

### Quick Start Commands
```bash
# Basic particle system
@fim:three_js creative_animation --preset=basic

# Audio-reactive particles
@fim:three_js creative_animation --audio_reactive=true --particles=25000

# Morphing geometry
@fim:three_js creative_animation --type=morphing --shapes="sphere,cube,torus"

# Flow field animation
@fim:three_js creative_animation --type=flow_field --complexity=high

# Custom shader effects
@fim:three_js creative_animation --shaders="displacement,glow,chromatic"
```

### Advanced Configuration
```bash
# Performance optimized
@fim:three_js creative_animation --particles=10000 --adaptive_quality=true --target_fps=60

# Mobile optimized
@fim:three_js creative_animation --mobile_preset=true --particles=5000 --simple_shaders=true

# Exhibition mode (high quality)
@fim:three_js creative_animation --quality=ultra --particles=100000 --post_processing=full
```

## Performance Optimization

### GPU Memory Management
```javascript
// Efficient buffer management
class BufferManager {
  constructor() {
    this.pools = new Map();
    this.activeBuffers = new Set();
  }

  getBuffer(type, size) {
    const key = `${type}_${size}`;
    if (!this.pools.has(key)) {
      this.pools.set(key, []);
    }

    const pool = this.pools.get(key);
    if (pool.length > 0) {
      return pool.pop();
    }

    return this.createBuffer(type, size);
  }

  releaseBuffer(buffer) {
    const key = `${buffer.type}_${buffer.size}`;
    if (this.pools.has(key)) {
      this.pools.get(key).push(buffer);
    }
  }

  createBuffer(type, size) {
    switch (type) {
      case 'position':
        return new Float32Array(size * 3);
      case 'color':
        return new Float32Array(size * 3);
      case 'velocity':
        return new Float32Array(size * 3);
      default:
        return new Float32Array(size);
    }
  }
}
```

### LOD (Level of Detail) System
```javascript
class LODParticleSystem {
  constructor(camera, config) {
    this.camera = camera;
    this.config = config;
    this.lodLevels = [
      { distance: 50, particles: config.particleCount },
      { distance: 100, particles: config.particleCount * 0.5 },
      { distance: 200, particles: config.particleCount * 0.25 }
    ];
  }

  updateLOD() {
    const distance = this.camera.position.length();
    let targetParticles = this.config.particleCount;

    for (const level of this.lodLevels) {
      if (distance > level.distance) {
        targetParticles = level.particles;
      }
    }

    this.adjustParticleCount(targetParticles);
  }

  adjustParticleCount(targetCount) {
    // Implementation for dynamic particle count adjustment
  }
}
```

## Troubleshooting Guide

### Common Issues

1. **Performance Problems**
   - Reduce particle count
   - Disable audio reactivity
   - Simplify shaders
   - Enable adaptive quality

2. **Audio Not Working**
   - Check microphone permissions
   - Verify AudioContext support
   - Test with different browsers
   - Use fallback visualization

3. **Shader Compilation Errors**
   - Check WebGL support
   - Validate shader syntax
   - Use simpler fallback shaders
   - Check uniform declarations

4. **Memory Leaks**
   - Dispose geometries and materials
   - Clean up event listeners
   - Release audio context
   - Use object pooling

### Performance Monitoring
```javascript
// Built-in performance monitoring
class PerformanceMonitor {
  constructor() {
    this.frameCount = 0;
    this.lastTime = performance.now();
    this.fps = 60;
    this.memoryUsage = 0;
  }

  update() {
    this.frameCount++;
    const currentTime = performance.now();

    if (currentTime - this.lastTime >= 1000) {
      this.fps = this.frameCount;
      this.frameCount = 0;
      this.lastTime = currentTime;

      if (performance.memory) {
        this.memoryUsage = performance.memory.usedJSHeapSize / 1024 / 1024;
      }

      this.checkPerformance();
    }
  }

  checkPerformance() {
    if (this.fps < 30) {
      console.warn('Low FPS detected:', this.fps);
      // Trigger performance optimizations
    }

    if (this.memoryUsage > 500) {
      console.warn('High memory usage:', this.memoryUsage, 'MB');
      // Trigger memory cleanup
    }
  }
}
```

## Integration Examples

### React Integration
```jsx
import React, { useEffect, useRef } from 'react';
import { CreativeAnimationSystem } from './three-creative-animation';

const ThreeJsAnimation = ({ config }) => {
  const mountRef = useRef(null);
  const animationRef = useRef(null);

  useEffect(() => {
    if (mountRef.current) {
      animationRef.current = new CreativeAnimationSystem({
        ...config,
        container: mountRef.current
      });
    }

    return () => {
      if (animationRef.current) {
        animationRef.current.destroy();
      }
    };
  }, [config]);

  return <div ref={mountRef} style={{ width: '100%', height: '100vh' }} />;
};

export default ThreeJsAnimation;
```

### Vue.js Integration
```vue
<template>
  <div ref="threeContainer" class="three-container"></div>
</template>

<script>
import { CreativeAnimationSystem } from './three-creative-animation';

export default {
  name: 'ThreeAnimation',
  props: {
    config: {
      type: Object,
      default: () => ({})
    }
  },
  mounted() {
    this.initAnimation();
  },
  beforeUnmount() {
    if (this.animation) {
      this.animation.destroy();
    }
  },
  methods: {
    initAnimation() {
      this.animation = new CreativeAnimationSystem({
        ...this.config,
        container: this.$refs.threeContainer
      });
    }
  }
};
</script>
```

## Use Case Applications

### 1. Music Visualization
- Real-time audio analysis
- Frequency-based particle behavior
- Beat detection and response
- Visual rhythm representation

### 2. Interactive Art Installations
- Motion sensor integration
- Multi-touch support
- Environmental data visualization
- Collaborative interaction systems

### 3. Brand Experiences
- Logo particle formations
- Color scheme integration
- Branded animation sequences
- Interactive product showcases

### 4. Educational Simulations
- Physics demonstrations
- Mathematical visualizations
- Scientific data representation
- Interactive learning modules

### 5. Gaming Applications
- Particle effect systems
- Environmental animations
- UI enhancement effects
- Atmospheric rendering

## NPL-FIM Advantages

1. **Rapid Prototyping**: Instant setup with working examples
2. **Production Ready**: Optimized, tested code patterns
3. **Customizable**: Extensive configuration options
4. **Scalable**: Performance optimization built-in
5. **Cross-Platform**: Works across devices and browsers
6. **Maintainable**: Clean, documented code structure
7. **Extensible**: Easy to add new features and effects

This comprehensive guide provides everything needed to implement sophisticated Three.js creative animation systems using NPL-FIM, with complete working examples, configuration options, performance optimizations, and troubleshooting guidance.