# NPL-FIM: panel
🎛️ Framework for building interactive dashboards and apps

## Installation
```bash
pip install panel
pip install bokeh  # Required dependency
pip install pandas numpy  # Recommended
```

## Basic Usage
```python
import panel as pn
import numpy as np
pn.extension('bokeh')

# Simple app
slider = pn.widgets.FloatSlider(name='Frequency', value=1, start=0.1, end=5)
def sine_wave(freq):
    x = np.linspace(0, 4*np.pi, 100)
    y = np.sin(freq * x)
    return pn.pane.Matplotlib(plt.plot(x, y)[0].figure)

app = pn.Column(
    '# Sine Wave Dashboard',
    slider,
    pn.bind(sine_wave, slider)
)
app.servable()  # For deployment
app  # Display in notebook

# Template-based app
template = pn.template.FastListTemplate(
    title='Dashboard',
    sidebar=[slider],
    main=[pn.bind(sine_wave, slider)]
)
template.servable()
```

## Jupyter Integration
```python
# Display in notebook
pn.extension()
app.show()

# Export to HTML
app.save('dashboard.html')

# Serve as web app
app.show(port=5006)

# Interactive updates
button = pn.widgets.Button(name='Click me')
output = pn.pane.Markdown('Status: Ready')

def update(_):
    output.object = 'Status: Clicked!'

button.on_click(update)
pn.Row(button, output)
```

## Components
- Panes: Matplotlib, Plotly, Bokeh, Vega, HTML
- Widgets: Slider, Select, TextInput, FileInput
- Layouts: Row, Column, Tabs, GridSpec
- Templates: Material, Bootstrap, Fast, Vanilla

## FIM Context
Full-featured dashboard framework, supports multiple viz libraries