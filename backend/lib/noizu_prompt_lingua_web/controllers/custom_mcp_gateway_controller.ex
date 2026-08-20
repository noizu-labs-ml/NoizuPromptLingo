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
        path = "/custom/#{slug}/mcp"
        resource = "https://#{conn.host}#{path}"

        # This endpoint audience-binds to its own URL, so its 401 challenge must
        # advertise its own RFC 9728 document -- the root one declares
        # `<host>/mcp`, and a client honouring that would come back with a token
        # bound to the wrong resource.
        opts =
          NoizuPromptLinguaWeb.MCPConfig.plug_opts(
            NoizuPromptLingua.MCP.Custom,
            [expected_audience: resource],
            resource_metadata:
              NoizuPromptLinguaWeb.MCPConfig.resource_metadata_url_for_path(conn.host, path)
          )
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
