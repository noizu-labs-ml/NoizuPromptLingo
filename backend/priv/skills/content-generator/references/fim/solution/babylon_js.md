# Babylon.js - Comprehensive 3D Web Engine

## Overview
Babylon.js is a powerful, open-source 3D engine for the web, built with TypeScript and JavaScript. It provides a complete framework for creating immersive 3D experiences, games, and applications that run in web browsers with WebGL, WebGPU, and WebXR support.

**Official Documentation**: https://doc.babylonjs.com/
**GitHub Repository**: https://github.com/BabylonJS/Babylon.js
**Community Forum**: https://forum.babylonjs.com/
**Playground**: https://playground.babylonjs.com/
**NPM Package**: https://www.npmjs.com/package/babylonjs

## Version Information
- **Current Version**: 7.x (Latest stable)
- **LTS Version**: 6.x (Long-term support)
- **Release Cycle**: Major releases every 6-12 months
- **Browser Compatibility**: All modern browsers with WebGL 1.0/2.0 support
- **Node.js Compatibility**: 16+ for build tools and server-side rendering

## License and Pricing
- **License**: Apache License 2.0 (Free and open-source)
- **Commercial Use**: Fully permitted without restrictions
- **Support**: Community support via forum, GitHub issues
- **Enterprise**: Microsoft-backed project with enterprise reliability

## Installation Methods

### NPM Installation (Recommended)
```bash
# Core engine
npm install babylonjs

# Optional loaders for 3D models
npm install babylonjs-loaders

# Materials library
npm install babylonjs-materials

# Post-processing library
npm install babylonjs-post-process

# GUI library
npm install babylonjs-gui

# Physics plugins
npm install babylonjs-havok babylonjs-cannon

# Serializers for export
npm install babylonjs-serializers
```

### CDN Integration
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Babylon.js App</title>
    <style>
        html, body {
            overflow: hidden;
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
        }

        #renderCanvas {
            width: 100%;
            height: 100%;
            touch-action: none;
        }
    </style>
</head>
<body>
    <canvas id="renderCanvas"></canvas>

    <!-- Core Babylon.js -->
    <script src="https://cdn.babylonjs.com/babylon.js"></script>

    <!-- Optional libraries -->
    <script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>
    <script src="https://cdn.babylonjs.com/materialsLibrary/babylonjs.materials.min.js"></script>
    <script src="https://cdn.babylonjs.com/postProcessesLibrary/babylonjs.postProcess.min.js"></script>
    <script src="https://cdn.babylonjs.com/proceduralTexturesLibrary/babylonjs.proceduralTextures.min.js"></script>
    <script src="https://cdn.babylonjs.com/gui/babylon.gui.min.js"></script>

    <script>
        // Your Babylon.js code here
    </script>
</body>
</html>
```

### ES6 Module Import
```javascript
import * as BABYLON from 'babylonjs';
import 'babylonjs-loaders/glTF';
import 'babylonjs-materials/grid';
```

## Complete HTML Setup Examples

### Basic WebGL Setup
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Babylon.js Basic Scene</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            width: 100%;
            height: 100%;
            overflow: hidden;
            font-family: Arial, sans-serif;
        }

        #renderCanvas {
            width: 100%;
            height: 100%;
            display: block;
            font-size: 0;
            touch-action: none;
            outline: none;
        }

        #canvasZone {
            width: 100%;
            height: 100%;
        }

        .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 20px;
        }
    </style>
</head>
<body>
    <div id="canvasZone">
        <canvas id="renderCanvas"></canvas>
        <div class="loading" id="loadingText">Loading...</div>
    </div>

    <script src="https://cdn.babylonjs.com/babylon.js"></script>
    <script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>

    <script>
        window.addEventListener('DOMContentLoaded', function() {
            const canvas = document.getElementById('renderCanvas');
            const loadingText = document.getElementById('loadingText');

            // Check WebGL support
            if (!BABYLON.Engine.isSupported()) {
                loadingText.textContent = 'WebGL not supported by your browser';
                return;
            }

            // Create engine with error handling
            let engine;
            try {
                engine = new BABYLON.Engine(canvas, true, {
                    preserveDrawingBuffer: true,
                    stencil: true,
                    antialias: true,
                    alpha: false,
                    premultipliedAlpha: false,
                    powerPreference: "high-performance"
                });
            } catch (e) {
                loadingText.textContent = 'Engine creation failed: ' + e.message;
                return;
            }

            // Hide loading text once engine is ready
            loadingText.style.display = 'none';

            // Your scene creation code here
            createScene(engine, canvas);
        });

        function createScene(engine, canvas) {
            // Scene creation implementation
        }
    </script>
</body>
</html>
```

### WebXR Ready Setup
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Babylon.js WebXR</title>
    <style>
        html, body {
            overflow: hidden;
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
            background-color: #000;
        }

        #renderCanvas {
            width: 100%;
            height: 100%;
            touch-action: none;
            outline: none;
        }

        .xr-button {
            position: absolute;
            bottom: 20px;
            right: 20px;
            padding: 12px 24px;
            background: #007acc;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            z-index: 100;
        }

        .xr-button:hover {
            background: #005a9e;
        }

        .xr-button:disabled {
            background: #666;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <canvas id="renderCanvas"></canvas>
    <button id="vrButton" class="xr-button" disabled>Enter VR</button>
    <button id="arButton" class="xr-button" disabled>Enter AR</button>

    <script src="https://cdn.babylonjs.com/babylon.js"></script>
    <script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>

    <script>
        // WebXR setup implementation
    </script>
</body>
</html>
```

## Core Architecture Examples

### Basic Scene Foundation
```javascript
class BabylonApp {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.engine = null;
        this.scene = null;
        this.camera = null;
        this.light = null;

        this.init();
    }

    async init() {
        try {
            // Create engine with advanced options
            this.engine = new BABYLON.Engine(this.canvas, true, {
                preserveDrawingBuffer: true,
                stencil: true,
                antialias: true,
                alpha: false,
                powerPreference: "high-performance",
                doNotHandleContextLost: true
            });

            // Create scene
            this.scene = new BABYLON.Scene(this.engine);
            this.scene.actionManager = new BABYLON.ActionManager(this.scene);

            // Setup camera
            this.setupCamera();

            // Setup lighting
            this.setupLighting();

            // Setup environment
            this.setupEnvironment();

            // Start render loop
            this.startRenderLoop();

            // Handle window resize
            this.handleResize();

            // Load assets
            await this.loadAssets();

        } catch (error) {
            console.error('Failed to initialize Babylon.js:', error);
        }
    }

    setupCamera() {
        // Universal camera with WASD controls
        this.camera = new BABYLON.UniversalCamera(
            "camera",
            new BABYLON.Vector3(0, 5, -10),
            this.scene
        );

        this.camera.attachControl(this.canvas, true);
        this.camera.setTarget(BABYLON.Vector3.Zero());

        // Camera settings
        this.camera.speed = 0.25;
        this.camera.angularSensibility = 4000;
        this.camera.minZ = 0.1;
        this.camera.maxZ = 1000;

        // Enable collision detection
        this.camera.checkCollisions = true;
        this.camera.applyGravity = true;
        this.camera.ellipsoid = new BABYLON.Vector3(1, 1, 1);
    }

    setupLighting() {
        // Hemisphere light for ambient lighting
        this.light = new BABYLON.HemisphericLight(
            "hemiLight",
            new BABYLON.Vector3(0, 1, 0),
            this.scene
        );
        this.light.intensity = 0.7;

        // Directional light for shadows
        const dirLight = new BABYLON.DirectionalLight(
            "dirLight",
            new BABYLON.Vector3(-1, -1, -1),
            this.scene
        );
        dirLight.position = new BABYLON.Vector3(20, 40, 20);
        dirLight.intensity = 0.5;

        // Enable shadows
        const shadowGenerator = new BABYLON.ShadowGenerator(1024, dirLight);
        shadowGenerator.useBlurExponentialShadowMap = true;
        shadowGenerator.blurKernel = 32;

        return shadowGenerator;
    }

    setupEnvironment() {
        // Create skybox
        const skybox = BABYLON.MeshBuilder.CreateSphere("skyBox", {diameter:100}, this.scene);
        const skyboxMaterial = new BABYLON.StandardMaterial("skyBox", this.scene);
        skyboxMaterial.backFaceCulling = false;
        skyboxMaterial.reflectionTexture = new BABYLON.CubeTexture("/assets/skybox/skybox", this.scene);
        skyboxMaterial.reflectionTexture.coordinatesMode = BABYLON.Texture.SKYBOX_MODE;
        skyboxMaterial.diffuseColor = new BABYLON.Color3(0, 0, 0);
        skyboxMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
        skybox.material = skyboxMaterial;

        // Create ground
        const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 50, height: 50}, this.scene);
        const groundMaterial = new BABYLON.StandardMaterial("groundMat", this.scene);
        groundMaterial.diffuseTexture = new BABYLON.Texture("/assets/textures/grass.jpg", this.scene);
        groundMaterial.diffuseTexture.uOffset = 0;
        groundMaterial.diffuseTexture.vOffset = 0;
        groundMaterial.diffuseTexture.wrapU = BABYLON.Texture.MIRROR_ADDRESSMODE;
        groundMaterial.diffuseTexture.wrapV = BABYLON.Texture.MIRROR_ADDRESSMODE;
        ground.material = groundMaterial;
        ground.receiveShadows = true;
        ground.checkCollisions = true;
    }

    startRenderLoop() {
        this.engine.runRenderLoop(() => {
            if (this.scene && this.scene.activeCamera) {
                this.scene.render();
            }
        });
    }

    handleResize() {
        window.addEventListener("resize", () => {
            this.engine.resize();
        });
    }

    async loadAssets() {
        // Asset loading implementation
        const assetsManager = new BABYLON.AssetsManager(this.scene);

        // Add tasks and load
        return new Promise((resolve) => {
            assetsManager.onFinish = (tasks) => {
                resolve(tasks);
            };

            assetsManager.load();
        });
    }

    dispose() {
        if (this.engine) {
            this.engine.dispose();
        }
    }
}

