# Leaflet.js
Lightweight mobile-friendly interactive map library. [Docs](https://leafletjs.com/) | [Tutorials](https://leafletjs.com/examples.html)

## Install/Setup
```bash
npm install leaflet  # Node.js
# Or CDN for browser
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
```

## Basic Usage
```javascript
const map = L.map('map').setView([51.505, -0.09], 13);
L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '© OpenStreetMap contributors'
}).addTo(map);

// Add marker
L.marker([51.5, -0.09])
  .addTo(map)
  .bindPopup('Location marker')
  .openPopup();
```

## Strengths
- Small footprint (~42KB gzipped)
- Mobile touch support out of the box
- Extensive plugin ecosystem (heatmaps, clustering, routing)
- Works with multiple tile providers (OpenStreetMap, Mapbox)

## Limitations
- Limited 3D capabilities compared to Mapbox GL
- Manual work required for advanced visualizations
- No built-in data visualization layers

## Best For
`location-maps`, `real-estate`, `delivery-tracking`, `geographic-data`, `store-locators`