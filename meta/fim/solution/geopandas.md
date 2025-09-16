# GeoPandas

Python library extending pandas for spatial operations.

## Installation
```bash
pip install geopandas
# Or with conda
conda install -c conda-forge geopandas
```

## Read Spatial Data
```python
import geopandas as gpd

gdf = gpd.read_file('data.shp')
gdf = gpd.read_file('data.geojson')
gdf = gpd.read_file('data.gpkg')
```

## Create GeoDataFrame
```python
from shapely.geometry import Point
import pandas as pd

df = pd.DataFrame({
    'city': ['Seattle', 'Portland', 'San Francisco'],
    'lat': [47.6062, 45.5152, 37.7749],
    'lon': [-122.3321, -122.6784, -122.4194]
})

geometry = [Point(xy) for xy in zip(df.lon, df.lat)]
gdf = gpd.GeoDataFrame(df, geometry=geometry, crs='EPSG:4326')
```

## Projection
```python
# Convert to Web Mercator
gdf_mercator = gdf.to_crs('EPSG:3857')
# Convert to UTM
gdf_utm = gdf.to_crs('EPSG:32610')
```

## Spatial Operations
```python
# Buffer
gdf['buffer'] = gdf.geometry.buffer(1000)

# Intersection
intersection = gdf1.overlay(gdf2, how='intersection')

# Union
union = gdf1.overlay(gdf2, how='union')

# Spatial join
joined = gpd.sjoin(points, polygons, how='inner', predicate='within')
```

## Area & Length
```python
# Project to equal area projection first
gdf_projected = gdf.to_crs('EPSG:3857')
gdf_projected['area'] = gdf_projected.geometry.area
gdf_projected['length'] = gdf_projected.geometry.length
```

## Plotting
```python
gdf.plot(column='value', cmap='viridis', legend=True, figsize=(10, 8))

# Multiple layers
ax = gdf1.plot(color='blue', alpha=0.5)
gdf2.plot(ax=ax, color='red', alpha=0.5)
```

## Write Output
```python
gdf.to_file('output.shp')
gdf.to_file('output.geojson', driver='GeoJSON')
gdf.to_file('output.gpkg', driver='GPKG')
```

## Key Features
- Pandas integration
- Shapely geometries
- Fiona I/O
- CRS transformations
- Spatial indexing with rtree