# Kepler.gl

Powerful geospatial analytics tool for large-scale data visualization.

## Installation
```bash
npm install kepler.gl redux react-redux
```

## React Component
```javascript
import KeplerGl from 'kepler.gl';
import {addDataToMap} from 'kepler.gl/actions';

const Map = () => (
  <KeplerGl
    id="map"
    mapboxApiAccessToken={MAPBOX_TOKEN}
    width={window.innerWidth}
    height={window.innerHeight}
  />
);
```

## Redux Setup
```javascript
import keplerGlReducer from 'kepler.gl/reducers';
import {createStore, combineReducers} from 'redux';

const reducer = combineReducers({
  keplerGl: keplerGlReducer
});

const store = createStore(reducer);
```

## Load Data
```javascript
const data = {
  datasets: [{
    info: {
      label: 'Dataset',
      id: 'dataset_1'
    },
    data: {
      fields: [
        {name: 'lat', type: 'real'},
        {name: 'lng', type: 'real'},
        {name: 'value', type: 'integer'}
      ],
      rows: [
        [37.7749, -122.4194, 100],
        [40.7128, -74.0060, 200]
      ]
    }
  }]
};

dispatch(addDataToMap(data));
```

## Configuration
```javascript
const config = {
  visState: {
    filters: [],
    layers: [{
      type: 'point',
      config: {
        dataId: 'dataset_1',
        columns: {
          lat: 'lat',
          lng: 'lng'
        },
        visConfig: {
          radius: 10,
          color: [255, 0, 0]
        }
      }
    }]
  }
};
```

## Export Map
```javascript
import {exportImageModal} from 'kepler.gl/actions';

dispatch(exportImageModal());
```

## Python Integration
```python
from keplergl import KeplerGl
map = KeplerGl(height=600, data={'data': df})
map.save_to_html(file_name='map.html')
```

## Key Features
- No-code data exploration
- Time-series animations
- Advanced filtering
- Multiple layer types
- GPU-accelerated rendering