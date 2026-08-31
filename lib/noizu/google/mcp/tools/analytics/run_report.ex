defmodule Noizu.Google.MCP.Tools.Analytics.RunReport do
  @moduledoc "Run a GA4 Data API report."

  use Noizu.MCP.Server.Tool,
    name: "Analytics.RunReport",
    description:
      "Run a GA4 Data API report. Metrics/dimensions are comma-separated names (e.g. sessions, city).",
    annotations: [read_only_hint: true]

  input do
    field(:property, :string, required: true, description: "Property id or properties/{id}")
    field(:start_date, :string, required: true, description: "Start date or relative (7daysAgo)")
    field(:end_date, :string, required: true, description: "End date or relative (yesterday)")
    field(:metrics, :string, required: true, description: "Comma-separated metric names")
    field(:dimensions, :string, description: "Comma-separated dimension names (optional)")
  end

  @impl true
  def call(args, _ctx) do
    metrics =
      args.metrics
      |> String.split(",", trim: true)
      |> Enum.map(fn n -> %{name: String.trim(n)} end)

    dimensions =
      case args[:dimensions] do
        nil -> []
        "" -> []
        s -> s |> String.split(",", trim: true) |> Enum.map(fn n -> %{name: String.trim(n)} end)
      end

    body =
      %{
        dateRanges: [%{startDate: args.start_date, endDate: args.end_date}],
        metrics: metrics
      }
      |> then(fn b -> if dimensions == [], do: b, else: Map.put(b, :dimensions, dimensions) end)

    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.AnalyticsData.Reports.run_report(args.property, body, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
