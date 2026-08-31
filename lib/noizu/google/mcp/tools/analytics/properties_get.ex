defmodule Noizu.Google.MCP.Tools.Analytics.PropertiesGet do
  @moduledoc "Get a GA4 property by id."

  use Noizu.MCP.Server.Tool,
    name: "Analytics.PropertiesGet",
    description: "Get a GA4 property (properties/{id} or bare id).",
    annotations: [read_only_hint: true]

  input do
    field(:property, :string,
      required: true,
      description: "Property resource name or id (properties/123 or 123)"
    )
  end

  @impl true
  def call(%{property: property}, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.AnalyticsAdmin.Properties.get(property, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
