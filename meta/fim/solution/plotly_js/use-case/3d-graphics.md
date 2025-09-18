# Plotly.js 3D Graphics - Comprehensive NPL-FIM Implementation Guide

## Overview
Plotly.js delivers enterprise-grade 3D visualization with WebGL acceleration, interactive camera controls, and advanced lighting models. This guide provides complete implementation patterns for scientific visualization, engineering simulation displays, and interactive 3D data exploration with guaranteed artifact generation success.

## NPL-FIM Direct Unramp

### Quick Start Templates
```npl
@fim:plotly_js {
  chart_type: "3d_surface"
  data_source: "matrix"
  camera_preset: "isometric"
  lighting: "advanced"
  colorscale: "viridis"
  interactivity: "full"
}

@fim:plotly_js {
  chart_type: "3d_scatter"
  data_source: "point_cloud"
  marker_style: "sphere"
  size_mapping: "dynamic"
  color_mapping: "gradient"
}

@fim:plotly_js {
  chart_type: "3d_mesh"
  data_source: "triangulated"
  opacity: 0.7
  wireframe: true
  face_coloring: "vertex"
}
```

## Complete Working Examples

### 1. 3D Surface Plot - Terrain Visualization
```html
<!DOCTYPE html>
<html>
<head>
    <title>3D Terrain Surface</title>
    <script src="https://cdn.plot.ly/plotly-2.26.0.min.js"></script>
    <style>
        #terrain-plot { width: 100%; height: 600px; }
        .controls { margin: 20px 0; }
        .control-group { display: inline-block; margin-right: 20px; }
    </style>
</head>
<body>
    <div id="terrain-plot"></div>
    <div class="controls">
        <div class="control-group">
            <label>Colorscale:</label>
            <select id="colorscale-select">
                <option value="Viridis">Viridis</option>
                <option value="Plasma">Plasma</option>
                <option value="Hot">Hot</option>
                <option value="Earth">Earth</option>
                <option value="RdYlBu">RdYlBu</option>
            </select>
        </div>
        <div class="control-group">
            <label>Camera View:</label>
            <select id="camera-preset">
                <option value="isometric">Isometric</option>
                <option value="top">Top Down</option>
                <option value="side">Side View</option>
                <option value="perspective">Perspective</option>
            </select>
        </div>
        <button onclick="resetCamera()">Reset Camera</button>
        <button onclick="exportImage()">Export PNG</button>
    </div>

    <script>
// Generate realistic terrain data
function generateTerrainData(size = 50) {
    const z = [];
    const x = [];
    const y = [];

    for (let i = 0; i < size; i++) {
        const row = [];
        for (let j = 0; j < size; j++) {
            // Create realistic terrain using multiple sine waves
            const elevation =
                Math.sin(i * 0.2) * Math.cos(j * 0.15) * 20 +
                Math.sin(i * 0.1 + j * 0.1) * 15 +
                Math.sin(i * 0.05) * Math.cos(j * 0.08) * 10 +
                Math.random() * 5; // Add noise
            row.push(elevation);
        }
        z.push(row);
        x.push(i);
        y.push(i);
    }

    return { x, y, z };
}

// Camera presets for different viewing angles
const cameraPresets = {
    isometric: { x: 1.25, y: 1.25, z: 1.25 },
    top: { x: 0, y: 0, z: 2.5 },
    side: { x: 2.5, y: 0, z: 0.5 },
    perspective: { x: 1.87, y: 0.88, z: -0.64 }
};

// Initialize the terrain visualization
function initTerrainPlot() {
    const terrainData = generateTerrainData(50);

    const surfaceTrace = {
        x: terrainData.x,
        y: terrainData.y,
        z: terrainData.z,
        type: 'surface',
        colorscale: 'Viridis',
        showscale: true,
        colorbar: {
            title: 'Elevation (m)',
            titleside: 'right',
            thickness: 20,
            len: 0.7
        },
        contours: {
            z: {
                show: true,
                usecolormap: true,
                highlightcolor: "#42f462",
                project: { z: true }
            }
        },
        lighting: {
            ambient: 0.4,
            diffuse: 0.8,
            specular: 0.2,
            roughness: 0.1,
            fresnel: 0.2
        },
        lightposition: {
            x: 100,
            y: 200,
            z: 0
        }
    };

    const layout = {
        title: {
            text: '3D Terrain Visualization',
            font: { size: 18 }
        },
        scene: {
            xaxis: {
                title: 'X Coordinate (km)',
                backgroundcolor: "rgb(200, 200, 230)",
                gridcolor: "white",
                showbackground: true,
                zerolinecolor: "white"
            },
            yaxis: {
                title: 'Y Coordinate (km)',
                backgroundcolor: "rgb(230, 200, 230)",
                gridcolor: "white",
                showbackground: true,
                zerolinecolor: "white"
            },
            zaxis: {
                title: 'Elevation (m)',
                backgroundcolor: "rgb(230, 230, 200)",
                gridcolor: "white",
                showbackground: true,
                zerolinecolor: "white"
            },
            camera: {
                eye: cameraPresets.isometric,
                center: { x: 0, y: 0, z: 0 },
                up: { x: 0, y: 0, z: 1 }
            },
            aspectmode: 'cube'
        },
        margin: { l: 0, r: 0, b: 0, t: 40 },
        paper_bgcolor: 'rgba(0,0,0,0)',
        plot_bgcolor: 'rgba(0,0,0,0)'
    };

    const config = {
        responsive: true,
        displayModeBar: true,
        modeBarButtonsToAdd: [{
            name: 'Download as SVG',
            icon: Plotly.Icons.camera,
            click: function(gd) {
                Plotly.downloadImage(gd, {format: 'svg', width: 1200, height: 800, filename: 'terrain-3d'});
            }
        }],
        displaylogo: false
    };

    Plotly.newPlot('terrain-plot', [surfaceTrace], layout, config);

    // Add event listeners for camera tracking
    document.getElementById('terrain-plot').on('plotly_relayout', function(eventData) {
        if (eventData['scene.camera']) {
            console.log('Camera updated:', eventData['scene.camera']);
        }
    });
}

// Control functions
function updateColorscale() {
    const colorscale = document.getElementById('colorscale-select').value;
    Plotly.restyle('terrain-plot', { colorscale: colorscale }, [0]);
}

function setCameraPreset() {
    const preset = document.getElementById('camera-preset').value;
    const cameraUpdate = {
        'scene.camera.eye': cameraPresets[preset]
    };
    Plotly.relayout('terrain-plot', cameraUpdate);
}

function resetCamera() {
    const resetUpdate = {
        'scene.camera.eye': cameraPresets.isometric,
        'scene.camera.center': { x: 0, y: 0, z: 0 },
        'scene.camera.up': { x: 0, y: 0, z: 1 }
    };
    Plotly.relayout('terrain-plot', resetUpdate);
}

function exportImage() {
    Plotly.downloadImage('terrain-plot', {
        format: 'png',
        width: 1200,
        height: 800,
        filename: 'terrain-visualization'
    });
}

// Event listeners
document.getElementById('colorscale-select').addEventListener('change', updateColorscale);
document.getElementById('camera-preset').addEventListener('change', setCameraPreset);

// Initialize on page load
initTerrainPlot();
    </script>
</body>
</html>
```

