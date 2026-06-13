# A-Frame - Web-based VR/AR framework using HTML-like declarative syntax | [Official Docs](https://aframe.io/docs/) | [GitHub](https://github.com/aframevr/aframe) | [Community](https://aframe.io/community/)

A-Frame is an open-source web framework for building virtual reality and augmented reality experiences that work across desktop, mobile, and VR headsets using standard web technologies.

## License and Pricing
- **License**: MIT License (free and open source)
- **Cost**: Completely free for all use cases
- **Commercial Use**: Permitted without restrictions
- **Support**: Community-driven with enterprise consulting available

## Environment Requirements

### Browser Support
- **Desktop**: Chrome 79+, Firefox 70+, Safari 12+, Edge 79+
- **Mobile**: Chrome Mobile 79+, Safari iOS 12+, Samsung Internet 10+
- **VR Browsers**: Oculus Browser, Firefox Reality, Chrome (with WebXR flag)

### Hardware Requirements
- **Minimum**: Any device with WebGL support
- **VR Headsets**: Oculus Quest/Rift, HTC Vive, Windows Mixed Reality, Magic Leap, ARCore/ARKit devices
- **Performance**: GPU recommended for complex scenes, mobile GPU sufficient for basic experiences

### Development Environment
- **Server**: Local development server required (live-server, http-server, or webpack-dev-server)
- **Tools**: Any text editor, browser developer tools for debugging
- **Dependencies**: Node.js 12+ for npm installation (optional)

## Installation and Setup

### CDN (Recommended for beginners)
```html
<!-- Latest stable version -->
<script src="https://aframe.io/releases/1.5.0/aframe.min.js"></script>

<!-- With inspector for debugging -->
<script src="https://cdn.jsdelivr.net/gh/aframevr/aframe-inspector@master/dist/aframe-inspector.min.js"></script>
```

### NPM Installation
```bash
# Install A-Frame
npm install aframe

# Install with TypeScript definitions
npm install aframe @types/aframe

# Development dependencies
npm install --save-dev live-server webpack webpack-cli
```

### Package.json Setup
```json
{
  "scripts": {
    "start": "live-server --port=8080",
    "build": "webpack --mode=production",
    "dev": "webpack serve --mode=development"
  },
  "dependencies": {
    "aframe": "^1.5.0"
  }
}
```

## Core Concepts and Architecture

### Entity-Component-System (ECS)
A-Frame uses an ECS architecture where:
- **Entities**: Objects in the scene (`<a-entity>`)
- **Components**: Reusable modules that add functionality
- **Systems**: Global scope managers for components

```html
<!-- Entity with multiple components -->
<a-entity
  geometry="primitive: box; width: 1; height: 1; depth: 1"
  material="color: red; metalness: 0.5"
  position="0 1.6 -3"
  animation="property: rotation; to: 0 360 0; loop: true; dur: 2000">
</a-entity>
```

### Scene Graph Structure
```html
<a-scene>
  <!-- Assets for performance -->
  <a-assets>
    <img id="texture" src="texture.jpg">
    <a-asset-item id="model" src="model.gltf"></a-asset-item>
    <audio id="sound" src="sound.mp3"></audio>
  </a-assets>

  <!-- Environment and lighting -->
  <a-sky color="#ECECEC"></a-sky>
  <a-light type="ambient" color="#404040"></a-light>
  <a-light type="directional" position="0 1 0" color="#ffffff"></a-light>

  <!-- Scene content -->
  <a-entity id="scene-content">
    <!-- Your VR content here -->
  </a-entity>

  <!-- User interaction -->
  <a-entity camera look-controls wasd-controls position="0 1.6 0">
    <a-cursor color="raycast"></a-cursor>
  </a-entity>
</a-scene>
```

## Comprehensive Examples

### Basic VR Scene
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>A-Frame Basic Scene</title>
  <meta name="description" content="Basic A-Frame VR Scene">
  <script src="https://aframe.io/releases/1.5.0/aframe.min.js"></script>
