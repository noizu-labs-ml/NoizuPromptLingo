# Three.js 3D Graphics - NPL-FIM Implementation Guide

## Overview

Three.js is the premier WebGL library for creating sophisticated 3D graphics and visualizations in web browsers. This comprehensive guide provides complete NPL-FIM integration patterns for immediate artifact generation, covering everything from basic scenes to advanced 3D applications with optimized rendering pipelines, physics simulation, and interactive controls.

## NPL-FIM Direct Unramp Configuration

### Core Scene Templates
```npl
@fim:three_js_scene {
  type: "basic" | "product_showcase" | "architectural" | "data_viz" | "game" | "vr_ar"
  renderer: {
    antialias: true | false
    shadows: "basic" | "pcf" | "pcfsoft" | "vsm"
    tone_mapping: "linear" | "reinhard" | "cineon" | "aces_filmic"
    color_space: "srgb" | "linear" | "rec2020"
  }
  camera: {
    type: "perspective" | "orthographic"
    fov: 30-120
    near: 0.1-10
    far: 100-10000
    position: [x, y, z]
  }
  controls: {
    type: "orbit" | "fly" | "first_person" | "trackball" | "transform"
    enabled_interactions: ["rotate", "zoom", "pan", "keys"]
    auto_rotate: true | false
  }
  lighting: {
    setup: "three_point" | "studio" | "outdoor" | "indoor" | "dramatic"
    shadows: true | false
    environment_map: "hdri_url" | null
  }
  post_processing: {
    effects: ["bloom", "ssao", "fxaa", "smaa", "depth_of_field", "motion_blur"]
    composer_enabled: true | false
  }
}
```

### Material System Configuration
```npl
@fim:three_js_materials {
  pbr_workflow: {
    base_color: "#ffffff" | "texture_url"
    metallic: 0.0-1.0 | "texture_url"
    roughness: 0.0-1.0 | "texture_url"
    normal: "texture_url" | null
    emission: "#000000" | "texture_url"
    ao: "texture_url" | null
  }
  advanced_materials: {
    subsurface_scattering: true | false
    clearcoat: 0.0-1.0
    transmission: 0.0-1.0
    ior: 1.0-2.5
    sheen: 0.0-1.0
  }
  optimization: {
    texture_compression: "dxt" | "etc" | "pvrtc" | "astc"
    mipmap_generation: true | false
    anisotropic_filtering: 1 | 2 | 4 | 8 | 16
  }
}
```

## Complete Working Examples