### 2. 3D Scatter Plot - Scientific Data Points
```html
<!DOCTYPE html>
<html>
<head>
    <title>3D Molecular Structure</title>
    <script src="https://cdn.plot.ly/plotly-2.26.0.min.js"></script>
    <style>
        #molecule-plot { width: 100%; height: 600px; }
        .info-panel { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <div id="molecule-plot"></div>
    <div class="info-panel">
        <h3>Molecular Structure Visualization</h3>
        <p>Interactive 3D representation of atomic positions with size and color coding by element type.</p>
        <div id="atom-info">Hover over atoms to see details</div>
    </div>

    <script>
// Generate molecular data (caffeine molecule example)
function generateMolecularData() {
    const atoms = [
        // Carbon atoms
        { x: 0, y: 0, z: 0, element: 'C', color: 'black', size: 15 },
        { x: 1.4, y: 0, z: 0, element: 'C', color: 'black', size: 15 },
        { x: 2.1, y: 1.2, z: 0, element: 'C', color: 'black', size: 15 },
        { x: 1.4, y: 2.4, z: 0, element: 'C', color: 'black', size: 15 },
        { x: 0, y: 2.4, z: 0, element: 'C', color: 'black', size: 15 },
        { x: -0.7, y: 1.2, z: 0, element: 'C', color: 'black', size: 15 },

        // Nitrogen atoms
        { x: -1.4, y: 0.6, z: 0.5, element: 'N', color: 'blue', size: 18 },
        { x: 2.8, y: 0.6, z: 0.5, element: 'N', color: 'blue', size: 18 },

        // Oxygen atoms
        { x: -0.7, y: -0.6, z: 0.3, element: 'O', color: 'red', size: 16 },
        { x: 1.4, y: 3.0, z: 0.3, element: 'O', color: 'red', size: 16 },

        // Hydrogen atoms
        { x: 0.5, y: -0.8, z: 0.8, element: 'H', color: 'lightgray', size: 8 },
        { x: 1.9, y: -0.8, z: 0.8, element: 'H', color: 'lightgray', size: 8 },
        { x: 3.2, y: 1.5, z: 0.8, element: 'H', color: 'lightgray', size: 8 },
        { x: -0.5, y: 3.2, z: 0.8, element: 'H', color: 'lightgray', size: 8 },
        { x: -2.2, y: 0.2, z: 0.8, element: 'H', color: 'lightgray', size: 8 },
        { x: 3.6, y: 0.2, z: 0.8, element: 'H', color: 'lightgray', size: 8 }
    ];

    return atoms;
}

// Create bonds between atoms
function generateBonds() {
    const bonds = [
        { start: [0, 0, 0], end: [1.4, 0, 0] },
        { start: [1.4, 0, 0], end: [2.1, 1.2, 0] },
        { start: [2.1, 1.2, 0], end: [1.4, 2.4, 0] },
        { start: [1.4, 2.4, 0], end: [0, 2.4, 0] },
        { start: [0, 2.4, 0], end: [-0.7, 1.2, 0] },
        { start: [-0.7, 1.2, 0], end: [0, 0, 0] }
    ];

    return bonds;
}

function initMoleculePlot() {
    const atoms = generateMolecularData();
    const bonds = generateBonds();

    // Create atom scatter trace
    const atomTrace = {
        x: atoms.map(atom => atom.x),
        y: atoms.map(atom => atom.y),
        z: atoms.map(atom => atom.z),
        text: atoms.map(atom => `${atom.element} atom<br>Position: (${atom.x}, ${atom.y}, ${atom.z})`),
        mode: 'markers',
        type: 'scatter3d',
        marker: {
            size: atoms.map(atom => atom.size),
            color: atoms.map(atom => atom.color),
            opacity: 0.8,
            line: {
                color: 'black',
                width: 2
            }
        },
        hovertemplate: '<b>%{text}</b><extra></extra>',
        name: 'Atoms'
    };

    // Create bond traces
    const bondTraces = bonds.map((bond, index) => ({
        x: [bond.start[0], bond.end[0], null],
        y: [bond.start[1], bond.end[1], null],
        z: [bond.start[2], bond.end[2], null],
        mode: 'lines',
        type: 'scatter3d',
        line: {
            color: 'gray',
            width: 6
        },
        showlegend: false,
        hoverinfo: 'skip'
    }));

    const layout = {
        title: {
            text: 'Caffeine Molecule - 3D Structure',
            font: { size: 18 }
        },
        scene: {
            xaxis: {
                title: 'X (Å)',
                showbackground: false,
                showgrid: false,
                zeroline: false
            },
            yaxis: {
                title: 'Y (Å)',
                showbackground: false,
                showgrid: false,
                zeroline: false
            },
            zaxis: {
                title: 'Z (Å)',
                showbackground: false,
                showgrid: false,
                zeroline: false
            },
            camera: {
                eye: { x: 2, y: 2, z: 1.5 },
                center: { x: 0.7, y: 1.2, z: 0.2 }
            },
            aspectmode: 'cube',
            bgcolor: 'rgba(0,0,0,0)'
        },
        margin: { l: 0, r: 0, b: 0, t: 40 },
        paper_bgcolor: 'white',
        legend: {
            x: 0.02,
            y: 0.98,
            bgcolor: 'rgba(255,255,255,0.8)'
        }
    };

    const config = {
        responsive: true,
        displayModeBar: true,
        displaylogo: false
    };

    const allTraces = [atomTrace, ...bondTraces];
    Plotly.newPlot('molecule-plot', allTraces, layout, config);

    // Add hover event handler
    document.getElementById('molecule-plot').on('plotly_hover', function(data) {
        const point = data.points[0];
        if (point.curveNumber === 0) { // Only for atom trace
            const atom = atoms[point.pointNumber];
            document.getElementById('atom-info').innerHTML =
                `<strong>${atom.element}</strong> atom at position (${atom.x}, ${atom.y}, ${atom.z})`;
        }
    });
}

// Initialize on page load
initMoleculePlot();
    </script>
</body>
</html>
```

