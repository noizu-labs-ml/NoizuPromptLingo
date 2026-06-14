# NPL-FIM: altair
📈 Declarative statistical visualization based on Vega-Lite

## Overview
Altair is a declarative statistical visualization library for Python, based on Vega-Lite. It provides a powerful yet simple grammar of graphics approach that enables users to build a wide range of statistical visualizations quickly and intuitively. Altair transforms Python code into Vega-Lite JSON specifications, which are then rendered as interactive web-based visualizations.

## Official Documentation & Resources
- **Official Documentation**: https://altair-viz.github.io/
- **GitHub Repository**: https://github.com/altair-viz/altair
- **Example Gallery**: https://altair-viz.github.io/gallery/
- **Vega-Lite Documentation**: https://vega.github.io/vega-lite/
- **PyPI Package**: https://pypi.org/project/altair/
- **Paper**: "Altair: Interactive Statistical Visualizations for Python" (2018)

## License Information
Licensed under BSD-3-Clause License, allowing commercial and open-source use with attribution.

## Installation & Environment Requirements

### Basic Installation
```bash
pip install altair
pip install pandas  # Required for data handling
```

### Extended Installation
```bash
pip install altair[all]  # Includes all optional dependencies
pip install altair_viewer  # For display outside notebooks
pip install altair_saver  # For saving as PNG/SVG
pip install vl-convert-python  # Fast conversion backend
```

### Version Compatibility
- **Python**: 3.7+ (3.8+ recommended)
- **Altair**: 4.0+ (5.0+ for latest features)
- **Pandas**: 1.0+ (2.0+ recommended)
- **Jupyter**: Lab 3.0+ or Notebook 6.0+
- **Browser**: Modern browsers with JavaScript enabled

### Environment Setup
```python
import altair as alt
import pandas as pd
import numpy as np

# Configure for your environment
alt.data_transformers.enable('json')  # Default
alt.renderers.enable('default')  # Auto-detect best renderer
```

## Basic Usage
```python
import altair as alt
import pandas as pd

# Sample data
data = pd.DataFrame({
    'x': range(10),
    'y': [2**i for i in range(10)],
    'category': ['A', 'B'] * 5
})

# Simple scatter plot
chart = alt.Chart(data).mark_point().encode(
    x='x:Q', y='y:Q', color='category:N'
).properties(title='Exponential Growth')

chart.show()
```

## Core Concepts & Grammar

### Chart Components
- **Data**: Input dataset (DataFrame, URL, or inline)
- **Mark**: Visual representation (point, line, bar, area, etc.)
- **Encoding**: Mapping data to visual properties (position, color, size)
- **Transform**: Data transformations (filter, aggregate, calculate)
- **Selection**: Interactive behaviors and brushing
- **Composition**: Combining charts (layer, facet, concatenate)

### Data Types & Encoding
```python
# Data type specifications
'column:Q'  # Quantitative (continuous numeric)
'column:O'  # Ordinal (ordered categorical)
'column:N'  # Nominal (unordered categorical)
'column:T'  # Temporal (datetime)
'column:G'  # Geojson (geographic data)

# Encoding channels
x='column:Q'          # X-axis position
y='column:Q'          # Y-axis position
color='column:N'      # Color encoding
size='column:Q'       # Size encoding
shape='column:N'      # Shape encoding
opacity='column:Q'    # Opacity encoding
tooltip=['col1', 'col2']  # Tooltip information
```

### Mark Types
```python
# Basic marks
.mark_point()         # Scatter plot points
.mark_line()          # Line chart
.mark_bar()           # Bar chart
.mark_area()          # Area chart
.mark_text()          # Text labels
.mark_tick()          # Tick marks

# Statistical marks
.mark_boxplot()       # Box-and-whisker plots
.mark_errorbar()      # Error bars
.mark_errorband()     # Error bands
.mark_rule()          # Reference lines

# Advanced marks
.mark_geoshape()      # Geographic shapes
.mark_image()         # Images
.mark_rect()          # Rectangles (heatmaps)
.mark_trail()         # Connected scatterplot
```