</head>
<body>
  <a-scene background="color: #212121" vr-mode-ui="enabled: true">
    <!-- Assets -->
    <a-assets>
      <img id="grid" src="https://cdn.aframe.io/a-painter/images/floor.jpg">
      <img id="sky" src="https://cdn.aframe.io/360-image-gallery-boilerplate/img/sechelt.jpg">
    </a-assets>

    <!-- Environment -->
    <a-sky src="#sky"></a-sky>
    <a-plane src="#grid" rotation="-90 0 0" width="30" height="30"></a-plane>

    <!-- Interactive objects -->
    <a-box
      position="-1 0.5 -3"
      rotation="0 45 0"
      color="#4CC3D9"
      animation__mouseenter="property: scale; to: 1.2 1.2 1.2; startEvents: mouseenter; dur: 300"
      animation__mouseleave="property: scale; to: 1 1 1; startEvents: mouseleave; dur: 300">
    </a-box>

    <a-sphere
      position="0 1.25 -5"
      radius="1.25"
      color="#EF2D5E"
      animation="property: position; to: 0 2.5 -5; dir: alternate; dur: 2000; loop: true">
    </a-sphere>

    <!-- Camera with controls -->
    <a-entity
      camera
      look-controls
      wasd-controls
      position="0 1.6 0"
      cursor="rayOrigin: mouse">
      <a-cursor
        geometry="primitive: ring; radiusInner: 0.02; radiusOuter: 0.03"
        material="color: white; shader: flat">
      </a-cursor>
    </a-entity>
  </a-scene>
</body>
</html>
```

### AR Experience
```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://aframe.io/releases/1.5.0/aframe.min.js"></script>
  <script src="https://cdn.jsdelivr.net/gh/AR-js-org/AR.js@3.4.5/aframe/build/aframe-ar.min.js"></script>
</head>
<body style="margin: 0; overflow: hidden;">
  <a-scene
    embedded
    arjs="sourceType: webcam; debugUIEnabled: false; detectionMode: mono_and_matrix; matrixCodeType: 3x3;">

    <!-- AR Marker -->
    <a-marker preset="hiro">
      <a-entity
        geometry="primitive: box; width: 1; height: 1; depth: 1"
        material="color: red"
        animation="property: rotation; to: 0 360 0; loop: true; dur: 2000">
      </a-entity>
    </a-marker>

    <!-- AR Camera -->
    <a-entity camera></a-entity>
  </a-scene>
</body>
</html>
```

### 360° Media Viewer
```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://aframe.io/releases/1.5.0/aframe.min.js"></script>
</head>
<body>
  <a-scene>
    <a-assets>
      <video id="video" autoplay loop="true" src="360-video.mp4"></video>
      <!-- Fallback image for unsupported video -->
      <img id="fallback" src="360-image.jpg">
    </a-assets>

    <!-- 360 Video Sphere -->
    <a-videosphere src="#video" rotation="0 180 0"></a-videosphere>

    <!-- UI Controls -->
    <a-entity id="ui" position="0 1.6 -2">
      <a-text
        value="360° Video Player"
        position="0 2 0"
        align="center"
        color="white">
      </a-text>

      <a-plane
        color="#333"
        width="3"
        height="0.5"
        position="0 1.5 0">
        <a-text
          value="Click to Play/Pause"
          align="center"
          position="0 0 0.01"
          color="white">
        </a-text>
      </a-plane>
    </a-entity>

    <!-- Camera -->
    <a-entity camera look-controls></a-entity>
  </a-scene>

  <script>
    // Video controls
    document.querySelector('a-plane').addEventListener('click', function() {
      const video = document.querySelector('#video');
      if (video.paused) {
        video.play();
      } else {
        video.pause();
      }
    });
  </script>
