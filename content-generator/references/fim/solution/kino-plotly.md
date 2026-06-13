# Kino.Plotly

## Description
Kino.Plotly brings Plotly.js charts to Elixir LiveBook environments. Provides interactive scientific visualizations with 3D plotting capabilities directly in notebook cells.

**GitHub**: [github.com/livebook-dev/kino_plotly](https://github.com/livebook-dev/kino_plotly)

## Installation
```elixir
# In LiveBook setup cell
Mix.install([
  {:kino_plotly, "~> 0.1.0"},
  {:kino, "~> 0.12.0"}
])
```

## Example Usage
```elixir
# 3D surface plot
import PlotlyEx

x = [1, 2, 3, 4, 5]
y = [1, 2, 3, 4, 5]
z = for i <- x, j <- y, do: i * j

data = %{
  x: x,
  y: y,
  z: z |> Enum.chunk_every(5),
  type: "surface"
}

layout = %{
  title: "3D Surface Plot",
  scene: %{
    xaxis: %{title: "X Axis"},
    yaxis: %{title: "Y Axis"},
    zaxis: %{title: "Z Axis"}
  }
}

Kino.Plotly.new([data], layout)
```

## Strengths
- **Rich interactivity**: 3D rotation, zoom, hover, crossfilter
- **Scientific plotting**: Heatmaps, contours, statistical charts
- **LiveBook native**: Seamless rendering in notebook cells
- **Plotly ecosystem**: Access to full Plotly.js feature set
- **Real-time updates**: Dynamic data binding with Kino.animate

## Limitations
- **LiveBook dependency**: Requires LiveBook runtime environment
- **Large payload**: Plotly.js bundle increases notebook size
- **Limited customization**: Less flexible than pure Plotly.js
- **Export constraints**: Notebook-bound visualizations

## Best For
- **Scientific visualization**: Research data analysis and exploration
- **3D plotting**: Surface plots, scatter3d, mesh visualizations
- **Interactive dashboards**: LiveBook-based data applications
- **Educational content**: Teaching scientific computing concepts

## NPL-FIM Integration
```fim
@component: kino_plotly_chart
@type: scientific_visualization
@runtime: livebook
@pattern: interactive_3d

trigger: dataset_loaded
action: |
  data = %{
    x: {{x_values}},
    y: {{y_values}},
    z: {{z_values}},
    type: "{{plot_type}}"
  }

  layout = %{
    title: "{{chart_title}}",
    scene: %{
      xaxis: %{title: "{{x_label}}"},
      yaxis: %{title: "{{y_label}}"},
      zaxis: %{title: "{{z_label}}"}
    }
  }

  Kino.Plotly.new([data], layout)
output: interactive_3d_chart
```