# MapLibre GL JS

Open-source fork of Mapbox GL JS for vector tile maps.

## Installation
```bash
npm install maplibre-gl
```

## Basic Map
```javascript
const map = new maplibregl.Map({
  container: 'map',
  style: 'https://demotiles.maplibre.org/style.json',
  center: [0, 0],
  zoom: 2
});
```

## Custom Style Sources
```javascript
const style = {
  version: 8,
  sources: {
    osm: {
      type: 'raster',
      tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
      tileSize: 256
    }
  },
  layers: [{
    id: 'osm',
    type: 'raster',
    source: 'osm'
  }]
};
```

## Vector Tiles
```javascript
map.addSource('vector-source', {
  type: 'vector',
  tiles: ['https://example.com/tiles/{z}/{x}/{y}.pbf'],
  maxzoom: 14
});

map.addLayer({
  id: 'vector-layer',
  type: 'fill',
  source: 'vector-source',
  'source-layer': 'buildings',
  paint: {
    'fill-color': '#088',
    'fill-opacity': 0.8
  }
});
```

## Controls
```javascript
map.addControl(new maplibregl.NavigationControl());
map.addControl(new maplibregl.ScaleControl());
map.addControl(new maplibregl.GeolocateControl());
```

## Popup
```javascript
new maplibregl.Popup()
  .setLngLat([lng, lat])
  .setHTML('<h3>Location</h3>')
  .addTo(map);
```

## Key Features
- No API key required
- Compatible with Mapbox GL styles
- Self-hosted vector tiles
- Open-source with active community
- Protocol buffer support