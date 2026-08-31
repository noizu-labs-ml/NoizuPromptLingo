defmodule Noizu.Google.MCP.Tools.SearchConsole.SitemapsList do
  @moduledoc "List sitemaps for a Search Console site."

  use Noizu.MCP.Server.Tool,
    name: "SearchConsole.SitemapsList",
    description: "List sitemaps submitted for a Search Console site.",
    annotations: [read_only_hint: true]

  input do
    field(:site_url, :string, required: true, description: "Search Console site URL")
  end

  @impl true
  def call(%{site_url: site_url}, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.SearchConsole.Sitemaps.list(site_url, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