</body>
</html>
```

## Component Ecosystem

### Built-in Components

#### Geometry Components
```html
<!-- Primitives -->
<a-box width="1" height="1" depth="1"></a-box>
<a-sphere radius="1"></a-sphere>
<a-cylinder radius="0.5" height="1"></a-cylinder>
<a-plane width="4" height="4"></a-plane>
<a-circle radius="1"></a-circle>
<a-ring radius-inner="0.5" radius-outer="1"></a-ring>
<a-cone radius-bottom="1" radius-top="0" height="2"></a-cone>
<a-dodecahedron radius="1"></a-dodecahedron>
<a-icosahedron radius="1"></a-icosahedron>
<a-octahedron radius="1"></a-octahedron>
<a-tetrahedron radius="1"></a-tetrahedron>
<a-torus radius="1" radius-tubular="0.1"></a-torus>
<a-torus-knot p="2" q="3" radius="1" radius-tubular="0.1"></a-torus-knot>
```

#### Material Components
```html
<!-- Standard materials -->
<a-entity material="color: red; metalness: 0.5; roughness: 0.2"></a-entity>
<a-entity material="shader: flat; color: blue"></a-entity>
<a-entity material="src: texture.jpg; repeat: 2 2"></a-entity>

<!-- Advanced materials -->
<a-entity material="shader: standard;
                   color: white;
                   metalness: 0.8;
                   roughness: 0.2;
                   normalMap: normal.jpg;
                   envMap: environment.hdr"></a-entity>
```

#### Animation Components
```html
<!-- Property animations -->
<a-entity animation="property: rotation;
                    to: 0 360 0;
                    loop: true;
                    dur: 2000;
                    easing: linear"></a-entity>

<!-- Multiple animations -->
<a-entity animation__rotation="property: rotation; to: 0 360 0; loop: true; dur: 2000"
          animation__position="property: position; to: 0 2 0; dir: alternate; dur: 1000"></a-entity>

<!-- Event-triggered animations -->
<a-entity animation__mouseenter="property: scale;
                                to: 1.5 1.5 1.5;
                                startEvents: mouseenter;
                                dur: 300"
          animation__mouseleave="property: scale;
                                to: 1 1 1;
                                startEvents: mouseleave;
                                dur: 300"></a-entity>
```

### Popular Community Components

#### Physics (aframe-physics-system)
```html
<script src="https://cdn.jsdelivr.net/gh/n5ro/aframe-physics-system@v4.0.1/dist/aframe-physics-system.min.js"></script>

<a-scene physics="driver: ammo; debug: true">
  <!-- Static ground -->
  <a-plane static-body width="10" height="10" rotation="-90 0 0"></a-plane>

  <!-- Dynamic falling box -->
  <a-box dynamic-body position="0 5 0" width="1" height="1" depth="1"></a-box>
</a-scene>
```

#### Environment (aframe-environment-component)
```html
<script src="https://cdn.jsdelivr.net/gh/supermedium/aframe-environment-component@master/dist/aframe-environment-component.min.js"></script>

<a-scene environment="preset: forest; groundColor: #445; grid: cross"></a-scene>
```

#### Teleportation (aframe-teleport-controls)
```html
<script src="https://cdn.jsdelivr.net/gh/fernandojsg/aframe-teleport-controls@master/dist/aframe-teleport-controls.min.js"></script>

<a-entity
  camera
  position="0 1.6 3"
  teleport-controls="cameraRig: #cameraRig; teleportOrigin: #camera; button: trigger">
</a-entity>
```

## Advanced JavaScript Integration

### Custom Components
```javascript
// Register custom component
AFRAME.registerComponent('hover-scale', {
  schema: {
    scale: {default: '1.2 1.2 1.2'},
    duration: {default: 300}
  },

  init: function() {
    const data = this.data;
    const el = this.el;

    // Store original scale
    this.originalScale = el.getAttribute('scale');

    // Add event listeners
    el.addEventListener('mouseenter', function() {
      el.setAttribute('animation__hoverscale', {
        property: 'scale',
        to: data.scale,
        dur: data.duration
      });
    });

    el.addEventListener('mouseleave', function() {
      el.setAttribute('animation__hoverscale', {
        property: 'scale',
        to: this.originalScale,
        dur: data.duration
      });
    }.bind(this));
  }
});

