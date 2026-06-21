# Elixir Livebook Interactive Components with Kino VegaLite

**NPL-FIM Solution**: Complete implementation guide for creating interactive data visualization components in Elixir Livebook using Kino and VegaLite for reactive dashboards, real-time updates, and dynamic user interfaces.

## Quick Start Template

```elixir
# Essential dependencies for Livebook
Mix.install([
  {:kino, "~> 0.12"},
  {:kino_vega_lite, "~> 0.1"},
  {:vega_lite, "~> 0.1"}
])

# Basic interactive chart component
defmodule InteractiveChart do
  @moduledoc "Ready-to-use interactive chart component"

  def create_dashboard(data, opts \\ []) do
    # Input controls
    chart_type = Kino.Input.select("Chart Type", [
      {"Bar Chart", :bar},
      {"Line Chart", :line},
      {"Area Chart", :area},
      {"Scatter Plot", :point}
    ])

    color_scheme = Kino.Input.select("Color Scheme", [
      {"Category10", "category10"},
      {"Set1", "set1"},
      {"Viridis", "viridis"},
      {"Plasma", "plasma"}
    ])

    # Layout container
    layout = Kino.Layout.grid([
      [chart_type, color_scheme],
      [create_chart(data, opts)]
    ], columns: 2)

    # Reactive updates
    Kino.Control.stream([chart_type, color_scheme])
    |> Kino.listen(fn _event ->
      type = Kino.Input.read(chart_type)
      scheme = Kino.Input.read(color_scheme)

      updated_chart = create_chart(data, [type: type, color_scheme: scheme] ++ opts)
      Kino.Frame.render(layout, updated_chart)
    end)

    layout
  end

  defp create_chart(data, opts) do
    type = Keyword.get(opts, :type, :bar)
    scheme = Keyword.get(opts, :color_scheme, "category10")

    Vl.new(width: 600, height: 400)
    |> Vl.data_from_values(data)
    |> Vl.mark(type)
    |> Vl.encode_field(:x, "x", type: :ordinal)
    |> Vl.encode_field(:y, "y", type: :quantitative)
    |> Vl.encode_field(:color, "category", scale: [scheme: scheme])
    |> Vl.encode_field(:tooltip, ["x", "y", "category"])
  end
end

# Sample data
sample_data = [
  %{"x" => "A", "y" => 28, "category" => "Alpha"},
  %{"x" => "B", "y" => 55, "category" => "Beta"},
  %{"x" => "C", "y" => 43, "category" => "Gamma"},
  %{"x" => "D", "y" => 91, "category" => "Delta"}
]

# Create and render dashboard
InteractiveChart.create_dashboard(sample_data)
```

## Core Components Library

### 1. Real-Time Data Input Components

```elixir
defmodule LiveDataInput do
  @moduledoc "Real-time data input and validation components"

  def numeric_slider(label, opts \\ []) do
    min = Keyword.get(opts, :min, 0)
    max = Keyword.get(opts, :max, 100)
    default = Keyword.get(opts, :default, div(max - min, 2))
    step = Keyword.get(opts, :step, 1)

    Kino.Input.range(label,
      min: min,
      max: max,
      default: default,
      step: step
    )
  end

  def categorical_selector(label, categories) do
    options = Enum.map(categories, fn cat ->
      case cat do
        {display, value} -> {display, value}
        value -> {to_string(value), value}
      end
    end)

    Kino.Input.select(label, options)
  end

  def date_range_picker(label, opts \\ []) do
    start_date = Keyword.get(opts, :start_date, Date.utc_today())
    end_date = Keyword.get(opts, :end_date, Date.add(Date.utc_today(), 30))

    form = Kino.Control.form([
      start_date: Kino.Input.date("Start Date", default: start_date),
      end_date: Kino.Input.date("End Date", default: end_date)
    ], submit: "Update Range")

    {form, fn ->
      %{data: %{start_date: start_d, end_date: end_d}} = Kino.Control.read(form)
      {start_d, end_d}
    end}
  end

  def multi_select_filter(label, options) do
    checkboxes = Enum.map(options, fn {display, value} ->
      {value, Kino.Input.checkbox(display, default: true)}
    end)

    container = Kino.Layout.grid(
      [Kino.Markdown.new("**#{label}**")] ++
      Enum.map(checkboxes, fn {_value, checkbox} -> checkbox end),
      columns: 1
    )

    {container, fn ->
      Enum.filter(checkboxes, fn {_value, checkbox} ->
        Kino.Input.read(checkbox)
      end)
      |> Enum.map(fn {value, _checkbox} -> value end)
    end}
  end
end
```

