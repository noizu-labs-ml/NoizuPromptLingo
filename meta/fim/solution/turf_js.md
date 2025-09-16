# Turf.js

Advanced geospatial analysis library for JavaScript.

## Installation
```bash
npm install @turf/turf
```

## Basic Usage
```javascript
import * as turf from '@turf/turf';
// Or specific modules
import { point, distance } from '@turf/turf';
```

## Points & Distance
```javascript
const from = turf.point([-75.343, 39.984]);
const to = turf.point([-75.534, 39.123]);
const dist = turf.distance(from, to, {units: 'miles'});
```

## Buffer
```javascript
const point = turf.point([-90.5, 35.5]);
const buffered = turf.buffer(point, 50, {units: 'kilometers'});
```

## Polygon Operations
```javascript
const poly1 = turf.polygon([[[0,0],[0,10],[10,10],[10,0],[0,0]]]);
const poly2 = turf.polygon([[[5,5],[5,15],[15,15],[15,5],[5,5]]]);

const intersection = turf.intersect(poly1, poly2);
const union = turf.union(poly1, poly2);
const difference = turf.difference(poly1, poly2);
```

## Point in Polygon
```javascript
const pt = turf.point([-77, 44]);
const poly = turf.polygon([[[0,0],[0,100],[100,100],[100,0],[0,0]]]);
const inside = turf.booleanPointInPolygon(pt, poly);
```

## Centroid
```javascript
const polygon = turf.polygon([[[0,0],[0,10],[10,10],[10,0],[0,0]]]);
const centroid = turf.centroid(polygon);
```

## Simplify
```javascript
const complex = turf.lineString([[0,0],[0.1,0.1],[0.2,0.1],[1,1]]);
const simplified = turf.simplify(complex, {tolerance: 0.01});
```

## Spatial Joins
```javascript
const points = turf.featureCollection([...]);
const polygons = turf.featureCollection([...]);
const tagged = turf.tag(points, polygons, 'zone', 'zone_id');
```

## Interpolation
```javascript
const points = turf.randomPoint(30, {bbox: [0, 0, 10, 10]});
const interpolated = turf.interpolate(points, 1, {gridType: 'hex'});
```

## Key Features
- 85+ spatial operations
- No dependencies
- GeoJSON based
- Modular architecture
- Browser and Node.js compatible