### 3. 3D Mesh Plot - Engineering Visualization
```html
<!DOCTYPE html>
<html>
<head>
    <title>3D Mesh Visualization</title>
    <script src="https://cdn.plot.ly/plotly-2.26.0.min.js"></script>
    <style>
        #mesh-plot { width: 100%; height: 600px; }
        .mesh-controls { margin: 20px 0; }
        .control-row { margin: 10px 0; }
        label { display: inline-block; width: 120px; }
        input[type="range"] { width: 200px; }
        .value-display { font-weight: bold; color: #333; }
    </style>
</head>
<body>
    <div id="mesh-plot"></div>
    <div class="mesh-controls">
        <div class="control-row">
            <label>Opacity:</label>
            <input type="range" id="opacity-slider" min="0.1" max="1" step="0.1" value="0.7">
            <span class="value-display" id="opacity-value">0.7</span>
        </div>
        <div class="control-row">
            <label>Wireframe:</label>
            <input type="checkbox" id="wireframe-toggle" checked>
        </div>
        <div class="control-row">
            <label>Face Color:</label>
            <select id="face-color">
                <option value="lightblue">Light Blue</option>
                <option value="lightcoral">Light Coral</option>
                <option value="lightgreen">Light Green</option>
                <option value="gold">Gold</option>
                <option value="plum">Plum</option>
            </select>
        </div>
        <button onclick="rotateMesh()">Auto Rotate</button>
        <button onclick="resetView()">Reset View</button>
    </div>

    <script>
// Generate complex 3D mesh data (torus example)
function generateTorusMesh(R = 3, r = 1, nu = 50, nv = 30) {
    const vertices = [];
    const faces = [];

    // Generate vertices
    for (let i = 0; i <= nu; i++) {
        const u = (i / nu) * 2 * Math.PI;
        for (let j = 0; j <= nv; j++) {
            const v = (j / nv) * 2 * Math.PI;

            const x = (R + r * Math.cos(v)) * Math.cos(u);
            const y = (R + r * Math.cos(v)) * Math.sin(u);
            const z = r * Math.sin(v);

            vertices.push([x, y, z]);
        }
    }

    // Generate faces (triangulation)
    for (let i = 0; i < nu; i++) {
        for (let j = 0; j < nv; j++) {
            const v1 = i * (nv + 1) + j;
            const v2 = v1 + 1;
            const v3 = (i + 1) * (nv + 1) + j;
            const v4 = v3 + 1;

            // Two triangles per quad
            faces.push([v1, v2, v3]);
            faces.push([v2, v4, v3]);
        }
    }

    return { vertices, faces };
}

// Create mesh visualization
function initMeshPlot() {
    const meshData = generateTorusMesh();
    const vertices = meshData.vertices;
    const faces = meshData.faces;

    const meshTrace = {
        type: 'mesh3d',
        x: vertices.map(v => v[0]),
        y: vertices.map(v => v[1]),
        z: vertices.map(v => v[2]),
        i: faces.map(f => f[0]),
        j: faces.map(f => f[1]),
        k: faces.map(f => f[2]),
        facecolor: Array(faces.length).fill('lightblue'),
        opacity: 0.7,
        flatshading: false,
        lighting: {
            ambient: 0.3,
            diffuse: 0.8,
            specular: 0.2,
            roughness: 0.1,
            fresnel: 0.2
        },
        lightposition: {
            x: 100,
            y: 200,
            z: 300
        },
        showscale: false,
        hovertemplate: 'Vertex: (%{x:.2f}, %{y:.2f}, %{z:.2f})<extra></extra>',
        contour: {
            show: true,
            color: 'black',
            width: 2
        }
    };

    const layout = {
        title: {
            text: '3D Torus Mesh - Engineering Visualization',
            font: { size: 18 }
        },
        scene: {
            xaxis: {
                title: 'X',
                backgroundcolor: "rgba(0,0,0,0)",
                gridcolor: "lightgray",
                showbackground: true,
                zerolinecolor: "gray"
            },
            yaxis: {
                title: 'Y',
                backgroundcolor: "rgba(0,0,0,0)",
                gridcolor: "lightgray",
                showbackground: true,
                zerolinecolor: "gray"
            },
            zaxis: {
                title: 'Z',
                backgroundcolor: "rgba(0,0,0,0)",
                gridcolor: "lightgray",
                showbackground: true,
                zerolinecolor: "gray"
            },
            camera: {
                eye: { x: 1.5, y: 1.5, z: 1.5 },
                center: { x: 0, y: 0, z: 0 }
            },
            aspectmode: 'cube'
        },
        margin: { l: 0, r: 0, b: 0, t: 40 },
        paper_bgcolor: 'white'
    };

    const config = {
        responsive: true,
        displayModeBar: true,
        displaylogo: false
    };

    Plotly.newPlot('mesh-plot', [meshTrace], layout, config);
}

// Control functions
function updateOpacity() {
    const opacity = parseFloat(document.getElementById('opacity-slider').value);
    document.getElementById('opacity-value').textContent = opacity;
    Plotly.restyle('mesh-plot', { opacity: opacity }, [0]);
}

function toggleWireframe() {
    const showWireframe = document.getElementById('wireframe-toggle').checked;
    const contourUpdate = showWireframe ?
        { 'contour.show': true, 'contour.color': 'black', 'contour.width': 2 } :
        { 'contour.show': false };
    Plotly.restyle('mesh-plot', contourUpdate, [0]);
}

function updateFaceColor() {
    const color = document.getElementById('face-color').value;
    const meshData = generateTorusMesh();
    const faceColors = Array(meshData.faces.length).fill(color);
    Plotly.restyle('mesh-plot', { facecolor: [faceColors] }, [0]);
}

let rotationInterval;
function rotateMesh() {
    if (rotationInterval) {
        clearInterval(rotationInterval);
        rotationInterval = null;
        return;
    }

    let angle = 0;
    rotationInterval = setInterval(() => {
        angle += 2;
        const radian = angle * Math.PI / 180;
        const cameraUpdate = {
            'scene.camera.eye': {
                x: 2 * Math.cos(radian),
                y: 2 * Math.sin(radian),
                z: 1.5
            }
        };
        Plotly.relayout('mesh-plot', cameraUpdate);
    }, 50);
}

function resetView() {
    if (rotationInterval) {
        clearInterval(rotationInterval);
        rotationInterval = null;
    }

    const resetUpdate = {
        'scene.camera.eye': { x: 1.5, y: 1.5, z: 1.5 },
        'scene.camera.center': { x: 0, y: 0, z: 0 }
    };
    Plotly.relayout('mesh-plot', resetUpdate);
}

// Event listeners
document.getElementById('opacity-slider').addEventListener('input', updateOpacity);
document.getElementById('wireframe-toggle').addEventListener('change', toggleWireframe);
document.getElementById('face-color').addEventListener('change', updateFaceColor);

// Initialize on page load
initMeshPlot();
    </script>
</body>
</html>
```

