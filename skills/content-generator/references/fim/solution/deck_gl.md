# deck.gl

WebGL-powered framework for large-scale data visualization.

## Installation
```bash
npm install deck.gl
```

## Basic Setup
```javascript
import {Deck} from '@deck.gl/core';
import {ScatterplotLayer} from '@deck.gl/layers';

const deck = new Deck({
  initialViewState: {
    longitude: -122.4,
    latitude: 37.8,
    zoom: 11,
    pitch: 0,
    bearing: 0
  },
  controller: true,
  layers: []
});
```

## Scatterplot Layer
```javascript
new ScatterplotLayer({
  id: 'scatterplot',
  data: points,
  getPosition: d => d.coordinates,
  getRadius: d => d.size,
  getFillColor: d => [255, 140, 0],
  radiusScale: 6
});
```

## Hexagon Layer
```javascript
import {HexagonLayer} from '@deck.gl/aggregation-layers';

new HexagonLayer({
  id: 'hexagon',
  data: points,
  getPosition: d => d.coordinates,
  radius: 1000,
  elevationScale: 4,
  extruded: true
});
```

## GeoJSON Layer
```javascript
import {GeoJsonLayer} from '@deck.gl/layers';

new GeoJsonLayer({
  id: 'geojson',
  data: geojsonData,
  filled: true,
  stroked: true,
  getFillColor: [160, 160, 180, 200],
  getLineColor: [255, 255, 255],
  getLineWidth: 2
});
```

## Map Integration
```javascript
import {MapboxLayer} from '@deck.gl/mapbox';

const myDeckLayer = new MapboxLayer({
  id: 'deck-layer',
  type: ScatterplotLayer,
  data: points,
  getPosition: d => d.coordinates
});

map.addLayer(myDeckLayer);
```

## Key Features
- GPU-accelerated rendering
- Handles millions of points
- 3D visualization layers
- Integrates with base maps
- Advanced aggregation layers