# NPL-FIM: plotly-python
🎯 Interactive plotting library with web-based output

## Installation
```bash
pip install plotly
pip install pandas  # Recommended
pip install kaleido  # For static image export
```

## Basic Usage
```python
import plotly.graph_objects as go
import plotly.express as px
import pandas as pd

# Express API (high-level)
df = px.data.iris()
fig = px.scatter(df, x='sepal_width', y='sepal_length',
                 color='species', size='petal_length',
                 hover_data=['petal_width'])
fig.show()

# Graph Objects API (low-level)
fig = go.Figure()
fig.add_trace(go.Scatter(x=[1, 2, 3, 4], y=[10, 11, 12, 13],
                         mode='lines+markers', name='trace1'))
fig.add_trace(go.Bar(x=[1, 2, 3, 4], y=[5, 6, 7, 8], name='trace2'))
fig.update_layout(title='Mixed Plot', xaxis_title='X', yaxis_title='Y')
fig.show()

# 3D plots
fig = px.scatter_3d(df, x='sepal_length', y='sepal_width',
                    z='petal_width', color='species')
fig.show()
```

## Jupyter Integration
```python
# Inline display
fig.show()

# Save as HTML
fig.write_html('plot.html')

# Save as static image
fig.write_image('plot.png')

# Interactive widgets
from plotly import graph_objects as go
from ipywidgets import widgets
```

## Plot Types
- Scatter, Line, Bar, Pie
- 3D Scatter, Surface, Mesh
- Maps: `scatter_geo()`, `choropleth()`
- Statistical: Box, Violin, Histogram
- Heatmaps, Contour plots
- Subplots: `make_subplots()`

## FIM Context
Interactive plots with zoom, pan, hover; exports to web-friendly formats