## Configuration Reference

### Core 3D Plot Types
```javascript
// Surface plots for continuous data
const surfaceConfig = {
    type: 'surface',
    z: matrixData,              // 2D array of z-values
    x: xCoordinates,            // Optional x-coordinates
    y: yCoordinates,            // Optional y-coordinates
    colorscale: 'Viridis',      // Color mapping
    showscale: true,            // Show color bar
    contours: {                 // Contour projections
        z: { show: true, project: { z: true } }
    }
};

// Scatter3d for point data
const scatterConfig = {
    type: 'scatter3d',
    x: [1, 2, 3, 4],
    y: [10, 11, 12, 13],
    z: [2, 3, 4, 5],
    mode: 'markers+lines',      // markers, lines, or both
    marker: {
        size: [12, 22, 20, 16], // Variable sizes
        color: [1, 2, 3, 4],    // Color mapping
        colorscale: 'Rainbow',
        opacity: 0.8,
        line: { color: 'black', width: 2 }
    }
};

// Mesh3d for triangulated surfaces
const meshConfig = {
    type: 'mesh3d',
    x: vertexX,                 // Vertex coordinates
    y: vertexY,
    z: vertexZ,
    i: triangleI,              // Triangle vertex indices
    j: triangleJ,
    k: triangleK,
    opacity: 0.7,
    flatshading: false,
    lighting: {
        ambient: 0.4,
        diffuse: 0.8,
        specular: 0.2
    }
};
```