### 1. Product Showcase Scene
```javascript
// Complete Product Visualization Setup
class ProductShowcase {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId);
    this.options = {
      enableShadows: true,
      enablePostProcessing: true,
      autoRotate: true,
      backgroundColor: 0xf0f0f0,
      ...options
    };

    this.init();
    this.setupLighting();
    this.setupControls();
    this.setupPostProcessing();
    this.animate();
  }

  init() {
    // Scene setup
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(this.options.backgroundColor);

    // Camera configuration
    this.camera = new THREE.PerspectiveCamera(
      45,
      this.container.clientWidth / this.container.clientHeight,
      0.1,
      1000
    );
    this.camera.position.set(5, 5, 5);

    // Renderer setup with optimal settings
    this.renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true,
      powerPreference: "high-performance"
    });
    this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = this.options.enableShadows;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.0;
    this.renderer.outputColorSpace = THREE.SRGBColorSpace;

    this.container.appendChild(this.renderer.domElement);

    // Environment setup
    this.setupEnvironment();

    // Responsive handling
    this.setupResponsiveResize();
  }

  setupEnvironment() {
    // HDR environment loading
    const rgbeLoader = new THREE.RGBELoader();
    rgbeLoader.load('/assets/hdri/studio_small_03_1k.hdr', (texture) => {
      texture.mapping = THREE.EquirectangularReflectionMapping;
      this.scene.environment = texture;
      this.scene.background = texture;
    });

    // Ground plane with realistic materials
    const groundGeometry = new THREE.PlaneGeometry(20, 20);
    const groundMaterial = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      roughness: 0.8,
      metalness: 0.1
    });
    this.ground = new THREE.Mesh(groundGeometry, groundMaterial);
    this.ground.rotation.x = -Math.PI / 2;
    this.ground.receiveShadow = true;
    this.scene.add(this.ground);
  }

  setupLighting() {
    // Three-point lighting setup

    // Key light (main directional light)
    this.keyLight = new THREE.DirectionalLight(0xffffff, 1.0);
    this.keyLight.position.set(10, 10, 5);
    this.keyLight.castShadow = true;
    this.keyLight.shadow.mapSize.width = 2048;
    this.keyLight.shadow.mapSize.height = 2048;
    this.keyLight.shadow.camera.near = 0.5;
    this.keyLight.shadow.camera.far = 50;
    this.keyLight.shadow.camera.left = -10;
    this.keyLight.shadow.camera.right = 10;
    this.keyLight.shadow.camera.top = 10;
    this.keyLight.shadow.camera.bottom = -10;
    this.scene.add(this.keyLight);

    // Fill light (softer, opposite side)
    this.fillLight = new THREE.DirectionalLight(0x87ceeb, 0.4);
    this.fillLight.position.set(-5, 5, -5);
    this.scene.add(this.fillLight);

    // Rim light (backlight for edge definition)
    this.rimLight = new THREE.DirectionalLight(0xffeaa7, 0.3);
    this.rimLight.position.set(0, 5, -10);
    this.scene.add(this.rimLight);

    // Ambient light for overall illumination
    this.ambientLight = new THREE.AmbientLight(0x404040, 0.2);
    this.scene.add(this.ambientLight);

    // Optional: Light helpers for debugging
    if (this.options.showLightHelpers) {
      this.scene.add(new THREE.DirectionalLightHelper(this.keyLight, 2));
      this.scene.add(new THREE.DirectionalLightHelper(this.fillLight, 2));
    }
  }

  setupControls() {
    this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.05;
    this.controls.minDistance = 2;
    this.controls.maxDistance = 20;
    this.controls.maxPolarAngle = Math.PI / 2;
    this.controls.autoRotate = this.options.autoRotate;
    this.controls.autoRotateSpeed = 1.0;
  }

  setupPostProcessing() {
    if (!this.options.enablePostProcessing) return;

    // Composer setup for post-processing effects
    this.composer = new THREE.EffectComposer(this.renderer);

    // Render pass
    this.renderPass = new THREE.RenderPass(this.scene, this.camera);
    this.composer.addPass(this.renderPass);

    // SSAO (Screen Space Ambient Occlusion)
    this.ssaoPass = new THREE.SSAOPass(this.scene, this.camera,
      this.container.clientWidth, this.container.clientHeight);
    this.ssaoPass.kernelRadius = 16;
    this.composer.addPass(this.ssaoPass);

    // Bloom effect
    this.bloomPass = new THREE.UnrealBloomPass(
      new THREE.Vector2(this.container.clientWidth, this.container.clientHeight),
      1.5, 0.4, 0.85
    );
    this.composer.addPass(this.bloomPass);

    // Anti-aliasing
    this.fxaaPass = new THREE.ShaderPass(THREE.FXAAShader);
    this.fxaaPass.material.uniforms['resolution'].value.x = 1 / this.container.clientWidth;
    this.fxaaPass.material.uniforms['resolution'].value.y = 1 / this.container.clientHeight;
    this.composer.addPass(this.fxaaPass);
  }

  loadModel(modelPath, options = {}) {
    const loader = new THREE.GLTFLoader();
    const dracoLoader = new THREE.DRACOLoader();
    dracoLoader.setDecoderPath('/libs/draco/');
    loader.setDRACOLoader(dracoLoader);

    return new Promise((resolve, reject) => {
      loader.load(
        modelPath,
        (gltf) => {
          const model = gltf.scene;

          // Configure shadows and materials
          model.traverse((node) => {
            if (node.isMesh) {
              node.castShadow = true;
              node.receiveShadow = true;

              // Enhance materials if needed
              if (node.material) {
                if (options.enhanceMaterials) {
                  this.enhanceMaterial(node.material);
                }
              }
            }
          });

          // Center and scale model
          const box = new THREE.Box3().setFromObject(model);
          const center = box.getCenter(new THREE.Vector3());
          const size = box.getSize(new THREE.Vector3());

          const maxDim = Math.max(size.x, size.y, size.z);
          const scale = options.targetSize || 2 / maxDim;

          model.position.sub(center);
          model.scale.setScalar(scale);

          this.scene.add(model);
          this.currentModel = model;

          resolve(model);
        },
        (progress) => {
          if (options.onProgress) {
            options.onProgress(progress);
          }
        },
        (error) => {
          reject(error);
        }
      );
    });
  }

  enhanceMaterial(material) {
    // Enhance PBR materials with better settings
    if (material.isMeshStandardMaterial || material.isMeshPhysicalMaterial) {
      material.envMapIntensity = 1.0;
      material.needsUpdate = true;
    }
  }

  setupResponsiveResize() {
    const resizeObserver = new ResizeObserver(entries => {
      const { clientWidth, clientHeight } = this.container;

      this.camera.aspect = clientWidth / clientHeight;
      this.camera.updateProjectionMatrix();

      this.renderer.setSize(clientWidth, clientHeight);

      if (this.composer) {
        this.composer.setSize(clientWidth, clientHeight);
        this.fxaaPass.material.uniforms['resolution'].value.x = 1 / clientWidth;
        this.fxaaPass.material.uniforms['resolution'].value.y = 1 / clientHeight;
      }
    });

    resizeObserver.observe(this.container);
  }

  animate() {
    requestAnimationFrame(() => this.animate());

    this.controls.update();

    if (this.composer) {
      this.composer.render();
    } else {
      this.renderer.render(this.scene, this.camera);
    }
  }

  // Utility methods for runtime control
  setAutoRotate(enabled) {
    this.controls.autoRotate = enabled;
  }

  updateLighting(intensity) {
    this.keyLight.intensity = intensity;
    this.fillLight.intensity = intensity * 0.4;
    this.rimLight.intensity = intensity * 0.3;
  }

  dispose() {
    this.renderer.dispose();
    this.composer?.dispose();
    // Clean up all resources
  }
}

// Usage example
const showcase = new ProductShowcase('product-container', {
  enableShadows: true,
  enablePostProcessing: true,
  autoRotate: true,
  backgroundColor: 0xf5f5f5
});

showcase.loadModel('/models/product.glb', {
  enhanceMaterials: true,
  targetSize: 3,
  onProgress: (progress) => {
    console.log('Loading progress:', progress.loaded / progress.total * 100 + '%');
  }
});
```

