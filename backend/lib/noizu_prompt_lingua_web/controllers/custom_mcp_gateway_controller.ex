defmodule NoizuPromptLinguaWeb.CustomMCPGatewayController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Schema.MCPCustomScope

  @doc """
  Org-addressed (canonical) entry: /org/<org_slug>/custom/<slug>/mcp.

  Resolves the org by slug (UUID-or-slug resolver with the Redis-backed slug
  cache), then resolves the scope by (org_id, slug) so a slug can never be
  served outside its owning org.
  """
  def handle_org(conn, %{"org_slug" => org_slug, "slug" => slug}) do
    with {:ok, org_id} <- Organizations.resolve_org_id(org_slug),
         %MCPCustomScope{} = scope <-
           MCPCustomScopes.get_by_org_and_slug(org_id, slug) do
      serve(conn, scope, "/org/#{org_slug}/custom/#{scope.slug}/mcp", org_id)
    else
      _ ->
        not_found(conn)
    end
  end

  @doc """
  Legacy entry: /custom/<slug>/mcp. Permanent alias, never breaks:

  - Browser GET/HEAD of an org-bound scope 301s to its canonical
    /org/<org_slug>/custom/<slug>/mcp URL.
  - Everything else (MCP clients POST JSON-RPC and cannot be relied on to
    re-issue a redirect) is served in place, exactly as before.
  """
  def handle(conn, %{"slug" => slug}) do
    case MCPCustomScopes.get_by_slug(slug) do
      nil ->
        not_found(conn)

      scope ->
        if redirect?(conn, scope) do
          redirect_legacy(conn, scope)
        else
          serve(conn, scope, "/custom/#{scope.slug}/mcp", nil)
        end
    end
  end

  defp redirect?(%{method: method}, scope) do
    method in ["GET", "HEAD"] and scope.organization_id != nil
  end

  defp redirect_legacy(conn, scope) do
    case Organizations.get_slug_by_id(scope.organization_id) do
      nil ->
        # Org row is gone/unreachable — keep the alias resolving in place.
        serve(conn, scope, "/custom/#{scope.slug}/mcp", nil)

      org_slug ->
        location =
          "/org/#{org_slug}/custom/#{scope.slug}/mcp" <>
            if(conn.query_string == "", do: "", else: "?" <> conn.query_string)

        conn
        |> put_status(:moved_permanently)
        |> put_resp_header("location", location)
        |> json(%{redirect: location})
      end
  end

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Custom MCP scope not found"})
  end

  defp serve(conn, scope, path, org_id) do
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
    |> Plug.Conn.assign(:custom_scope_slug, scope.slug)
    |> Plug.Conn.assign(:custom_scope_org_id, org_id)
    |> Map.put(:path_info, [])
    |> Noizu.MCP.Transport.StreamableHTTP.Plug.call(opts)
  end

  def mcp_context(conn) do
    base = %{custom_scope_slug: conn.assigns[:custom_scope_slug]}

    case conn.assigns[:custom_scope_org_id] do
      nil -> base
      org_id -> Map.put(base, :custom_scope_org_id, org_id)
    end
  end
end