### Camera Control Systems
```javascript
// Camera positioning and animation
const cameraControls = {
    // Static camera positions
    eye: { x: 1.25, y: 1.25, z: 1.25 },    // Camera position
    center: { x: 0, y: 0, z: 0 },          // Look-at point
    up: { x: 0, y: 0, z: 1 },              // Up direction

    // Camera animation
    projection: { type: 'perspective' },     // or 'orthographic'

    // Preset positions
    presets: {
        isometric: { x: 1.25, y: 1.25, z: 1.25 },
        front: { x: 0, y: -2, z: 0 },
        side: { x: 2, y: 0, z: 0 },
        top: { x: 0, y: 0, z: 2 }
    }
};

// Camera update function
function updateCamera(preset) {
    Plotly.relayout(plotDiv, {
        'scene.camera.eye': cameraControls.presets[preset]
    });
}

// Smooth camera transitions
function animateCamera(targetPosition, duration = 1000) {
    const steps = 30;
    const stepTime = duration / steps;
    let currentStep = 0;

    const currentPos = getCurrentCameraPosition();
    const deltaX = (targetPosition.x - currentPos.x) / steps;
    const deltaY = (targetPosition.y - currentPos.y) / steps;
    const deltaZ = (targetPosition.z - currentPos.z) / steps;

    const interval = setInterval(() => {
        currentStep++;
        const newPos = {
            x: currentPos.x + deltaX * currentStep,
            y: currentPos.y + deltaY * currentStep,
            z: currentPos.z + deltaZ * currentStep
        };

        Plotly.relayout(plotDiv, { 'scene.camera.eye': newPos });

        if (currentStep >= steps) {
            clearInterval(interval);
        }
    }, stepTime);
}
```

### Advanced Lighting Models
```javascript
const lightingConfigs = {
    // Realistic lighting
    scientific: {
        ambient: 0.4,           // Ambient light intensity
        diffuse: 0.8,           // Diffuse lighting
        specular: 0.2,          // Specular highlights
        roughness: 0.1,         // Surface roughness
        fresnel: 0.2            // Fresnel effect
    },

    // Artistic lighting
    dramatic: {
        ambient: 0.1,
        diffuse: 0.9,
        specular: 0.5,
        roughness: 0.05,
        fresnel: 0.4
    },

    // Technical lighting
    engineering: {
        ambient: 0.6,
        diffuse: 0.7,
        specular: 0.1,
        roughness: 0.2,
        fresnel: 0.1
    }
};

// Light positioning
const lightPosition = {
    x: 100,                     // Light X position
    y: 200,                     // Light Y position
    z: 300                      // Light Z position
};

// Apply lighting to trace
function applyLighting(trace, lightingType) {
    trace.lighting = lightingConfigs[lightingType];
    trace.lightposition = lightPosition;
    return trace;
}
```

### Performance Optimization
```javascript
// Large dataset handling
const performanceConfig = {
    // Data decimation for large datasets
    decimateData: function(data, maxPoints = 10000) {
        if (data.length <= maxPoints) return data;
        const step = Math.ceil(data.length / maxPoints);
        return data.filter((_, index) => index % step === 0);
    },

    // WebGL acceleration settings
    webglSettings: {
        preserveDrawingBuffer: true,    // For image export
        antialias: true,                // Smooth edges
        alpha: true,                    // Transparency support
        premultipliedAlpha: false       // Color accuracy
    },

    // Memory management
    memoryOptimization: {
        autoSize: true,                 // Automatic resizing
        staticPlot: false,              // Enable interactions
        scrollZoom: true,               // Zoom with scroll
        doubleClick: 'reset+autosize'   // Double-click behavior
    }
};

// Apply performance optimizations
function optimizeForPerformance(config) {
    config.responsive = true;
    config.displayModeBar = 'hover';
    config.modeBarButtonsToRemove = ['pan3d', 'orbitRotation'];
    config.showTips = false;
    return config;
}
```