### 2. Data Visualization in 3D Space
```javascript
// 3D Data Visualization Framework
class Data3DVisualizer {
  constructor(containerId, dataConfig) {
    this.container = document.getElementById(containerId);
    this.dataConfig = dataConfig;
    this.dataPoints = [];
    this.connections = [];

    this.init();
    this.setupInteraction();
    this.animate();
  }

  init() {
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x0a0a0a);

    this.camera = new THREE.PerspectiveCamera(
      60,
      this.container.clientWidth / this.container.clientHeight,
      0.1,
      1000
    );
    this.camera.position.set(50, 50, 50);

    this.renderer = new THREE.WebGLRenderer({ antialias: true });
    this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
    this.container.appendChild(this.renderer.domElement);

    // Controls for navigation
    this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;

    // Lighting for data visualization
    const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
    const pointLight = new THREE.PointLight(0xffffff, 0.8, 100);
    pointLight.position.set(20, 20, 20);
    this.scene.add(ambientLight, pointLight);

    // Grid helper for spatial reference
    const gridHelper = new THREE.GridHelper(100, 50, 0x444444, 0x222222);
    this.scene.add(gridHelper);
  }

  visualizeData(dataset) {
    this.clearVisualization();

    // Create data points as 3D objects
    dataset.forEach((dataPoint, index) => {
      const geometry = new THREE.SphereGeometry(
        this.dataConfig.pointSize || (dataPoint.value / 10),
        16,
        16
      );

      // Color mapping based on data category
      const color = this.getColorForCategory(dataPoint.category);
      const material = new THREE.MeshPhongMaterial({
        color: color,
        transparent: true,
        opacity: 0.8
      });

      const sphere = new THREE.Mesh(geometry, material);
      sphere.position.set(
        dataPoint.x || (index % 10) * 5,
        dataPoint.y || Math.random() * 20,
        dataPoint.z || Math.floor(index / 10) * 5
      );

      // Store data reference for interaction
      sphere.userData = dataPoint;
      this.dataPoints.push(sphere);
      this.scene.add(sphere);

      // Add text labels if enabled
      if (this.dataConfig.showLabels) {
        this.addTextLabel(sphere, dataPoint.label || dataPoint.name);
      }
    });

    // Create connections between related data points
    if (this.dataConfig.showConnections) {
      this.createConnections(dataset);
    }
  }

  getColorForCategory(category) {
    const colors = {
      'A': 0xff6b6b,
      'B': 0x4ecdc4,
      'C': 0x45b7d1,
      'D': 0xf9ca24,
      'E': 0xf0932b
    };
    return colors[category] || 0xffffff;
  }

  createConnections(dataset) {
    // Create lines between related data points
    dataset.forEach((point, i) => {
      if (point.connections) {
        point.connections.forEach(targetIndex => {
          if (targetIndex < this.dataPoints.length) {
            const geometry = new THREE.BufferGeometry().setFromPoints([
              this.dataPoints[i].position,
              this.dataPoints[targetIndex].position
            ]);

            const material = new THREE.LineBasicMaterial({
              color: 0x666666,
              transparent: true,
              opacity: 0.3
            });

            const line = new THREE.Line(geometry, material);
            this.connections.push(line);
            this.scene.add(line);
          }
        });
      }
    });
  }

  addTextLabel(object, text) {
    const canvas = document.createElement('canvas');
    const context = canvas.getContext('2d');
    context.font = '64px Arial';
    context.fillStyle = 'white';
    context.fillText(text, 0, 64);

    const texture = new THREE.CanvasTexture(canvas);
    const spriteMaterial = new THREE.SpriteMaterial({ map: texture });
    const sprite = new THREE.Sprite(spriteMaterial);
    sprite.position.copy(object.position);
    sprite.position.y += 2;
    sprite.scale.set(4, 2, 1);

    this.scene.add(sprite);
  }

  setupInteraction() {
    this.raycaster = new THREE.Raycaster();
    this.mouse = new THREE.Vector2();

    this.renderer.domElement.addEventListener('click', (event) => {
      this.mouse.x = (event.clientX / this.container.clientWidth) * 2 - 1;
      this.mouse.y = -(event.clientY / this.container.clientHeight) * 2 + 1;

      this.raycaster.setFromCamera(this.mouse, this.camera);
      const intersects = this.raycaster.intersectObjects(this.dataPoints);

      if (intersects.length > 0) {
        const selectedObject = intersects[0].object;
        this.onDataPointClick(selectedObject.userData);
      }
    });
  }

  onDataPointClick(dataPoint) {
    console.log('Selected data point:', dataPoint);
    // Implement custom interaction logic
  }

  clearVisualization() {
    [...this.dataPoints, ...this.connections].forEach(obj => {
      this.scene.remove(obj);
      obj.geometry?.dispose();
      obj.material?.dispose();
    });
    this.dataPoints = [];
    this.connections = [];
  }

  animate() {
    requestAnimationFrame(() => this.animate());
    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }
}

// Usage
const visualizer = new Data3DVisualizer('data-container', {
  pointSize: 1,
  showLabels: true,
  showConnections: true
});

const sampleData = [
  { x: 0, y: 5, z: 0, value: 10, category: 'A', label: 'Point 1' },
  { x: 5, y: 8, z: 5, value: 15, category: 'B', label: 'Point 2' },
  { x: -3, y: 12, z: 8, value: 8, category: 'C', label: 'Point 3' }
];

visualizer.visualizeData(sampleData);
```