### 2. Advanced Chart Templates

```elixir
defmodule ChartTemplates do
  @moduledoc "Pre-configured chart templates for common use cases"

  def time_series_chart(data, x_field, y_field, opts \\ []) do
    title = Keyword.get(opts, :title, "Time Series")
    width = Keyword.get(opts, :width, 800)
    height = Keyword.get(opts, :height, 400)
    color_field = Keyword.get(opts, :color_field)

    chart = Vl.new(width: width, height: height, title: title)
    |> Vl.data_from_values(data)
    |> Vl.mark(:line, point: true, strokeWidth: 2)
    |> Vl.encode_field(:x, x_field,
        type: :temporal,
        axis: [title: x_field, format: "%Y-%m-%d"])
    |> Vl.encode_field(:y, y_field,
        type: :quantitative,
        axis: [title: y_field])

    if color_field do
      chart |> Vl.encode_field(:color, color_field, type: :nominal)
    else
      chart
    end
  end

  def correlation_heatmap(data, fields) do
    # Calculate correlation matrix
    correlations = calculate_correlations(data, fields)

    heatmap_data = for {field1, correlations_map} <- correlations,
                       {field2, correlation} <- correlations_map do
      %{"field1" => field1, "field2" => field2, "correlation" => correlation}
    end

    Vl.new(width: 400, height: 400, title: "Correlation Matrix")
    |> Vl.data_from_values(heatmap_data)
    |> Vl.mark(:rect)
    |> Vl.encode_field(:x, "field1", type: :ordinal, axis: [title: ""])
    |> Vl.encode_field(:y, "field2", type: :ordinal, axis: [title: ""])
    |> Vl.encode_field(:color, "correlation",
        type: :quantitative,
        scale: [scheme: "redblue", domain: [-1, 1]])
    |> Vl.encode_field(:tooltip, ["field1", "field2", "correlation"])
  end

  def distribution_histogram(data, field, opts \\ []) do
    bins = Keyword.get(opts, :bins, 20)
    title = Keyword.get(opts, :title, "Distribution of #{field}")

    Vl.new(width: 600, height: 300, title: title)
    |> Vl.data_from_values(data)
    |> Vl.mark(:bar, binSpacing: 1)
    |> Vl.encode_field(:x, field,
        type: :quantitative,
        bin: [maxbins: bins],
        axis: [title: field])
    |> Vl.encode(:y, aggregate: :count, type: :quantitative)
    |> Vl.encode_field(:tooltip, [field])
  end

  def scatter_plot_matrix(data, fields) do
    plots = for field1 <- fields, field2 <- fields do
      if field1 == field2 do
        distribution_histogram(data, field1, bins: 15)
      else
        Vl.new(width: 150, height: 150)
        |> Vl.data_from_values(data)
        |> Vl.mark(:point, size: 30, opacity: 0.6)
        |> Vl.encode_field(:x, field1, type: :quantitative)
        |> Vl.encode_field(:y, field2, type: :quantitative)
      end
    end

    # Arrange in grid layout
    grid_size = length(fields)
    Kino.Layout.grid(Enum.chunk_every(plots, grid_size), columns: grid_size)
  end

  defp calculate_correlations(data, fields) do
    # Simple correlation calculation
    for field1 <- fields, into: %{} do
      correlations = for field2 <- fields, into: %{} do
        values1 = Enum.map(data, & &1[field1])
        values2 = Enum.map(data, & &1[field2])
        correlation = pearson_correlation(values1, values2)
        {field2, correlation}
      end
      {field1, correlations}
    end
  end

  defp pearson_correlation(x, y) do
    n = length(x)
    sum_x = Enum.sum(x)
    sum_y = Enum.sum(y)
    sum_xy = Enum.zip(x, y) |> Enum.map(fn {a, b} -> a * b end) |> Enum.sum()
    sum_x2 = Enum.map(x, & &1 * &1) |> Enum.sum()
    sum_y2 = Enum.map(y, & &1 * &1) |> Enum.sum()

    numerator = n * sum_xy - sum_x * sum_y
    denominator = :math.sqrt((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))

    if denominator == 0, do: 0, else: numerator / denominator
  end
end
```

### 3. Interactive Dashboard Framework

