# NPL-FIM: dash
⚡ Reactive web applications for Python

## Installation
```bash
pip install dash
pip install pandas  # Recommended
pip install dash-bootstrap-components  # For themes
```

## Basic Usage
```python
import dash
from dash import dcc, html, Input, Output
import plotly.express as px
import pandas as pd

# Initialize app
app = dash.Dash(__name__)

# Sample data
df = pd.DataFrame({
    'x': range(10),
    'y': [i**2 for i in range(10)],
    'category': ['A', 'B'] * 5
})

# Layout
app.layout = html.Div([
    html.H1('Dashboard Title'),
    dcc.Dropdown(
        id='dropdown',
        options=[{'label': i, 'value': i} for i in df['category'].unique()],
        value='A'
    ),
    dcc.Graph(id='graph'),
    dcc.Slider(id='slider', min=0, max=10, value=5, marks={i: str(i) for i in range(11)})
])

# Callbacks
@app.callback(
    Output('graph', 'figure'),
    [Input('dropdown', 'value'), Input('slider', 'value')]
)
def update_graph(category, slider_value):
    filtered_df = df[df['category'] == category]
    filtered_df = filtered_df[filtered_df['x'] <= slider_value]
    fig = px.scatter(filtered_df, x='x', y='y', title=f'Category: {category}')
    return fig

if __name__ == '__main__':
    app.run_server(debug=True)
```

## Components
```python
# Core components
dcc.Graph()  # Plotly charts
dcc.Dropdown(), dcc.Slider(), dcc.Input()
dcc.Markdown(), dcc.Upload()
dcc.Store()  # Client-side storage

# HTML components
html.Div(), html.H1(), html.P()
html.Button(), html.Table()

# Bootstrap components
import dash_bootstrap_components as dbc
dbc.Card(), dbc.Row(), dbc.Col()
```

## Advanced Features
```python
# Multiple outputs
@app.callback(
    [Output('graph1', 'figure'), Output('graph2', 'figure')],
    Input('input', 'value')
)

# State without triggering
from dash import State
@app.callback(
    Output('output', 'children'),
    Input('button', 'n_clicks'),
    State('input', 'value')
)

# Client-side callbacks for performance
app.clientside_callback(...)
```

## FIM Context
Production-ready dashboards with React.js frontend, ideal for complex interactions