### 3. Architectural Walkthrough
```javascript
// Architectural Visualization with First-Person Controls
class ArchitecturalWalkthrough {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId);
    this.options = {
      enableVR: false,
      showMinimap: true,
      enablePhysics: true,
      walkSpeed: 5,
      ...options
    };

    this.init();
    this.setupFirstPersonControls();
    this.setupAudio();
    this.animate();
  }

  init() {
    this.scene = new THREE.Scene();
    this.scene.fog = new THREE.Fog(0xcce0ff, 1, 100);

    this.camera = new THREE.PerspectiveCamera(
      75,
      this.container.clientWidth / this.container.clientHeight,
      0.1,
      1000
    );
    this.camera.position.set(0, 1.7, 5); // Eye height

    this.renderer = new THREE.WebGLRenderer({ antialias: true });
    this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.container.appendChild(this.renderer.domElement);

    this.setupLighting();
    this.setupEnvironment();
  }

  setupLighting() {
    // Realistic lighting for architectural visualization

    // Sun light (directional)
    this.sunLight = new THREE.DirectionalLight(0xffffff, 1.2);
    this.sunLight.position.set(30, 50, 30);
    this.sunLight.castShadow = true;
    this.sunLight.shadow.mapSize.width = 4096;
    this.sunLight.shadow.mapSize.height = 4096;
    this.sunLight.shadow.camera.near = 0.5;
    this.sunLight.shadow.camera.far = 200;
    this.sunLight.shadow.camera.left = -50;
    this.sunLight.shadow.camera.right = 50;
    this.sunLight.shadow.camera.top = 50;
    this.sunLight.shadow.camera.bottom = -50;
    this.scene.add(this.sunLight);

    // Sky light (hemisphere)
    this.skyLight = new THREE.HemisphereLight(0x87ceeb, 0x1e3a8a, 0.5);
    this.scene.add(this.skyLight);

    // Interior lights
    this.addInteriorLighting();
  }

  addInteriorLighting() {
    // Ceiling lights
    const lightPositions = [
      [-5, 8, -5], [5, 8, -5], [-5, 8, 5], [5, 8, 5],
      [0, 8, 0]
    ];

    lightPositions.forEach(pos => {
      const light = new THREE.PointLight(0xfff8dc, 0.8, 15);
      light.position.set(...pos);
      light.castShadow = true;
      this.scene.add(light);

      // Add light fixture geometry
      const fixtureGeometry = new THREE.CylinderGeometry(0.3, 0.3, 0.1, 8);
      const fixtureMaterial = new THREE.MeshStandardMaterial({
        color: 0x333333,
        metalness: 0.8,
        roughness: 0.2
      });
      const fixture = new THREE.Mesh(fixtureGeometry, fixtureMaterial);
      fixture.position.set(pos[0], pos[1] - 0.2, pos[2]);
      this.scene.add(fixture);
    });
  }

  setupEnvironment() {
    // Load HDRI environment
    const rgbeLoader = new THREE.RGBELoader();
    rgbeLoader.load('/assets/hdri/outdoor_day.hdr', (texture) => {
      texture.mapping = THREE.EquirectangularReflectionMapping;
      this.scene.environment = texture;
    });

    // Ground plane
    const groundGeometry = new THREE.PlaneGeometry(200, 200);
    const groundMaterial = new THREE.MeshStandardMaterial({
      color: 0x4a5d23,
      roughness: 0.9
    });
    this.ground = new THREE.Mesh(groundGeometry, groundMaterial);
    this.ground.rotation.x = -Math.PI / 2;
    this.ground.receiveShadow = true;
    this.scene.add(this.ground);
  }

  loadArchitecturalModel(modelPath) {
    const loader = new THREE.GLTFLoader();
    const dracoLoader = new THREE.DRACOLoader();
    dracoLoader.setDecoderPath('/libs/draco/');
    loader.setDRACOLoader(dracoLoader);

    return new Promise((resolve, reject) => {
      loader.load(modelPath, (gltf) => {
        const building = gltf.scene;

        building.traverse((node) => {
          if (node.isMesh) {
            node.castShadow = true;
            node.receiveShadow = true;

            // Apply architectural materials
            this.enhanceArchitecturalMaterial(node);
          }
        });

        this.scene.add(building);
        this.buildingModel = building;

        // Setup collision detection
        if (this.options.enablePhysics) {
          this.setupCollisionDetection(building);
        }

        resolve(building);
      }, undefined, reject);
    });
  }

  enhanceArchitecturalMaterial(node) {
    if (node.material) {
      // Enhance different material types
      const materialName = node.material.name.toLowerCase();

      if (materialName.includes('glass')) {
        node.material.transparent = true;
        node.material.opacity = 0.8;
        node.material.metalness = 0.1;
        node.material.roughness = 0.1;
        node.material.transmission = 0.9;
      } else if (materialName.includes('metal')) {
        node.material.metalness = 0.9;
        node.material.roughness = 0.1;
      } else if (materialName.includes('wood')) {
        node.material.metalness = 0.0;
        node.material.roughness = 0.8;
      } else if (materialName.includes('concrete')) {
        node.material.metalness = 0.0;
        node.material.roughness = 0.9;
      }
    }
  }

  setupFirstPersonControls() {
    this.controls = new THREE.FirstPersonControls(this.camera, this.renderer.domElement);
    this.controls.movementSpeed = this.options.walkSpeed;
    this.controls.lookSpeed = 0.1;
    this.controls.constrainVertical = true;
    this.controls.verticalMin = 0;
    this.controls.verticalMax = Math.PI;

    // Custom movement constraints
    this.velocity = new THREE.Vector3();
    this.direction = new THREE.Vector3();

    this.setupKeyboardControls();
  }

  setupKeyboardControls() {
    this.keys = {
      forward: false,
      backward: false,
      left: false,
      right: false
    };

    document.addEventListener('keydown', (event) => {
      switch (event.code) {
        case 'KeyW': this.keys.forward = true; break;
        case 'KeyS': this.keys.backward = true; break;
        case 'KeyA': this.keys.left = true; break;
        case 'KeyD': this.keys.right = true; break;
      }
    });

    document.addEventListener('keyup', (event) => {
      switch (event.code) {
        case 'KeyW': this.keys.forward = false; break;
        case 'KeyS': this.keys.backward = false; break;
        case 'KeyA': this.keys.left = false; break;
        case 'KeyD': this.keys.right = false; break;
      }
    });
  }

  setupCollisionDetection(building) {
    // Simplified collision detection using raycasting
    this.collisionObjects = [];

    building.traverse((node) => {
      if (node.isMesh && node.material.name.includes('wall')) {
        this.collisionObjects.push(node);
      }
    });
  }

  checkCollisions() {
    if (!this.collisionObjects.length) return true;

    const raycaster = new THREE.Raycaster();
    raycaster.set(this.camera.position, this.direction);

    const intersections = raycaster.intersectObjects(this.collisionObjects);
    return intersections.length === 0 || intersections[0].distance > 1;
  }

  setupAudio() {
    // 3D positional audio
    this.listener = new THREE.AudioListener();
    this.camera.add(this.listener);

    // Ambient sound
    this.ambientSound = new THREE.Audio(this.listener);
    const audioLoader = new THREE.AudioLoader();
    audioLoader.load('/audio/ambient_indoor.mp3', (buffer) => {
      this.ambientSound.setBuffer(buffer);
      this.ambientSound.setLoop(true);
      this.ambientSound.setVolume(0.3);
    });

    // Footstep sounds
    this.footstepSound = new THREE.Audio(this.listener);
    audioLoader.load('/audio/footsteps.mp3', (buffer) => {
      this.footstepSound.setBuffer(buffer);
    });
  }

  updateMovement(deltaTime) {
    this.velocity.x -= this.velocity.x * 10.0 * deltaTime;
    this.velocity.z -= this.velocity.z * 10.0 * deltaTime;

    this.direction.z = Number(this.keys.forward) - Number(this.keys.backward);
    this.direction.x = Number(this.keys.right) - Number(this.keys.left);
    this.direction.normalize();

    if (this.keys.forward || this.keys.backward) {
      this.velocity.z -= this.direction.z * 400.0 * deltaTime;
    }
    if (this.keys.left || this.keys.right) {
      this.velocity.x -= this.direction.x * 400.0 * deltaTime;
    }

    // Apply movement if no collision
    const prevPosition = this.camera.position.clone();
    this.camera.translateX(this.velocity.x * deltaTime);
    this.camera.translateZ(this.velocity.z * deltaTime);

    if (!this.checkCollisions()) {
      this.camera.position.copy(prevPosition);
    }
  }

  animate() {
    requestAnimationFrame(() => this.animate());

    const deltaTime = 0.016; // ~60fps
    this.updateMovement(deltaTime);

    this.renderer.render(this.scene, this.camera);
  }
}

// Usage
const walkthrough = new ArchitecturalWalkthrough('building-container', {
  enablePhysics: true,
  walkSpeed: 8,
  showMinimap: true
});

walkthrough.loadArchitecturalModel('/models/modern_house.glb');
```