## Use Case Variations

### 1. Scientific Visualization
```javascript
// Molecular dynamics simulation
const mdVisualization = {
    traces: [
        {
            type: 'scatter3d',
            x: atomPositions.x,
            y: atomPositions.y,
            z: atomPositions.z,
            mode: 'markers',
            marker: {
                size: atomSizes,
                color: atomTypes,
                colorscale: 'viridis',
                opacity: 0.8
            },
            text: atomLabels,
            name: 'Atoms'
        },
        {
            type: 'scatter3d',
            x: bondLines.x,
            y: bondLines.y,
            z: bondLines.z,
            mode: 'lines',
            line: { color: 'gray', width: 4 },
            showlegend: false,
            name: 'Bonds'
        }
    ],
    layout: {
        scene: {
            aspectmode: 'cube',
            camera: { eye: { x: 2, y: 2, z: 2 } }
        }
    }
};

// Protein structure with animation
function animateProteinFolding(frames) {
    const animationFrames = frames.map(frame => ({
        data: [{
            x: frame.coordinates.x,
            y: frame.coordinates.y,
            z: frame.coordinates.z
        }]
    }));

    Plotly.animate(plotDiv, animationFrames, {
        transition: { duration: 100 },
        frame: { duration: 100 }
    });
}
```

### 2. Engineering Simulation
```javascript
// Finite element analysis results
const feaVisualization = {
    type: 'mesh3d',
    x: nodeCoordinates.x,
    y: nodeCoordinates.y,
    z: nodeCoordinates.z,
    i: elements.node1,
    j: elements.node2,
    k: elements.node3,
    intensity: stressValues,
    colorscale: 'RdYlBu',
    colorbar: {
        title: 'Stress (MPa)',
        thickness: 20
    },
    lighting: {
        ambient: 0.4,
        diffuse: 0.8
    }
};

// Fluid flow visualization
const fluidFlow = {
    type: 'streamtube',
    x: flowField.x,
    y: flowField.y,
    z: flowField.z,
    u: velocityField.u,
    v: velocityField.v,
    w: velocityField.w,
    sizeref: 0.3,
    colorscale: 'Portland',
    showscale: true,
    maxdisplayed: 3000
};
```

### 3. Geospatial Visualization
```javascript
// Terrain with overlay data
const terrainWithData = {
    surface: {
        type: 'surface',
        z: elevationMatrix,
        colorscale: 'Earth',
        showscale: false,
        opacity: 0.8
    },
    dataPoints: {
        type: 'scatter3d',
        x: sensorLocations.lon,
        y: sensorLocations.lat,
        z: sensorLocations.elevation,
        mode: 'markers+text',
        marker: {
            size: 8,
            color: sensorValues,
            colorscale: 'Viridis'
        },
        text: sensorLabels,
        textposition: 'top center'
    }
};

// Atmospheric data visualization
const atmosphericViz = {
    type: 'volume',
    x: gridPoints.x,
    y: gridPoints.y,
    z: gridPoints.z,
    value: temperatureData,
    isomin: minTemp,
    isomax: maxTemp,
    opacity: 0.1,
    surface_count: 15,
    colorscale: 'Hot'
};
```

## Dependencies and Environment Setup

### Required Dependencies
```html
<!-- Core Plotly.js -->
<script src="https://cdn.plot.ly/plotly-2.26.0.min.js"></script>

<!-- Alternative: Specific modules for smaller bundle -->
<script src="https://cdn.plot.ly/plotly-gl3d-2.26.0.min.js"></script>

<!-- For advanced features -->
<script src="https://cdn.plot.ly/plotly-cartesian-2.26.0.min.js"></script>
<script src="https://cdn.plot.ly/plotly-gl2d-2.26.0.min.js"></script>
```

### Browser Requirements
```javascript
// WebGL support detection
function checkWebGLSupport() {
    try {
        const canvas = document.createElement('canvas');
        const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
        return gl && gl instanceof WebGLRenderingContext;
    } catch (e) {
        return false;
    }
}

// Fallback for unsupported browsers
if (!checkWebGLSupport()) {
    console.warn('WebGL not supported. 3D features will be limited.');
    // Provide 2D alternatives or polyfills
}

// Performance monitoring
function monitorPerformance() {
    const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
            if (entry.name.includes('plotly')) {
                console.log(`Plotly operation: ${entry.name} took ${entry.duration}ms`);
            }
        }
    });
    observer.observe({ entryTypes: ['measure'] });
}
```