// Initialize app
const app = new BabylonApp('renderCanvas');
```

## Advanced Lighting Examples

### PBR Lighting Setup
```javascript
function createPBRLighting(scene) {
    // Environment lighting
    const envTexture = BABYLON.CubeTexture.CreateFromPrefilteredData(
        "/assets/environment.env", scene
    );
    scene.environmentTexture = envTexture;
    scene.createDefaultSkybox(envTexture, true, 100);

    // Image-based lighting
    const hdrTexture = new BABYLON.HDRCubeTexture("/assets/forest.hdr", scene, 512);
    scene.environmentTexture = hdrTexture;

    // Tone mapping
    scene.imageProcessingConfiguration.toneMappingEnabled = true;
    scene.imageProcessingConfiguration.toneMappingType = BABYLON.ImageProcessingConfiguration.TONEMAPPING_ACES;
    scene.imageProcessingConfiguration.exposure = 1.0;

    return {
        envTexture,
        hdrTexture
    };
}

function createAdvancedLighting(scene) {
    // Point lights array
    const pointLights = [];

    // Main point light
    const pointLight = new BABYLON.PointLight("pointLight", new BABYLON.Vector3(10, 10, 0), scene);
    pointLight.diffuse = new BABYLON.Color3(1, 1, 0);
    pointLight.specular = new BABYLON.Color3(1, 1, 0);
    pointLight.intensity = 0.5;
    pointLight.range = 100;
    pointLights.push(pointLight);

    // Spot light with animations
    const spotLight = new BABYLON.SpotLight(
        "spotLight",
        new BABYLON.Vector3(0, 30, -10),
        new BABYLON.Vector3(0, -1, 0),
        Math.PI / 3,
        2,
        scene
    );
    spotLight.diffuse = new BABYLON.Color3(1, 1, 1);
    spotLight.specular = new BABYLON.Color3(1, 1, 1);
    spotLight.intensity = 2;

    // Animate spot light
    const animationSpotLight = BABYLON.Animation.CreateAndStartAnimation(
        "spotLightAnim",
        spotLight,
        "position.x",
        30,
        120,
        -20,
        20,
        BABYLON.Animation.ANIMATIONLOOPMODE_CYCLE
    );

    // Area light simulation
    const areaLight = new BABYLON.DirectionalLight(
        "areaLight",
        new BABYLON.Vector3(0, -1, 0),
        scene
    );
    areaLight.intensity = 0.3;

    return {
        pointLights,
        spotLight,
        areaLight
    };
}
```

### Dynamic Lighting System
```javascript
class DynamicLightingSystem {
    constructor(scene) {
        this.scene = scene;
        this.lights = [];
        this.shadowGenerators = [];
        this.timeOfDay = 0.5; // 0 = midnight, 0.5 = noon, 1 = midnight

        this.init();
    }

    init() {
        // Sun light (directional)
        this.sunLight = new BABYLON.DirectionalLight(
            "sunLight",
            new BABYLON.Vector3(-1, -1, -1),
            this.scene
        );

        // Moon light (directional)
        this.moonLight = new BABYLON.DirectionalLight(
            "moonLight",
            new BABYLON.Vector3(1, -1, 1),
            this.scene
        );

        // Ambient light
        this.ambientLight = new BABYLON.HemisphericLight(
            "ambientLight",
            new BABYLON.Vector3(0, 1, 0),
            this.scene
        );

        // Setup shadow generators
        this.sunShadows = new BABYLON.ShadowGenerator(2048, this.sunLight);
        this.sunShadows.useBlurExponentialShadowMap = true;

        this.updateTimeOfDay(this.timeOfDay);
    }

    updateTimeOfDay(time) {
        this.timeOfDay = time;

        // Calculate sun position
        const sunAngle = time * Math.PI * 2 - Math.PI/2;
        const sunHeight = Math.sin(sunAngle);
        const sunX = Math.cos(sunAngle);

        this.sunLight.direction = new BABYLON.Vector3(sunX, -Math.abs(sunHeight), 0.5);

        // Day/night intensity
        const dayIntensity = Math.max(0, sunHeight);
        const nightIntensity = Math.max(0, -sunHeight * 0.3);

        this.sunLight.intensity = dayIntensity;
        this.moonLight.intensity = nightIntensity;

        // Color temperature
        const dayColor = new BABYLON.Color3(1, 0.95, 0.8); // Warm daylight
        const sunsetColor = new BABYLON.Color3(1, 0.5, 0.2); // Orange sunset
        const nightColor = new BABYLON.Color3(0.3, 0.3, 0.8); // Cool moonlight

        if (dayIntensity > 0.1) {
            // Day time
            this.sunLight.diffuse = dayColor;
            this.ambientLight.diffuse = dayColor.scale(0.6);
        } else if (dayIntensity > -0.1) {
            // Sunset/sunrise
            this.sunLight.diffuse = sunsetColor;
            this.ambientLight.diffuse = sunsetColor.scale(0.4);
        } else {
            // Night time
            this.moonLight.diffuse = nightColor;
            this.ambientLight.diffuse = nightColor.scale(0.3);
        }

        // Update ambient intensity
        this.ambientLight.intensity = 0.3 + dayIntensity * 0.4;
    }

    animateTimeOfDay(duration = 60000) {
        const startTime = this.timeOfDay;
        const endTime = startTime + 1;

        BABYLON.Animation.CreateAndStartAnimation(
            "timeOfDayAnim",
            this,
            "timeOfDay",
            60,
            60 * (duration / 1000),
            startTime,
            endTime,
            BABYLON.Animation.ANIMATIONLOOPMODE_CYCLE,
            null,
            () => this.updateTimeOfDay(this.timeOfDay)
        );
    }
}
```

## Material and Texture Examples

### PBR Material Creation
```javascript
function createPBRMaterials(scene) {
    const materials = {};

    // Metal material
    materials.metal = new BABYLON.PBRMaterial("metalMaterial", scene);
    materials.metal.baseTexture = new BABYLON.Texture("/assets/textures/metal_basecolor.jpg", scene);
    materials.metal.normalTexture = new BABYLON.Texture("/assets/textures/metal_normal.jpg", scene);
    materials.metal.metallicTexture = new BABYLON.Texture("/assets/textures/metal_metallic.jpg", scene);
    materials.metal.roughnessTexture = new BABYLON.Texture("/assets/textures/metal_roughness.jpg", scene);
    materials.metal.occlusionTexture = new BABYLON.Texture("/assets/textures/metal_ao.jpg", scene);
    materials.metal.metallicFactor = 1.0;
    materials.metal.roughnessFactor = 0.4;

    // Glass material
    materials.glass = new BABYLON.PBRMaterial("glassMaterial", scene);
    materials.glass.baseColor = new BABYLON.Color3(0.9, 0.9, 1.0);
    materials.glass.metallicFactor = 0.0;
    materials.glass.roughnessFactor = 0.05;
    materials.glass.alpha = 0.3;
    materials.glass.indexOfRefraction = 1.52;
    materials.glass.linkRefractionWithTransparency = true;

    // Fabric material
    materials.fabric = new BABYLON.PBRMaterial("fabricMaterial", scene);
    materials.fabric.baseTexture = new BABYLON.Texture("/assets/textures/fabric_basecolor.jpg", scene);
    materials.fabric.normalTexture = new BABYLON.Texture("/assets/textures/fabric_normal.jpg", scene);
    materials.fabric.metallicFactor = 0.0;
    materials.fabric.roughnessFactor = 0.8;
    materials.fabric.baseTexture.uScale = 4;
    materials.fabric.baseTexture.vScale = 4;

    // Emissive material
    materials.emissive = new BABYLON.PBRMaterial("emissiveMaterial", scene);
    materials.emissive.emissiveTexture = new BABYLON.Texture("/assets/textures/emissive.jpg", scene);
    materials.emissive.emissiveColor = new BABYLON.Color3(0, 0.5, 1);
    materials.emissive.emissiveIntensity = 2.0;

    return materials;
}

function createProceduralTextures(scene) {
    // Noise texture
    const noiseTexture = new BABYLON.NoiseProceduralTexture("noise", 256, scene);
    noiseTexture.animationSpeedFactor = 5;
    noiseTexture.persistence = 2;
    noiseTexture.brightness = 0.5;
    noiseTexture.octaves = 8;

    // Wood texture
    const woodTexture = new BABYLON.WoodProceduralTexture("wood", 1024, scene);
    woodTexture.woodColor = new BABYLON.Color3(0.49, 0.25, 0);
    woodTexture.ringColor = new BABYLON.Color3(0.78, 0.42, 0.19);

    // Marble texture
    const marbleTexture = new BABYLON.MarbleProceduralTexture("marble", 512, scene);
    marbleTexture.numberOfTilesHeight = 4;
    marbleTexture.numberOfTilesWidth = 4;
    marbleTexture.marbleColor = new BABYLON.Color3(0.77, 0.47, 0.40);
    marbleTexture.jointColor = new BABYLON.Color3(0.72, 0.72, 0.72);

    return {
        noise: noiseTexture,
        wood: woodTexture,
        marble: marbleTexture
    };
}
```

### Dynamic Material System
```javascript
class MaterialLibrary {
    constructor(scene) {
        this.scene = scene;
        this.materials = new Map();
        this.textures = new Map();
        this.shaders = new Map();

        this.initializeBaseMaterials();
    }

    initializeBaseMaterials() {
        // Standard materials
        this.createStandardMaterial('default', {
            diffuseColor: new BABYLON.Color3(0.8, 0.8, 0.8),
            specularColor: new BABYLON.Color3(0.2, 0.2, 0.2)
        });

        // PBR materials
        this.createPBRMaterial('defaultPBR', {
            baseColor: new BABYLON.Color3(0.8, 0.8, 0.8),
            metallicFactor: 0.0,
            roughnessFactor: 0.5
        });
    }

