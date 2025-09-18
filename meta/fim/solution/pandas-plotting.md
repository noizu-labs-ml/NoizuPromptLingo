# NPL-FIM: pandas-plotting
🐼 Built-in plotting functionality in pandas DataFrames for rapid data visualization

⌜npl-fim|solution|pandas-plotting@2.2.3⌝

## Overview
Pandas provides a comprehensive plotting interface built on matplotlib that enables direct visualization of DataFrame and Series data with minimal code. The `.plot()` accessor offers immediate access to various chart types, statistical plots, and customization options, making it ideal for exploratory data analysis and quick visualization generation.

## Official Documentation
- **Primary Documentation**: https://pandas.pydata.org/docs/user_guide/visualization.html
- **API Reference**: https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.plot.html
- **Plotting Backend Guide**: https://pandas.pydata.org/docs/user_guide/options.html#plotting-backend
- **Matplotlib Integration**: https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.html
- **Gallery Examples**: https://pandas.pydata.org/docs/user_guide/cookbook.html#cookbook-plotting

## License and Pricing
- **License**: BSD 3-Clause "New" or "Revised" License (Open Source)
- **Cost**: Free for all use cases (commercial and non-commercial)
- **Dependencies**: matplotlib (BSD-compatible), numpy (BSD-compatible)
- **Commercial Support**: Available through Anaconda, NumFOCUS consulting
- **Enterprise**: No licensing restrictions for enterprise deployment

## Version Compatibility

### Supported Versions
- **pandas**: 1.3.0+ (recommended 2.0.0+)
- **matplotlib**: 3.3.0+ (recommended 3.7.0+)
- **Python**: 3.8+ (3.9+ recommended)
- **numpy**: 1.20.0+ (for optimal performance)

### Version-Specific Features
```python
# pandas 2.0+ enhanced plotting
df.plot(backend='plotly')  # Native plotly backend
df.plot.scatter(backend='hvplot')  # hvplot integration

# pandas 1.5+ improvements
df.plot(xlabel='Custom X', ylabel='Custom Y')  # Direct axis labeling

# matplotlib 3.7+ features
df.plot(figsize=(10, 6), layout_engine='constrained')  # Better layouts
```

## Environment Requirements

### Minimal Installation
```bash
pip install pandas matplotlib
# Core plotting functionality
```

### Enhanced Installation
```bash
pip install pandas matplotlib seaborn plotly bokeh
# Full plotting ecosystem with backends
```

### Conda Environment
```bash
conda create -n dataviz python=3.11
conda activate dataviz
conda install pandas matplotlib seaborn plotly bokeh jupyter
```

### Docker Setup
```dockerfile
FROM python:3.11-slim
RUN pip install pandas matplotlib seaborn plotly
COPY requirements.txt .
RUN pip install -r requirements.txt
```

## Installation and Setup

### Basic Installation
```bash
# Core dependencies
pip install pandas matplotlib

# Optional backends
pip install plotly bokeh holoviews hvplot

# Jupyter integration
pip install ipywidgets jupyter-dash

# Statistical plotting
pip install seaborn scipy statsmodels
```

### Configuration
```python
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Set global plotting options
pd.options.plotting.backend = 'matplotlib'  # Default backend
plt.style.use('seaborn-v0_8')  # Better default aesthetics
plt.rcParams['figure.figsize'] = (10, 6)
plt.rcParams['figure.dpi'] = 100
```

## Core Plotting Interface

### DataFrame.plot() Method
```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Create comprehensive sample data
np.random.seed(42)
dates = pd.date_range('2023-01-01', periods=365, freq='D')
df = pd.DataFrame({
    'revenue': np.random.normal(10000, 2000, 365).cumsum(),
    'costs': np.random.normal(7000, 1500, 365).cumsum(),
    'profit': lambda x: x['revenue'] - x['costs'],
    'category': np.random.choice(['A', 'B', 'C', 'D'], 365),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 365),
    'temperature': np.random.normal(20, 10, 365),
    'sales_count': np.random.poisson(50, 365)
}, index=dates)

# Basic line plot
df[['revenue', 'costs', 'profit']].plot(
    title='Financial Performance Over Time',
    figsize=(12, 6),
    xlabel='Date',
    ylabel='Amount ($)',
    grid=True,
    alpha=0.8
)
plt.show()

# Multiple plot types
fig, axes = plt.subplots(2, 2, figsize=(15, 10))

# Line plot with styling
df[['revenue', 'costs']].plot(
    ax=axes[0,0],
    title='Revenue vs Costs',
    style=['--', '-.'],
    color=['blue', 'red'],
    linewidth=2
)

# Scatter plot with color mapping
df.plot.scatter(
    x='temperature',
    y='sales_count',
    c='profit',
    ax=axes[0,1],
    title='Temperature vs Sales (colored by profit)',
    colormap='viridis',
    alpha=0.6
)

# Histogram with custom bins
df['profit'].plot.hist(
    ax=axes[1,0],
    bins=30,
    title='Profit Distribution',
    alpha=0.7,
    color='green',
    edgecolor='black'
)

# Box plot by category
df.boxplot(
    column='profit',
    by='category',
    ax=axes[1,1],
    grid=False
)

plt.tight_layout()
plt.show()
```

