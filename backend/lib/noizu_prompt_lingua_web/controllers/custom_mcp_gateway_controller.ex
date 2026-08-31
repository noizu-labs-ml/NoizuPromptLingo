defmodule NoizuPromptLinguaWeb.CustomMCPGatewayController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Schema.MCPCustomScope

  @doc """
  Legacy gateway path — `/custom/:slug/mcp`. Permanent alias per the URL
  contract: serves any scope regardless of visibility.
  """
  def handle(conn, %{"slug" => _slug} = params) do
    with {:ok, scope, slug, path} <- resolve_scope(conn, :legacy, params) do
      serve(conn, scope, slug, path)
    else
      {:error, :not_found} -> not_found(conn)
    end
  end

  @doc """
  Account-level gateway path — `/user/:slug/mcp` (W2). Serves scopes whose
  `visibility` is `"account"` or `"shared"`; org-only scopes 404 (no
  existence leak). Shares `resolve_scope/3` with `handle/2` and, once W1's
  `/org/:org_slug/custom/:slug/mcp` route lands, with the org path too.
  """
  def handle_user(conn, %{"slug" => _slug} = params) do
    with {:ok, scope, slug, path} <- resolve_scope(conn, :user, params) do
      serve(conn, scope, slug, path)
    else
      {:error, :not_found} -> not_found(conn)
    end
  end

  @doc """
  Common route resolution for the custom-scope gateway paths.

    * `:legacy` — any existing scope resolves.
    * `:user`   — existing scope whose visibility is `account`/`shared`.

  Returns `{:ok, scope, slug, path}` (path is the route actually hit — the
  endpoint audience-binds to its own URL) or `{:error, :not_found}`.
  """
  def resolve_scope(_conn, route, %{"slug" => slug})
      when route in [:legacy, :user] do
    case MCPCustomScopes.get_by_slug(slug) do
      nil ->
        {:error, :not_found}

      scope ->
        cond do
          route == :legacy -> {:ok, scope, slug, "/custom/#{slug}/mcp"}
          account_visible?(scope) -> {:ok, scope, slug, "/user/#{slug}/mcp"}
          true -> {:error, :not_found}
        end
    end
  end

  def resolve_scope(_, _, _), do: {:error, :not_found}

  defp account_visible?(scope), do: MCPCustomScope.visibility(scope) in ~w(account shared)

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Custom MCP scope not found"})
  end

  defp serve(conn, _scope, slug, path) do
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

  def mcp_context(conn) do
    %{custom_scope_slug: conn.assigns[:custom_scope_slug]}
  end
end
