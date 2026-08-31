defmodule Noizu.Google.MCP.Tools.SearchConsole.SitesGet do
  @moduledoc "Get a Search Console site by URL."

  use Noizu.MCP.Server.Tool,
    name: "SearchConsole.SitesGet",
    description:
      "Get permission level for a Search Console site URL (e.g. https://example.com/).",
    annotations: [read_only_hint: true]

  input do
    field(:site_url, :string,
      required: true,
      description:
        "Site URL as registered in Search Console (include trailing slash for URL-prefix properties)."
    )
  end

  @impl true
  def call(%{site_url: site_url}, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.SearchConsole.Sites.get(site_url, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
