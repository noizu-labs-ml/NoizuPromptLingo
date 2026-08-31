defmodule Noizu.Google.MCP.Tools.Analytics.DataStreamsList do
  @moduledoc "List GA4 data streams for a property."

  use Noizu.MCP.Server.Tool,
    name: "Analytics.DataStreamsList",
    description: "List data streams for a GA4 property.",
    annotations: [read_only_hint: true]

  input do
    field(:property, :string,
      required: true,
      description: "Property resource name or id"
    )
  end

  @impl true
  def call(%{property: property}, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.AnalyticsAdmin.DataStreams.list(property, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
