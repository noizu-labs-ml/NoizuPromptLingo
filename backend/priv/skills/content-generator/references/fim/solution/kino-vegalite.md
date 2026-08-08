# Kino.VegaLite

## Description
Kino.VegaLite provides interactive Vega-Lite visualizations for Elixir LiveBook environments. It enables declarative data visualization using the Vega-Lite specification language directly in Elixir notebooks.

**Documentation**: [hexdocs.pm/kino_vega_lite](https://hexdocs.pm/kino_vega_lite)

## Installation
```elixir
# In LiveBook setup cell
Mix.install([
  {:kino_vega_lite, "~> 0.1.11"},
  {:kino, "~> 0.12.0"}
])
```

## Example Usage
```elixir
# Create sample data
data = [
  %{category: "A", value: 30},
  %{category: "B", value: 55},
  %{category: "C", value: 43},
  %{category: "D", value: 91}
]

# Build bar chart
VegaLite.new(width: 400, height: 300)
|> VegaLite.data_from_values(data)
|> VegaLite.mark(:bar)
|> VegaLite.encode_field(:x, "category", type: :nominal)
|> VegaLite.encode_field(:y, "value", type: :quantitative)
|> VegaLite.encode_field(:color, "category", type: :nominal)
```

## Strengths
- **Interactive visualizations**: Pan, zoom, hover tooltips out of the box
- **Declarative syntax**: Build complex charts with simple specifications
- **LiveBook integration**: Seamless rendering in notebook cells
- **Vega-Lite power**: Access full Vega-Lite specification features
- **Data transformations**: Built-in aggregations and calculations

## Limitations
- **LiveBook only**: Requires LiveBook runtime environment
- **Static export**: Limited options for embedding outside notebooks
- **Learning curve**: Vega-Lite specification knowledge needed for advanced use
- **Performance**: Large datasets may impact notebook responsiveness

## Best For
- **Data exploration**: Interactive analysis in Elixir LiveBook
- **Prototyping**: Quick visualization experiments
- **Education**: Teaching data visualization concepts
- **Reports**: Notebook-based data analysis reports
- **Real-time data**: Streaming visualizations with Kino.animate

## NPL-FIM Integration
```fim
@component: kino_vega_lite_chart
@type: visualization
@runtime: livebook
@pattern: declarative_viz

trigger: data_ready
action: |
  VegaLite.new()
  |> VegaLite.data_from_values({{data}})
  |> VegaLite.mark(:{{chart_type}})
  |> VegaLite.encode_field(:x, "{{x_field}}", type: :{{x_type}})
  |> VegaLite.encode_field(:y, "{{y_field}}", type: :{{y_type}})
output: interactive_chart
```