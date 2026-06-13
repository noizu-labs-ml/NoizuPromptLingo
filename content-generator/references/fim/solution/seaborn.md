# NPL-FIM: seaborn
📊 Statistical data visualization built on matplotlib

## Installation
```bash
pip install seaborn
pip install pandas  # Recommended
```

## Basic Usage
```python
import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt

# Load sample data
df = sns.load_dataset('iris')

# Statistical plots
sns.scatterplot(data=df, x='sepal_length', y='sepal_width', hue='species')
plt.show()

# Distribution plots
sns.histplot(data=df, x='sepal_length', kde=True)
plt.show()

# Categorical plots
sns.boxplot(data=df, x='species', y='sepal_length')
plt.show()

# Correlation heatmap
sns.heatmap(df.corr(), annot=True, cmap='coolwarm')
plt.show()

# Pair plot for relationships
sns.pairplot(df, hue='species')
plt.show()
```

## Jupyter Integration
```python
# Set style
sns.set_theme(style='whitegrid')
sns.set_palette('husl')

# Figure-level functions
g = sns.FacetGrid(df, col='species', height=4)
g.map(sns.histplot, 'sepal_length')
```

## Plot Types
- Relational: `scatterplot()`, `lineplot()`
- Distributions: `histplot()`, `kdeplot()`, `ecdfplot()`
- Categorical: `boxplot()`, `violinplot()`, `swarmplot()`
- Regression: `regplot()`, `lmplot()`
- Matrix: `heatmap()`, `clustermap()`

## FIM Context
Statistical visualization layer over matplotlib, ideal for exploratory data analysis