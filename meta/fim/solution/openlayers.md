# OpenLayers

High-performance feature-rich library for interactive maps.

## Installation
```bash
npm install ol
```

## Basic Map
```javascript
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM()
    })
  ],
  view: new View({
    center: [0, 0],
    zoom: 2
  })
});
```

## Vector Layer
```javascript
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';

const vectorLayer = new VectorLayer({
  source: new VectorSource({
    url: 'data.geojson',
    format: new GeoJSON()
  })
});
map.addLayer(vectorLayer);
```

## Draw Features
```javascript
import Draw from 'ol/interaction/Draw';

const draw = new Draw({
  source: vectorSource,
  type: 'Polygon'
});
map.addInteraction(draw);
```

## WMS Layer
```javascript
import TileWMS from 'ol/source/TileWMS';

new TileLayer({
  source: new TileWMS({
    url: 'https://wms.example.com/geoserver/wms',
    params: {'LAYERS': 'workspace:layer'}
  })
});
```

## Styling
```javascript
import {Style, Fill, Stroke, Circle} from 'ol/style';

const style = new Style({
  fill: new Fill({color: 'rgba(255,0,0,0.5)'}),
  stroke: new Stroke({color: '#ff0000', width: 2}),
  image: new Circle({
    radius: 5,
    fill: new Fill({color: '#ff0000'})
  })
});
```

## Key Features
- Supports all major tile sources
- Advanced projection handling
- Rich interaction tools
- WMS/WFS support
- Canvas and WebGL rendering