# NPL-FIM: ipywidgets
🎮 Interactive widgets for Jupyter notebooks

## Installation
```bash
pip install ipywidgets
# Enable extension
jupyter nbextension enable --py widgetsnbextension
# For JupyterLab
jupyter labextension install @jupyter-widgets/jupyterlab-manager
```

## Basic Usage
```python
import ipywidgets as widgets
from IPython.display import display
import numpy as np
import matplotlib.pyplot as plt

# Basic widgets
slider = widgets.IntSlider(value=50, min=0, max=100, description='Value:')
display(slider)

# Interactive function
@widgets.interact(x=(0, 10, 0.1), y=(0, 10, 0.1))
def plot_func(x=5, y=5):
    plt.figure(figsize=(6, 4))
    t = np.linspace(0, 2*np.pi, 100)
    plt.plot(t, x*np.sin(t) + y*np.cos(t))
    plt.show()

# Manual interaction
def on_value_change(change):
    print(f'New value: {change.new}')

slider.observe(on_value_change, names='value')

# Linked widgets
a = widgets.FloatText()
b = widgets.FloatSlider()
link = widgets.jslink((a, 'value'), (b, 'value'))
display(a, b)
```

## Widget Types
```python
# Input widgets
widgets.Text(description='Name:')
widgets.IntSlider(min=0, max=100)
widgets.FloatSlider(min=0.0, max=10.0)
widgets.Dropdown(options=['A', 'B', 'C'])
widgets.Checkbox(description='Check me')
widgets.RadioButtons(options=['X', 'Y', 'Z'])
widgets.DatePicker()
widgets.ColorPicker()

# Output widgets
output = widgets.Output()
with output:
    print('This goes to output widget')
    plt.plot([1, 2, 3], [4, 5, 6])
    plt.show()

# Layout
widgets.HBox([slider, text])
widgets.VBox([dropdown, button])
widgets.Tab([page1, page2])
widgets.Accordion([section1, section2])
```

## Advanced Features
```python
# Interactive output
from ipywidgets import interact_manual

@interact_manual
def slow_function(x=10):
    # Long computation
    return x**2

# Custom widget
class CounterWidget(widgets.DOMWidget):
    value = widgets.Int(0).tag(sync=True)
```

## FIM Context
Native Jupyter interactivity, bidirectional Python-JavaScript communication