    createStandardMaterial(name, options = {}) {
        const material = new BABYLON.StandardMaterial(name, this.scene);

        // Apply options
        Object.keys(options).forEach(key => {
            if (material[key] !== undefined) {
                material[key] = options[key];
            }
        });

        this.materials.set(name, material);
        return material;
    }

    createPBRMaterial(name, options = {}) {
        const material = new BABYLON.PBRMaterial(name, this.scene);

        // Apply options
        Object.keys(options).forEach(key => {
            if (material[key] !== undefined) {
                material[key] = options[key];
            }
        });

        this.materials.set(name, material);
        return material;
    }

    createCustomShader(name, vertexSource, fragmentSource, options = {}) {
        const shaderMaterial = new BABYLON.ShaderMaterial(name, this.scene, {
            vertex: "custom",
            fragment: "custom"
        }, options);

        // Register shaders
        BABYLON.Effect.ShadersStore[`${name}VertexShader`] = vertexSource;
        BABYLON.Effect.ShadersStore[`${name}FragmentShader`] = fragmentSource;

        this.shaders.set(name, shaderMaterial);
        return shaderMaterial;
    }

    loadTexture(name, url, options = {}) {
        const texture = new BABYLON.Texture(url, this.scene, options.noMipmap, options.invertY);

        // Apply texture options
        if (options.uScale) texture.uScale = options.uScale;
        if (options.vScale) texture.vScale = options.vScale;
        if (options.wrapU) texture.wrapU = options.wrapU;
        if (options.wrapV) texture.wrapV = options.wrapV;

        this.textures.set(name, texture);
        return texture;
    }

    getMaterial(name) {
        return this.materials.get(name) || this.shaders.get(name);
    }

    getTexture(name) {
        return this.textures.get(name);
    }

    cloneMaterial(sourceName, newName, modifications = {}) {
        const source = this.getMaterial(sourceName);
        if (!source) return null;

        const cloned = source.clone(newName);

        // Apply modifications
        Object.keys(modifications).forEach(key => {
            if (cloned[key] !== undefined) {
                cloned[key] = modifications[key];
            }
        });

        this.materials.set(newName, cloned);
        return cloned;
    }
}
```

## Animation Examples

### Comprehensive Animation System
```javascript
class AnimationController {
    constructor(scene) {
        this.scene = scene;
        this.animations = new Map();
        this.animationGroups = new Map();
        this.morphTargetManagers = new Map();
    }

    createBasicAnimation(target, property, keys, options = {}) {
        const animation = new BABYLON.Animation(
            options.name || `${property}Animation`,
            property,
            options.frameRate || 30,
            options.dataType || BABYLON.Animation.ANIMATIONTYPE_FLOAT,
            options.loopMode || BABYLON.Animation.ANIMATIONLOOPMODE_CYCLE
        );

        animation.setKeys(keys);

        // Add easing function if specified
        if (options.easingFunction) {
            animation.setEasingFunction(options.easingFunction);
        }

        target.animations.push(animation);
        this.animations.set(options.name || `${property}Animation`, animation);

        return animation;
    }

    createRotationAnimation(mesh, duration = 2000) {
        const animationRotation = new BABYLON.Animation(
            "rotationAnimation",
            "rotation.y",
            30,
            BABYLON.Animation.ANIMATIONTYPE_FLOAT,
            BABYLON.Animation.ANIMATIONLOOPMODE_CYCLE
        );

        const keys = [
            { frame: 0, value: 0 },
            { frame: 30, value: Math.PI },
            { frame: 60, value: Math.PI * 2 }
        ];

        animationRotation.setKeys(keys);

        // Add smooth easing
        const easingFunction = new BABYLON.CircleEase();
        easingFunction.setEasingMode(BABYLON.EasingFunction.EASINGMODE_EASEINOUT);
        animationRotation.setEasingFunction(easingFunction);

        mesh.animations.push(animationRotation);

        return this.scene.beginAnimation(mesh, 0, 60, true);
    }

    createComplexAnimation(mesh, keyframes) {
        const animationGroup = new BABYLON.AnimationGroup("complexAnimation");

        keyframes.forEach((keyframe, index) => {
            const { property, values, duration, delay = 0 } = keyframe;

            const animation = new BABYLON.Animation(
                `${property}Animation_${index}`,
                property,
                30,
                this.getAnimationType(values[0]),
                BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT
            );

            const keys = values.map((value, i) => ({
                frame: (duration / values.length) * i,
                value: value
            }));

            animation.setKeys(keys);

            const animatable = this.scene.beginDirectAnimation(
                mesh,
                [animation],
                0,
                duration,
                false,
                1,
                () => {
                    // Animation complete callback
                }
            );

            animationGroup.addTargetedAnimation(animation, mesh);
        });

        this.animationGroups.set(mesh.name + "_complex", animationGroup);
        return animationGroup;
    }

    createMorphTargetAnimation(mesh, morphTargetManager) {
        if (!morphTargetManager) return null;

        const animations = [];

        for (let i = 0; i < morphTargetManager.numTargets; i++) {
            const target = morphTargetManager.getTarget(i);
            const animation = new BABYLON.Animation(
                `morphTarget_${i}`,
                "influence",
                30,
                BABYLON.Animation.ANIMATIONTYPE_FLOAT,
                BABYLON.Animation.ANIMATIONLOOPMODE_CYCLE
            );

            const keys = [
                { frame: 0, value: 0 },
                { frame: 30, value: 1 },
                { frame: 60, value: 0 }
            ];

            animation.setKeys(keys);
            target.animations.push(animation);
            animations.push(animation);
        }

        this.morphTargetManagers.set(mesh.name, morphTargetManager);
        return animations;
    }

    createParticleAnimation(particleSystem, properties) {
        const animations = [];

        Object.keys(properties).forEach(property => {
            const config = properties[property];
            const animation = new BABYLON.Animation(
                `particle_${property}`,
                property,
                30,
                this.getAnimationType(config.values[0]),
                BABYLON.Animation.ANIMATIONLOOPMODE_CYCLE
            );

            const keys = config.values.map((value, index) => ({
                frame: (config.duration / config.values.length) * index,
                value: value
            }));

            animation.setKeys(keys);
            particleSystem.animations.push(animation);
            animations.push(animation);
        });

        return animations;
    }

    getAnimationType(value) {
        if (typeof value === 'number') {
            return BABYLON.Animation.ANIMATIONTYPE_FLOAT;
        } else if (value instanceof BABYLON.Vector3) {
            return BABYLON.Animation.ANIMATIONTYPE_VECTOR3;
        } else if (value instanceof BABYLON.Color3) {
            return BABYLON.Animation.ANIMATIONTYPE_COLOR3;
        }
        return BABYLON.Animation.ANIMATIONTYPE_FLOAT;
    }

    playAnimation(name, options = {}) {
        const animation = this.animations.get(name);
        const animationGroup = this.animationGroups.get(name);

        if (animationGroup) {
            animationGroup.start(options.loop, options.speedRatio, options.from, options.to);
            return animationGroup;
        } else if (animation) {
            return this.scene.beginAnimation(
                animation.targetPath,
                options.from || 0,
                options.to || 100,
                options.loop || false,
                options.speedRatio || 1.0
            );
        }

        return null;
    }

    stopAnimation(name) {
        const animationGroup = this.animationGroups.get(name);
        if (animationGroup) {
            animationGroup.stop();
        }
    }

    pauseAnimation(name) {
        const animationGroup = this.animationGroups.get(name);
        if (animationGroup) {
            animationGroup.pause();
        }
    }

    dispose() {
        this.animations.clear();
        this.animationGroups.forEach(group => group.dispose());
        this.animationGroups.clear();
        this.morphTargetManagers.clear();
    }
}
```

### Skeletal Animation with Mixamo
```javascript
class SkeletalAnimationSystem {
    constructor(scene) {
        this.scene = scene;
        this.skeletons = new Map();
        this.animationGroups = new Map();
        this.currentAnimations = new Map();
    }

    async loadCharacterWithAnimations(modelUrl, animationUrls = []) {
        try {
            // Load main character model
            const result = await BABYLON.SceneLoader.ImportMeshAsync("", "", modelUrl, this.scene);
            const character = result.meshes[0];
            const skeleton = result.skeletons[0];

            if (skeleton) {
                this.skeletons.set(character.name, skeleton);

                // Load additional animations
                for (const animUrl of animationUrls) {
                    await this.loadAnimation(character.name, animUrl);
                }
            }

            return { character, skeleton };
        } catch (error) {
            console.error('Failed to load character:', error);
            return null;
        }
    }

    async loadAnimation(characterName, animationUrl) {
        try {
            const result = await BABYLON.SceneLoader.ImportAnimationsAsync(
                "",
                "",
                animationUrl,
                this.scene
            );

            if (result.animationGroups && result.animationGroups.length > 0) {
                const animationGroup = result.animationGroups[0];
                const animName = animationGroup.name || `anim_${Date.now()}`;

                // Store animation
                if (!this.animationGroups.has(characterName)) {
                    this.animationGroups.set(characterName, new Map());
                }

                this.animationGroups.get(characterName).set(animName, animationGroup);

                return animationGroup;
            }
        } catch (error) {
            console.error('Failed to load animation:', error);
        }

        return null;
    }

    playAnimation(characterName, animationName, options = {}) {
        const characterAnims = this.animationGroups.get(characterName);
        if (!characterAnims) return null;

        const animationGroup = characterAnims.get(animationName);
        if (!animationGroup) return null;

        // Stop current animation if playing
        this.stopAnimation(characterName);

        // Configure animation
        animationGroup.loopAnimation = options.loop !== false;
        animationGroup.speedRatio = options.speed || 1.0;

        // Blend with current animation if specified
        if (options.blendTime && this.currentAnimations.has(characterName)) {
            const currentAnim = this.currentAnimations.get(characterName);
            if (currentAnim && currentAnim !== animationGroup) {
                // Perform blending
                this.blendAnimations(currentAnim, animationGroup, options.blendTime);
            }
        }

        animationGroup.start(options.loop !== false, options.speed || 1.0);
        this.currentAnimations.set(characterName, animationGroup);

        return animationGroup;
    }

