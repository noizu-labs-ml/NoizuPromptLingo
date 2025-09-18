# Elixir Livebook Interactive Components
Create interactive, data-driven components for Elixir Livebook combining functional code, real-time data processing, and dynamic visualizations using Kino widgets and Phoenix LiveView patterns.
[Livebook Documentation](https://livebook.dev/), [Kino Widgets](https://hexdocs.pm/kino/Kino.html)

## When to Use
- Building Phoenix LiveView prototypes with interactive data exploration
- Creating educational Elixir content with executable GenServer examples
- Developing real-time monitoring dashboards using Elixir processes
- Prototyping distributed system interfaces with live node connectivity
- Generating documentation with runnable OTP supervision tree examples
- Building interactive data pipelines with Flow and Broadway patterns

## Key Outputs
`livebook-cells`, `kino-widgets`, `phoenix-liveview-components`, `genserver-forms`, `vega-lite-charts`, `data-tables`, `smart-cells`, `process-monitors`

## Core Livebook Patterns

### 1. Kino Input Widgets with Process State
```elixir
# Interactive parameter control with GenServer state
input = Kino.Input.range("Batch Size", min: 1, max: 1000, default: 100)
refresh_button = Kino.Control.button("Process Data")

{:ok, processor} = GenServer.start_link(DataProcessor, %{batch_size: 100})

Kino.Control.stream(refresh_button)
|> Kino.listen(fn _event ->
  batch_size = Kino.Input.read(input)
  GenServer.call(processor, {:update_batch_size, batch_size})
  GenServer.call(processor, :process_batch)
end)
```

### 2. Real-time Data Visualization with VegaLite
```elixir
# Live updating chart with Elixir streams
alias VegaLite, as: Vl

chart =
  Vl.new(width: 600, height: 400)
  |> Vl.mark(:line)
  |> Vl.encode_field(:x, "timestamp", type: :temporal)
  |> Vl.encode_field(:y, "value", type: :quantitative)
  |> Kino.VegaLite.new()

# Stream data from GenServer or external source
Task.async(fn ->
  Stream.interval(1000)
  |> Stream.map(fn _ ->
    %{timestamp: DateTime.utc_now(), value: :rand.uniform(100)}
  end)
  |> Stream.each(&Kino.VegaLite.push(chart, &1))
  |> Stream.run()
end)
```

### 3. Phoenix LiveView Component Prototyping
```elixir
# Rapid LiveView component development and testing
defmodule ComponentPreview do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <.live_component
        module={YourComponent}
        id="preview"
        params={@params}
        on_change={JS.push("update_params")}
      />
    </div>
    """
  end

  def handle_event("update_params", params, socket) do
    {:noreply, assign(socket, :params, params)}
  end
end

# Live preview in Livebook
Kino.start_child({Phoenix.PubSub, name: ComponentPubSub})
LivebookWeb.preview_component(ComponentPreview, %{params: %{}})
```

### 4. Smart Cell for Ecto Query Building
```elixir
# Interactive database query builder
schema_input = Kino.Input.select("Schema", [
  {"User", MyApp.User},
  {"Post", MyApp.Post},
  {"Comment", MyApp.Comment}
])

fields_input = Kino.Input.text("Select Fields", default: "*")
where_input = Kino.Input.text("Where Clause", default: "")
limit_input = Kino.Input.number("Limit", default: 10)

query_button = Kino.Control.button("Build Query")

Kino.Control.stream(query_button)
|> Kino.listen(fn _event ->
  schema = Kino.Input.read(schema_input)
  fields = Kino.Input.read(fields_input)
  where_clause = Kino.Input.read(where_input)
  limit = Kino.Input.read(limit_input)

  query = build_dynamic_query(schema, fields, where_clause, limit)
  results = MyApp.Repo.all(query)

  Kino.DataTable.new(results)
end)
```

### 5. Process Monitoring Dashboard
```elixir
# Real-time supervision tree monitoring
process_tree = Kino.Tree.new()
memory_chart = create_memory_chart()

Task.async(fn ->
  Stream.interval(2000)
  |> Stream.each(fn _ ->
    # Update process tree
    processes = Supervisor.which_children(MyApp.Supervisor)
    tree_data = build_process_tree(processes)
    Kino.Tree.update(process_tree, tree_data)

    # Update memory usage
    memory_data = %{
      timestamp: DateTime.utc_now(),
      total: :erlang.memory(:total),
      processes: :erlang.memory(:processes),
      atom: :erlang.memory(:atom)
    }
    Kino.VegaLite.push(memory_chart, memory_data)
  end)
  |> Stream.run()
end)

Kino.Layout.grid([process_tree, memory_chart], columns: 2)
```

## Implementation Quick Example
```elixir
# Complete interactive data analysis component
defmodule DataExplorer do
  def create_dashboard(dataset) do
    # Input controls
    column_select = Kino.Input.select("Analyze Column",
      dataset |> hd() |> Map.keys() |> Enum.map(&{&1, &1}))

    analysis_type = Kino.Input.select("Analysis Type", [
      {"Distribution", :distribution},
      {"Time Series", :time_series},
      {"Correlation", :correlation}
    ])

    analyze_button = Kino.Control.button("Analyze")

    # Output containers
    chart_output = Kino.Frame.new()
    stats_output = Kino.Frame.new()

    # Event handling
    Kino.Control.stream(analyze_button)
    |> Kino.listen(fn _event ->
      column = Kino.Input.read(column_select)
      type = Kino.Input.read(analysis_type)

      {chart, stats} = analyze_data(dataset, column, type)

      Kino.Frame.render(chart_output, chart)
      Kino.Frame.render(stats_output, stats)
    end)

    # Layout
    controls = Kino.Layout.grid([column_select, analysis_type, analyze_button])
    outputs = Kino.Layout.grid([chart_output, stats_output], columns: 2)

    Kino.Layout.grid([controls, outputs], boxed: true)
  end

  defp analyze_data(dataset, column, :distribution) do
    values = Enum.map(dataset, &Map.get(&1, column))

    chart =
      Vl.new()
      |> Vl.data_from_values(Enum.map(values, &%{value: &1}))
      |> Vl.mark(:bar)
      |> Vl.encode_field(:x, "value", type: :ordinal, bin: true)
      |> Vl.encode(:y, aggregate: :count)
      |> Kino.VegaLite.new()

    stats = %{
      mean: Enum.sum(values) / length(values),
      min: Enum.min(values),
      max: Enum.max(values),
      count: length(values)
    } |> Kino.DataTable.new()

    {chart, stats}
  end
end

# Usage
dataset = [
  %{name: "Alice", age: 30, score: 85},
  %{name: "Bob", age: 25, score: 92},
  %{name: "Carol", age: 35, score: 78}
]

DataExplorer.create_dashboard(dataset)
```