### Series.plot() Method
```python
# Time series plotting
revenue_series = df['revenue']

# Basic time series
revenue_series.plot(
    title='Revenue Trend',
    figsize=(12, 4),
    color='darkblue',
    linewidth=2
)

# Rolling statistics
revenue_series.rolling(30).mean().plot(
    label='30-day MA',
    color='red',
    alpha=0.8
)
revenue_series.rolling(90).mean().plot(
    label='90-day MA',
    color='green',
    alpha=0.8
)
plt.legend()
plt.show()

# Distribution plots
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Histogram
revenue_series.plot.hist(
    ax=axes[0],
    bins=50,
    title='Revenue Histogram',
    alpha=0.7
)

# Kernel density estimate
revenue_series.plot.kde(
    ax=axes[1],
    title='Revenue Density',
    color='red'
)

# Box plot
revenue_series.plot.box(
    ax=axes[2],
    title='Revenue Box Plot'
)

plt.tight_layout()
plt.show()
```

## Comprehensive Plot Types

### Line Plots
```python
# Basic line plots
df[['revenue', 'costs']].plot(kind='line')

# Multi-axis line plots
ax = df['revenue'].plot(color='blue', label='Revenue')
df['costs'].plot(ax=ax, secondary_y=True, color='red', label='Costs')
ax.set_ylabel('Revenue ($)', color='blue')
ax.right_ax.set_ylabel('Costs ($)', color='red')
plt.title('Revenue and Costs (Dual Axis)')
plt.show()

# Styled line plots
df[['revenue', 'costs', 'profit']].plot(
    style={
        'revenue': '--',
        'costs': '-.',
        'profit': ':'
    },
    color=['blue', 'red', 'green'],
    linewidth=2,
    alpha=0.8,
    figsize=(12, 6)
)
```

### Bar Charts
```python
# Grouped bar chart
monthly_data = df.groupby(df.index.month)[['revenue', 'costs', 'profit']].mean()
monthly_data.plot(
    kind='bar',
    figsize=(12, 6),
    title='Average Monthly Performance',
    xlabel='Month',
    ylabel='Amount ($)',
    rot=45,
    color=['skyblue', 'lightcoral', 'lightgreen']
)

# Horizontal bar chart
category_summary = df.groupby('category')['profit'].sum().sort_values()
category_summary.plot(
    kind='barh',
    title='Total Profit by Category',
    color='steelblue',
    figsize=(8, 6)
)

# Stacked bar chart
quarterly_data = df.groupby(df.index.quarter)[['revenue', 'costs']].sum()
quarterly_data.plot(
    kind='bar',
    stacked=True,
    title='Quarterly Revenue and Costs (Stacked)',
    figsize=(10, 6),
    color=['lightblue', 'salmon']
)
```

### Histograms and Distributions
```python
# Multiple histograms
df[['revenue', 'costs', 'profit']].plot(
    kind='hist',
    bins=30,
    alpha=0.7,
    figsize=(15, 5),
    subplots=True,
    layout=(1, 3),
    sharex=False
)

# Overlaid histograms
plt.figure(figsize=(10, 6))
df['revenue'].plot.hist(alpha=0.5, bins=30, label='Revenue')
df['costs'].plot.hist(alpha=0.5, bins=30, label='Costs')
plt.legend()
plt.title('Revenue vs Costs Distribution')
plt.show()

# Kernel density estimation
df[['revenue', 'costs', 'profit']].plot(
    kind='kde',
    figsize=(10, 6),
    title='Probability Density Functions'
)
```