## Configuration Variations

### Performance Optimization Presets
```javascript
// Performance presets for different hardware capabilities
const PERFORMANCE_PRESETS = {
  mobile: {
    renderer: {
      antialias: false,
      shadowMapSize: 512,
      pixelRatio: 1,
      powerPreference: "low-power"
    },
    postProcessing: false,
    maxLights: 3,
    textureSize: 512
  },

  desktop: {
    renderer: {
      antialias: true,
      shadowMapSize: 2048,
      pixelRatio: Math.min(window.devicePixelRatio, 2),
      powerPreference: "high-performance"
    },
    postProcessing: true,
    maxLights: 8,
    textureSize: 1024
  },

  highEnd: {
    renderer: {
      antialias: true,
      shadowMapSize: 4096,
      pixelRatio: window.devicePixelRatio,
      powerPreference: "high-performance"
    },
    postProcessing: true,
    maxLights: 16,
    textureSize: 2048
  }
};

// Auto-detection based on device capabilities
function detectDeviceCapabilities() {
  const canvas = document.createElement('canvas');
  const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');

  if (!gl) return 'mobile';

  const debugInfo = gl.getExtension('WEBGL_debug_renderer_info');
  const renderer = debugInfo ? gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL) : '';

  if (renderer.includes('Mali') || renderer.includes('Adreno') ||
      renderer.includes('PowerVR') || navigator.platform.includes('Mobile')) {
    return 'mobile';
  } else if (renderer.includes('GeForce RTX') || renderer.includes('Radeon RX')) {
    return 'highEnd';
  } else {
    return 'desktop';
  }
}
```