## Advanced Features

### Transformations
```python
# Data transformations
chart = alt.Chart(data).transform_filter(
    alt.datum.value > 10
).transform_calculate(
    log_y='log(datum.y)'
).transform_aggregate(
    mean_y='mean(y)',
    groupby=['category']
).transform_window(
    rolling_mean='mean(y)',
    frame=[-2, 2]
)
```

### Interactive Selections
```python
# Single selection
click = alt.selection_single()

# Multi selection
brush = alt.selection_multi()

# Interval selection (brushing)
interval = alt.selection_interval(bind='scales')

# Parameter-based selection (Altair 5+)
slider = alt.param(value=50, bind=alt.binding_range(min=0, max=100))

# Using selections
chart = alt.Chart(data).mark_point().encode(
    x='x:Q',
    y='y:Q',
    color=alt.condition(click, 'category:N', alt.value('lightgray'))
).add_selection(click)
```

### Chart Composition
```python
# Layering
base = alt.Chart(data)
points = base.mark_point().encode(x='x:Q', y='y:Q')
line = base.mark_line().encode(x='x:Q', y='mean(y):Q')
layered = points + line

# Faceting
faceted = alt.Chart(data).mark_point().encode(
    x='x:Q', y='y:Q'
).facet(
    column='category:N',
    columns=2
)

# Concatenation
chart1 = alt.Chart(data).mark_point().encode(x='x:Q', y='y:Q')
chart2 = alt.Chart(data).mark_bar().encode(x='category:N', y='count():Q')
combined = alt.hconcat(chart1, chart2)  # Horizontal
combined = alt.vconcat(chart1, chart2)  # Vertical
```

### Geographic Visualizations
```python
# Choropleth map
states = alt.topo_feature(data.us_10m.url, 'states')
chart = alt.Chart(states).mark_geoshape().encode(
    color='unemployment:Q'
).project(
    type='albersUsa'
).properties(
    width=700,
    height=400
)
```

### Custom Scales and Axes
```python
chart = alt.Chart(data).mark_point().encode(
    x=alt.X('x:Q',
        scale=alt.Scale(domain=[0, 100], type='log'),
        axis=alt.Axis(title='Log Scale X', grid=True)
    ),
    y=alt.Y('y:Q',
        scale=alt.Scale(scheme='viridis'),
        axis=alt.Axis(title='Y Values', format='.2f')
    ),
    color=alt.Color('category:N',
        scale=alt.Scale(range=['red', 'blue']),
        legend=alt.Legend(title='Categories')
    )
)
```

## Data Handling & Sources

### Data Sources
```python
# Pandas DataFrame
chart = alt.Chart(df)

# URL data source
chart = alt.Chart('https://raw.githubusercontent.com/vega/vega-datasets/master/data/cars.json')

# Built-in datasets
from vega_datasets import data
chart = alt.Chart(data.cars())

# Inline data
chart = alt.Chart({
    'values': [{'x': 1, 'y': 2}, {'x': 2, 'y': 4}]
})
```

### Data Size Limits
```python
# Handle large datasets
alt.data_transformers.enable('json')  # Default (5000 rows)
alt.data_transformers.enable('csv')   # For larger datasets
alt.data_transformers.enable('data_server')  # Local server

# Custom limits
alt.data_transformers.disable_max_rows()
```

## Output & Export Options

### Jupyter Integration
```python
# Rendering options
alt.renderers.enable('default')     # Auto-detect
alt.renderers.enable('notebook')    # Jupyter Notebook
alt.renderers.enable('jupyterlab')  # JupyterLab
alt.renderers.enable('nteract')     # nteract
alt.renderers.enable('colab')       # Google Colab
```