### Scatter Plots
```python
# Basic scatter plot
df.plot.scatter(
    x='revenue',
    y='profit',
    title='Revenue vs Profit',
    figsize=(8, 6),
    alpha=0.6
)

# Colored scatter plot
df.plot.scatter(
    x='temperature',
    y='sales_count',
    c='profit',
    colormap='RdYlBu',
    title='Temperature vs Sales (colored by profit)',
    figsize=(10, 6),
    alpha=0.7
)

# Size-mapped scatter plot
df.plot.scatter(
    x='revenue',
    y='profit',
    s=df['sales_count'],  # Size mapping
    c='temperature',      # Color mapping
    alpha=0.6,
    figsize=(10, 6),
    title='Revenue vs Profit (size=sales, color=temp)'
)

# Hexbin plot for dense data
df.plot.hexbin(
    x='revenue',
    y='profit',
    gridsize=20,
    figsize=(8, 6),
    title='Revenue vs Profit Density'
)
```

### Box Plots and Statistical Plots
```python
# Single box plot
df[['revenue', 'costs', 'profit']].plot(kind='box', figsize=(8, 6))

# Grouped box plots
df.boxplot(
    column=['revenue', 'costs', 'profit'],
    by='category',
    figsize=(12, 8),
    layout=(2, 2)
)

# Box plot with outlier styling
df[['revenue', 'costs']].plot.box(
    figsize=(8, 6),
    patch_artist=True,
    boxprops=dict(facecolor='lightblue', alpha=0.7),
    medianprops=dict(color='red', linewidth=2)
)
```

### Area and Pie Charts
```python
# Area plot
df[['revenue', 'costs']].plot.area(
    figsize=(12, 6),
    alpha=0.7,
    title='Cumulative Revenue and Costs'
)

# Stacked area plot
monthly_data.plot.area(
    stacked=True,
    figsize=(12, 6),
    title='Monthly Performance (Stacked Area)',
    alpha=0.8
)

# Pie chart
category_profit = df.groupby('category')['profit'].sum()
category_profit.plot.pie(
    figsize=(8, 8),
    autopct='%1.1f%%',
    title='Profit Distribution by Category',
    colors=['lightblue', 'lightgreen', 'lightcoral', 'lightyellow']
)
```

## Advanced Plotting Techniques

### Subplots and Layouts
```python
# Automatic subplot creation
df[['revenue', 'costs', 'profit', 'sales_count']].plot(
    subplots=True,
    layout=(2, 2),
    figsize=(15, 10),
    title='Individual Metrics'
)

# Custom subplot arrangements
fig, axes = plt.subplots(2, 3, figsize=(18, 10))

# Time series
df['revenue'].plot(ax=axes[0,0], title='Revenue', color='blue')
df['costs'].plot(ax=axes[0,1], title='Costs', color='red')
df['profit'].plot(ax=axes[0,2], title='Profit', color='green')

# Distributions
df['revenue'].plot.hist(ax=axes[1,0], bins=30, alpha=0.7)
df['costs'].plot.hist(ax=axes[1,1], bins=30, alpha=0.7)
df['profit'].plot.hist(ax=axes[1,2], bins=30, alpha=0.7)

plt.tight_layout()
plt.show()

# Shared axes
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), sharex=True)
df['revenue'].plot(ax=ax1, title='Revenue')
df['costs'].plot(ax=ax2, title='Costs', color='red')
plt.show()
```

### Secondary Axes
```python
# Dual y-axis plotting
fig, ax1 = plt.subplots(figsize=(12, 6))

# Primary axis
df['revenue'].plot(ax=ax1, color='blue', label='Revenue')
ax1.set_ylabel('Revenue ($)', color='blue')
ax1.tick_params(axis='y', labelcolor='blue')

# Secondary axis
ax2 = ax1.twinx()
df['temperature'].plot(ax=ax2, color='red', label='Temperature')
ax2.set_ylabel('Temperature (°C)', color='red')
ax2.tick_params(axis='y', labelcolor='red')

plt.title('Revenue and Temperature Over Time')
plt.show()

# Multiple secondary axes
ax1 = df['revenue'].plot(figsize=(12, 6), color='blue')
ax2 = df['costs'].plot(ax=ax1, secondary_y=True, color='red')
ax3 = df['temperature'].plot(ax=ax1, secondary_y=['temperature'], color='green')
plt.show()
```