### Material System Configurations
```javascript
// Advanced material configurations for different use cases
const MATERIAL_CONFIGS = {
  photorealistic: {
    workflow: 'PBR',
    textureTypes: ['albedo', 'normal', 'roughness', 'metallic', 'ao', 'height'],
    envMapIntensity: 1.0,
    transmission: true,
    clearcoat: true,
    sheen: true
  },

  stylized: {
    workflow: 'toon',
    textureTypes: ['diffuse', 'normal'],
    envMapIntensity: 0.3,
    toonShading: true,
    outlines: true
  },

  technical: {
    workflow: 'unlit',
    wireframe: true,
    vertexColors: true,
    annotations: true
  }
};

class MaterialManager {
  constructor(config) {
    this.config = config;
    this.materials = new Map();
    this.textures = new Map();
  }

  createMaterial(type, options = {}) {
    const config = this.config[type] || this.config.photorealistic;

    switch (config.workflow) {
      case 'PBR':
        return this.createPBRMaterial(options, config);
      case 'toon':
        return this.createToonMaterial(options, config);
      case 'unlit':
        return this.createUnlitMaterial(options, config);
      default:
        return new THREE.MeshStandardMaterial(options);
    }
  }

  createPBRMaterial(options, config) {
    const material = new THREE.MeshPhysicalMaterial({
      ...options,
      envMapIntensity: config.envMapIntensity
    });

    if (config.transmission) {
      material.transmission = options.transmission || 0;
      material.thickness = options.thickness || 0;
    }

    if (config.clearcoat) {
      material.clearcoat = options.clearcoat || 0;
      material.clearcoatRoughness = options.clearcoatRoughness || 0;
    }

    return material;
  }

  async loadTextures(materialId, texturePaths) {
    const textureLoader = new THREE.TextureLoader();
    const textures = {};

    for (const [type, path] of Object.entries(texturePaths)) {
      try {
        textures[type] = await new Promise((resolve, reject) => {
          textureLoader.load(path, resolve, undefined, reject);
        });

        // Configure texture settings
        textures[type].wrapS = THREE.RepeatWrapping;
        textures[type].wrapT = THREE.RepeatWrapping;
        textures[type].flipY = false;
      } catch (error) {
        console.warn(`Failed to load texture: ${path}`, error);
      }
    }

    this.textures.set(materialId, textures);
    return textures;
  }
}
```

## Dependencies and Environment Setup

### Required Dependencies
```json
{
  "name": "three-js-project",
  "dependencies": {
    "three": "^0.158.0"
  },
  "devDependencies": {
    "vite": "^4.5.0",
    "@types/three": "^0.158.0"
  },
  "optionalDependencies": {
    "three-stdlib": "^2.27.0",
    "cannon-es": "^0.20.0",
    "ammojs-typed": "^1.0.6"
  }
}
```

### Module Imports
```javascript
// Core Three.js imports
import * as THREE from 'three';

// Essential controls
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { FirstPersonControls } from 'three/examples/jsm/controls/FirstPersonControls.js';
import { FlyControls } from 'three/examples/jsm/controls/FlyControls.js';
import { TransformControls } from 'three/examples/jsm/controls/TransformControls.js';

// Loaders
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js';
import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader.js';
import { KTX2Loader } from 'three/examples/jsm/loaders/KTX2Loader.js';

// Post-processing
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js';
import { SSAOPass } from 'three/examples/jsm/postprocessing/SSAOPass.js';
import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js';
import { FXAAShader } from 'three/examples/jsm/shaders/FXAAShader.js';

// Physics (optional)
import CANNON from 'cannon-es';

// Utilities
import { GUI } from 'three/examples/jsm/libs/lil-gui.module.min.js';
```

### CDN Integration
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Three.js Application</title>
    <style>
        body { margin: 0; overflow: hidden; }
        #container { width: 100vw; height: 100vh; }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-family: Arial;
        }
    </style>
</head>
<body>
    <div id="container">
        <div id="loading">Loading...</div>
    </div>

    <!-- Three.js CDN -->
    <script src="https://unpkg.com/three@0.158.0/build/three.min.js"></script>

    <!-- Controls -->
    <script src="https://unpkg.com/three@0.158.0/examples/js/controls/OrbitControls.js"></script>

    <!-- Loaders -->
    <script src="https://unpkg.com/three@0.158.0/examples/js/loaders/GLTFLoader.js"></script>
    <script src="https://unpkg.com/three@0.158.0/examples/js/loaders/DRACOLoader.js"></script>

    <script>
        // Your Three.js code here
        console.log('Three.js version:', THREE.REVISION);
    </script>
</body>
</html>
```

## Troubleshooting Guide

### Performance Issues

**Problem**: Low frame rate or stuttering
```javascript
// Performance monitoring and optimization
class PerformanceMonitor {
  constructor() {
    this.stats = {
      fps: 0,
      frameTime: 0,
      memoryUsage: 0,
      drawCalls: 0
    };

    this.setupMonitoring();
  }

  setupMonitoring() {
    // FPS monitoring
    this.fpsCounter = 0;
    this.lastTime = performance.now();

    // Memory monitoring (if available)
    if (performance.memory) {
      setInterval(() => {
        this.stats.memoryUsage = performance.memory.usedJSHeapSize / 1048576; // MB
      }, 1000);
    }

    // WebGL render info
    this.setupWebGLMonitoring();
  }

  setupWebGLMonitoring() {
    // Override renderer.render to count draw calls
    const originalRender = THREE.WebGLRenderer.prototype.render;
    THREE.WebGLRenderer.prototype.render = function(...args) {
      this.info.reset();
      const result = originalRender.apply(this, args);

      // Update draw call statistics
      window.performanceMonitor?.updateDrawCalls(this.info.render.calls);

      return result;
    };
  }

  update() {
    const now = performance.now();
    this.fpsCounter++;

    if (now - this.lastTime >= 1000) {
      this.stats.fps = this.fpsCounter;
      this.stats.frameTime = (now - this.lastTime) / this.fpsCounter;
      this.fpsCounter = 0;
      this.lastTime = now;

      this.onStatsUpdate(this.stats);
    }
  }

  onStatsUpdate(stats) {
    // Log performance warnings
    if (stats.fps < 30) {
      console.warn('Low FPS detected:', stats.fps);
      this.suggestOptimizations();
    }

    if (stats.memoryUsage > 100) {
      console.warn('High memory usage:', stats.memoryUsage + 'MB');
    }
  }

  suggestOptimizations() {
    console.log('Performance optimization suggestions:');
    console.log('- Reduce shadow map size');
    console.log('- Disable post-processing effects');
    console.log('- Use lower resolution textures');
    console.log('- Implement LOD (Level of Detail)');
    console.log('- Reduce polygon count');
  }
}

