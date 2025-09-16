# Data Visualization with Kino VegaLite

Interactive data visualization in Elixir Livebook using VegaLite specification.

## Core Implementation

```elixir
# Livebook cell for interactive data visualization
alias VegaLite, as: Vl

# Create sample dataset
data = [
  %{category: "A", value: 28, date: ~D[2023-01-01]},
  %{category: "B", value: 55, date: ~D[2023-01-01]},
  %{category: "C", value: 43, date: ~D[2023-01-01]},
  %{category: "A", value: 91, date: ~D[2023-02-01]},
  %{category: "B", value: 81, date: ~D[2023-02-01]},
  %{category: "C", value: 53, date: ~D[2023-02-01]}
]

# Interactive bar chart with selection
Vl.new(width: 400, height: 300)
|> Vl.data_from_values(data)
|> Vl.mark(:bar)
|> Vl.encode_field(:x, "category", type: :nominal, axis: [title: "Category"])
|> Vl.encode_field(:y, "value", type: :quantitative, axis: [title: "Value"])
|> Vl.encode_field(:color, "category", type: :nominal, legend: false)
|> Vl.encode_field(:tooltip, ["category", "value"])

# Time series with interactive selection
Vl.new(width: 500, height: 200)
|> Vl.data_from_values(data)
|> Vl.mark(:line, point: true)
|> Vl.encode_field(:x, "date", type: :temporal, axis: [title: "Date"])
|> Vl.encode_field(:y, "value", type: :quantitative, axis: [title: "Value"])
|> Vl.encode_field(:color, "category", type: :nominal)
|> Vl.encode_field(:stroke_dash, "category", type: :nominal)

# Dashboard with linked visualizations
Vl.new()
|> Vl.data_from_values(data)
|> Vl.concat([
  Vl.new()
  |> Vl.mark(:bar)
  |> Vl.encode_field(:x, "category", type: :nominal)
  |> Vl.encode_field(:y, "value", type: :quantitative)
  |> Vl.encode_field(:color, "category", type: :nominal),

  Vl.new()
  |> Vl.mark(:point, size: 100)
  |> Vl.encode_field(:x, "date", type: :temporal)
  |> Vl.encode_field(:y, "value", type: :quantitative)
  |> Vl.encode_field(:color, "category", type: :nominal)
], :horizontal)
```

## Key Features
- Real-time data binding with Livebook
- Interactive brushing and linking
- Responsive chart layouts
- Built-in statistical transformations
- Export to PNG/SVG formats
- Integration with Elixir data pipelines