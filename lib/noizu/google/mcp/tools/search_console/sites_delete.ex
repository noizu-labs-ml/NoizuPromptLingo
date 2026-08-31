defmodule Noizu.Google.MCP.Tools.SearchConsole.SitesDelete do
  @moduledoc "Remove a site from Search Console."

  use Noizu.MCP.Server.Tool,
    name: "SearchConsole.SitesDelete",
    description: "Remove a site from Search Console. Destructive — requires confirm=true.",
    annotations: [destructive_hint: true]

  input do
    field(:site_url, :string, required: true, description: "Site URL to remove")

    field(:confirm, :boolean,
      required: true,
      description: "Must be true to proceed with delete"
    )
  end

  @impl true
  def call(%{site_url: site_url, confirm: confirm}, _ctx) do
    if confirm != true do
      {:error, "confirm must be true to delete a Search Console site"}
    else
      with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
        Noizu.Google.Api.SearchConsole.Sites.delete(site_url, client: client)
        |> Noizu.Google.MCP.Auth.wrap()
      end
    end
  end
end
