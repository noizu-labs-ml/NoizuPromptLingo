# WebGL NPL-FIM Solution

WebGL provides low-level GPU-accelerated graphics using OpenGL ES shaders directly in browsers.

## Installation

No installation needed - native browser API.

## Working Example

```javascript
// Get WebGL context
const canvas = document.getElementById('canvas');
const gl = canvas.getContext('webgl2');

// Vertex shader
const vsSource = `
  attribute vec4 aVertexPosition;
  uniform mat4 uModelViewMatrix;
  uniform mat4 uProjectionMatrix;

  void main() {
    gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
  }
`;

// Fragment shader
const fsSource = `
  precision mediump float;
  uniform vec4 uColor;

  void main() {
    gl_FragColor = uColor;
  }
`;

// Create shader program
function loadShader(gl, type, source) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  return shader;
}

const vertexShader = loadShader(gl, gl.VERTEX_SHADER, vsSource);
const fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fsSource);

const shaderProgram = gl.createProgram();
gl.attachShader(shaderProgram, vertexShader);
gl.attachShader(shaderProgram, fragmentShader);
gl.linkProgram(shaderProgram);

// Create geometry buffer
const vertices = new Float32Array([
  -1.0, -1.0, 0.0,
   1.0, -1.0, 0.0,
   0.0,  1.0, 0.0
]);

const vertexBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
```

## NPL-FIM Integration

```markdown
⟨npl:fim:webgl⟩
shaders: custom_glsl
buffers: [vertex, index, texture]
techniques: instanced_rendering
api: webgl2
⟨/npl:fim:webgl⟩
```

## Key Features
- Direct GPU control via shaders
- Compute shaders in WebGL 2
- Instanced rendering for particles
- Transform feedback
- Multiple render targets

## Best Practices
- Batch draw calls
- Use VAOs for state management
- Implement frustum culling
- Optimize shader precision