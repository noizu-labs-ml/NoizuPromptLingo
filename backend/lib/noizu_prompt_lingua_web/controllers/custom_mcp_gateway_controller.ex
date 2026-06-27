defmodule NoizuPromptLinguaWeb.CustomMCPGatewayController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.MCPCustomScopes

  def handle(conn, %{"slug" => slug}) do
    case MCPCustomScopes.get_by_slug(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Custom MCP scope not found"})

      _scope ->
        opts =
          NoizuPromptLinguaWeb.MCPConfig.plug_opts(NoizuPromptLingua.MCP.Custom)
          |> Keyword.put(:context, {__MODULE__, :mcp_context})
          |> Noizu.MCP.Transport.StreamableHTTP.Plug.init()

        conn
        |> Plug.Conn.assign(:custom_scope_slug, slug)
        |> Map.put(:path_info, [])
        |> Noizu.MCP.Transport.StreamableHTTP.Plug.call(opts)
    end
  end

  def mcp_context(conn) do
    %{custom_scope_slug: conn.assigns[:custom_scope_slug]}
  end
end
