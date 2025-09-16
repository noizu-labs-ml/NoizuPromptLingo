# Data Visualization with Matplotlib

Publication-ready charts and plots for data analysis and presentation.

## Core Implementation

```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Configure plotting style
plt.style.use('seaborn-v0_8')
plt.rcParams['figure.figsize'] = (12, 8)
plt.rcParams['font.size'] = 12

# Create subplots for multiple visualizations
fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 10))

# Line plot with error bars
x = np.linspace(0, 10, 100)
y = np.sin(x) + np.random.normal(0, 0.1, 100)
ax1.plot(x, y, 'b-', alpha=0.7, label='Data')
ax1.fill_between(x, y-0.2, y+0.2, alpha=0.3)
ax1.set_title('Time Series with Uncertainty')
ax1.legend()

# Histogram with density curve
data = np.random.normal(100, 15, 1000)
ax2.hist(data, bins=30, density=True, alpha=0.7, color='skyblue')
ax2.axvline(np.mean(data), color='red', linestyle='--', label=f'Mean: {np.mean(data):.1f}')
ax2.set_title('Distribution Analysis')
ax2.legend()

# Scatter plot with regression line
x_scatter = np.random.rand(100) * 10
y_scatter = 2 * x_scatter + np.random.normal(0, 1, 100)
ax3.scatter(x_scatter, y_scatter, alpha=0.6)
z = np.polyfit(x_scatter, y_scatter, 1)
p = np.poly1d(z)
ax3.plot(x_scatter, p(x_scatter), "r--", alpha=0.8)
ax3.set_title('Correlation Analysis')

# Heatmap
data_matrix = np.random.rand(10, 10)
im = ax4.imshow(data_matrix, cmap='viridis')
ax4.set_title('Correlation Matrix')
plt.colorbar(im, ax=ax4)

plt.tight_layout()
plt.savefig('analysis_report.png', dpi=300, bbox_inches='tight')
plt.show()
```

## Key Features
- Multiple subplot configurations
- Statistical overlays and annotations
- Custom color schemes and styling
- High-resolution export formats
- Interactive zoom and pan capabilities