### Saving Charts
```python
# Save as various formats
chart.save('chart.html')                    # Interactive HTML
chart.save('chart.png', scale_factor=2.0)   # High-res PNG
chart.save('chart.svg')                     # Vector SVG
chart.save('chart.pdf')                     # PDF format
chart.save('chart.json')                    # Vega-Lite JSON

# With custom configuration
chart.save('chart.png',
           width=800,
           height=600,
           webdriver='chrome')
```

### Programmatic Access
```python
# Get Vega-Lite specification
spec = chart.to_dict()
json_spec = chart.to_json()

# Render to various formats
html = chart._repr_html_()
mimebundle = chart._repr_mimebundle_()
```

## Theming & Customization

### Built-in Themes
```python
# Available themes
alt.themes.enable('default')
alt.themes.enable('opaque')
alt.themes.enable('none')
alt.themes.enable('dark')
alt.themes.enable('excel')
alt.themes.enable('ggplot2')
alt.themes.enable('quartz')
alt.themes.enable('vox')
alt.themes.enable('urbaninstitute')
alt.themes.enable('googlecharts')
alt.themes.enable('latimes')
alt.themes.enable('powerbi')
```

### Custom Themes
```python
def custom_theme():
    return {
        'config': {
            'view': {'stroke': 'transparent'},
            'axis': {'labelFontSize': 12, 'titleFontSize': 14},
            'legend': {'labelFontSize': 12, 'titleFontSize': 14},
            'header': {'labelFontSize': 12, 'titleFontSize': 14},
            'mark': {'font': 'Arial'},
            'title': {'fontSize': 16, 'anchor': 'start'}
        }
    }

alt.themes.register('custom', custom_theme)
alt.themes.enable('custom')
```

## Performance Optimization

### Efficient Data Handling
```python
# Sample large datasets
sampled_chart = alt.Chart(large_df.sample(n=1000))

# Use data transformations server-side
chart = alt.Chart(url).transform_aggregate(
    mean_value='mean(value)',
    groupby=['category']
)

# Optimize encoding for performance
chart = alt.Chart(data).mark_point(
    size=60,  # Fixed size instead of encoding
    opacity=0.7
).encode(
    x='x:Q',
    y='y:Q'
)
```

### Memory Management
```python
# Clear data transformer cache
alt.data_transformers.disable_max_rows()

# Use generators for large datasets
def data_generator():
    for chunk in pd.read_csv('large_file.csv', chunksize=1000):
        yield chunk

# Streaming approach
for chunk in data_generator():
    chart = alt.Chart(chunk).mark_point().encode(x='x:Q', y='y:Q')
    display(chart)
```

## Integration Examples

### Pandas Integration
```python
import pandas as pd
import altair as alt

# Direct from pandas
df = pd.read_csv('data.csv')
chart = alt.Chart(df).mark_point().encode(
    x='column1:Q',
    y='column2:Q',
    color='category:N'
)

# With pandas operations
chart = alt.Chart(
    df.groupby('category').mean().reset_index()
).mark_bar().encode(
    x='category:N',
    y='value:Q'
)
```

### NumPy Integration
```python
import numpy as np

# Generate synthetic data
x = np.linspace(0, 10, 100)
y = np.sin(x) + np.random.normal(0, 0.1, 100)
df = pd.DataFrame({'x': x, 'y': y})

chart = alt.Chart(df).mark_line().encode(
    x='x:Q',
    y='y:Q'
)
```

### Streamlit Integration
```python
import streamlit as st
import altair as alt

# In Streamlit app
st.altair_chart(chart, use_container_width=True)

# Interactive widgets
selection = st.selectbox('Choose category', df['category'].unique())
filtered_data = df[df['category'] == selection]
chart = alt.Chart(filtered_data).mark_point().encode(x='x:Q', y='y:Q')
st.altair_chart(chart)
```

### Dash Integration
```python
import dash
from dash import dcc, html
import json

# Convert Altair to Plotly
app = dash.Dash(__name__)
app.layout = html.Div([
    dcc.Graph(
        figure=chart.to_dict()
    )
])
```

