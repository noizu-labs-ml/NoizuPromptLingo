# Python Code Generation with Matplotlib

Programmatic chart creation and template-driven visualization workflows.

## Core Implementation

```python
import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, List, Any

class ChartGenerator:
    def __init__(self, style='seaborn-v0_8', figsize=(10, 6)):
        plt.style.use(style)
        self.figsize = figsize

    def generate_chart(self, chart_type: str, data: Dict[str, Any],
                      config: Dict[str, Any] = None) -> plt.Figure:
        """Generate charts based on configuration templates"""

        fig, ax = plt.subplots(figsize=self.figsize)

        if chart_type == 'line':
            self._create_line_chart(ax, data, config or {})
        elif chart_type == 'bar':
            self._create_bar_chart(ax, data, config or {})
        elif chart_type == 'scatter':
            self._create_scatter_chart(ax, data, config or {})

        return fig

    def _create_line_chart(self, ax, data, config):
        x, y = data['x'], data['y']

        ax.plot(x, y,
               color=config.get('color', 'blue'),
               linewidth=config.get('linewidth', 2),
               marker=config.get('marker', 'o'))

        self._apply_styling(ax, config)

    def _create_bar_chart(self, ax, data, config):
        categories, values = data['categories'], data['values']

        bars = ax.bar(categories, values,
                     color=config.get('colors', 'skyblue'),
                     alpha=config.get('alpha', 0.8))

        # Add value labels on bars
        for bar, value in zip(bars, values):
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                   f'{value:.1f}', ha='center', va='bottom')

        self._apply_styling(ax, config)

    def _apply_styling(self, ax, config):
        ax.set_title(config.get('title', ''), fontsize=14, fontweight='bold')
        ax.set_xlabel(config.get('xlabel', ''), fontsize=12)
        ax.set_ylabel(config.get('ylabel', ''), fontsize=12)
        ax.grid(config.get('grid', True), alpha=0.3)

# Usage example
generator = ChartGenerator()

# Generate multiple charts from data templates
chart_configs = [
    {
        'type': 'line',
        'data': {'x': np.linspace(0, 10, 50), 'y': np.sin(np.linspace(0, 10, 50))},
        'config': {'title': 'Sine Wave', 'color': 'red'}
    },
    {
        'type': 'bar',
        'data': {'categories': ['A', 'B', 'C'], 'values': [10, 15, 8]},
        'config': {'title': 'Sample Data', 'colors': ['red', 'green', 'blue']}
    }
]

for i, chart_config in enumerate(chart_configs):
    fig = generator.generate_chart(**chart_config)
    fig.savefig(f'generated_chart_{i}.png', dpi=300, bbox_inches='tight')
    plt.close(fig)
```

## Key Features
- Template-driven chart generation
- Configuration-based styling
- Batch processing capabilities
- Object-oriented design patterns
- Automated file naming and export