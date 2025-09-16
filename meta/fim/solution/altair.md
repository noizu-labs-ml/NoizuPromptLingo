# NPL-FIM: altair
📈 Declarative statistical visualization based on Vega-Lite

## Installation
```bash
pip install altair
pip install pandas
pip install altair_viewer  # For display outside notebooks
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

# Declarative syntax
chart = alt.Chart(data).mark_point().encode(
    x='x:Q',  # Quantitative
    y='y:Q',
    color='category:N',  # Nominal
    size=alt.value(100)
).properties(
    title='Exponential Growth',
    width=400,
    height=300
)

chart.show()  # or chart in Jupyter

# Layered chart
points = alt.Chart(data).mark_point().encode(x='x', y='y')
line = alt.Chart(data).mark_line().encode(x='x', y='y')
combined = points + line
```

## Jupyter Integration
```python
# Enable rendering
alt.renderers.enable('notebook')

# Save charts
chart.save('chart.html')
chart.save('chart.png')  # Requires altair_saver
chart.save('chart.svg')

# Interactive selections
selection = alt.selection_single()
chart = alt.Chart(data).mark_point().encode(
    x='x', y='y',
    color=alt.condition(selection, 'category', alt.value('lightgray'))
).add_selection(selection)
```

## Chart Types
- Marks: `mark_point()`, `mark_line()`, `mark_bar()`, `mark_area()`
- Statistical: `mark_boxplot()`, `mark_errorband()`
- Geographic: `mark_geoshape()`
- Faceting: `facet()`, `repeat()`, `concat()`

## FIM Context
Grammar of graphics approach, outputs Vega-Lite JSON specifications