## Common Patterns & Recipes

### Statistical Visualizations
```python
# Distribution plots
histogram = alt.Chart(data).mark_bar().encode(
    alt.X('value:Q', bin=alt.Bin(maxbins=30)),
    y='count()'
)

# Box plots with outliers
box_plot = alt.Chart(data).mark_boxplot(
    extent='min-max'
).encode(
    x='category:N',
    y='value:Q'
)

# Regression line
scatter = alt.Chart(data).mark_point().encode(x='x:Q', y='y:Q')
line = scatter.transform_regression('x', 'y').mark_line()
regression = scatter + line
```

### Time Series
```python
# Time series plot
time_chart = alt.Chart(time_data).mark_line().encode(
    x=alt.X('date:T', axis=alt.Axis(format='%Y-%m')),
    y='value:Q',
    color='series:N'
).properties(
    width=600,
    height=300
)

# Time series with confidence bands
base = alt.Chart(time_data)
line = base.mark_line().encode(x='date:T', y='mean(value):Q')
band = base.mark_area(opacity=0.3).encode(
    x='date:T',
    y='ci0(value):Q',
    y2='ci1(value):Q'
)
time_series = line + band
```

### Dashboard-style Compositions
```python
# Multi-chart dashboard
def create_dashboard(data):
    # Summary statistics
    summary = alt.Chart(data).mark_text(
        fontSize=20, fontWeight='bold'
    ).encode(
        text='mean(value):Q'
    ).properties(
        title='Average Value',
        width=150,
        height=100
    )

    # Main chart
    main_chart = alt.Chart(data).mark_point().encode(
        x='x:Q', y='y:Q', color='category:N'
    ).properties(
        width=400,
        height=300
    )

    # Distribution
    dist = alt.Chart(data).mark_bar().encode(
        x=alt.X('value:Q', bin=True),
        y='count()'
    ).properties(
        width=200,
        height=150
    )

    # Combine
    top_row = alt.hconcat(summary, dist)
    dashboard = alt.vconcat(top_row, main_chart)

    return dashboard
```

## Troubleshooting & Common Issues

### Rendering Problems
```python
# Check renderer status
alt.renderers.active

# Reset to default
alt.renderers.enable('default')

# Force specific renderer
alt.renderers.enable('notebook')

# Debug mode
alt.data_transformers.enable('json', urlpath='data')
```

### Data Issues
```python
# Handle missing values
chart = alt.Chart(data.dropna()).mark_point().encode(x='x:Q', y='y:Q')

# Data type issues
data['date'] = pd.to_datetime(data['date'])
chart = alt.Chart(data).mark_line().encode(x='date:T', y='value:Q')

# Large dataset handling
alt.data_transformers.disable_max_rows()
```

### Performance Issues
```python
# Optimize for large datasets
chart = alt.Chart(data.sample(n=5000)).mark_point(
    size=30,
    opacity=0.5
).encode(
    x='x:Q',
    y='y:Q'
).resolve_scale(
    color='independent'
)
```

## Best For
- **Exploratory Data Analysis**: Quick, interactive visualizations for data exploration
- **Statistical Visualizations**: Grammar of graphics approach for complex statistical plots
- **Jupyter Notebooks**: Seamless integration with scientific Python ecosystem
- **Web-based Dashboards**: Interactive visualizations that export to web formats
- **Academic Research**: Publication-quality plots with precise control over aesthetics
- **Business Intelligence**: Interactive dashboards with filtering and selection capabilities
- **Geographic Analysis**: Built-in support for choropleth maps and geographic projections
- **Time Series Analysis**: Sophisticated temporal visualizations with brushing and zooming
- **Multi-dimensional Data**: Faceting and small multiples for complex datasets
- **Prototyping**: Rapid iteration on visualization designs with declarative syntax