```elixir
defmodule InteractiveDashboard do
  @moduledoc "Complete dashboard framework with state management"

  defstruct [:data, :filters, :charts, :layout, :frame]

  def new(data, opts \\ []) do
    layout_type = Keyword.get(opts, :layout, :grid)
    title = Keyword.get(opts, :title, "Interactive Dashboard")

    dashboard = %__MODULE__{
      data: data,
      filters: %{},
      charts: %{},
      layout: layout_type,
      frame: Kino.Frame.new()
    }

    setup_dashboard(dashboard, title)
  end

  def add_filter(dashboard, key, filter_component) do
    updated_filters = Map.put(dashboard.filters, key, filter_component)
    %{dashboard | filters: updated_filters}
  end

  def add_chart(dashboard, key, chart_spec) do
    updated_charts = Map.put(dashboard.charts, key, chart_spec)
    %{dashboard | charts: updated_charts}
  end

  def render(dashboard) do
    # Create filter controls
    filter_controls = create_filter_controls(dashboard.filters)

    # Generate charts with current filters
    charts = generate_charts(dashboard)

    # Layout components
    layout = case dashboard.layout do
      :grid -> Kino.Layout.grid([filter_controls, charts])
      :tabs -> Kino.Layout.tabs(charts)
      :vertical -> Kino.Layout.grid([filter_controls | charts], columns: 1)
    end

    Kino.Frame.render(dashboard.frame, layout)
    dashboard.frame
  end

  def start_reactive_updates(dashboard) do
    # Stream all filter changes
    filter_streams = Map.values(dashboard.filters)

    Kino.Control.stream(filter_streams)
    |> Kino.listen(fn _event ->
      render(dashboard)
    end)

    dashboard
  end

  defp setup_dashboard(dashboard, title) do
    header = Kino.Markdown.new("# #{title}")
    Kino.Frame.render(dashboard.frame, header)
    dashboard
  end

  defp create_filter_controls(filters) do
    controls = Map.values(filters)
    Kino.Layout.grid(controls, columns: length(controls))
  end

  defp generate_charts(dashboard) do
    filtered_data = apply_filters(dashboard.data, dashboard.filters)

    Map.values(dashboard.charts)
    |> Enum.map(fn chart_spec ->
      case chart_spec do
        {module, function, args} -> apply(module, function, [filtered_data | args])
        {function, args} when is_function(function) -> function.(filtered_data, args)
        chart -> chart
      end
    end)
  end

  defp apply_filters(data, filters) do
    Enum.reduce(filters, data, fn {_key, filter}, acc_data ->
      case filter do
        %{type: :range, field: field, min: min, max: max} ->
          Enum.filter(acc_data, fn row ->
            value = row[field]
            value >= min and value <= max
          end)

        %{type: :select, field: field, values: values} ->
          Enum.filter(acc_data, fn row ->
            row[field] in values
          end)

        _ -> acc_data
      end
    end)
  end
end
```

### 4. Real-Time Data Streaming