    blendAnimations(fromAnim, toAnim, duration = 0.3) {
        // Create weight animations for blending
        const blendAnimation = BABYLON.Animation.CreateAndStartAnimation(
            "blendWeight",
            fromAnim,
            "weight",
            30,
            30 * duration,
            1.0,
            0.0,
            BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT,
            null,
            () => {
                fromAnim.stop();
            }
        );

        toAnim.weight = 0.0;
        toAnim.start();

        BABYLON.Animation.CreateAndStartAnimation(
            "blendWeight",
            toAnim,
            "weight",
            30,
            30 * duration,
            0.0,
            1.0,
            BABYLON.Animation.ANIMATIONLOOPMODE_CONSTANT
        );
    }

    stopAnimation(characterName) {
        const currentAnim = this.currentAnimations.get(characterName);
        if (currentAnim) {
            currentAnim.stop();
            this.currentAnimations.delete(characterName);
        }
    }

    pauseAnimation(characterName) {
        const currentAnim = this.currentAnimations.get(characterName);
        if (currentAnim) {
            currentAnim.pause();
        }
    }

    getAnimationProgress(characterName) {
        const currentAnim = this.currentAnimations.get(characterName);
        if (currentAnim) {
            return currentAnim.animatables[0]?.masterFrame / currentAnim.to;
        }
        return 0;
    }

    setAnimationProgress(characterName, progress) {
        const currentAnim = this.currentAnimations.get(characterName);
        if (currentAnim && currentAnim.animatables[0]) {
            const frame = progress * currentAnim.to;
            currentAnim.animatables[0].goToFrame(frame);
        }
    }
}
```

## Physics Examples

### Havok Physics Integration
```javascript
class PhysicsManager {
    constructor(scene) {
        this.scene = scene;
        this.physicsPlugin = null;
        this.physicsObjects = new Map();

        this.initializePhysics();
    }

    async initializePhysics() {
        try {
            // Initialize Havok physics
            const havokInstance = await HavokPhysics();
            this.physicsPlugin = new BABYLON.HavokPlugin(true, havokInstance);

            this.scene.enablePhysics(new BABYLON.Vector3(0, -9.81, 0), this.physicsPlugin);

            console.log('Havok Physics initialized successfully');
        } catch (error) {
            console.warn('Havok not available, falling back to Cannon.js');
            this.initializeCannonJS();
        }
    }

    initializeCannonJS() {
        this.physicsPlugin = new BABYLON.CannonJSPlugin();
        this.scene.enablePhysics(new BABYLON.Vector3(0, -9.81, 0), this.physicsPlugin);
    }

    createRigidBody(mesh, options = {}) {
        const physicsImpostor = new BABYLON.PhysicsImpostor(
            mesh,
            options.shape || BABYLON.PhysicsImpostor.BoxImpostor,
            {
                mass: options.mass || 1,
                restitution: options.restitution || 0.7,
                friction: options.friction || 0.3,
                ...options
            },
            this.scene
        );

        this.physicsObjects.set(mesh.name, physicsImpostor);
        return physicsImpostor;
    }

    createCompoundBody(meshes, options = {}) {
        const parent = meshes[0];
        const parentImpostor = this.createRigidBody(parent, {
            mass: 0, // Will be calculated from children
            ...options
        });

        meshes.slice(1).forEach(mesh => {
            const childImpostor = this.createRigidBody(mesh, {
                mass: options.childMass || 1,
                ...options
            });

            // Create joint between parent and child
            const joint = new BABYLON.PhysicsJoint(
                BABYLON.PhysicsJoint.PointToPointJoint,
                {
                    mainPivot: mesh.position.subtract(parent.position),
                    connectedPivot: BABYLON.Vector3.Zero()
                }
            );

            parentImpostor.addJoint(childImpostor, joint);
        });

        return parentImpostor;
    }

    createSoftBody(mesh, options = {}) {
        // Soft body simulation using physics constraints
        const vertices = mesh.getVerticesData(BABYLON.VertexBuffer.PositionKind);
        const indices = mesh.getIndices();

        if (!vertices || !indices) return null;

        const spheres = [];
        const constraints = [];

        // Create sphere for each vertex
        for (let i = 0; i < vertices.length; i += 3) {
            const sphere = BABYLON.MeshBuilder.CreateSphere(
                `softBody_${i/3}`,
                { diameter: 0.1 },
                this.scene
            );

            sphere.position = new BABYLON.Vector3(
                vertices[i],
                vertices[i + 1],
                vertices[i + 2]
            );

            const impostor = this.createRigidBody(sphere, {
                mass: options.particleMass || 0.1,
                shape: BABYLON.PhysicsImpostor.SphereImpostor
            });

            spheres.push({ mesh: sphere, impostor });
        }

        // Create constraints between connected vertices
        for (let i = 0; i < indices.length; i += 3) {
            const a = indices[i];
            const b = indices[i + 1];
            const c = indices[i + 2];

            this.createSpringConstraint(spheres[a], spheres[b], options);
            this.createSpringConstraint(spheres[b], spheres[c], options);
            this.createSpringConstraint(spheres[c], spheres[a], options);
        }

        return { spheres, constraints };
    }

    createSpringConstraint(objectA, objectB, options = {}) {
        const distance = BABYLON.Vector3.Distance(
            objectA.mesh.position,
            objectB.mesh.position
        );

        const joint = new BABYLON.PhysicsJoint(
            BABYLON.PhysicsJoint.SpringJoint,
            {
                length: distance,
                stiffness: options.stiffness || 100,
                damping: options.damping || 10
            }
        );

        objectA.impostor.addJoint(objectB.impostor, joint);
        return joint;
    }

    createTriggerZone(position, size, onEnter, onExit) {
        const trigger = BABYLON.MeshBuilder.CreateBox("trigger", size, this.scene);
        trigger.position = position;
        trigger.visibility = 0; // Invisible

        const impostor = new BABYLON.PhysicsImpostor(
            trigger,
            BABYLON.PhysicsImpostor.BoxImpostor,
            { mass: 0 },
            this.scene
        );

        // Monitor for intersections
        impostor.registerOnPhysicsCollide(BABYLON.PhysicsImpostor.BoxImpostor, (main, collided) => {
            if (onEnter) onEnter(collided.object);
        });

        return { trigger, impostor };
    }

    applyForce(meshName, force, localPosition) {
        const impostor = this.physicsObjects.get(meshName);
        if (impostor) {
            impostor.applyImpulse(force, localPosition || impostor.object.position);
        }
    }

    setVelocity(meshName, velocity) {
        const impostor = this.physicsObjects.get(meshName);
        if (impostor) {
            impostor.setLinearVelocity(velocity);
        }
    }

    raycast(origin, direction, maxDistance = 100) {
        const ray = new BABYLON.Ray(origin, direction, maxDistance);
        const hit = this.scene.pickWithRay(ray);

        if (hit && hit.hit) {
            return {
                hit: true,
                point: hit.pickedPoint,
                mesh: hit.pickedMesh,
                distance: hit.distance,
                normal: hit.getNormal()
            };
        }

        return { hit: false };
    }

    dispose() {
        this.physicsObjects.forEach(impostor => {
            impostor.dispose();
        });
        this.physicsObjects.clear();

        if (this.scene.getPhysicsEngine()) {
            this.scene.getPhysicsEngine().dispose();
        }
    }
}
```

### Particle Physics System
```javascript
class ParticlePhysicsSystem {
    constructor(scene) {
        this.scene = scene;
        this.particleSystems = new Map();
        this.gpu = !!scene.getEngine().getCaps().parallelShaderCompile;
    }

    createFireEffect(position, options = {}) {
        const particleSystem = new BABYLON.ParticleSystem("fire", 2000, this.scene);

        // Texture
        particleSystem.particleTexture = new BABYLON.Texture("/assets/particles/flare.png", this.scene);

        // Position and emission
        particleSystem.emitter = position;
        particleSystem.minEmitBox = new BABYLON.Vector3(-1, 0, -1);
        particleSystem.maxEmitBox = new BABYLON.Vector3(1, 0, 1);

        // Colors
        particleSystem.color1 = new BABYLON.Color4(1, 0.5, 0, 1.0);
        particleSystem.color2 = new BABYLON.Color4(1, 0.2, 0, 1.0);
        particleSystem.colorDead = new BABYLON.Color4(0, 0, 0, 0.0);

        // Size
        particleSystem.minSize = 0.1;
        particleSystem.maxSize = 0.5;

        // Life time
        particleSystem.minLifeTime = 0.3;
        particleSystem.maxLifeTime = 1.5;

        // Emission rate
        particleSystem.emitRate = 1500;

        // Blend mode
        particleSystem.blendMode = BABYLON.ParticleSystem.BLENDMODE_ONEONE;

        // Direction
        particleSystem.direction1 = new BABYLON.Vector3(-2, 8, -2);
        particleSystem.direction2 = new BABYLON.Vector3(2, 8, 2);

        // Angular velocity
        particleSystem.minAngularVelocity = 0;
        particleSystem.maxAngularVelocity = Math.PI;

        // Speed
        particleSystem.minInitialRotation = 0;
        particleSystem.maxInitialRotation = Math.PI;

        // Gravity
        particleSystem.gravity = new BABYLON.Vector3(0, -9.81, 0);

        particleSystem.start();

        this.particleSystems.set('fire', particleSystem);
        return particleSystem;
    }