## Strengths
- **Declarative Syntax**: Intuitive grammar of graphics approach that maps directly to visualization intent
- **Vega-Lite Foundation**: Built on robust, well-specified visualization grammar with extensive documentation
- **Interactive Features**: Native support for selections, brushing, linking, and dynamic filtering
- **JSON Export**: Charts compile to portable Vega-Lite JSON specifications for web deployment
- **Jupyter Integration**: Seamless notebook integration with multiple rendering backends
- **Statistical Focus**: Excellent support for statistical transformations and aggregations
- **Composition System**: Powerful layering, faceting, and concatenation for complex visualizations
- **Web Standards**: Outputs web-compatible visualizations using SVG and Canvas
- **Theme System**: Rich theming capabilities with built-in professional themes
- **Data Handling**: Flexible data input from pandas, URLs, JSON, and streaming sources
- **Geographic Support**: Built-in choropleth mapping and cartographic projections
- **Performance Optimization**: Efficient data transformations and sampling for large datasets
- **Type Safety**: Strong data type system prevents common visualization errors
- **Documentation**: Comprehensive documentation with extensive gallery of examples
- **Active Development**: Regular updates and active community support

## Limitations
- **Learning Curve**: Grammar of graphics paradigm requires conceptual shift from traditional plotting libraries
- **Customization Constraints**: Less fine-grained control compared to matplotlib for pixel-perfect designs
- **JavaScript Dependency**: Requires JavaScript runtime for rendering, limiting some deployment scenarios
- **Large Dataset Performance**: Can struggle with datasets exceeding memory limits without preprocessing
- **3D Limitations**: No native support for 3D visualizations or volumetric rendering
- **Animation Constraints**: Limited animation capabilities compared to D3.js or specialized animation libraries
- **Styling Limitations**: CSS-level styling control is more limited than direct SVG manipulation
- **Backend Dependencies**: Some export formats require additional system dependencies (Chrome, Node.js)
- **Memory Usage**: JSON serialization can be memory-intensive for large datasets
- **Debugging Complexity**: Error messages can be cryptic when Vega-Lite compilation fails
- **Mobile Responsiveness**: Limited built-in responsive design features for mobile devices
- **Print Optimization**: Web-first design may require additional work for print publication quality
- **Real-time Updates**: Not optimized for high-frequency real-time data streaming
- **Custom Mark Types**: Extending with completely custom mark types requires Vega knowledge
- **Computational Limits**: Client-side data processing constraints for very large analytical operations

## FIM Context

### Integration Patterns for AI-Assisted Development

Altair's declarative syntax makes it particularly well-suited for AI-assisted visualization development. The grammar of graphics approach provides clear semantic structure that can be easily understood and generated by AI systems.

#### Code Generation Patterns
```python
# Template for AI-generated visualizations
def create_chart_template(data_source, chart_type, encodings, properties=None):
    """
    Template function for AI-generated Altair charts

    Args:
        data_source: DataFrame or URL
        chart_type: mark type (point, line, bar, etc.)
        encodings: dict of encoding mappings
        properties: optional chart properties
    """
    chart = alt.Chart(data_source)

    # Dynamic mark selection
    mark_method = getattr(chart, f'mark_{chart_type}')
    chart = mark_method()

    # Apply encodings
    chart = chart.encode(**encodings)

    # Apply properties if provided
    if properties:
        chart = chart.properties(**properties)

    return chart

# Example AI-generated usage
chart = create_chart_template(
    data_source=df,
    chart_type='point',
    encodings={'x': 'height:Q', 'y': 'weight:Q', 'color': 'species:N'},
    properties={'title': 'Height vs Weight by Species', 'width': 400}
)
```

#### Semantic Understanding for AI
- **Data Types**: The `:Q`, `:N`, `:O`, `:T` suffix system provides clear semantic meaning for AI interpretation
- **Encoding Channels**: Standardized mapping from data to visual properties (position, color, size, shape)
- **Transformation Pipeline**: Clear sequence of data transformations that can be programmatically constructed
- **Composition Operators**: `+`, `|`, `&` operators for layering, faceting, and combining charts
- **Selection Grammar**: Declarative interaction specification that can be systematically generated