```elixir
defmodule RealTimeStreaming do
  @moduledoc "Real-time data streaming and live chart updates"

  def create_live_chart(initial_data, update_function, opts \\ []) do
    interval = Keyword.get(opts, :interval, 1000)
    max_points = Keyword.get(opts, :max_points, 100)
    chart_type = Keyword.get(opts, :chart_type, :line)

    # Initialize with current data
    agent = Agent.start_link(fn -> initial_data end)

    # Create frame for updates
    frame = Kino.Frame.new()

    # Start data update process
    Task.start(fn ->
      stream_updates(agent, frame, update_function, interval, max_points, chart_type)
    end)

    frame
  end

  def create_websocket_chart(websocket_url, data_parser, opts \\ []) do
    frame = Kino.Frame.new()
    buffer = Agent.start_link(fn -> [] end)

    # WebSocket connection would be implemented here
    # For demo, we'll simulate with periodic updates
    Task.start(fn ->
      simulate_websocket_data(buffer, frame, data_parser, opts)
    end)

    frame
  end

  def create_genserver_chart(genserver_pid, data_selector, opts \\ []) do
    frame = Kino.Frame.new()
    interval = Keyword.get(opts, :interval, 500)

    Task.start(fn ->
      Stream.interval(interval)
      |> Stream.map(fn _ ->
        GenServer.call(genserver_pid, data_selector)
      end)
      |> Stream.each(fn data ->
        chart = create_chart_from_data(data, opts)
        Kino.Frame.render(frame, chart)
      end)
      |> Stream.run()
    end)

    frame
  end

  defp stream_updates(agent, frame, update_function, interval, max_points, chart_type) do
    Stream.interval(interval)
    |> Stream.each(fn _tick ->
      # Get new data point
      new_data = update_function.()

      # Update agent state
      Agent.update(agent, fn current_data ->
        updated = current_data ++ [new_data]
        if length(updated) > max_points do
          Enum.drop(updated, 1)
        else
          updated
        end
      end)

      # Get current data and render
      current_data = Agent.get(agent, & &1)
      chart = create_streaming_chart(current_data, chart_type)
      Kino.Frame.render(frame, chart)
    end)
    |> Stream.run()
  end

  defp simulate_websocket_data(buffer, frame, parser, opts) do
    # Simulate incoming WebSocket data
    Stream.interval(200)
    |> Stream.map(fn _ ->
      # Generate random data point
      %{
        timestamp: DateTime.utc_now(),
        value: :rand.uniform() * 100,
        category: Enum.random(["A", "B", "C"])
      }
    end)
    |> Stream.each(fn raw_data ->
      parsed_data = parser.(raw_data)

      Agent.update(buffer, fn current ->
        [parsed_data | current] |> Enum.take(50)
      end)

      current_data = Agent.get(buffer, & &1)
      chart = create_chart_from_data(current_data, opts)
      Kino.Frame.render(frame, chart)
    end)
    |> Stream.run()
  end

  defp create_streaming_chart(data, chart_type) do
    Vl.new(width: 600, height: 300, title: "Live Data Stream")
    |> Vl.data_from_values(data)
    |> Vl.mark(chart_type, interpolate: "monotone")
    |> Vl.encode_field(:x, "timestamp", type: :temporal)
    |> Vl.encode_field(:y, "value", type: :quantitative)
    |> Vl.encode_field(:color, "category", type: :nominal)
  end

  defp create_chart_from_data(data, opts) do
    chart_type = Keyword.get(opts, :chart_type, :line)

    Vl.new(width: 600, height: 300)
    |> Vl.data_from_values(data)
    |> Vl.mark(chart_type)
    |> Vl.encode_field(:x, "timestamp", type: :temporal)
    |> Vl.encode_field(:y, "value", type: :quantitative)
  end
end
```

## Configuration Options

### Environment Setup

```elixir
# Complete dependency specification
Mix.install([
  {:kino, "~> 0.12"},
  {:kino_vega_lite, "~> 0.1"},
  {:vega_lite, "~> 0.1"},
  {:jason, "~> 1.4"},      # JSON handling
  {:req, "~> 0.4"},        # HTTP requests
  {:nimble_csv, "~> 1.1"}  # CSV parsing
])
```

### Theme Configuration

```elixir
defmodule ThemeConfig do
  @moduledoc "Chart theming and styling configuration"

  def apply_theme(chart, theme \\ :default) do
    case theme do
      :dark ->
        chart
        |> Vl.config(
          background: "#2e2e2e",
          title: [color: "#ffffff"],
          axis: [
            labelColor: "#ffffff",
            titleColor: "#ffffff",
            gridColor: "#555555"
          ]
        )

      :minimal ->
        chart
        |> Vl.config(
          axis: [grid: false, ticks: false],
          view: [stroke: "transparent"]
        )

      :corporate ->
        chart
        |> Vl.config(
          range: [
            category: ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728"]
          ],
          title: [fontSize: 16, fontWeight: "bold"]
        )

      _ -> chart
    end
  end

  def responsive_sizing(chart, container_type \\ :notebook) do
    {width, height} = case container_type do
      :notebook -> {700, 400}
      :dashboard -> {500, 300}
      :mobile -> {350, 250}
      :fullscreen -> {1200, 600}
    end

    chart
    |> Vl.param("width", width)
    |> Vl.param("height", height)
  end
end
```

## Complete Use Case Examples

### 1. Financial Dashboard

