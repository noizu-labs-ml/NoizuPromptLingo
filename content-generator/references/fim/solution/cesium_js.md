# Cesium.js - 3D Globes & Maps

## Installation
```bash
npm install cesium
```

## CDN
```html
<link href="https://cesium.com/downloads/cesiumjs/releases/1.114/Build/Cesium/Widgets/widgets.css" rel="stylesheet">
<script src="https://cesium.com/downloads/cesiumjs/releases/1.114/Build/Cesium/Cesium.js"></script>
```

## Basic Globe
```javascript
// Set your Cesium Ion access token
Cesium.Ion.defaultAccessToken = 'YOUR_ACCESS_TOKEN';

// Create viewer
const viewer = new Cesium.Viewer('cesiumContainer', {
  terrainProvider: Cesium.createWorldTerrain(),
  baseLayerPicker: false,
  geocoder: false,
  homeButton: false,
  sceneModePicker: false,
  navigationHelpButton: false
});

// Add 3D buildings
viewer.scene.primitives.add(Cesium.createOsmBuildings());

// Fly to location
viewer.camera.flyTo({
  destination: Cesium.Cartesian3.fromDegrees(-74.0066, 40.7128, 1500),
  orientation: {
    heading: Cesium.Math.toRadians(0),
    pitch: Cesium.Math.toRadians(-45),
    roll: 0
  },
  duration: 3
});

// Add entity (point)
const entity = viewer.entities.add({
  position: Cesium.Cartesian3.fromDegrees(-74.0066, 40.7128, 100),
  point: {
    pixelSize: 10,
    color: Cesium.Color.RED,
    outlineColor: Cesium.Color.WHITE,
    outlineWidth: 2
  },
  label: {
    text: 'New York City',
    font: '14pt monospace',
    style: Cesium.LabelStyle.FILL_AND_OUTLINE,
    outlineWidth: 2,
    verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
    pixelOffset: new Cesium.Cartesian2(0, -9)
  }
});

// Add 3D model
const modelEntity = viewer.entities.add({
  position: Cesium.Cartesian3.fromDegrees(-74.01, 40.71, 0),
  model: {
    uri: 'path/to/model.glb',
    scale: 100
  }
});
```

## Strengths
- Accurate globe rendering with terrain
- Time-dynamic visualization
- Support for massive datasets
- Built-in geocoding and imagery layers
- 3D Tiles support for city-scale models

## Limitations
- Requires access token for full features
- Large library size (10MB+)
- Complex API for simple use cases
- Performance heavy for basic maps

## Best Use Cases
- Geospatial data visualization
- Flight tracking applications
- Weather and climate visualization
- Urban planning tools
- Satellite imagery analysis