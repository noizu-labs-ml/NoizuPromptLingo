defmodule Noizu.Google.MCP.Tools.SearchConsole.SitesAdd do
  @moduledoc "Add a site to Search Console."

  use Noizu.MCP.Server.Tool,
    name: "SearchConsole.SitesAdd",
    description: "Add a site URL to Google Search Console for the authenticated user.",
    annotations: [destructive_hint: false, idempotent_hint: true]

  input do
    field(:site_url, :string, required: true, description: "Site URL (e.g. https://example.com/)")
  end

  @impl true
  def call(%{site_url: site_url}, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.SearchConsole.Sites.add(site_url, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