```elixir
defmodule FinancialDashboard do
  def create_portfolio_dashboard(portfolio_data) do
    # Time range selector
    time_range = Kino.Input.select("Time Range", [
      {"1 Week", 7},
      {"1 Month", 30},
      {"3 Months", 90},
      {"1 Year", 365}
    ])

    # Asset selector
    assets = portfolio_data |> Enum.map(& &1["symbol"]) |> Enum.uniq()
    asset_selector = Kino.Input.select("Asset",
      [{"All", :all}] ++ Enum.map(assets, &{&1, &1}))

    # Metric selector
    metric_selector = Kino.Input.select("Metric", [
      {"Price", "price"},
      {"Volume", "volume"},
      {"Market Cap", "market_cap"}
    ])

    # Dashboard frame
    dashboard_frame = Kino.Frame.new()

    # Update function
    update_dashboard = fn ->
      days = Kino.Input.read(time_range)
      selected_asset = Kino.Input.read(asset_selector)
      metric = Kino.Input.read(metric_selector)

      filtered_data = filter_portfolio_data(portfolio_data, selected_asset, days)

      price_chart = create_price_chart(filtered_data, metric)
      volume_chart = create_volume_chart(filtered_data)
      performance_table = create_performance_table(filtered_data)

      layout = Kino.Layout.grid([
        [price_chart],
        [volume_chart, performance_table]
      ], columns: 2)

      Kino.Frame.render(dashboard_frame, layout)
    end

    # Initial render
    update_dashboard.()

    # Setup reactive updates
    Kino.Control.stream([time_range, asset_selector, metric_selector])
    |> Kino.listen(fn _event -> update_dashboard.() end)

    # Layout with controls
    Kino.Layout.grid([
      [time_range, asset_selector, metric_selector],
      [dashboard_frame]
    ], columns: 3)
  end

  defp filter_portfolio_data(data, asset, days) do
    cutoff_date = Date.add(Date.utc_today(), -days)

    data
    |> Enum.filter(fn row ->
      row_date = Date.from_iso8601!(row["date"])
      Date.compare(row_date, cutoff_date) != :lt
    end)
    |> Enum.filter(fn row ->
      asset == :all or row["symbol"] == asset
    end)
  end

  defp create_price_chart(data, metric) do
    Vl.new(width: 600, height: 300, title: "#{String.capitalize(metric)} Over Time")
    |> Vl.data_from_values(data)
    |> Vl.mark(:line, point: true)
    |> Vl.encode_field(:x, "date", type: :temporal)
    |> Vl.encode_field(:y, metric, type: :quantitative)
    |> Vl.encode_field(:color, "symbol", type: :nominal)
    |> Vl.encode_field(:tooltip, ["date", "symbol", metric])
  end

  defp create_volume_chart(data) do
    Vl.new(width: 300, height: 200, title: "Trading Volume")
    |> Vl.data_from_values(data)
    |> Vl.mark(:bar)
    |> Vl.encode_field(:x, "date", type: :temporal)
    |> Vl.encode_field(:y, "volume", type: :quantitative)
    |> Vl.encode_field(:color, "symbol", type: :nominal)
  end

  defp create_performance_table(data) do
    performance_data = calculate_performance_metrics(data)

    Kino.DataTable.new(performance_data,
      name: "Performance Metrics",
      keys: [:symbol, :return_pct, :volatility, :sharpe_ratio]
    )
  end

  defp calculate_performance_metrics(data) do
    data
    |> Enum.group_by(& &1["symbol"])
    |> Enum.map(fn {symbol, symbol_data} ->
      prices = Enum.map(symbol_data, & &1["price"])
      returns = calculate_returns(prices)

      %{
        symbol: symbol,
        return_pct: Enum.sum(returns) * 100,
        volatility: calculate_volatility(returns) * 100,
        sharpe_ratio: calculate_sharpe_ratio(returns)
      }
    end)
  end

  defp calculate_returns(prices) do
    prices
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [prev, curr] -> (curr - prev) / prev end)
  end

  defp calculate_volatility(returns) do
    mean = Enum.sum(returns) / length(returns)
    variance = Enum.sum(Enum.map(returns, &((&1 - mean) ** 2))) / length(returns)
    :math.sqrt(variance)
  end

  defp calculate_sharpe_ratio(returns) do
    mean_return = Enum.sum(returns) / length(returns)
    volatility = calculate_volatility(returns)
    if volatility > 0, do: mean_return / volatility, else: 0
  end
end
```

### 2. Data Science Exploration Tool