### Custom Styling and Themes
```python
# Apply matplotlib styles
plt.style.use('seaborn-v0_8-darkgrid')
df[['revenue', 'costs']].plot(figsize=(12, 6))

# Custom color palettes
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
df[['revenue', 'costs', 'profit', 'sales_count']].plot(
    color=colors,
    figsize=(12, 6),
    linewidth=2
)

# Advanced styling
df[['revenue', 'costs']].plot(
    figsize=(12, 6),
    title='Financial Performance',
    xlabel='Date',
    ylabel='Amount ($)',
    grid=True,
    alpha=0.8,
    linewidth=2,
    linestyle='--',
    marker='o',
    markersize=3,
    markerfacecolor='white',
    markeredgewidth=1
)

# Custom figure and axis styling
fig, ax = plt.subplots(figsize=(12, 6))
df['revenue'].plot(ax=ax, color='navy', linewidth=3)
ax.set_facecolor('#f8f9fa')
ax.grid(True, alpha=0.3)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.title('Revenue Trend', fontsize=16, fontweight='bold')
plt.show()
```

## Integration with Other Libraries

### Seaborn Integration
```python
import seaborn as sns

# Use seaborn style with pandas plotting
sns.set_style("whitegrid")
df[['revenue', 'costs', 'profit']].plot(figsize=(12, 6))

# Combine with seaborn plots
fig, axes = plt.subplots(2, 2, figsize=(15, 10))

# Pandas plotting
df['profit'].plot.hist(ax=axes[0,0], bins=30)

# Seaborn plotting
sns.scatterplot(data=df, x='revenue', y='profit', hue='category', ax=axes[0,1])
sns.boxplot(data=df, x='category', y='profit', ax=axes[1,0])
sns.heatmap(df[['revenue', 'costs', 'profit', 'temperature']].corr(),
            ax=axes[1,1], annot=True)

plt.tight_layout()
plt.show()
```

### Plotly Backend
```python
# Set plotly as backend
pd.options.plotting.backend = 'plotly'

# Interactive plots
fig = df[['revenue', 'costs', 'profit']].plot(
    title='Interactive Financial Performance'
)
fig.show()

# Plotly-specific features
fig = df.plot.scatter(
    x='revenue',
    y='profit',
    color='category',
    title='Interactive Scatter Plot',
    hover_data=['costs', 'temperature']
)
fig.show()

# Reset to matplotlib
pd.options.plotting.backend = 'matplotlib'
```

### Statistical Analysis Integration
```python
# Rolling statistics
df['revenue_ma'] = df['revenue'].rolling(30).mean()
df['revenue_std'] = df['revenue'].rolling(30).std()

# Plot with confidence bands
fig, ax = plt.subplots(figsize=(12, 6))
df['revenue'].plot(ax=ax, alpha=0.3, label='Revenue')
df['revenue_ma'].plot(ax=ax, color='red', label='30-day Moving Average')

# Add confidence bands
upper_band = df['revenue_ma'] + 2 * df['revenue_std']
lower_band = df['revenue_ma'] - 2 * df['revenue_std']
ax.fill_between(df.index, upper_band, lower_band, alpha=0.2, color='red')

plt.legend()
plt.title('Revenue with Moving Average and Confidence Bands')
plt.show()
```

## Performance Optimization

### Large Dataset Handling
```python
# For large datasets, use sampling
large_df = pd.DataFrame({
    'x': np.random.randn(1000000),
    'y': np.random.randn(1000000),
    'category': np.random.choice(['A', 'B', 'C'], 1000000)
})

# Sample for plotting
sample_df = large_df.sample(n=10000)
sample_df.plot.scatter(x='x', y='y', c='category', alpha=0.5)

# Use hexbin for density
large_df.plot.hexbin(x='x', y='y', gridsize=50, figsize=(8, 6))

# Aggregation before plotting
aggregated = large_df.groupby(
    [pd.cut(large_df['x'], bins=50), 'category']
)['y'].mean().unstack()
aggregated.plot(kind='bar', figsize=(12, 6))
```

