defmodule Noizu.Google.MCP.Tools.SearchConsole.SearchAnalyticsQuery do
  @moduledoc "Query Search Console search analytics."

  use Noizu.MCP.Server.Tool,
    name: "SearchConsole.SearchAnalyticsQuery",
    description:
      "Run a Search Console searchAnalytics/query for a site (clicks, impressions, CTR, position).",
    annotations: [read_only_hint: true]

  input do
    field(:site_url, :string, required: true, description: "Search Console site URL")
    field(:start_date, :string, required: true, description: "Start date YYYY-MM-DD")
    field(:end_date, :string, required: true, description: "End date YYYY-MM-DD")

    field(:dimensions, :string,
      description: "Comma-separated dimensions (query,page,country,device,date). Default: query"
    )

    field(:row_limit, :integer, description: "Max rows (default 25)")
  end

  @impl true
  def call(args, _ctx) do
    dims =
      case args[:dimensions] do
        nil -> ["query"]
        "" -> ["query"]
        s -> s |> String.split(",", trim: true) |> Enum.map(&String.trim/1)
      end

    body = %{
      startDate: args.start_date,
      endDate: args.end_date,
      dimensions: dims,
      rowLimit: args[:row_limit] || 25
    }

    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.SearchConsole.SearchAnalytics.query(args.site_url, body, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
