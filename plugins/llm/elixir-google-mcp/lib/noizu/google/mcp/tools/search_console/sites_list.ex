defmodule Noizu.Google.MCP.Tools.SearchConsole.SitesList do
  @moduledoc "List Search Console sites for the authenticated user."

  use Noizu.MCP.Server.Tool,
    name: "SearchConsole.SitesList",
    description: "List Google Search Console sites (properties) for the authenticated account.",
    annotations: [read_only_hint: true]

  @impl true
  def call(_args, _ctx) do
    with {:ok, client} <- Noizu.Google.MCP.Auth.client() do
      Noizu.Google.Api.SearchConsole.Sites.list(client: client)
      |> Noizu.Google.MCP.Auth.wrap()
    end
  end
end