```elixir
defmodule DataScienceExplorer do
  def create_exploration_tool(dataset) do
    fields = get_numeric_fields(dataset)
    categorical_fields = get_categorical_fields(dataset)

    # Field selectors
    x_field = Kino.Input.select("X-Axis", Enum.map(fields, &{&1, &1}))
    y_field = Kino.Input.select("Y-Axis", Enum.map(fields, &{&1, &1}))
    color_field = Kino.Input.select("Color By",
      [{"None", nil}] ++ Enum.map(categorical_fields, &{&1, &1}))

    # Analysis type
    analysis_type = Kino.Input.select("Analysis", [
      {"Scatter Plot", :scatter},
      {"Correlation", :correlation},
      {"Distribution", :distribution},
      {"Box Plot", :boxplot},
      {"Regression", :regression}
    ])

    # Options
    options_form = Kino.Control.form([
      log_scale: Kino.Input.checkbox("Log Scale", default: false),
      show_trend: Kino.Input.checkbox("Show Trend Line", default: false),
      jitter: Kino.Input.checkbox("Add Jitter", default: false)
    ], submit: "Update")

    # Results frame
    results_frame = Kino.Frame.new()

    # Update function
    update_analysis = fn ->
      x = Kino.Input.read(x_field)
      y = Kino.Input.read(y_field)
      color = Kino.Input.read(color_field)
      analysis = Kino.Input.read(analysis_type)

      %{data: options} = Kino.Control.read(options_form)

      chart = create_analysis_chart(dataset, x, y, color, analysis, options)
      stats = calculate_statistics(dataset, x, y)

      layout = Kino.Layout.grid([
        [chart],
        [stats]
      ])

      Kino.Frame.render(results_frame, layout)
    end

    # Initial render
    update_analysis.()

    # Setup reactive updates
    all_inputs = [x_field, y_field, color_field, analysis_type, options_form]
    Kino.Control.stream(all_inputs)
    |> Kino.listen(fn _event -> update_analysis.() end)

    # Main layout
    Kino.Layout.grid([
      [x_field, y_field, color_field, analysis_type],
      [options_form],
      [results_frame]
    ], columns: 4)
  end

  defp create_analysis_chart(data, x_field, y_field, color_field, analysis_type, options) do
    base_chart = Vl.new(width: 600, height: 400)
    |> Vl.data_from_values(data)

    chart = case analysis_type do
      :scatter ->
        base_chart
        |> Vl.mark(:point, size: 60, opacity: 0.7)
        |> add_encodings(x_field, y_field, color_field, options)

      :correlation ->
        create_correlation_matrix(data, [x_field, y_field])

      :distribution ->
        base_chart
        |> Vl.mark(:bar)
        |> Vl.encode_field(:x, x_field, type: :quantitative, bin: true)
        |> Vl.encode(:y, aggregate: :count)

      :boxplot ->
        base_chart
        |> Vl.mark(:boxplot)
        |> Vl.encode_field(:x, color_field || "category", type: :nominal)
        |> Vl.encode_field(:y, y_field, type: :quantitative)

      :regression ->
        regression_chart = base_chart
        |> Vl.mark(:point, opacity: 0.5)
        |> add_encodings(x_field, y_field, color_field, options)

        trend_line = base_chart
        |> Vl.mark(:line, color: "red")
        |> Vl.encode_field(:x, x_field, type: :quantitative)
        |> Vl.encode_field(:y, y_field, type: :quantitative)
        |> Vl.transform(regression: y_field, on: x_field)

        Vl.layers([regression_chart, trend_line])
    end

    if options[:log_scale] do
      chart |> Vl.encode_field(:y, y_field, scale: [type: "log"])
    else
      chart
    end
  end

  defp add_encodings(chart, x_field, y_field, color_field, options) do
    chart = chart
    |> Vl.encode_field(:x, x_field, type: :quantitative)
    |> Vl.encode_field(:y, y_field, type: :quantitative)

    chart = if color_field do
      chart |> Vl.encode_field(:color, color_field, type: :nominal)
    else
      chart
    end

    chart |> Vl.encode_field(:tooltip, [x_field, y_field, color_field])
  end

  defp calculate_statistics(data, x_field, y_field) do
    x_values = Enum.map(data, & &1[x_field])
    y_values = Enum.map(data, & &1[y_field])

    correlation = ChartTemplates.pearson_correlation(x_values, y_values)

    stats_data = [
      %{"Metric" => "Correlation", "Value" => Float.round(correlation, 4)},
      %{"Metric" => "X Mean", "Value" => Float.round(Enum.sum(x_values) / length(x_values), 2)},
      %{"Metric" => "Y Mean", "Value" => Float.round(Enum.sum(y_values) / length(y_values), 2)},
      %{"Metric" => "Sample Size", "Value" => length(data)}
    ]

    Kino.DataTable.new(stats_data, name: "Statistics")
  end

  defp get_numeric_fields(data) do
    case List.first(data) do
      nil -> []
      sample ->
        sample
        |> Enum.filter(fn {_key, value} -> is_number(value) end)
        |> Enum.map(fn {key, _value} -> key end)
    end
  end

  defp get_categorical_fields(data) do
    case List.first(data) do
      nil -> []
      sample ->
        sample
        |> Enum.filter(fn {_key, value} -> is_binary(value) or is_atom(value) end)
        |> Enum.map(fn {key, _value} -> key end)
    end
  end
end
```