    createSmokeEffect(position, options = {}) {
        const particleSystem = new BABYLON.ParticleSystem("smoke", 1000, this.scene);

        particleSystem.particleTexture = new BABYLON.Texture("/assets/particles/smoke.png", this.scene);

        particleSystem.emitter = position;
        particleSystem.minEmitBox = new BABYLON.Vector3(-0.5, 0, -0.5);
        particleSystem.maxEmitBox = new BABYLON.Vector3(0.5, 0, 0.5);

        // Smoke colors (grayscale)
        particleSystem.color1 = new BABYLON.Color4(0.8, 0.8, 0.8, 1.0);
        particleSystem.color2 = new BABYLON.Color4(0.6, 0.6, 0.6, 1.0);
        particleSystem.colorDead = new BABYLON.Color4(0, 0, 0, 0.0);

        particleSystem.minSize = 0.5;
        particleSystem.maxSize = 2.0;

        particleSystem.minLifeTime = 2.0;
        particleSystem.maxLifeTime = 4.0;

        particleSystem.emitRate = 300;

        particleSystem.blendMode = BABYLON.ParticleSystem.BLENDMODE_STANDARD;

        // Upward movement
        particleSystem.direction1 = new BABYLON.Vector3(-1, 4, -1);
        particleSystem.direction2 = new BABYLON.Vector3(1, 6, 1);

        particleSystem.gravity = new BABYLON.Vector3(0, -2, 0);

        // Add some turbulence
        particleSystem.noiseTexture = new BABYLON.NoiseProceduralTexture("noise", 256, this.scene);
        particleSystem.noiseStrength = new BABYLON.Vector3(10, 5, 10);

        particleSystem.start();

        this.particleSystems.set('smoke', particleSystem);
        return particleSystem;
    }

    createRainEffect(area, options = {}) {
        const particleSystem = new BABYLON.ParticleSystem("rain", 10000, this.scene);

        // Create emitter area
        const emitter = BABYLON.MeshBuilder.CreateBox("rainEmitter", {
            width: area.width || 50,
            height: 0.1,
            depth: area.depth || 50
        }, this.scene);
        emitter.position = new BABYLON.Vector3(area.x || 0, area.y || 20, area.z || 0);
        emitter.visibility = 0;

        particleSystem.emitter = emitter;
        particleSystem.particleTexture = new BABYLON.Texture("/assets/particles/raindrop.png", this.scene);

        // Rain appearance
        particleSystem.color1 = new BABYLON.Color4(0.7, 0.8, 1.0, 0.8);
        particleSystem.color2 = new BABYLON.Color4(0.5, 0.6, 0.8, 0.6);

        particleSystem.minSize = 0.02;
        particleSystem.maxSize = 0.05;

        particleSystem.minLifeTime = 2.0;
        particleSystem.maxLifeTime = 4.0;

        particleSystem.emitRate = 3000;

        // Downward direction
        particleSystem.direction1 = new BABYLON.Vector3(-0.5, -10, -0.5);
        particleSystem.direction2 = new BABYLON.Vector3(0.5, -15, 0.5);

        particleSystem.gravity = new BABYLON.Vector3(0, -20, 0);

        particleSystem.start();

        this.particleSystems.set('rain', particleSystem);
        return particleSystem;
    }

    createExplosionEffect(position, options = {}) {
        const particleSystem = new BABYLON.ParticleSystem("explosion", 5000, this.scene);

        particleSystem.particleTexture = new BABYLON.Texture("/assets/particles/explosion.png", this.scene);
        particleSystem.emitter = position;

        // Explosion colors
        particleSystem.color1 = new BABYLON.Color4(1, 0.8, 0, 1.0);
        particleSystem.color2 = new BABYLON.Color4(1, 0.4, 0, 1.0);
        particleSystem.colorDead = new BABYLON.Color4(0.5, 0.5, 0.5, 0.0);

        particleSystem.minSize = 0.1;
        particleSystem.maxSize = 1.0;

        particleSystem.minLifeTime = 0.5;
        particleSystem.maxLifeTime = 2.0;

        particleSystem.emitRate = 2000;

        // Spherical explosion
        particleSystem.createSphereEmitter(1.0);

        particleSystem.minEmitPower = 5;
        particleSystem.maxEmitPower = 10;

        particleSystem.gravity = new BABYLON.Vector3(0, -5, 0);

        // Auto-stop after explosion
        setTimeout(() => {
            particleSystem.stop();
        }, 1000);

        particleSystem.start();

        this.particleSystems.set('explosion_' + Date.now(), particleSystem);
        return particleSystem;
    }

    createGPUParticleSystem(name, capacity) {
        if (!this.gpu) {
            console.warn('GPU particles not supported, falling back to CPU');
            return new BABYLON.ParticleSystem(name, capacity, this.scene);
        }

        const gpuParticleSystem = new BABYLON.GPUParticleSystem(name, capacity, this.scene);
        this.particleSystems.set(name, gpuParticleSystem);
        return gpuParticleSystem;
    }

    stopAllParticles() {
        this.particleSystems.forEach(system => {
            system.stop();
        });
    }

    disposeAllParticles() {
        this.particleSystems.forEach(system => {
            system.dispose();
        });
        this.particleSystems.clear();
    }
}
```

## Asset Loading and Management

### Advanced Asset Manager
```javascript
class AssetManager {
    constructor(scene) {
        this.scene = scene;
        this.loadedAssets = new Map();
        this.loadingTasks = new Map();
        this.assetGroups = new Map();
        this.progressCallbacks = new Map();
    }

    async loadModel(name, url, options = {}) {
        if (this.loadedAssets.has(name)) {
            return this.loadedAssets.get(name);
        }

        try {
            const result = await BABYLON.SceneLoader.ImportMeshAsync(
                options.meshNames || "",
                "",
                url,
                this.scene,
                (progress) => {
                    const callback = this.progressCallbacks.get(name);
                    if (callback) {
                        callback(progress.loaded / progress.total);
                    }
                }
            );

            const asset = {
                meshes: result.meshes,
                skeletons: result.skeletons,
                animationGroups: result.animationGroups,
                transformNodes: result.transformNodes,
                geometries: result.geometries,
                lights: result.lights
            };

            // Apply post-processing
            if (options.postProcess) {
                await this.postProcessAsset(asset, options.postProcess);
            }

            this.loadedAssets.set(name, asset);
            return asset;

        } catch (error) {
            console.error(`Failed to load model ${name}:`, error);
            throw error;
        }
    }

    async loadTexture(name, url, options = {}) {
        if (this.loadedAssets.has(name)) {
            return this.loadedAssets.get(name);
        }

        const texture = new BABYLON.Texture(url, this.scene, options.noMipmap, options.invertY);

        return new Promise((resolve, reject) => {
            texture.onLoadObservable.add(() => {
                // Apply texture options
                if (options.wrapU) texture.wrapU = options.wrapU;
                if (options.wrapV) texture.wrapV = options.wrapV;
                if (options.uScale) texture.uScale = options.uScale;
                if (options.vScale) texture.vScale = options.vScale;

                this.loadedAssets.set(name, texture);
                resolve(texture);
            });

            texture.onErrorObservable.add((error) => {
                reject(error);
            });
        });
    }

    async loadEnvironment(name, url, options = {}) {
        try {
            let envTexture;

            if (url.endsWith('.hdr')) {
                envTexture = new BABYLON.HDRCubeTexture(url, this.scene, options.size || 512);
            } else if (url.endsWith('.env')) {
                envTexture = BABYLON.CubeTexture.CreateFromPrefilteredData(url, this.scene);
            } else {
                envTexture = new BABYLON.CubeTexture(url, this.scene);
            }

            if (options.setAsEnvironment) {
                this.scene.environmentTexture = envTexture;

                if (options.createSkybox) {
                    this.scene.createDefaultSkybox(envTexture, true, options.skyboxSize || 100);
                }
            }

            this.loadedAssets.set(name, envTexture);
            return envTexture;

        } catch (error) {
            console.error(`Failed to load environment ${name}:`, error);
            throw error;
        }
    }

    async loadAssetGroup(groupName, assets) {
        const loadPromises = assets.map(asset => {
            switch (asset.type) {
                case 'model':
                    return this.loadModel(asset.name, asset.url, asset.options);
                case 'texture':
                    return this.loadTexture(asset.name, asset.url, asset.options);
                case 'environment':
                    return this.loadEnvironment(asset.name, asset.url, asset.options);
                default:
                    return Promise.reject(new Error(`Unknown asset type: ${asset.type}`));
            }
        });

        try {
            const results = await Promise.all(loadPromises);
            this.assetGroups.set(groupName, results);
            return results;
        } catch (error) {
            console.error(`Failed to load asset group ${groupName}:`, error);
            throw error;
        }
    }

    createAssetInstance(assetName, instanceName, options = {}) {
        const asset = this.loadedAssets.get(assetName);
        if (!asset || !asset.meshes) {
            console.error(`Asset ${assetName} not found or has no meshes`);
            return null;
        }

        const rootMesh = asset.meshes.find(mesh => !mesh.parent);
        if (!rootMesh) {
            console.error(`No root mesh found in asset ${assetName}`);
            return null;
        }

        // Create instance
        const instance = rootMesh.createInstance(instanceName);

        // Apply transform options
        if (options.position) instance.position = options.position.clone();
        if (options.rotation) instance.rotation = options.rotation.clone();
        if (options.scaling) instance.scaling = options.scaling.clone();

        // Clone children if needed
        if (options.cloneChildren) {
            asset.meshes.forEach(mesh => {
                if (mesh.parent === rootMesh) {
                    const childInstance = mesh.createInstance(instanceName + "_" + mesh.name);
                    childInstance.parent = instance;
                }
            });
        }

        return instance;
    }

    async postProcessAsset(asset, options) {
        // Optimize meshes
        if (options.mergeMeshes) {
            const merged = BABYLON.Mesh.MergeMeshes(asset.meshes.filter(mesh => mesh.geometry));
            if (merged) {
                asset.mergedMesh = merged;
            }
        }

        // Setup LOD
        if (options.lod) {
            this.setupLOD(asset, options.lod);
        }

        // Optimize materials
        if (options.optimizeMaterials) {
            this.optimizeMaterials(asset);
        }

        // Setup physics
        if (options.physics) {
            this.setupPhysics(asset, options.physics);
        }
    }

