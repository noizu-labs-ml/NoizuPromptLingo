# Geospatial Mapping
Generate maps, GIS visualizations, spatial analysis, and geographic data representations using NPL-FIM.
[Documentation](https://leafletjs.com/reference.html)

## WWHW
**What:** Create interactive maps, spatial visualizations, and geographic data analysis
**Why:** Visualize geographic patterns, analyze spatial relationships, and communicate location-based insights
**How:** Use Leaflet, D3.js, QGIS expressions, or GeoJSON through NPL-FIM
**When:** Data analysis, urban planning, environmental studies, or location-based applications

## When to Use
- Creating interactive web maps for data visualization
- Analyzing spatial patterns in geographic datasets
- Generating custom map styles and overlays
- Converting between geographic data formats
- Building location-aware dashboards and reports

## Key Outputs
`geojson`, `leaflet`, `d3-geo`, `svg-maps`, `kml`, `gpx`

## Quick Example
```javascript
var map = L.map('mapid').setView([51.505, -0.09], 13);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
L.marker([51.5, -0.09]).addTo(map)
    .bindPopup('London')
    .openPopup();
```

## Extended Reference
- [Leaflet Tutorials](https://leafletjs.com/examples.html)
- [D3.js Geographic Projections](https://github.com/d3/d3-geo)
- [OpenStreetMap API](https://wiki.openstreetmap.org/wiki/API)
- [QGIS Documentation](https://docs.qgis.org/latest/en/docs/)
- [GeoJSON Specification](https://geojson.org/)
- [Natural Earth Data](https://www.naturalearthdata.com/)