// Usage
window.performanceMonitor = new PerformanceMonitor();

// In your animation loop
function animate() {
  window.performanceMonitor.update();
  // ... rest of animation code
}
```

**Solution Strategies**:
1. **Level of Detail (LOD)**: Implement multiple geometry resolutions
2. **Frustum Culling**: Only render visible objects
3. **Texture Optimization**: Use compressed textures and mipmaps
4. **Shadow Optimization**: Reduce shadow map resolution or use CSM
5. **Geometry Instancing**: For repeated objects

### Memory Leaks

**Problem**: Increasing memory usage over time
```javascript
// Resource management utilities
class ResourceManager {
  constructor() {
    this.disposables = new Set();
    this.textures = new Map();
    this.geometries = new Map();
    this.materials = new Map();
  }

  trackResource(resource) {
    this.disposables.add(resource);
    return resource;
  }

  disposeAll() {
    this.disposables.forEach(resource => {
      if (resource.dispose) {
        resource.dispose();
      }
    });
    this.disposables.clear();
  }

  // Geometry management
  getGeometry(id, createFn) {
    if (!this.geometries.has(id)) {
      const geometry = createFn();
      this.geometries.set(id, geometry);
      this.trackResource(geometry);
    }
    return this.geometries.get(id);
  }

  // Material management
  getMaterial(id, createFn) {
    if (!this.materials.has(id)) {
      const material = createFn();
      this.materials.set(id, material);
      this.trackResource(material);
    }
    return this.materials.get(id);
  }

  // Texture management with caching
  loadTexture(url) {
    if (!this.textures.has(url)) {
      const loader = new THREE.TextureLoader();
      const texture = loader.load(url);
      this.textures.set(url, texture);
      this.trackResource(texture);
    }
    return this.textures.get(url);
  }
}

// Usage in application
const resourceManager = new ResourceManager();

// When creating objects
const geometry = resourceManager.getGeometry('box', () => new THREE.BoxGeometry(1, 1, 1));
const material = resourceManager.getMaterial('basic', () => new THREE.MeshBasicMaterial());

// Clean up when done
resourceManager.disposeAll();
```

### Loading Issues

**Problem**: Models or textures not loading
```javascript
// Robust loading with error handling
class AssetLoader {
  constructor() {
    this.loaders = {
      gltf: new THREE.GLTFLoader(),
      texture: new THREE.TextureLoader(),
      cube: new THREE.CubeTextureLoader(),
      rgbe: new THREE.RGBELoader()
    };

    this.setupDRACO();
    this.setupKTX2();
  }

  setupDRACO() {
    const dracoLoader = new THREE.DRACOLoader();
    dracoLoader.setDecoderPath('/libs/draco/');
    this.loaders.gltf.setDRACOLoader(dracoLoader);
  }

  setupKTX2() {
    const ktx2Loader = new KTX2Loader();
    ktx2Loader.setTranscoderPath('/libs/basis/');
    this.loaders.gltf.setKTX2Loader(ktx2Loader);
  }

  async loadModel(url, options = {}) {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error(`Loading timeout for: ${url}`));
      }, options.timeout || 30000);

      this.loaders.gltf.load(
        url,
        (gltf) => {
          clearTimeout(timeout);
          resolve(gltf);
        },
        (progress) => {
          if (options.onProgress) {
            options.onProgress(progress);
          }
        },
        (error) => {
          clearTimeout(timeout);
          console.error('Model loading error:', error);

          // Provide fallback or retry logic
          if (options.fallback && !options.retried) {
            console.log('Attempting fallback model...');
            this.loadModel(options.fallback, { ...options, retried: true })
              .then(resolve)
              .catch(reject);
          } else {
            reject(error);
          }
        }
      );
    });
  }

  async loadTexture(url, options = {}) {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error(`Texture loading timeout: ${url}`));
      }, options.timeout || 15000);

      this.loaders.texture.load(
        url,
        (texture) => {
          clearTimeout(timeout);

          // Apply texture settings
          if (options.wrapS) texture.wrapS = options.wrapS;
          if (options.wrapT) texture.wrapT = options.wrapT;
          if (options.repeat) texture.repeat.copy(options.repeat);
          if (options.flipY !== undefined) texture.flipY = options.flipY;

          resolve(texture);
        },
        undefined,
        (error) => {
          clearTimeout(timeout);
          reject(error);
        }
      );
    });
  }

  // Batch loading with progress tracking
  async loadAssets(assetList, onProgress) {
    const results = [];
    let loaded = 0;

    for (const asset of assetList) {
      try {
        let result;

        switch (asset.type) {
          case 'model':
            result = await this.loadModel(asset.url, asset.options);
            break;
          case 'texture':
            result = await this.loadTexture(asset.url, asset.options);
            break;
          default:
            throw new Error(`Unknown asset type: ${asset.type}`);
        }

        results.push({ id: asset.id, data: result });
        loaded++;

        if (onProgress) {
          onProgress(loaded / assetList.length);
        }

      } catch (error) {
        console.error(`Failed to load asset ${asset.id}:`, error);
        results.push({ id: asset.id, error });
      }
    }

    return results;
  }
}

// Usage example
const assetLoader = new AssetLoader();

const assets = [
  { id: 'building', type: 'model', url: '/models/building.glb', options: { fallback: '/models/simple_building.glb' }},
  { id: 'skybox', type: 'texture', url: '/textures/skybox.jpg' },
  { id: 'ground', type: 'texture', url: '/textures/ground.jpg', options: { wrapS: THREE.RepeatWrapping, wrapT: THREE.RepeatWrapping }}
];