    setupLOD(asset, lodOptions) {
        const mainMesh = asset.meshes[0];
        if (!mainMesh) return;

        lodOptions.levels.forEach(level => {
            if (level.mesh) {
                mainMesh.addLODLevel(level.distance, level.mesh);
            } else if (level.quality) {
                // Create simplified version
                const simplified = mainMesh.clone(mainMesh.name + "_LOD" + level.distance);
                // Apply simplification (would need additional library)
                mainMesh.addLODLevel(level.distance, simplified);
            }
        });
    }

    optimizeMaterials(asset) {
        const materials = new Map();

        asset.meshes.forEach(mesh => {
            if (mesh.material) {
                const matId = this.getMaterialId(mesh.material);
                if (materials.has(matId)) {
                    mesh.material = materials.get(matId);
                } else {
                    materials.set(matId, mesh.material);
                }
            }
        });
    }

    getMaterialId(material) {
        // Create unique ID based on material properties
        const props = [
            material.diffuseColor?.toString(),
            material.specularColor?.toString(),
            material.diffuseTexture?.url,
            material.normalTexture?.url
        ].filter(Boolean);

        return props.join('|');
    }

    setupPhysics(asset, physicsOptions) {
        asset.meshes.forEach(mesh => {
            if (mesh.name.includes('collision') || physicsOptions.autoDetect) {
                const impostor = new BABYLON.PhysicsImpostor(
                    mesh,
                    physicsOptions.shape || BABYLON.PhysicsImpostor.BoxImpostor,
                    physicsOptions
                );

                mesh.physicsImpostor = impostor;
            }
        });
    }

    getAsset(name) {
        return this.loadedAssets.get(name);
    }

    getAssetGroup(groupName) {
        return this.assetGroups.get(groupName);
    }

    setProgressCallback(assetName, callback) {
        this.progressCallbacks.set(assetName, callback);
    }

    unloadAsset(name) {
        const asset = this.loadedAssets.get(name);
        if (asset) {
            if (asset.meshes) {
                asset.meshes.forEach(mesh => mesh.dispose());
            }
            if (asset.dispose) {
                asset.dispose();
            }
            this.loadedAssets.delete(name);
        }
    }

    dispose() {
        this.loadedAssets.forEach((asset, name) => {
            this.unloadAsset(name);
        });
        this.loadedAssets.clear();
        this.assetGroups.clear();
        this.progressCallbacks.clear();
    }
}
```

## Performance Optimization

### Performance Monitor and Optimizer
```javascript
class PerformanceOptimizer {
    constructor(scene, engine) {
        this.scene = scene;
        this.engine = engine;
        this.stats = {
            fps: 0,
            frameTime: 0,
            drawCalls: 0,
            triangles: 0,
            meshes: 0,
            materials: 0,
            textures: 0
        };

        this.thresholds = {
            targetFPS: 60,
            maxDrawCalls: 100,
            maxTriangles: 100000,
            maxMeshes: 1000
        };

        this.optimizations = {
            frustumCulling: true,
            occlusionCulling: false,
            lodEnabled: true,
            instancedRendering: true,
            batchedMeshes: true
        };

        this.init();
    }

    init() {
        // Setup performance monitoring
        this.setupPerformanceMonitoring();

        // Apply initial optimizations
        this.applyOptimizations();

        // Start monitoring loop
        this.startMonitoring();
    }

    setupPerformanceMonitoring() {
        this.scene.registerBeforeRender(() => {
            this.updateStats();
        });

        // FPS monitoring
        this.fpsMonitor = new BABYLON.EngineInstrumentation(this.engine);
        this.fpsMonitor.captureFrameTime = true;
        this.fpsMonitor.captureGPUFrameTime = true;

        // Scene monitoring
        this.sceneMonitor = new BABYLON.SceneInstrumentation(this.scene);
        this.sceneMonitor.captureActiveMeshesEvaluationTime = true;
        this.sceneMonitor.captureRenderTargetsRenderTime = true;
        this.sceneMonitor.captureParticlesRenderTime = true;
        this.sceneMonitor.captureSpritesRenderTime = true;
        this.sceneMonitor.capturePhysicsTime = true;
        this.sceneMonitor.captureAnimationsTime = true;
        this.sceneMonitor.captureFrameTime = true;
        this.sceneMonitor.captureRenderTime = true;
        this.sceneMonitor.captureInterFrameTime = true;
    }

    updateStats() {
        this.stats.fps = this.engine.getFps();
        this.stats.frameTime = this.fpsMonitor.frameTimeCounter.lastSecAverage;
        this.stats.drawCalls = this.engine.getGlInfo().drawCalls;

        // Count scene elements
        this.stats.meshes = this.scene.meshes.length;
        this.stats.materials = this.scene.materials.length;
        this.stats.textures = this.scene.textures.length;

        // Count triangles
        this.stats.triangles = this.scene.meshes.reduce((total, mesh) => {
            if (mesh.getTotalIndices) {
                return total + (mesh.getTotalIndices() / 3);
            }
            return total;
        }, 0);
    }

    applyOptimizations() {
        // Enable frustum culling
        if (this.optimizations.frustumCulling) {
            this.scene.frustumCullingEnabled = true;
        }

        // Enable occlusion culling if supported
        if (this.optimizations.occlusionCulling && this.engine.getCaps().colorBufferFloat) {
            this.scene.occlusionEnabled = true;
        }

        // Optimize render pipeline
        this.optimizeRenderPipeline();

        // Setup mesh optimization
        this.optimizeMeshes();

        // Setup material optimization
        this.optimizeMaterials();

        // Setup texture optimization
        this.optimizeTextures();
    }

    optimizeRenderPipeline() {
        // Reduce shadow map size for better performance
        this.scene.lights.forEach(light => {
            if (light.getShadowGenerator) {
                const shadowGen = light.getShadowGenerator();
                if (shadowGen) {
                    shadowGen.mapSize = Math.min(shadowGen.mapSize, 1024);
                    shadowGen.useBlurExponentialShadowMap = true;
                    shadowGen.blurKernel = 16; // Reduce blur quality for performance
                }
            }
        });

        // Optimize post-processing
        if (this.scene.postProcessesEnabled) {
            this.scene.postProcessManager.autoClear = false;
        }

        // Enable hardware scaling for lower-end devices
        if (this.stats.fps < 30) {
            this.engine.setHardwareScalingLevel(1.5);
        }
    }

    optimizeMeshes() {
        const meshesToOptimize = this.scene.meshes.filter(mesh =>
            mesh.isEnabled() && mesh.isVisible && mesh.getTotalIndices() > 1000
        );

        meshesToOptimize.forEach(mesh => {
            // Freeze world matrix for static meshes
            if (!mesh.animations || mesh.animations.length === 0) {
                mesh.freezeWorldMatrix();
            }

            // Enable mesh merging for similar meshes
            if (this.optimizations.batchedMeshes) {
                this.attemptMeshMerging(mesh);
            }

            // Setup LOD if not already present
            if (this.optimizations.lodEnabled && mesh.getLODLevels().length === 0) {
                this.setupAutoLOD(mesh);
            }

            // Enable instancing for repeated meshes
            if (this.optimizations.instancedRendering) {
                this.setupInstancing(mesh);
            }
        });
    }

    attemptMeshMerging(mesh) {
        const similarMeshes = this.scene.meshes.filter(otherMesh =>
            otherMesh !== mesh &&
            otherMesh.material === mesh.material &&
            !otherMesh.skeleton &&
            !otherMesh.animations?.length
        );

        if (similarMeshes.length > 2) {
            const merged = BABYLON.Mesh.MergeMeshes([mesh, ...similarMeshes.slice(0, 10)]);
            if (merged) {
                console.log(`Merged ${similarMeshes.length + 1} meshes into one`);
            }
        }
    }

    setupAutoLOD(mesh) {
        if (mesh.getTotalIndices() > 5000) {
            // Create simplified versions
            const lod1 = mesh.clone(mesh.name + "_LOD1");
            const lod2 = mesh.clone(mesh.name + "_LOD2");

            // Simplify geometry (pseudo-code - would need real simplification)
            this.simplifyMesh(lod1, 0.7);
            this.simplifyMesh(lod2, 0.4);

            mesh.addLODLevel(50, lod1);
            mesh.addLODLevel(100, lod2);
            mesh.addLODLevel(200, null); // No rendering at distance
        }
    }

    simplifyMesh(mesh, factor) {
        // Placeholder for mesh simplification
        // In a real implementation, you'd use a library like simplify-js
        const indices = mesh.getIndices();
        const simplified = Math.floor(indices.length * factor);

        // This is a naive approach - real simplification is more complex
        mesh.setIndices(indices.slice(0, simplified));
    }

    setupInstancing(mesh) {
        const duplicates = this.scene.meshes.filter(otherMesh =>
            otherMesh !== mesh &&
            otherMesh.geometry === mesh.geometry &&
            otherMesh.material === mesh.material
        );

        if (duplicates.length > 5) {
            // Convert to instanced rendering
            const matrices = duplicates.map(duplicate => duplicate.getWorldMatrix());
            const thinInstances = new BABYLON.ThinInstancesManager(mesh);

            matrices.forEach((matrix, index) => {
                thinInstances.setMatrixAt(index, matrix);
            });

            // Remove original duplicates
            duplicates.forEach(duplicate => duplicate.dispose());

            console.log(`Created instanced rendering for ${duplicates.length} meshes`);
        }
    }

    optimizeMaterials() {
        const materialCache = new Map();

        this.scene.meshes.forEach(mesh => {
            if (mesh.material) {
                const matKey = this.getMaterialKey(mesh.material);

                if (materialCache.has(matKey)) {
                    mesh.material = materialCache.get(matKey);
                } else {
                    materialCache.set(matKey, mesh.material);

                    // Optimize individual material
                    this.optimizeMaterial(mesh.material);
                }
            }
        });
    }

    getMaterialKey(material) {
        // Create key based on material properties
        const key = [
            material.constructor.name,
            material.diffuseColor?.toString(),
            material.diffuseTexture?.url,
            material.normalTexture?.url
        ].filter(Boolean).join('|');

        return key;
    }

