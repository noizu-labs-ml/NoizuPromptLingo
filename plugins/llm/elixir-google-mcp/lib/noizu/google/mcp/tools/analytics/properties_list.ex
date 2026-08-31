defmodule Noizu.Google.MCP.Tools.Analytics.PropertiesList do
  @moduledoc "List GA4 properties under an account."

  use Noizu.MCP.Server.Tool,
    name: "Analytics.PropertiesList",
    description:
      "List GA4 properties. Filter is typically parent:accounts/{id} (Admin API required).",
    annotations: [read_only_hint: true]

  input do
    field(:filter, :string,
      required: true,
      description: "Admin API filter, e.g. parent:accounts/123456"
    )
  end

  @impl true
  def call(%{filter: filter}, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.AnalyticsAdmin.Properties.list(filter: filter, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