// Usage
// <a-box hover-scale="scale: 1.5 1.5 1.5; duration: 200"></a-box>
```

### System Integration
```javascript
// Register system for global management
AFRAME.registerSystem('score', {
  schema: {
    points: {default: 0}
  },

  init: function() {
    this.score = 0;
    this.display = document.querySelector('#score-display');
  },

  addPoints: function(points) {
    this.score += points;
    this.updateDisplay();
  },

  updateDisplay: function() {
    if (this.display) {
      this.display.setAttribute('text', 'value', `Score: ${this.score}`);
    }
  }
});

// Component that uses the system
AFRAME.registerComponent('collectible', {
  schema: {
    points: {default: 10}
  },

  init: function() {
    this.el.addEventListener('click', this.collect.bind(this));
  },

  collect: function() {
    this.el.sceneEl.systems.score.addPoints(this.data.points);
    this.el.remove();
  }
});
```

### Event Handling
```javascript
// Scene lifecycle events
document.querySelector('a-scene').addEventListener('loaded', function() {
  console.log('Scene loaded and ready');
});

// Component events
document.querySelector('a-box').addEventListener('componentchanged', function(evt) {
  if (evt.detail.name === 'position') {
    console.log('Position changed:', evt.detail.newData);
  }
});

// Custom events
const entity = document.querySelector('#player');
entity.emit('hit', {damage: 10}, false);

entity.addEventListener('hit', function(evt) {
  console.log('Player hit for:', evt.detail.damage);
});
```

### Asset Management
```javascript
// Preload assets
const assets = document.querySelector('a-assets');
const scene = document.querySelector('a-scene');

// Create asset items programmatically
function loadModel(id, src) {
  const assetItem = document.createElement('a-asset-item');
  assetItem.setAttribute('id', id);
  assetItem.setAttribute('src', src);
  assets.appendChild(assetItem);

  return new Promise((resolve) => {
    assetItem.addEventListener('loaded', resolve);
  });
}

// Load multiple assets
Promise.all([
  loadModel('character', 'models/character.gltf'),
  loadModel('environment', 'models/environment.gltf')
]).then(() => {
  console.log('All models loaded');
  // Create entities using loaded models
  createGameWorld();
});
```

## Performance Optimization

### Best Practices
```html
<!-- Use a-assets for caching -->
<a-assets>
  <img id="texture" src="texture.jpg">
  <a-asset-item id="model" src="model.gltf"></a-asset-item>
</a-assets>

<!-- Reference assets by ID -->
<a-box material="src: #texture"></a-box>
<a-entity gltf-model="#model"></a-entity>

<!-- Pool entities for dynamic content -->
<a-entity pool__bullets="mixin: bullet; size: 50"></a-entity>

<!-- Use instanced rendering for many similar objects -->
<a-entity instanced-mesh="count: 1000; mesh: #tree-mesh"></a-entity>
```

### Component Optimization
```javascript
AFRAME.registerComponent('optimized-movement', {
  schema: {
    speed: {default: 1}
  },

  init: function() {
    this.direction = new THREE.Vector3();
    this.position = new THREE.Vector3();
  },

  tick: function(time, timeDelta) {
    // Use object pooling for vectors
    const position = this.position;
    const direction = this.direction;

    // Batch DOM updates
    if (time % 100 < timeDelta) { // Update every 100ms
      this.el.object3D.getWorldPosition(position);
      this.el.setAttribute('position', position);
    }
  }
});
```

### Memory Management
```javascript
// Component cleanup
AFRAME.registerComponent('cleanup-example', {
  init: function() {
    this.handleClick = this.handleClick.bind(this);
    this.el.addEventListener('click', this.handleClick);
  },

  remove: function() {
    // Clean up event listeners
    this.el.removeEventListener('click', this.handleClick);

    // Dispose of Three.js resources
    if (this.mesh) {
      this.mesh.geometry.dispose();
      this.mesh.material.dispose();
    }
  },

  handleClick: function() {
    // Handle click
  }
});
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Scene Not Loading
```javascript
// Check console for errors
console.log('A-Frame version:', AFRAME.version);

// Verify scene initialization
document.querySelector('a-scene').addEventListener('loaded', function() {
  console.log('Scene loaded successfully');
});

// Check for missing dependencies
if (!AFRAME) {
  console.error('A-Frame not loaded. Check script tag.');
}
```

