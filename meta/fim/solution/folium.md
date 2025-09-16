# Folium

Python library for creating interactive Leaflet maps.

## Installation
```bash
pip install folium
```

## Basic Map
```python
import folium

m = folium.Map(location=[45.5236, -122.6750], zoom_start=13)
m.save('map.html')
```

## Markers
```python
folium.Marker(
    [45.5236, -122.6750],
    popup='Portland, OR',
    tooltip='Click for info',
    icon=folium.Icon(color='red', icon='info-sign')
).add_to(m)
```

## Circle Marker
```python
folium.CircleMarker(
    location=[45.5236, -122.6750],
    radius=50,
    popup='Circle',
    color='#3186cc',
    fill=True,
    fillColor='#3186cc'
).add_to(m)
```

## GeoJSON Layer
```python
folium.GeoJson(
    'data.geojson',
    style_function=lambda x: {
        'fillColor': '#00ff00',
        'color': 'black',
        'weight': 2,
        'fillOpacity': 0.7
    }
).add_to(m)
```

## Choropleth Map
```python
folium.Choropleth(
    geo_data='counties.geojson',
    data=df,
    columns=['county', 'value'],
    key_on='feature.properties.name',
    fill_color='YlGn',
    legend_name='Value'
).add_to(m)
```

## Heatmap
```python
from folium.plugins import HeatMap

heat_data = [[lat, lon, value] for lat, lon, value in data]
HeatMap(heat_data).add_to(m)
```

## Marker Cluster
```python
from folium.plugins import MarkerCluster

mc = MarkerCluster().add_to(m)
for lat, lon in coordinates:
    folium.Marker([lat, lon]).add_to(mc)
```

## Layer Control
```python
fg1 = folium.FeatureGroup(name='Layer 1').add_to(m)
fg2 = folium.FeatureGroup(name='Layer 2').add_to(m)
folium.LayerControl().add_to(m)
```

## Key Features
- Leaflet.js wrapper
- Jupyter notebook integration
- Multiple tile providers
- Plugin ecosystem
- GeoJSON/TopoJSON support