defmodule Noizu.Google.MCP.Tools.SearchConsole.SitemapsSubmit do
  @moduledoc "Submit a sitemap feedpath for a Search Console site."

  use Noizu.MCP.Server.Tool,
    name: "SearchConsole.SitemapsSubmit",
    description: "Submit a sitemap feedpath for a Search Console site.",
    annotations: [idempotent_hint: true]

  input do
    field(:site_url, :string, required: true)
    field(:feedpath, :string, required: true, description: "Sitemap URL (feedpath)")
  end

  @impl true
  def call(%{site_url: site_url, feedpath: feedpath}, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.SearchConsole.Sitemaps.submit(site_url, feedpath, client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
