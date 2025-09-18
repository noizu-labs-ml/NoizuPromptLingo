# Mapbox GL JS

Vector tile-based web mapping library with WebGL rendering.

## Installation
```bash
npm install mapbox-gl
```

## API Key Setup
```javascript
mapboxgl.accessToken = 'pk.eyJ1IjoiYWNjb3VudCIsImEiOiJja...';
```
Get token at: https://account.mapbox.com/access-tokens/

## Basic Map
```javascript
const map = new mapboxgl.Map({
  container: 'map',
  style: 'mapbox://styles/mapbox/streets-v12',
  center: [-74.5, 40],
  zoom: 9
});
```

## Add Marker
```javascript
new mapboxgl.Marker()
  .setLngLat([-74.5, 40])
  .addTo(map);
```

## GeoJSON Layer
```javascript
map.addSource('points', {
  type: 'geojson',
  data: {
    type: 'FeatureCollection',
    features: [...]
  }
});

map.addLayer({
  id: 'points-layer',
  type: 'circle',
  source: 'points',
  paint: {
    'circle-radius': 6,
    'circle-color': '#007cbf'
  }
});
```

## Custom Tiles
```javascript
map.addSource('custom-tiles', {
  type: 'raster',
  tiles: ['https://tile.example.com/{z}/{x}/{y}.png'],
  tileSize: 256
});
```

## Events
```javascript
map.on('click', 'points-layer', (e) => {
  const coordinates = e.features[0].geometry.coordinates;
  console.log(coordinates);
});
```

## Key Features
- WebGL rendering for performance
- Vector tiles for smooth zooming
- Extensive style customization
- 3D terrain and buildings
- Real-time data updates