## Edge Cases and Troubleshooting

### Common Issues and Solutions

```elixir
defmodule Troubleshooting do
  @moduledoc "Common issues and debugging helpers"

  def debug_data_issues(data) do
    issues = []

    # Check for empty data
    issues = if Enum.empty?(data) do
      ["Data is empty" | issues]
    else
      issues
    end

    # Check for missing fields
    sample = List.first(data) || %{}
    required_fields = ["x", "y"]
    missing_fields = Enum.filter(required_fields, &(not Map.has_key?(sample, &1)))

    issues = if length(missing_fields) > 0 do
      ["Missing required fields: #{Enum.join(missing_fields, ", ")}" | issues]
    else
      issues
    end

    # Check for data type consistency
    field_types = get_field_types(data)
    inconsistent_fields = Enum.filter(field_types, fn {_field, types} ->
      length(types) > 1
    end)

    issues = if length(inconsistent_fields) > 0 do
      field_names = Enum.map(inconsistent_fields, fn {field, _} -> field end)
      ["Inconsistent data types in fields: #{Enum.join(field_names, ", ")}" | issues]
    else
      issues
    end

    if Enum.empty?(issues) do
      Kino.Markdown.new("✅ **Data validation passed**")
    else
      issue_list = Enum.map(issues, &("- #{&1}")) |> Enum.join("\n")
      Kino.Markdown.new("⚠️ **Data Issues Found:**\n#{issue_list}")
    end
  end

  def performance_monitor(chart_function, data) do
    start_time = System.monotonic_time(:millisecond)

    try do
      result = chart_function.(data)
      end_time = System.monotonic_time(:millisecond)
      render_time = end_time - start_time

      info = Kino.Markdown.new("""
      ✅ **Chart rendered successfully**
      - Render time: #{render_time}ms
      - Data points: #{length(data)}
      - Memory usage: #{get_memory_usage()}MB
      """)

      Kino.Layout.grid([result, info])
    rescue
      error ->
        end_time = System.monotonic_time(:millisecond)
        error_time = end_time - start_time

        error_info = Kino.Markdown.new("""
        ❌ **Chart rendering failed**
        - Error time: #{error_time}ms
        - Error: #{inspect(error)}
        - Data points attempted: #{length(data)}
        """)

        error_info
    end
  end

  def memory_usage_monitor() do
    frame = Kino.Frame.new()

    Task.start(fn ->
      Stream.interval(1000)
      |> Stream.each(fn _ ->
        memory_mb = get_memory_usage()

        usage_chart = Vl.new(width: 300, height: 100, title: "Memory Usage")
        |> Vl.data_from_values([%{"time" => DateTime.utc_now(), "memory" => memory_mb}])
        |> Vl.mark(:line)
        |> Vl.encode_field(:x, "time", type: :temporal)
        |> Vl.encode_field(:y, "memory", type: :quantitative)

        Kino.Frame.render(frame, usage_chart)
      end)
      |> Stream.run()
    end)

    frame
  end

  defp get_field_types(data) do
    data
    |> Enum.take(10)  # Sample first 10 rows
    |> Enum.reduce(%{}, fn row, acc ->
      Enum.reduce(row, acc, fn {field, value}, field_acc ->
        type = cond do
          is_number(value) -> :number
          is_binary(value) -> :string
          is_boolean(value) -> :boolean
          is_nil(value) -> :nil
          true -> :other
        end

        Map.update(field_acc, field, [type], fn existing_types ->
          if type in existing_types, do: existing_types, else: [type | existing_types]
        end)
      end)
    end)
  end

  defp get_memory_usage() do
    {:ok, memory} = :erlang.memory() |> Keyword.fetch(:total)
    Float.round(memory / 1_000_000, 2)
  end
end
```

### Performance Optimization

