# NPL-FIM: holoviews
🔄 Data analysis and visualization with automatic plots

## Installation
```bash
pip install holoviews
pip install bokeh  # Default backend
pip install matplotlib plotly  # Additional backends
pip install pandas numpy
```

## Basic Usage
```python
import holoviews as hv
import pandas as pd
import numpy as np
hv.extension('bokeh')  # or 'matplotlib', 'plotly'

# Simple plot
xs = np.linspace(0, np.pi*4, 100)
curve = hv.Curve((xs, np.sin(xs)), 'x', 'y')
curve

# Overlays and layouts
curve2 = hv.Curve((xs, np.cos(xs)), 'x', 'y')
overlay = curve * curve2  # Overlay
layout = curve + curve2   # Side-by-side

# Data exploration
df = pd.DataFrame({
    'x': np.random.randn(1000),
    'y': np.random.randn(1000),
    'category': np.random.choice(['A', 'B', 'C'], 1000)
})

points = hv.Points(df, ['x', 'y'], ['category'])
points.opts(color='category', size=5, tools=['hover'])
```

## Jupyter Integration
```python
# Interactive widgets
hv.extension('bokeh', width=100)

# DynamicMap for large datasets
def sine_curve(freq):
    xs = np.linspace(0, np.pi*4, 100)
    return hv.Curve((xs, np.sin(xs*freq)), 'x', 'y')

dmap = hv.DynamicMap(sine_curve, kdims=['freq'])
dmap.redim.range(freq=(1, 10))

# Save outputs
hv.save(curve, 'plot.html')
hv.save(curve, 'plot.png', backend='matplotlib')
```

## Data Structures
- Elements: Curve, Points, Image, Bars
- Containers: Overlay (*), Layout (+), GridSpace
- Operations: `groupby()`, `reduce()`, `aggregate()`
- Pipelines: `datashade()`, `rasterize()` for big data

## FIM Context
Declarative data visualization, seamless switching between backends