### Memory Optimization
```python
# Use appropriate data types
df_optimized = df.copy()
df_optimized['category'] = df_optimized['category'].astype('category')
df_optimized['region'] = df_optimized['region'].astype('category')

# Chunked processing for very large files
def plot_chunks(filename, chunksize=10000):
    fig, ax = plt.subplots(figsize=(12, 6))
    for chunk in pd.read_csv(filename, chunksize=chunksize):
        chunk['value'].plot(ax=ax, alpha=0.5)
    plt.show()

# Efficient datetime handling
df.index = pd.to_datetime(df.index)  # Ensure datetime index
monthly_summary = df.resample('M').mean()  # Aggregate to reduce size
monthly_summary.plot(figsize=(12, 6))
```

## Error Handling and Debugging

### Common Issues and Solutions
```python
# Handle missing data
df_with_na = df.copy()
df_with_na.loc[df_with_na.sample(100).index, 'profit'] = np.nan

# Plot with missing data
df_with_na['profit'].plot(figsize=(12, 6), title='Data with Missing Values')

# Fill missing data before plotting
df_with_na['profit'].fillna(method='ffill').plot(
    figsize=(12, 6),
    title='Forward-filled Data'
)

# Handle non-numeric data
df_mixed = df.copy()
df_mixed['text_column'] = 'text_value'

# Select only numeric columns
numeric_cols = df_mixed.select_dtypes(include=[np.number]).columns
df_mixed[numeric_cols].plot(figsize=(12, 6))

# Error handling wrapper
def safe_plot(data, plot_type='line', **kwargs):
    try:
        if plot_type == 'scatter' and len(data.columns) < 2:
            raise ValueError("Scatter plot requires at least 2 columns")

        return data.plot(kind=plot_type, **kwargs)
    except Exception as e:
        print(f"Plotting error: {e}")
        # Fallback to simple line plot
        return data.plot(kind='line', **kwargs)

# Usage
safe_plot(df[['revenue']], plot_type='scatter')  # Will fallback
```

### Debugging Plot Output
```python
# Check plot backend
print(f"Current backend: {pd.options.plotting.backend}")

# Verify data before plotting
def debug_plot(data):
    print(f"Data shape: {data.shape}")
    print(f"Data types:\n{data.dtypes}")
    print(f"Missing values:\n{data.isnull().sum()}")
    print(f"Data range:\n{data.describe()}")

    # Attempt plot
    try:
        return data.plot(figsize=(10, 6))
    except Exception as e:
        print(f"Plot failed: {e}")
        return None

debug_plot(df[['revenue', 'costs']])
```

## Best Practices

### Code Organization
```python
# Plotting utility functions
def create_financial_dashboard(data):
    """Create comprehensive financial dashboard."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))

    # Revenue trend
    data['revenue'].plot(ax=axes[0,0], title='Revenue Trend', color='blue')

    # Profit distribution
    data['profit'].plot.hist(ax=axes[0,1], bins=30, title='Profit Distribution')

    # Category performance
    data.groupby('category')['profit'].mean().plot.bar(
        ax=axes[0,2], title='Average Profit by Category'
    )

    # Correlation matrix
    corr_data = data[['revenue', 'costs', 'profit', 'temperature']].corr()
    im = axes[1,0].imshow(corr_data, cmap='coolwarm', aspect='auto')
    axes[1,0].set_title('Correlation Matrix')

    # Scatter plot
    data.plot.scatter(x='revenue', y='profit', ax=axes[1,1],
                     title='Revenue vs Profit', alpha=0.6)

    # Time series with trend
    data['revenue'].rolling(30).mean().plot(ax=axes[1,2],
                                           title='30-day Revenue MA', color='red')

    plt.tight_layout()
    return fig

# Usage
dashboard = create_financial_dashboard(df)
plt.show()
```

### Configuration Management
```python
# Plotting configuration class
class PlottingConfig:
    def __init__(self):
        self.figsize = (12, 6)
        self.dpi = 100
        self.style = 'seaborn-v0_8'
        self.colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
        self.alpha = 0.8

    def apply(self):
        plt.style.use(self.style)
        plt.rcParams['figure.figsize'] = self.figsize
        plt.rcParams['figure.dpi'] = self.dpi

    def get_plot_kwargs(self):
        return {
            'figsize': self.figsize,
            'alpha': self.alpha,
            'color': self.colors[0]
        }

# Usage
config = PlottingConfig()
config.apply()
df['revenue'].plot(**config.get_plot_kwargs())
```

## NPL-FIM Integration Patterns

