# Kino.DataTable

Interactive tabular data visualization for LiveBook notebooks.

## Description

Kino.DataTable renders tabular data with built-in sorting, filtering, and pagination capabilities. Part of the core Kino library, it transforms data structures into interactive HTML tables within LiveBook cells.

**Documentation**: [hexdocs.pm/kino/Kino.DataTable.html](https://hexdocs.pm/kino/Kino.DataTable.html)

## Installation

Built-in with Kino. No additional dependencies required.

```elixir
# Already available in LiveBook
```

## Basic Usage

```elixir
# From list of maps
data = [
  %{name: "Alice", age: 30, city: "NYC"},
  %{name: "Bob", age: 25, city: "LA"},
  %{name: "Carol", age: 35, city: "Chicago"}
]

Kino.DataTable.new(data)
```

```elixir
# From list of tuples with keys
data = [
  {"Alice", 30, "NYC"},
  {"Bob", 25, "LA"},
  {"Carol", 35, "Chicago"}
]

Kino.DataTable.new(data, keys: [:name, :age, :city])
```

```elixir
# With pagination
large_dataset = Enum.map(1..1000, fn i ->
  %{id: i, value: :rand.uniform(100)}
end)

Kino.DataTable.new(large_dataset, keys: [:id, :value])
```

## Strengths

- **Interactive Features**: Click-to-sort columns, built-in filtering
- **Zero Setup**: No configuration needed, works immediately
- **Performance**: Handles large datasets with pagination
- **Type Awareness**: Automatic formatting for dates, numbers, booleans
- **LiveBook Integration**: Seamless notebook experience

## Limitations

- **LiveBook Only**: Cannot be used outside notebook environment
- **Styling Constraints**: Limited customization options
- **Read-Only**: No inline editing capabilities
- **Memory Bound**: Large datasets consume notebook memory

## Best Use Cases

- **Data Exploration**: Quick inspection of query results
- **Prototype Development**: Rapid data visualization during development
- **Report Generation**: Interactive tables in LiveBook reports
- **Educational Content**: Teaching data analysis concepts

## NPL-FIM Integration

```npl
⟪kino-datatable-fim⟫
↦ context: LiveBook tabular data display
↦ input: data structures (maps, tuples, structs)
↦ output: interactive HTML table widget
↦ constraints: LiveBook environment required
⟫
```

**FIM Pattern**: Data → Transform → Render
- **Data**: Any enumerable with consistent structure
- **Transform**: Automatic type detection and formatting
- **Render**: Interactive table with sorting/filtering

**Integration Points**:
- Database query results
- CSV/JSON data imports
- API response visualization
- Data pipeline intermediate results