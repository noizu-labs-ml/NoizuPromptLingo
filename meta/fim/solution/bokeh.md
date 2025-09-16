# NPL-FIM: bokeh
🔲 Interactive visualization library for web browsers

## Installation
```bash
pip install bokeh
pip install pandas  # Recommended
```

## Basic Usage
```python
from bokeh.plotting import figure, show, output_file
from bokeh.models import HoverTool
from bokeh.layouts import row, column
import numpy as np

# Basic plot
p = figure(title='Line Plot', x_axis_label='x', y_axis_label='y',
           width=600, height=400)
x = np.linspace(0, 4*np.pi, 100)
y = np.sin(x)
p.line(x, y, legend_label='sin(x)', line_width=2)
p.circle(x[::5], y[::5], size=10, color='red', alpha=0.5)

# Add hover tool
hover = HoverTool(tooltips=[('(x,y)', '($x, $y)')])
p.add_tools(hover)

# Show in browser
show(p)

# Save to file
output_file('plot.html')
show(p)
```

## Jupyter Integration
```python
from bokeh.io import output_notebook, push_notebook
from bokeh.plotting import figure, show

# Enable notebook output
output_notebook()

# Interactive updates
p = figure()
r = p.circle([1, 2, 3], [4, 5, 6])
handle = show(p, notebook_handle=True)

# Update data
r.data_source.data['y'] = [6, 5, 4]
push_notebook(handle=handle)
```

## Advanced Features
```python
# Layouts
from bokeh.layouts import gridplot
plots = [[p1, p2], [p3, p4]]
grid = gridplot(plots)

# Widgets
from bokeh.models.widgets import Slider, Button
slider = Slider(start=0, end=10, value=1, step=0.1, title='Value')

# Server apps
from bokeh.server.server import Server
```

## FIM Context
Browser-based interactive plots, supports streaming data and server apps