    optimizeMaterial(material) {
        // Disable unnecessary features
        if (material.needAlphaBlending?.() === false) {
            material.alphaMode = BABYLON.Constants.ALPHA_DISABLE;
        }

        // Reduce reflection quality for performance
        if (material.reflectionTexture) {
            material.reflectionTexture.renderList = material.reflectionTexture.renderList?.slice(0, 20);
        }

        // Freeze material to prevent unnecessary updates
        material.freeze();
    }

    optimizeTextures() {
        this.scene.textures.forEach(texture => {
            // Reduce texture size for distant objects
            if (texture.getSize && texture.getSize().width > 1024) {
                // Check if texture is used by distant meshes only
                const meshesUsingTexture = this.scene.meshes.filter(mesh =>
                    mesh.material && this.materialUsesTexture(mesh.material, texture)
                );

                const averageDistance = this.getAverageDistanceToCamera(meshesUsingTexture);

                if (averageDistance > 100) {
                    texture.updateSize(512, 512);
                }
            }

            // Enable texture streaming if available
            if (texture.streamLevels) {
                texture.streamLevels = Math.min(texture.streamLevels, 3);
            }
        });
    }

    materialUsesTexture(material, texture) {
        return Object.values(material).some(prop => prop === texture);
    }

    getAverageDistanceToCamera(meshes) {
        if (!meshes.length || !this.scene.activeCamera) return 0;

        const cameraPosition = this.scene.activeCamera.position;
        const totalDistance = meshes.reduce((sum, mesh) => {
            return sum + BABYLON.Vector3.Distance(mesh.position, cameraPosition);
        }, 0);

        return totalDistance / meshes.length;
    }

    startMonitoring() {
        setInterval(() => {
            this.analyzePerformance();
        }, 5000); // Check every 5 seconds
    }

    analyzePerformance() {
        const issues = [];

        if (this.stats.fps < this.thresholds.targetFPS * 0.8) {
            issues.push(`Low FPS: ${this.stats.fps.toFixed(1)}`);
            this.applyEmergencyOptimizations();
        }

        if (this.stats.drawCalls > this.thresholds.maxDrawCalls) {
            issues.push(`High draw calls: ${this.stats.drawCalls}`);
        }

        if (this.stats.triangles > this.thresholds.maxTriangles) {
            issues.push(`High triangle count: ${this.stats.triangles}`);
        }

        if (this.stats.meshes > this.thresholds.maxMeshes) {
            issues.push(`Too many meshes: ${this.stats.meshes}`);
        }

        if (issues.length > 0) {
            console.warn('Performance issues detected:', issues);
            this.reportPerformanceIssues(issues);
        }
    }

    applyEmergencyOptimizations() {
        // Reduce hardware scaling
        this.engine.setHardwareScalingLevel(2.0);

        // Disable expensive features temporarily
        this.scene.particlesEnabled = false;
        this.scene.spritesEnabled = false;
        this.scene.skeletonAnimationEnabled = false;

        // Reduce shadow quality
        this.scene.lights.forEach(light => {
            const shadowGen = light.getShadowGenerator?.();
            if (shadowGen) {
                shadowGen.mapSize = 256;
            }
        });

        console.warn('Emergency optimizations applied due to low performance');
    }

    reportPerformanceIssues(issues) {
        // Could send to analytics or display to user
        console.group('Performance Report');
        console.table(this.stats);
        console.log('Issues:', issues);
        console.groupEnd();
    }

    getPerformanceReport() {
        return {
            stats: { ...this.stats },
            frameTime: this.fpsMonitor.frameTimeCounter.lastSecAverage,
            gpuFrameTime: this.fpsMonitor.gpuFrameTimeCounter.lastSecAverage,
            sceneStats: {
                activeMeshesEvaluation: this.sceneMonitor.activeMeshesEvaluationTimeCounter.lastSecAverage,
                renderTargets: this.sceneMonitor.renderTargetsRenderTimeCounter.lastSecAverage,
                particles: this.sceneMonitor.particlesRenderTimeCounter.lastSecAverage,
                physics: this.sceneMonitor.physicsTimeCounter.lastSecAverage,
                animations: this.sceneMonitor.animationsTimeCounter.lastSecAverage
            }
        };
    }

    dispose() {
        if (this.fpsMonitor) {
            this.fpsMonitor.dispose();
        }

        if (this.sceneMonitor) {
            this.sceneMonitor.dispose();
        }
    }
}
```

## Troubleshooting Guide

### Common Issues and Solutions

#### WebGL Context Loss
```javascript
class ContextLossHandler {
    constructor(engine, canvas) {
        this.engine = engine;
        this.canvas = canvas;
        this.isContextLost = false;

        this.setupContextLossHandling();
    }

    setupContextLossHandling() {
        this.canvas.addEventListener('webglcontextlost', (event) => {
            event.preventDefault();
            this.isContextLost = true;
            console.warn('WebGL context lost');
            this.handleContextLoss();
        });

        this.canvas.addEventListener('webglcontextrestored', () => {
            console.log('WebGL context restored');
            this.handleContextRestore();
        });
    }

    handleContextLoss() {
        // Stop render loop
        this.engine.stopRenderLoop();

        // Notify user
        this.showContextLossMessage();

        // Attempt to recover after delay
        setTimeout(() => {
            this.attemptRecovery();
        }, 1000);
    }

    handleContextRestore() {
        this.isContextLost = false;

        // Recreate engine
        this.engine = new BABYLON.Engine(this.canvas, true);

        // Reload scene
        this.reloadScene();

        // Hide message
        this.hideContextLossMessage();
    }

    showContextLossMessage() {
        const message = document.createElement('div');
        message.id = 'context-loss-message';
        message.innerHTML = `
            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
                        background: rgba(0,0,0,0.8); color: white; padding: 20px; border-radius: 10px;
                        text-align: center; z-index: 1000;">
                <h3>Graphics Context Lost</h3>
                <p>Attempting to recover...</p>
                <button onclick="location.reload()">Reload Page</button>
            </div>
        `;
        document.body.appendChild(message);
    }

    hideContextLossMessage() {
        const message = document.getElementById('context-loss-message');
        if (message) {
            message.remove();
        }
    }

    attemptRecovery() {
        try {
            // Force context restore
            const gl = this.canvas.getContext('webgl2') || this.canvas.getContext('webgl');
            if (gl) {
                gl.getExtension('WEBGL_lose_context')?.restoreContext();
            }
        } catch (error) {
            console.error('Failed to restore context:', error);
            this.showRecoveryFailedMessage();
        }
    }

    showRecoveryFailedMessage() {
        const message = document.getElementById('context-loss-message');
        if (message) {
            message.innerHTML = `
                <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
                            background: rgba(0,0,0,0.8); color: white; padding: 20px; border-radius: 10px;
                            text-align: center; z-index: 1000;">
                    <h3>Recovery Failed</h3>
                    <p>Please reload the page to continue.</p>
                    <button onclick="location.reload()">Reload Page</button>
                </div>
            `;
        }
    }
}
```

#### Memory Management
```javascript
class MemoryManager {
    constructor(scene, engine) {
        this.scene = scene;
        this.engine = engine;
        this.memoryThreshold = 100 * 1024 * 1024; // 100MB
        this.disposedObjects = new Set();

        this.startMemoryMonitoring();
    }

    startMemoryMonitoring() {
        setInterval(() => {
            this.checkMemoryUsage();
        }, 10000); // Check every 10 seconds
    }

    checkMemoryUsage() {
        if (performance.memory) {
            const usedMemory = performance.memory.usedJSHeapSize;
            const totalMemory = performance.memory.totalJSHeapSize;
            const memoryLimit = performance.memory.jsHeapSizeLimit;

            const usagePercent = (usedMemory / memoryLimit) * 100;

            if (usagePercent > 80) {
                console.warn(`High memory usage: ${usagePercent.toFixed(1)}%`);
                this.performGarbageCollection();
            }

            if (usedMemory > this.memoryThreshold) {
                this.attemptMemoryCleanup();
            }
        }
    }

    performGarbageCollection() {
        // Dispose unused textures
        this.scene.textures.forEach(texture => {
            if (texture.isReady() && !this.isTextureInUse(texture)) {
                console.log('Disposing unused texture:', texture.url);
                texture.dispose();
            }
        });

        // Dispose unused materials
        this.scene.materials.forEach(material => {
            if (!this.isMaterialInUse(material)) {
                console.log('Disposing unused material:', material.name);
                material.dispose();
            }
        });

        // Dispose unused meshes
        this.scene.meshes.forEach(mesh => {
            if (!mesh.isEnabled() && !mesh.isVisible) {
                console.log('Disposing disabled mesh:', mesh.name);
                mesh.dispose();
            }
        });

        // Force JavaScript garbage collection if available
        if (window.gc) {
            window.gc();
        }
    }

    isTextureInUse(texture) {
        return this.scene.materials.some(material => {
            return Object.values(material).some(prop => prop === texture);
        });
    }

    isMaterialInUse(material) {
        return this.scene.meshes.some(mesh => mesh.material === material);
    }

    attemptMemoryCleanup() {
        // Reduce texture quality
        this.scene.textures.forEach(texture => {
            if (texture.getSize && texture.getSize().width > 512) {
                texture.updateSize(512, 512);
            }
        });

        // Reduce particle count
        this.scene.particleSystems.forEach(system => {
            system.capacity = Math.floor(system.capacity * 0.7);
        });

        // Disable expensive features temporarily
        this.scene.shadowsEnabled = false;
        this.scene.particlesEnabled = false;

        console.warn('Memory cleanup performed - some features temporarily disabled');
    }

    trackDisposedObject(object) {
        this.disposedObjects.add(object);
    }

    isDisposed(object) {
        return this.disposedObjects.has(object);
    }

    safeDispose(object) {
        if (object && !this.isDisposed(object) && typeof object.dispose === 'function') {
            object.dispose();
            this.trackDisposedObject(object);
        }
    }
}
```

#### Mobile Device Optimization
```javascript
class MobileOptimizer {
    constructor(scene, engine) {
        this.scene = scene;
        this.engine = engine;
        this.isMobile = this.detectMobile();
        this.isLowEndDevice = this.detectLowEndDevice();

        if (this.isMobile) {
            this.applyMobileOptimizations();
        }
    }