### Data Visualization Workflows
```python
# NPL-FIM pattern for exploratory data analysis
def npl_fim_eda_pipeline(data):
    """NPL-FIM pattern for comprehensive EDA visualization."""

    # 1. Data overview
    print("=== Data Overview ===")
    print(f"Shape: {data.shape}")
    print(f"Columns: {list(data.columns)}")

    # 2. Distribution analysis
    numeric_cols = data.select_dtypes(include=[np.number]).columns
    n_cols = len(numeric_cols)
    n_rows = (n_cols + 2) // 3

    fig, axes = plt.subplots(n_rows, 3, figsize=(15, 5*n_rows))
    axes = axes.flatten() if n_rows > 1 else [axes]

    for i, col in enumerate(numeric_cols):
        if i < len(axes):
            data[col].plot.hist(ax=axes[i], bins=30, title=f'{col} Distribution')

    plt.tight_layout()
    plt.show()

    # 3. Time series analysis (if datetime index)
    if isinstance(data.index, pd.DatetimeIndex):
        data[numeric_cols].plot(
            figsize=(15, 8),
            subplots=True,
            layout=(len(numeric_cols)//2 + 1, 2),
            title='Time Series Analysis'
        )
        plt.show()

    # 4. Correlation analysis
    if len(numeric_cols) > 1:
        corr_matrix = data[numeric_cols].corr()
        fig, ax = plt.subplots(figsize=(10, 8))
        im = ax.imshow(corr_matrix, cmap='coolwarm', aspect='auto')
        ax.set_xticks(range(len(numeric_cols)))
        ax.set_yticks(range(len(numeric_cols)))
        ax.set_xticklabels(numeric_cols, rotation=45)
        ax.set_yticklabels(numeric_cols)
        plt.colorbar(im)
        plt.title('Correlation Matrix')
        plt.tight_layout()
        plt.show()

# Apply NPL-FIM pattern
npl_fim_eda_pipeline(df)
```

### Template-Based Visualization
```python
# NPL-FIM visualization templates
class NPLFIMPlotTemplates:
    @staticmethod
    def financial_performance(data, revenue_col='revenue', cost_col='costs'):
        """Standard financial performance visualization."""
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))

        # Revenue and costs over time
        data[[revenue_col, cost_col]].plot(ax=axes[0,0],
                                          title='Revenue and Costs Trend')

        # Profit calculation and plot
        profit = data[revenue_col] - data[cost_col]
        profit.plot(ax=axes[0,1], title='Profit Trend', color='green')

        # Distribution comparison
        data[[revenue_col, cost_col]].plot.hist(ax=axes[1,0],
                                               bins=30, alpha=0.7,
                                               title='Revenue vs Costs Distribution')

        # Profit margin
        margin = (profit / data[revenue_col] * 100)
        margin.plot(ax=axes[1,1], title='Profit Margin %', color='orange')

        plt.tight_layout()
        return fig

    @staticmethod
    def categorical_analysis(data, value_col, category_col):
        """Standard categorical analysis visualization."""
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))

        # Bar chart
        data.groupby(category_col)[value_col].mean().plot.bar(
            ax=axes[0,0], title=f'Average {value_col} by {category_col}'
        )

        # Box plot
        data.boxplot(column=value_col, by=category_col, ax=axes[0,1])

        # Violin plot (using matplotlib)
        categories = data[category_col].unique()
        violin_data = [data[data[category_col] == cat][value_col].values
                      for cat in categories]
        axes[1,0].violinplot(violin_data)
        axes[1,0].set_xticks(range(1, len(categories) + 1))
        axes[1,0].set_xticklabels(categories)
        axes[1,0].set_title(f'{value_col} Distribution by {category_col}')

        # Pie chart of category counts
        data[category_col].value_counts().plot.pie(
            ax=axes[1,1], title=f'{category_col} Distribution'
        )

        plt.tight_layout()
        return fig

# Usage
financial_fig = NPLFIMPlotTemplates.financial_performance(df)
categorical_fig = NPLFIMPlotTemplates.categorical_analysis(df, 'profit', 'category')
plt.show()
```

## Strengths

### Ease of Use
- **Direct Integration**: Seamless `.plot()` accessor on DataFrame and Series objects
- **Minimal Code**: Single-line plotting with sensible defaults
- **Automatic Handling**: Intelligent handling of data types, missing values, and axes
- **Quick Iteration**: Rapid prototyping and exploratory data analysis capabilities