#### AI-Friendly Design Patterns
```python
# Structured approach for AI code generation
class AltairChartBuilder:
    def __init__(self, data):
        self.data = data
        self.chart = alt.Chart(data)
        self.layers = []

    def add_mark(self, mark_type, **mark_props):
        """Add a mark with properties"""
        mark_method = getattr(alt.Chart(self.data), f'mark_{mark_type}')
        layer = mark_method(**mark_props)
        self.layers.append(layer)
        return self

    def add_encoding(self, layer_idx, **encodings):
        """Add encodings to specific layer"""
        self.layers[layer_idx] = self.layers[layer_idx].encode(**encodings)
        return self

    def add_transform(self, layer_idx, transform_type, **params):
        """Add transformation to specific layer"""
        transform_method = getattr(self.layers[layer_idx], f'transform_{transform_type}')
        self.layers[layer_idx] = transform_method(**params)
        return self

    def compose(self, composition_type='layer'):
        """Compose layers using specified method"""
        if composition_type == 'layer':
            return sum(self.layers[1:], self.layers[0])
        elif composition_type == 'hconcat':
            return alt.hconcat(*self.layers)
        elif composition_type == 'vconcat':
            return alt.vconcat(*self.layers)
```

#### Natural Language to Code Mapping
Common visualization requests and their Altair implementations:

**"Show me a scatter plot of X vs Y colored by category"**
```python
alt.Chart(data).mark_point().encode(
    x='X:Q', y='Y:Q', color='category:N'
)
```

**"Create a line chart showing trends over time"**
```python
alt.Chart(data).mark_line().encode(
    x='date:T', y='value:Q'
)
```

**"Make a bar chart with error bars"**
```python
bars = alt.Chart(data).mark_bar().encode(x='category:N', y='mean(value):Q')
errors = alt.Chart(data).mark_errorbar().encode(
    x='category:N', y='ci0(value):Q', y2='ci1(value):Q'
)
bars + errors
```

#### Debugging and Validation Patterns
```python
def validate_altair_chart(chart):
    """
    Validation function for AI-generated charts
    """
    try:
        # Check if chart compiles to valid Vega-Lite
        spec = chart.to_dict()

        # Validate required fields
        required_fields = ['mark', 'encoding']
        for field in required_fields:
            if field not in spec:
                return False, f"Missing required field: {field}"

        # Check data reference
        if 'data' not in spec and not hasattr(chart, 'data'):
            return False, "No data source specified"

        return True, "Chart validation successful"

    except Exception as e:
        return False, f"Chart validation failed: {str(e)}"

# Usage in AI development workflow
chart = generate_chart_from_prompt(user_prompt, data)
is_valid, message = validate_altair_chart(chart)
if not is_valid:
    chart = fix_chart_issues(chart, message)
```

#### Performance Considerations for AI Development
- **Data Sampling**: Automatically sample large datasets to reasonable sizes for interactive development
- **Progressive Enhancement**: Start with basic charts and add complexity incrementally
- **Caching Strategies**: Cache compiled Vega-Lite specifications for repeated use
- **Batch Processing**: Generate multiple chart variations efficiently

#### Version Control and Reproducibility
```python
def export_chart_config(chart, metadata=None):
    """
    Export chart configuration for version control
    """
    config = {
        'altair_version': alt.__version__,
        'vega_lite_spec': chart.to_dict(),
        'creation_timestamp': datetime.now().isoformat(),
        'metadata': metadata or {}
    }
    return config

def load_chart_config(config):
    """
    Recreate chart from configuration
    """
    spec = config['vega_lite_spec']
    return alt.Chart.from_dict(spec)
```

This comprehensive guide positions Altair as a powerful tool for AI-assisted data visualization development, emphasizing its declarative nature, semantic clarity, and systematic approach to building complex visualizations through composition and transformation patterns.