    detectMobile() {
        return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    }

    detectLowEndDevice() {
        // Heuristics for low-end device detection
        const canvas = document.createElement('canvas');
        const gl = canvas.getContext('webgl');

        if (!gl) return true;

        const renderer = gl.getParameter(gl.RENDERER);
        const vendor = gl.getParameter(gl.VENDOR);

        // Check for known low-end GPUs
        const lowEndGPUs = [
            'Adreno 3', 'Adreno 4', 'Adreno 5',
            'Mali-4', 'Mali-T6', 'Mali-T7',
            'PowerVR SGX', 'Vivante'
        ];

        const isLowEndGPU = lowEndGPUs.some(gpu =>
            renderer.toLowerCase().includes(gpu.toLowerCase())
        );

        // Check memory constraints
        const isLowMemory = navigator.deviceMemory && navigator.deviceMemory < 4;

        // Check CPU cores
        const isLowCPU = navigator.hardwareConcurrency && navigator.hardwareConcurrency < 4;

        return isLowEndGPU || isLowMemory || isLowCPU;
    }

    applyMobileOptimizations() {
        // Reduce hardware scaling for mobile
        this.engine.setHardwareScalingLevel(1.5);

        // Disable expensive features
        this.scene.shadowsEnabled = false;
        this.scene.particlesEnabled = false;
        this.scene.spritesEnabled = false;
        this.scene.lensFlaresEnabled = false;
        this.scene.postProcessesEnabled = false;

        // Reduce texture quality
        this.scene.textures.forEach(texture => {
            if (texture.getSize && texture.getSize().width > 512) {
                texture.updateSize(256, 256);
            }
        });

        // Simplify materials
        this.scene.materials.forEach(material => {
            if (material instanceof BABYLON.PBRMaterial) {
                // Convert PBR to Standard material for better performance
                const standardMat = new BABYLON.StandardMaterial(material.name + '_mobile', this.scene);
                standardMat.diffuseTexture = material.baseTexture;
                standardMat.diffuseColor = material.baseColor;

                // Replace PBR material
                this.scene.meshes.forEach(mesh => {
                    if (mesh.material === material) {
                        mesh.material = standardMat;
                    }
                });

                material.dispose();
            }
        });

        // Reduce geometry detail
        this.scene.meshes.forEach(mesh => {
            if (mesh.getTotalIndices && mesh.getTotalIndices() > 5000) {
                this.simplifyMeshForMobile(mesh);
            }
        });

        // Optimize render pipeline
        this.optimizeRenderPipelineForMobile();

        console.log('Mobile optimizations applied');
    }

    simplifyMeshForMobile(mesh) {
        // Reduce subdivision levels
        if (mesh.subdivisions) {
            mesh.subdivisions = Math.max(1, mesh.subdivisions - 2);
        }

        // Remove unnecessary detail
        const indices = mesh.getIndices();
        if (indices && indices.length > 3000) {
            // Simple decimation - remove every nth triangle
            const decimationFactor = 0.6;
            const newIndices = [];

            for (let i = 0; i < indices.length; i += 3) {
                if (Math.random() < decimationFactor) {
                    newIndices.push(indices[i], indices[i + 1], indices[i + 2]);
                }
            }

            mesh.setIndices(newIndices);
        }
    }

    optimizeRenderPipelineForMobile() {
        // Reduce frustum culling precision for performance
        this.scene.frustumCullingEnabled = true;

        // Disable occlusion culling on mobile
        this.scene.occlusionCullingEnabled = false;

        // Reduce picking precision
        this.scene.pointerDownPredicate = (mesh) => {
            return mesh.isPickable && mesh.isVisible && mesh.isEnabled();
        };

        // Optimize animation systems
        this.scene.animationPropertiesOverride = new BABYLON.AnimationPropertiesOverride();
        this.scene.animationPropertiesOverride.enableBlending = false;
        this.scene.animationPropertiesOverride.blendingSpeed = 0.02;

        // Reduce precision for mobile
        this.engine.setDepthBuffer(false);
        this.engine.setStencilBuffer(false);
    }

    handleDeviceOrientation() {
        if (this.isMobile) {
            window.addEventListener('orientationchange', () => {
                setTimeout(() => {
                    this.engine.resize();
                }, 500);
            });
        }
    }

    setupTouchControls() {
        if (this.isMobile && this.scene.activeCamera) {
            // Enable touch camera controls
            this.scene.activeCamera.attachControl(this.engine.getRenderingCanvas(), true);

            // Customize touch sensitivity
            if (this.scene.activeCamera.angularSensibility) {
                this.scene.activeCamera.angularSensibility = 8000; // Less sensitive
            }

            // Add pinch-to-zoom for arc cameras
            if (this.scene.activeCamera instanceof BABYLON.ArcRotateCamera) {
                this.scene.activeCamera.pinchPrecision = 50;
                this.scene.activeCamera.panningSensibility = 1000;
            }
        }
    }
}
```

## Limitations and Considerations

### WebGL Requirements and Browser Support
- **WebGL 1.0**: Minimum requirement for basic functionality
- **WebGL 2.0**: Required for advanced features (compute shaders, transform feedback)
- **WebGPU**: Experimental support in latest browsers for next-generation graphics

### Mobile Device Limitations
- **GPU Power**: Limited compared to desktop GPUs, requires optimization
- **Memory Constraints**: Typically 2-8GB RAM shared between system and graphics
- **Battery Life**: 3D rendering is power-intensive, affects device battery
- **Heat Management**: Sustained 3D rendering can cause device throttling
- **Touch Controls**: Different interaction paradigms compared to mouse/keyboard

### Performance Considerations
- **File Size**: Core library is 2MB+, additional modules increase size
- **Loading Time**: Complex 3D assets can take significant time to load
- **Memory Usage**: 3D scenes consume substantial memory, especially textures
- **CPU/GPU Balance**: Requires careful optimization of both CPU and GPU workloads

### Development Complexity
- **Learning Curve**: Steep for developers new to 3D graphics concepts
- **Debugging**: 3D debugging is more complex than traditional web development
- **Cross-Platform**: Different devices have varying capabilities and limitations
- **Asset Creation**: Requires 3D modeling skills or external artists

## Strengths and Advantages

### Comprehensive 3D Engine
- **Complete Solution**: Everything needed for 3D development in one package
- **PBR Rendering**: Physically Based Rendering for realistic materials and lighting
- **Advanced Features**: Physics, animations, particles, post-processing, audio
- **WebXR Support**: Built-in VR/AR capabilities for immersive experiences

### Developer Experience
- **Excellent Documentation**: Comprehensive docs, tutorials, and examples at https://doc.babylonjs.com/
- **Active Community**: Large community forum at https://forum.babylonjs.com/
- **Interactive Playground**: Live code editor at https://playground.babylonjs.com/
- **TypeScript Support**: Full TypeScript definitions for better development experience
- **Visual Tools**: Scene inspector, node material editor, sandbox viewer

### Performance and Compatibility
- **WebGPU Ready**: Future-proofed with WebGPU support
- **Cross-Platform**: Runs on all modern browsers and devices
- **Optimized**: Built-in performance monitoring and optimization tools
- **Scalable**: From simple visualizations to complex games and simulations

### Enterprise Ready
- **Microsoft Backing**: Developed and maintained by Microsoft
- **Apache License**: Free for commercial use without restrictions
- **Long-term Support**: LTS versions available for enterprise deployments
- **Professional Support**: Available through Microsoft partnerships

## Best Use Cases

### Game Development
- **3D Web Games**: Full-featured games with physics, animations, and audio
- **Multiplayer Games**: Network-enabled games with real-time synchronization
- **Educational Games**: Interactive learning experiences with 3D environments
- **Simulation Games**: Complex simulations with realistic physics

### Enterprise Applications
- **Product Configurators**: Interactive 3D product customization tools
- **Training Simulations**: Realistic training environments for various industries
- **Data Visualization**: 3D representations of complex datasets
- **Digital Twins**: Real-time 3D representations of physical systems

### Creative Industries
- **Architectural Visualization**: Interactive building and space exploration
- **Art Installations**: Interactive 3D art experiences for web browsers
- **Virtual Museums**: Online exhibitions with 3D artifacts and environments
- **Fashion Visualization**: Virtual try-on and fashion show experiences

### Scientific and Medical
- **Molecular Visualization**: 3D representation of molecular structures
- **Medical Imaging**: Interactive 3D medical scan visualization
- **Astronomy**: Interactive space exploration and celestial object visualization
- **Engineering**: 3D CAD viewers and collaborative design tools

## Best Practices and Production Considerations

### Asset Optimization
- **Texture Compression**: Use compressed texture formats (DXT, ASTC, ETC)
- **Model Optimization**: Reduce polygon count, optimize UV mapping
- **LOD Implementation**: Multiple detail levels for distance-based rendering
- **Texture Atlasing**: Combine multiple textures to reduce draw calls

### Code Organization
- **Modular Architecture**: Separate concerns into distinct modules
- **Asset Management**: Centralized asset loading and caching system
- **Performance Monitoring**: Real-time performance tracking and optimization
- **Error Handling**: Robust error handling for all asset loading and rendering

### Deployment Strategies
- **CDN Usage**: Serve large assets from content delivery networks
- **Progressive Loading**: Load essential content first, stream additional assets
- **Caching Strategy**: Implement effective browser and server-side caching
- **Fallback Options**: Provide alternatives for unsupported devices

### Security Considerations
- **Asset Validation**: Validate all loaded assets to prevent malicious content
- **CORS Configuration**: Proper cross-origin resource sharing setup
- **Content Security Policy**: Implement CSP headers for additional security
- **User Data Protection**: Secure handling of user-generated content

This comprehensive NPL-FIM metadata provides a complete reference for 3D development with Babylon.js, covering everything from basic setup to advanced optimization techniques and production deployment strategies.