#### VR Mode Issues
```html
<!-- Ensure VR mode UI is enabled -->
<a-scene vr-mode-ui="enabled: true">

<!-- Check WebXR support -->
<script>
if (navigator.xr) {
  console.log('WebXR supported');
} else {
  console.warn('WebXR not supported');
}
</script>
```

#### Performance Problems
```javascript
// Monitor frame rate
AFRAME.registerSystem('performance-monitor', {
  init: function() {
    this.frameCount = 0;
    this.lastTime = performance.now();
  },

  tick: function() {
    this.frameCount++;
    const now = performance.now();

    if (now - this.lastTime >= 1000) {
      const fps = this.frameCount;
      console.log(`FPS: ${fps}`);

      if (fps < 30) {
        console.warn('Low framerate detected');
      }

      this.frameCount = 0;
      this.lastTime = now;
    }
  }
});
```

#### Asset Loading Failures
```html
<a-assets timeout="10000">
  <img id="texture" src="texture.jpg"
       onerror="console.error('Failed to load texture')">
  <a-asset-item id="model" src="model.gltf"
                onerror="console.error('Failed to load model')">
  </a-asset-item>
</a-assets>

<script>
// Monitor asset loading
document.querySelector('a-assets').addEventListener('loaded', function() {
  console.log('All assets loaded');
});

document.querySelector('a-assets').addEventListener('timeout', function() {
  console.error('Asset loading timed out');
});
</script>
```

### Debug Tools

#### A-Frame Inspector
```html
<!-- Enable inspector with Ctrl+Alt+I -->
<script src="https://cdn.jsdelivr.net/gh/aframevr/aframe-inspector@master/dist/aframe-inspector.min.js"></script>

<script>
// Programmatically open inspector
document.addEventListener('keydown', function(event) {
  if (event.ctrlKey && event.altKey && event.keyCode === 73) { // Ctrl+Alt+I
    document.querySelector('a-scene').components.inspector.openInspector();
  }
});
</script>
```

#### Custom Debug Components
```javascript
AFRAME.registerComponent('debug-info', {
  init: function() {
    this.info = document.createElement('div');
    this.info.style.position = 'fixed';
    this.info.style.top = '10px';
    this.info.style.left = '10px';
    this.info.style.color = 'white';
    this.info.style.fontFamily = 'monospace';
    this.info.style.zIndex = '9999';
    document.body.appendChild(this.info);
  },

  tick: function() {
    const pos = this.el.getAttribute('position');
    const rot = this.el.getAttribute('rotation');
    this.info.innerHTML = `
      Position: ${pos.x.toFixed(2)}, ${pos.y.toFixed(2)}, ${pos.z.toFixed(2)}<br>
      Rotation: ${rot.x.toFixed(2)}, ${rot.y.toFixed(2)}, ${rot.z.toFixed(2)}
    `;
  }
});
```

## Production Deployment

### Build Process
```json
{
  "scripts": {
    "build": "webpack --mode=production",
    "optimize": "npm run build && npm run minify",
    "minify": "terser dist/bundle.js -o dist/bundle.min.js",
    "deploy": "npm run build && rsync -av dist/ user@server:/var/www/vr-app/"
  }
}
```

### Webpack Configuration
```javascript
// webpack.config.js
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.(gltf|glb|obj|mtl)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: 'models/[name].[ext]'
            }
          }
        ]
      },
      {
        test: /\.(png|jpg|jpeg|gif|svg)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: 'images/[name].[ext]'
            }
          }
        ]
      }
    ]
  }
};
```

