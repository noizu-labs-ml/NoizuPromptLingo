# NPL-FIM: pandas-plotting
🐼 Built-in plotting functionality in pandas DataFrames

## Installation
```bash
pip install pandas
pip install matplotlib  # Backend for plotting
```

## Basic Usage
```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Create sample DataFrame
df = pd.DataFrame({
    'A': np.random.randn(100).cumsum(),
    'B': np.random.randn(100).cumsum(),
    'C': np.random.randn(100).cumsum(),
    'category': np.random.choice(['X', 'Y', 'Z'], 100)
})

# Direct plotting
df.plot()  # Line plot of all columns
df.plot(kind='scatter', x='A', y='B')
df.plot(kind='bar', x='category', y='A')
df['A'].plot(kind='hist', bins=20)
df.plot(kind='box')
df.plot(kind='area', stacked=True)
df.plot(kind='pie', y='A')

# Groupby plotting
df.groupby('category')['A'].mean().plot(kind='bar')
df.groupby('category').sum().plot(kind='barh')

# Styling
df.plot(figsize=(10, 6),
        title='Time Series',
        xlabel='Time',
        ylabel='Value',
        legend=True,
        grid=True,
        style=['--', '-.', ':'])
```

## Plot Types
```python
# Available via kind parameter
df.plot(kind='line')     # Default
df.plot(kind='bar')       # Vertical bars
df.plot(kind='barh')      # Horizontal bars
df.plot(kind='hist')      # Histogram
df.plot(kind='box')       # Boxplot
df.plot(kind='kde')       # Kernel density
df.plot(kind='area')      # Area plot
df.plot(kind='pie')       # Pie chart
df.plot(kind='scatter')   # Scatter plot
df.plot(kind='hexbin')    # Hexagonal bin plot
```

## Advanced Features
```python
# Subplots
df.plot(subplots=True, layout=(2, 2), figsize=(10, 8))

# Secondary y-axis
ax = df['A'].plot()
df['B'].plot(ax=ax, secondary_y=True)

# Backend selection
df.plot(backend='plotly')  # If plotly installed
pd.options.plotting.backend = 'plotly'
```

## FIM Context
Quick exploratory plots directly from DataFrames, minimal code required