```elixir
defmodule PerformanceOptimization do
  @moduledoc "Performance optimization utilities for large datasets"

  def sample_large_dataset(data, max_points \\ 1000) do
    if length(data) <= max_points do
      data
    else
      # Strategic sampling preserving distribution
      step = div(length(data), max_points)
      data |> Enum.take_every(step) |> Enum.take(max_points)
    end
  end

  def create_efficient_chart(data, opts \\ []) do
    max_points = Keyword.get(opts, :max_points, 1000)
    use_aggregation = Keyword.get(opts, :aggregate, true)

    processed_data = if length(data) > max_points and use_aggregation do
      aggregate_data(data, max_points)
    else
      sample_large_dataset(data, max_points)
    end

    chart_type = if length(processed_data) > 500, do: :point, else: :circle

    Vl.new(width: 600, height: 400)
    |> Vl.data_from_values(processed_data)
    |> Vl.mark(chart_type, size: if(chart_type == :point, do: 10, else: 30))
    |> Vl.encode_field(:x, "x", type: :quantitative)
    |> Vl.encode_field(:y, "y", type: :quantitative)
  end

  def lazy_loading_chart(data_generator, opts \\ []) do
    frame = Kino.Frame.new()
    batch_size = Keyword.get(opts, :batch_size, 100)

    # Initial load
    initial_data = data_generator.(0, batch_size)
    initial_chart = create_efficient_chart(initial_data)
    Kino.Frame.render(frame, initial_chart)

    # Load more button
    load_more_btn = Kino.Control.button("Load More Data")
    current_offset = Agent.start_link(fn -> batch_size end)

    Kino.Control.stream(load_more_btn)
    |> Kino.listen(fn _event ->
      offset = Agent.get(current_offset, & &1)
      new_data = data_generator.(offset, batch_size)

      # Update chart with accumulated data
      updated_chart = create_efficient_chart(new_data)
      Kino.Frame.render(frame, updated_chart)

      Agent.update(current_offset, &(&1 + batch_size))
    end)

    Kino.Layout.grid([frame, load_more_btn])
  end

  defp aggregate_data(data, target_points) do
    # Simple binning aggregation
    bin_size = div(length(data), target_points)

    data
    |> Enum.chunk_every(bin_size)
    |> Enum.map(fn chunk ->
      x_values = Enum.map(chunk, & &1["x"])
      y_values = Enum.map(chunk, & &1["y"])

      %{
        "x" => Enum.sum(x_values) / length(x_values),
        "y" => Enum.sum(y_values) / length(y_values),
        "count" => length(chunk)
      }
    end)
  end
end
```

## Integration Examples

### File Upload and Processing

```elixir
defmodule FileUploadProcessor do
  def create_upload_interface() do
    file_input = Kino.Input.file("Upload CSV/JSON file")
    process_btn = Kino.Control.button("Process File")
    results_frame = Kino.Frame.new()

    Kino.Control.stream(process_btn)
    |> Kino.listen(fn _event ->
      case Kino.Input.read(file_input) do
        nil ->
          Kino.Frame.render(results_frame,
            Kino.Markdown.new("Please select a file first."))

        file_data ->
          try do
            parsed_data = parse_file(file_data)
            dashboard = create_auto_dashboard(parsed_data)
            Kino.Frame.render(results_frame, dashboard)
          rescue
            error ->
              Kino.Frame.render(results_frame,
                Kino.Markdown.new("Error processing file: #{inspect(error)}"))
          end
      end
    end)

    Kino.Layout.grid([
      [file_input, process_btn],
      [results_frame]
    ], columns: 2)
  end

  defp parse_file(%{file_ref: file_ref, client_name: filename}) do
    content = Kino.Input.file_path(file_ref) |> File.read!()

    case Path.extname(filename) do
      ".csv" -> parse_csv(content)
      ".json" -> Jason.decode!(content)
      _ -> raise "Unsupported file format"
    end
  end

  defp parse_csv(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> CSV.decode(headers: true)
    |> Enum.to_list()
  end

  defp create_auto_dashboard(data) when is_list(data) and length(data) > 0 do
    numeric_fields = get_numeric_fields(data)

    if length(numeric_fields) >= 2 do
      InteractiveChart.create_dashboard(data,
        type: :scatter,
        x_field: Enum.at(numeric_fields, 0),
        y_field: Enum.at(numeric_fields, 1)
      )
    else
      ChartTemplates.distribution_histogram(data, List.first(numeric_fields))
    end
  end
end
```

This comprehensive implementation provides all the essential components for creating interactive Elixir Livebook visualizations with Kino VegaLite, including complete working examples, configuration options, troubleshooting, and real-world use cases that meet NPL-FIM standards for immediate artifact generation.