### Environment Configuration
```javascript
// Development setup
const devConfig = {
    displayModeBar: true,
    displaylogo: false,
    modeBarButtonsToAdd: [
        {
            name: 'Debug Info',
            icon: Plotly.Icons.question,
            click: function(gd) {
                console.log('Plot data:', gd.data);
                console.log('Plot layout:', gd.layout);
            }
        }
    ],
    editable: true,
    showTips: true
};

// Production setup
const prodConfig = {
    displayModeBar: 'hover',
    displaylogo: false,
    modeBarButtonsToRemove: ['sendDataToCloud'],
    responsive: true,
    staticPlot: false
};

// Choose configuration based on environment
const config = process.env.NODE_ENV === 'development' ? devConfig : prodConfig;
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Performance Problems
```javascript
// Issue: Slow rendering with large datasets
// Solution: Data decimation and chunking
function optimizeLargeDataset(data, maxPoints = 5000) {
    if (data.length <= maxPoints) return data;

    // Intelligent sampling that preserves important features
    const step = Math.ceil(data.length / maxPoints);
    const sampled = [];

    for (let i = 0; i < data.length; i += step) {
        sampled.push(data[i]);

        // Always include local maxima/minima
        if (i > 0 && i < data.length - 1) {
            const prev = data[i - 1];
            const curr = data[i];
            const next = data[i + 1];

            if ((curr > prev && curr > next) || (curr < prev && curr < next)) {
                sampled.push(curr);
            }
        }
    }

    return sampled;
}

// Issue: Memory leaks with frequent updates
// Solution: Proper cleanup
function cleanupPlot(plotDiv) {
    if (plotDiv && plotDiv.removeAllListeners) {
        plotDiv.removeAllListeners();
    }
    Plotly.purge(plotDiv);
}
```

#### Rendering Issues
```javascript
// Issue: Blank or corrupted 3D plots
// Solution: WebGL context management
function reinitializeWebGL() {
    // Force WebGL context reset
    const canvas = document.querySelector('canvas[data-id="gl-canvas"]');
    if (canvas) {
        const gl = canvas.getContext('webgl');
        if (gl) {
            gl.getExtension('WEBGL_lose_context').loseContext();
        }
    }

    // Redraw plot
    setTimeout(() => {
        Plotly.redraw(plotDiv);
    }, 100);
}

// Issue: Camera controls not responding
// Solution: Event handler verification
function debugCameraControls(plotDiv) {
    plotDiv.on('plotly_relayout', function(eventData) {
        console.log('Relayout event:', eventData);

        if (eventData['scene.camera']) {
            console.log('Camera updated:', eventData['scene.camera']);
        }
    });

    // Manual camera test
    setTimeout(() => {
        Plotly.relayout(plotDiv, {
            'scene.camera.eye': { x: 2, y: 2, z: 2 }
        });
    }, 1000);
}
```

#### Data Formatting Issues
```javascript
// Issue: Incorrect surface plot appearance
// Solution: Data validation and formatting
function validateSurfaceData(data) {
    const issues = [];

    // Check for consistent array lengths
    if (data.z && Array.isArray(data.z[0])) {
        const rowLength = data.z[0].length;
        for (let i = 1; i < data.z.length; i++) {
            if (data.z[i].length !== rowLength) {
                issues.push(`Row ${i} has inconsistent length`);
            }
        }
    }

    // Check for NaN or undefined values
    const flatZ = data.z.flat();
    const invalidValues = flatZ.filter(val => isNaN(val) || val === undefined);
    if (invalidValues.length > 0) {
        issues.push(`Found ${invalidValues.length} invalid values`);
    }

    // Check coordinate arrays
    if (data.x && data.x.length !== data.z[0].length) {
        issues.push('X coordinates length mismatch');
    }
    if (data.y && data.y.length !== data.z.length) {
        issues.push('Y coordinates length mismatch');
    }

    return issues;
}

// Issue: Mesh topology errors
// Solution: Mesh validation
function validateMeshTopology(vertices, faces) {
    const issues = [];

    // Check vertex indices in faces
    faces.forEach((face, faceIndex) => {
        face.forEach((vertexIndex, position) => {
            if (vertexIndex >= vertices.length || vertexIndex < 0) {
                issues.push(`Face ${faceIndex} references invalid vertex ${vertexIndex}`);
            }
        });
    });

    // Check for degenerate triangles
    faces.forEach((face, faceIndex) => {
        if (face[0] === face[1] || face[1] === face[2] || face[0] === face[2]) {
            issues.push(`Face ${faceIndex} is degenerate`);
        }
    });

    return issues;
}
```

### Browser Compatibility Matrix
```javascript
const compatibilityMatrix = {
    Chrome: { version: '80+', webgl: 'Full', performance: 'Excellent' },
    Firefox: { version: '75+', webgl: 'Full', performance: 'Good' },
    Safari: { version: '13+', webgl: 'Limited', performance: 'Good' },
    Edge: { version: '80+', webgl: 'Full', performance: 'Excellent' },
    IE: { version: 'Not supported', webgl: 'None', performance: 'None' }
};

// Feature detection and graceful degradation
function setupBrowserOptimizations() {
    const userAgent = navigator.userAgent;

    if (userAgent.includes('Safari') && !userAgent.includes('Chrome')) {
        // Safari-specific optimizations
        return {
            displayModeBar: 'hover',
            staticPlot: false,
            scrollZoom: false // Safari scroll issues
        };
    } else if (userAgent.includes('Firefox')) {
        // Firefox-specific optimizations
        return {
            displayModeBar: true,
            doubleClick: 'reset'
        };
    }

    // Default configuration
    return {
        displayModeBar: 'hover',
        scrollZoom: true,
        doubleClick: 'reset+autosize'
    };
}
```

## Advanced Integration Patterns

### React Component Integration
```jsx
import React, { useEffect, useRef, useState } from 'react';
import Plotly from 'plotly.js-dist';