### Server Configuration
```nginx
# nginx.conf for A-Frame applications
server {
    listen 443 ssl http2;
    server_name your-vr-app.com;

    # SSL configuration required for WebXR
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    # Enable GZIP compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|gltf|glb)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers for WebXR
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header Referrer-Policy strict-origin-when-cross-origin;

    # Feature Policy for VR/AR features
    add_header Feature-Policy "xr-spatial-tracking 'self'; camera 'self'; microphone 'self'";

    location / {
        root /var/www/vr-app;
        try_files $uri $uri/ /index.html;
    }
}
```

## Best For

A-Frame is ideally suited for:

- **WebXR Applications**: Cross-platform VR/AR experiences that work across all major headsets and browsers
- **Educational VR Content**: Interactive learning experiences, virtual museums, and training simulations
- **360° Media Experiences**: Immersive photo and video viewers for marketing and entertainment
- **Rapid Prototyping**: Quick VR/AR concept validation with minimal setup time
- **Entry-level VR Development**: Teams new to VR development who want HTML-familiar syntax
- **Cross-platform Deployment**: Single codebase targeting desktop, mobile, and VR platforms
- **Community-driven Projects**: Leveraging extensive component ecosystem and active community
- **Marketing and Showcases**: Interactive product demonstrations and immersive brand experiences
- **Data Visualization**: 3D charts, graphs, and interactive data exploration tools
- **Social VR Experiences**: Multi-user virtual spaces and collaborative environments

## Limitations and Considerations

### Performance Limitations
- **Entity-Component Overhead**: ECS architecture adds performance cost compared to pure Three.js
- **Mobile Performance**: Complex scenes may struggle on lower-end mobile devices
- **Large Scene Optimization**: Requires careful optimization for scenes with thousands of entities
- **Physics Simulation**: CPU-intensive physics calculations can impact frame rate

### Development Constraints
- **Rendering Pipeline Control**: Limited low-level access compared to pure WebGL/Three.js
- **Custom Shader Integration**: More complex than traditional 3D engines
- **Advanced Graphics Features**: Some cutting-edge rendering techniques require custom components
- **Hot Reloading**: Limited development workflow optimization compared to modern frameworks

### Platform Limitations
- **WebXR Support**: Requires modern browsers with WebXR implementation
- **iOS Limitations**: Limited AR capabilities due to iOS WebXR restrictions
- **Desktop VR**: Some VR features require browser flags or specific browser versions
- **Legacy Browser Support**: Modern web features limit compatibility with older browsers

### Ecosystem Considerations
- **Component Quality**: Community components vary in quality and maintenance
- **Documentation Gaps**: Some advanced features lack comprehensive documentation
- **Breaking Changes**: Framework updates may break community components
- **Enterprise Support**: Limited official enterprise support options

## Community and Resources

### Official Resources
- **Main Website**: [aframe.io](https://aframe.io/)
- **Documentation**: [aframe.io/docs/](https://aframe.io/docs/)
- **GitHub Repository**: [github.com/aframevr/aframe](https://github.com/aframevr/aframe)
- **Examples**: [aframe.io/examples/](https://aframe.io/examples/)
- **Blog**: [aframe.io/blog/](https://aframe.io/blog/)

### Community Resources
- **Discord**: [discord.gg/dFJncWwHun](https://discord.gg/dFJncWwHun)
- **Stack Overflow**: [stackoverflow.com/questions/tagged/aframe](https://stackoverflow.com/questions/tagged/aframe)
- **Reddit**: [reddit.com/r/WebVR](https://reddit.com/r/WebVR)
- **Twitter**: [@aframevr](https://twitter.com/aframevr)

### Learning Resources
- **A-Frame School**: [aframe.io/aframe-school/](https://aframe.io/aframe-school/)
- **Component Library**: [github.com/supermedium/awesome-aframe](https://github.com/supermedium/awesome-aframe)
- **Tutorial Series**: Various YouTube channels and blog tutorials
- **Workshop Materials**: Conference talks and workshop repositories

### Enterprise and Professional Services
- **Supermedium**: Professional A-Frame development and consulting
- **Mozilla Mixed Reality**: Enterprise WebXR solutions
- **Community Experts**: Freelance developers specializing in A-Frame
- **Training Programs**: Corporate training for WebXR development teams