assetLoader.loadAssets(assets, (progress) => {
  console.log(`Loading progress: ${Math.round(progress * 100)}%`);
}).then(results => {
  console.log('All assets loaded:', results);
});
```

## Advanced Use Cases

### VR/AR Integration
```javascript
// WebXR support for VR/AR experiences
class WebXRScene {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    this.init();
    this.setupXR();
  }

  init() {
    this.scene = new THREE.Scene();

    this.camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 0.01, 20);

    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.xr.enabled = true;

    this.container.appendChild(this.renderer.domElement);
  }

  setupXR() {
    // VR button
    document.body.appendChild(VRButton.createButton(this.renderer));

    // Controller setup
    this.controller1 = this.renderer.xr.getController(0);
    this.controller1.addEventListener('selectstart', this.onSelectStart.bind(this));
    this.controller1.addEventListener('selectend', this.onSelectEnd.bind(this));
    this.scene.add(this.controller1);

    this.controller2 = this.renderer.xr.getController(1);
    this.scene.add(this.controller2);

    // Hand tracking
    this.hand1 = this.renderer.xr.getHand(0);
    this.hand2 = this.renderer.xr.getHand(1);
    this.scene.add(this.hand1, this.hand2);
  }

  onSelectStart(event) {
    // Implement VR interaction logic
  }

  onSelectEnd(event) {
    // Implement VR interaction logic
  }
}
```

### Real-time Collaboration
```javascript
// WebSocket-based real-time 3D collaboration
class CollaborativeScene {
  constructor(sceneManager, websocketUrl) {
    this.sceneManager = sceneManager;
    this.websocket = new WebSocket(websocketUrl);
    this.users = new Map();

    this.setupWebSocket();
    this.setupUserPresence();
  }

  setupWebSocket() {
    this.websocket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleMessage(data);
    };
  }

  handleMessage(data) {
    switch (data.type) {
      case 'user_joined':
        this.addUser(data.userId, data.avatar);
        break;
      case 'user_left':
        this.removeUser(data.userId);
        break;
      case 'object_moved':
        this.updateObject(data.objectId, data.transform);
        break;
      case 'object_added':
        this.addObject(data.object);
        break;
    }
  }

  addUser(userId, avatarData) {
    // Create avatar representation
    const avatarGeometry = new THREE.CapsuleGeometry(0.3, 1.6);
    const avatarMaterial = new THREE.MeshStandardMaterial({ color: avatarData.color });
    const avatar = new THREE.Mesh(avatarGeometry, avatarMaterial);

    this.users.set(userId, avatar);
    this.sceneManager.scene.add(avatar);
  }

  broadcastTransform(objectId, transform) {
    this.websocket.send(JSON.stringify({
      type: 'object_moved',
      objectId,
      transform,
      userId: this.userId
    }));
  }
}
```

## NPL-FIM Tool-Specific Advantages

### Three.js Strengths for NPL-FIM
1. **Comprehensive WebGL Abstraction**: Complete high-level API for complex 3D graphics
2. **Rich Ecosystem**: Extensive collection of loaders, controls, and post-processing effects
3. **Performance Optimization**: Built-in frustum culling, level-of-detail, and batching
4. **Cross-Platform Compatibility**: Works across all modern browsers and devices
5. **Active Development**: Regular updates and strong community support
6. **Material System**: Advanced PBR materials with realistic lighting models
7. **Animation Framework**: Built-in keyframe animation and morphing capabilities
8. **Physics Integration**: Compatible with popular physics engines like Cannon.js and Ammo.js

### Limitations and Considerations
1. **Learning Curve**: Complex API requires understanding of 3D graphics concepts
2. **Bundle Size**: Large library size can impact initial loading times
3. **Mobile Performance**: Resource-intensive on lower-end mobile devices
4. **Memory Management**: Requires careful disposal of resources to prevent leaks
5. **WebGL Dependency**: Limited by browser WebGL support and hardware capabilities

### Best Practices for NPL-FIM Integration
1. **Modular Loading**: Load Three.js modules only as needed
2. **Performance Presets**: Provide device-appropriate configuration templates
3. **Progressive Enhancement**: Start with basic features and add complexity
4. **Error Handling**: Implement comprehensive fallback strategies
5. **Resource Management**: Use automated disposal and caching systems

## Implementation Checklist

### Essential Setup
- [ ] Three.js core library loaded and initialized
- [ ] WebGL capability detection and fallback handling
- [ ] Responsive rendering setup with proper aspect ratio management
- [ ] Basic scene, camera, and renderer configuration
- [ ] Asset loading system with progress tracking and error handling

### Rendering Pipeline
- [ ] Lighting system appropriate for use case (product, architectural, data viz)
- [ ] Shadow mapping configuration and optimization
- [ ] Material system with PBR workflow support
- [ ] Post-processing effects pipeline (optional but recommended)
- [ ] Performance monitoring and adaptive quality

### Interaction and Controls
- [ ] Camera controls (orbit, first-person, or custom as needed)
- [ ] Object interaction system (raycasting, selection, manipulation)
- [ ] Responsive event handling for mouse, touch, and keyboard
- [ ] Animation system for smooth transitions and updates

### Optimization and Production
- [ ] Resource disposal and memory management
- [ ] Performance optimization based on device capabilities
- [ ] Error boundaries and graceful degradation
- [ ] Loading states and progress indicators
- [ ] Production build optimization and asset compression

This comprehensive guide provides everything needed for NPL-FIM to generate sophisticated Three.js 3D graphics applications without false starts, covering all essential components from basic setup to advanced features like VR integration and real-time collaboration.