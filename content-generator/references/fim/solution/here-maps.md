# HERE Maps

Location platform with mapping, geocoding, and routing services.

## API Key Setup
```javascript
const platform = new H.service.Platform({
  'apikey': 'YOUR_HERE_API_KEY'
});
```
Get key at: https://developer.here.com/

## Basic Map
```javascript
const defaultLayers = platform.createDefaultLayers();
const map = new H.Map(
  document.getElementById('map'),
  defaultLayers.vector.normal.map,
  {
    zoom: 10,
    center: {lat: 52.520008, lng: 13.404954}
  }
);

const behavior = new H.mapevents.Behavior(new H.mapevents.MapEvents(map));
const ui = H.ui.UI.createDefault(map, defaultLayers);
```

## Marker
```javascript
const marker = new H.map.Marker({lat: 52.520008, lng: 13.404954});
map.addObject(marker);
```

## Geocoding
```javascript
const geocoder = platform.getSearchService();
geocoder.geocode({
  q: 'Berlin, Germany'
}, (result) => {
  const location = result.items[0].position;
  map.setCenter(location);
});
```

## Routing
```javascript
const router = platform.getRoutingService(null, 8);
router.calculateRoute({
  routingMode: 'fast',
  transportMode: 'car',
  origin: '52.520008,13.404954',
  destination: '52.530000,13.385000'
}, (result) => {
  const route = result.routes[0];
  const linestring = H.geo.LineString.fromFlexiblePolyline(route.sections[0].polyline);
  const routeLine = new H.map.Polyline(linestring);
  map.addObject(routeLine);
});
```

## Traffic Layer
```javascript
map.addLayer(defaultLayers.vector.normal.traffic);
```

## Custom Tiles
```javascript
const tileProvider = new H.map.provider.ImageTileProvider({
  getURL: (zoom, x, y) => `https://tiles.example.com/${zoom}/${x}/${y}.png`
});
const tileLayer = new H.map.layer.TileLayer(tileProvider);
map.addLayer(tileLayer);
```

## Key Features
- Real-time traffic flow
- Public transit routing
- Fleet telematics APIs
- Indoor maps
- Isoline routing