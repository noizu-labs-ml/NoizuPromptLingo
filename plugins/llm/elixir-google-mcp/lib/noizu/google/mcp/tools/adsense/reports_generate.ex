defmodule Noizu.Google.MCP.Tools.AdSense.ReportsGenerate do
  @moduledoc "Generate an AdSense Management API report."

  use Noizu.MCP.Server.Tool,
    name: "AdSense.ReportsGenerate",
    description:
      "Generate an AdSense report. metrics/dimensions are comma-separated (e.g. ESTIMATED_EARNINGS,DATE).",
    annotations: [read_only_hint: true]

  input do
    field(:account, :string, required: true, description: "accounts/pub-… or pub-…")
    field(:start_date, :string, required: true, description: "YYYY-MM-DD")
    field(:end_date, :string, required: true, description: "YYYY-MM-DD")
    field(:metrics, :string, required: true, description: "Comma-separated metrics")
    field(:dimensions, :string, description: "Comma-separated dimensions")
    field(:currency_code, :string, description: "e.g. USD")
    field(:limit, :integer)
  end

  @impl true
  def call(args, _ctx) do
    metrics = split(args.metrics)
    dimensions = split(args[:dimensions] || "")

    opts =
      [
        start_date: args.start_date,
        end_date: args.end_date,
        metrics: metrics
      ]
      |> then(fn o ->
        if dimensions == [], do: o, else: Keyword.put(o, :dimensions, dimensions)
      end)
      |> maybe(:currency_code, args[:currency_code])
      |> maybe(:limit, args[:limit])

    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.AdSense.Reports.generate(args.account, Keyword.put(opts, :client, client))
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end

  defp split(nil), do: []
  defp split(""), do: []
  defp split(s), do: s |> String.split(",", trim: true) |> Enum.map(&String.trim/1)

  defp maybe(kw, _k, nil), do: kw
  defp maybe(kw, _k, ""), do: kw
  defp maybe(kw, k, v), do: Keyword.put(kw, k, v)
end