### Comprehensive Coverage
- **Plot Types**: Extensive variety of chart types (line, bar, scatter, histogram, box, etc.)
- **Statistical Plots**: Built-in support for distributions, correlations, and aggregations
- **Customization**: Rich styling and configuration options
- **Backend Flexibility**: Support for matplotlib, plotly, and other plotting backends

### Data Integration
- **Native DataFrame Support**: Direct plotting from pandas data structures
- **Index Awareness**: Intelligent use of DataFrame index for x-axis
- **Groupby Integration**: Seamless plotting of grouped data
- **Time Series**: Excellent support for datetime-indexed data

### Performance
- **Optimized Rendering**: Efficient matplotlib integration with optimized data handling
- **Memory Efficient**: Intelligent data sampling and aggregation for large datasets
- **Fast Iteration**: Quick plot generation for interactive analysis
- **Caching Support**: Leverages matplotlib's caching for improved performance

## Limitations

### Advanced Visualization Needs
- **Complex Layouts**: Limited support for highly customized subplot arrangements
- **3D Plotting**: No native 3D plotting capabilities (requires matplotlib directly)
- **Interactive Features**: Basic interactivity compared to dedicated libraries like plotly
- **Animation**: No built-in animation support

### Styling Constraints
- **Theme System**: Limited built-in themes compared to seaborn or plotly
- **Publication Quality**: May require additional matplotlib customization for publication
- **Brand Consistency**: No built-in corporate styling or brand guideline support
- **Color Mapping**: Limited advanced color mapping capabilities

### Performance Limitations
- **Large Datasets**: Can become slow with very large datasets (>1M points)
- **Memory Usage**: High memory consumption for complex plots with large data
- **Real-time Updates**: Not optimized for real-time or streaming data visualization
- **Export Options**: Limited export formats compared to specialized libraries

### Dependency Constraints
- **Matplotlib Dependency**: Inherits matplotlib limitations and complexities
- **Backend Switching**: Backend switching can be cumbersome and inconsistent
- **Version Compatibility**: Plotting features tied to pandas and matplotlib versions
- **Installation Size**: Large dependency footprint for simple plotting needs

## Common Patterns and Recipes

### Data Exploration Workflow
```python
def explore_dataset(df):
    """Complete data exploration using pandas plotting."""

    # Basic info
    print(f"Dataset shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")

    # Numeric columns overview
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    if len(numeric_cols) > 0:
        df[numeric_cols].plot(
            kind='box',
            figsize=(12, 6),
            title='Numeric Columns Distribution Overview'
        )
        plt.show()

        # Correlation heatmap
        if len(numeric_cols) > 1:
            corr = df[numeric_cols].corr()
            fig, ax = plt.subplots(figsize=(10, 8))
            im = ax.imshow(corr, cmap='coolwarm', vmin=-1, vmax=1)
            ax.set_xticks(range(len(numeric_cols)))
            ax.set_yticks(range(len(numeric_cols)))
            ax.set_xticklabels(numeric_cols, rotation=45)
            ax.set_yticklabels(numeric_cols)

            # Add correlation values
            for i in range(len(numeric_cols)):
                for j in range(len(numeric_cols)):
                    text = ax.text(j, i, f'{corr.iloc[i, j]:.2f}',
                                 ha="center", va="center", color="black")

            plt.colorbar(im)
            plt.title('Correlation Matrix')
            plt.tight_layout()
            plt.show()

    # Categorical columns
    categorical_cols = df.select_dtypes(include=['object', 'category']).columns
    for col in categorical_cols:
        if df[col].nunique() < 20:  # Only plot if not too many categories
            df[col].value_counts().plot(
                kind='bar',
                figsize=(10, 6),
                title=f'{col} Distribution'
            )
            plt.show()

# Usage
explore_dataset(df)
```

This comprehensive enhancement transforms the pandas-plotting.md file from a basic 77-line document to a thorough 500+ line resource that meets NPL-FIM solution standards. The file now includes:

1. **Official documentation links** and comprehensive references
2. **Detailed strengths and limitations** analysis
3. **Version compatibility** and environment requirements
4. **License and pricing** information (open source)
5. **Extensive code examples** covering all major plotting functionality
6. **Performance optimization** techniques
7. **NPL-FIM integration patterns** for structured workflows
8. **Best practices** and common patterns
9. **Error handling** and debugging guidance
10. **Advanced techniques** for complex visualizations

The enhanced file provides NPL-FIM with comprehensive guidance for generating pandas visualization artifacts across all common use cases and complexity levels.