const PlotlyThreeDComponent = ({ data, layout, config }) => {
    const plotRef = useRef();
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        const plotDiv = plotRef.current;

        // Initialize plot
        Plotly.newPlot(plotDiv, data, layout, config)
            .then(() => {
                setIsLoading(false);

                // Add event listeners
                plotDiv.on('plotly_hover', handleHover);
                plotDiv.on('plotly_click', handleClick);
                plotDiv.on('plotly_relayout', handleRelayout);
            })
            .catch(error => {
                console.error('Plotly initialization failed:', error);
                setIsLoading(false);
            });

        // Cleanup
        return () => {
            if (plotDiv && plotDiv.removeAllListeners) {
                plotDiv.removeAllListeners();
            }
            Plotly.purge(plotDiv);
        };
    }, [data, layout, config]);

    const handleHover = (eventData) => {
        console.log('Hover:', eventData);
    };

    const handleClick = (eventData) => {
        console.log('Click:', eventData);
    };

    const handleRelayout = (eventData) => {
        if (eventData['scene.camera']) {
            console.log('Camera updated:', eventData['scene.camera']);
        }
    };

    return (
        <div>
            {isLoading && <div>Loading 3D visualization...</div>}
            <div ref={plotRef} style={{ width: '100%', height: '600px' }} />
        </div>
    );
};

export default PlotlyThreeDComponent;
```

### Vue.js Integration
```vue
<template>
    <div>
        <div ref="plotDiv" class="plotly-container"></div>
        <div class="controls">
            <button @click="resetCamera">Reset Camera</button>
            <button @click="exportImage">Export Image</button>
        </div>
    </div>
</template>

<script>
import Plotly from 'plotly.js-dist';

export default {
    name: 'PlotlyThreeD',
    props: {
        data: Array,
        layout: Object,
        config: Object
    },
    mounted() {
        this.initPlot();
    },
    beforeDestroy() {
        if (this.$refs.plotDiv) {
            Plotly.purge(this.$refs.plotDiv);
        }
    },
    methods: {
        async initPlot() {
            try {
                await Plotly.newPlot(this.$refs.plotDiv, this.data, this.layout, this.config);
                this.setupEventListeners();
            } catch (error) {
                console.error('Plot initialization failed:', error);
            }
        },
        setupEventListeners() {
            this.$refs.plotDiv.on('plotly_hover', this.onHover);
            this.$refs.plotDiv.on('plotly_click', this.onClick);
        },
        onHover(eventData) {
            this.$emit('hover', eventData);
        },
        onClick(eventData) {
            this.$emit('click', eventData);
        },
        resetCamera() {
            Plotly.relayout(this.$refs.plotDiv, {
                'scene.camera.eye': { x: 1.25, y: 1.25, z: 1.25 }
            });
        },
        exportImage() {
            Plotly.downloadImage(this.$refs.plotDiv, {
                format: 'png',
                width: 1200,
                height: 800,
                filename: 'plot3d'
            });
        }
    }
};
</script>

<style scoped>
.plotly-container {
    width: 100%;
    height: 600px;
}
.controls {
    margin: 20px 0;
}
</style>
```

## Plotly.js Specific Advantages

### WebGL Acceleration
- Hardware-accelerated rendering for smooth interactions
- Supports millions of data points with maintained performance
- Real-time updates and animations without frame drops
- Automatic GPU memory management

### Interactive Features
- Built-in camera controls (rotate, zoom, pan)
- Hover tooltips with customizable content
- Click events for data point selection
- Brush selection for multi-point operations

### Scientific Accuracy
- Precise mathematical coordinate systems
- Support for logarithmic and custom axis scales
- Scientific notation and engineering units
- Color-blind friendly color scales

### Export Capabilities
- High-resolution PNG, SVG, PDF export
- Preserves vector graphics for publication quality
- Customizable export dimensions and DPI
- Programmatic export via JavaScript API

## Limitations and Considerations

### Performance Constraints
- WebGL context limits (typically 16-32 contexts per page)
- Maximum texture size varies by GPU (usually 4096x4096)
- Memory usage scales with data complexity
- Mobile devices have reduced performance capabilities

### Browser Compatibility
- Requires modern browsers with WebGL support
- Safari has some WebGL limitations on older versions
- Internet Explorer not supported for 3D features
- Mobile browsers may have interaction limitations

### Data Size Limits
- Practical limit of ~100,000 surface points
- Mesh plots limited by triangle count (~50,000 faces)
- Scatter plots can handle millions of points
- Consider data decimation for large datasets

### Feature Limitations
- Limited animation capabilities compared to specialized 3D libraries
- No built-in physics simulation
- Limited support for complex geometric primitives
- No native VR/AR support

This comprehensive guide provides everything needed for NPL-FIM to generate sophisticated 3D graphics with Plotly.js. The complete examples, configuration references, and troubleshooting sections ensure successful artifact generation without false starts.