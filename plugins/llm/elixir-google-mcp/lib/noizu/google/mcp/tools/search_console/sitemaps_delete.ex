defmodule Noizu.Google.MCP.Tools.SearchConsole.SitemapsDelete do
  @moduledoc "Delete a submitted sitemap. Requires confirm=true."

  use Noizu.MCP.Server.Tool,
    name: "SearchConsole.SitemapsDelete",
    description: "Delete a submitted sitemap. Requires confirm=true.",
    annotations: [destructive_hint: true]

  input do
    field(:site_url, :string, required: true)
    field(:feedpath, :string, required: true)
    field(:confirm, :boolean, required: true)
  end

  @impl true
  def call(%{site_url: site_url, feedpath: feedpath, confirm: confirm}, _ctx) do
    if confirm != true do
      {:error, "confirm must be true to delete a sitemap"}
    else
      with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
        Noizu.Google.Api.SearchConsole.Sitemaps.delete(site_url, feedpath, client: client)
        |> Noizu.Google.MCP.Auth.wrap()
      end
    end
  end
end
