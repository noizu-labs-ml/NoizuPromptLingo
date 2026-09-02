defmodule NoizuPromptLinguaWeb.CustomMCPGatewayController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.MCPCustomScope
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLinguaWeb.MCPConfig

  @doc """
  Org-addressed (canonical) entry: /org/<org_slug>/custom/<slug>/mcp.

  Resolves the org by slug (UUID-or-slug resolver with the Redis-backed slug
  cache), then resolves the scope by (org_id, slug) so a slug can never be
  served outside its owning org.

  Member-gated (mirror of `MCPSetGatewayController`'s audience gate): the
  caller's identity — the MCP key's owner or the OAuth `sub` — must hold an
  ACTIVE membership in the resolved org. Any gate miss ⇒ 404, indistinguishable
  from an unknown slug (no existence leak). A missing/unverifiable bearer is
  NOT a gate miss: it defers to the transport plug's 401 challenge, which
  leaks nothing either.
  """
  def handle_org(conn, %{"org_slug" => org_slug, "slug" => slug}) do
    path = "/org/#{org_slug}/custom/#{slug}/mcp"

    with {:ok, org_id} <- Organizations.resolve_org_id(org_slug),
         %MCPCustomScope{} = scope <- MCPCustomScopes.get_by_org_and_slug(org_id, slug),
         :ok <- membership_gate(conn, org_id, path) do
      serve(conn, scope, path, org_id)
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

  @doc """
  Account-level gateway path — `/user/:slug/mcp` (W2). Serves scopes whose
  `visibility` is `"account"` or `"shared"`; org-only scopes 404 (no
  existence leak). `resolve_scope/3` is the shared resolution point for this
  path (W1's /org route keeps its (org_id, slug) ownership check in
  `handle_org/2`, and the legacy path keeps its 301 redirect behavior).
  """
  def handle_user(conn, %{"slug" => _slug} = params) do
    with {:ok, scope, _slug, path} <- resolve_scope(conn, :user, params) do
      serve(conn, scope, path, nil)
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

  # ── org-addressed membership gate (mirror of MCPSetGatewayController) ──────

  defp membership_gate(conn, org_id, path) do
    case verified_claims(conn, path) do
      {:ok, claims} ->
        case member_ref(claims) do
          nil ->
            {:gate_miss, :no_identity}

          ref ->
            if ScopedMemberships.active_member?("organization", org_id, ref),
              do: :ok,
              else: {:gate_miss, :not_member}
        end

      # No/invalid bearer: defer to the transport plug's RFC 6750 challenge.
      _ ->
        :ok
    end
  end

  # The key's OWNER (Schema.MCPApiKey belongs_to :user) is the gating identity —
  # DB-resolved, never a client-supplied claim.
  defp member_ref(%{"api_key_id" => key_id}) when is_binary(key_id) and key_id != "" do
    case active_key_user(key_id) do
      nil -> nil
      user_id -> %{type: :user, id: user_id}
    end
  end

  # OAuth identity: canonical user ref (strips the "user:" prefix OAuth tokens
  # carry; svc:/client: subs are not users ⇒ no identity ⇒ 404).
  defp member_ref(claims) do
    case NoizuPromptLingua.MCP.Resolve.normalize_user_id(claims) do
      nil -> nil
      user_id -> %{type: :user, id: user_id}
    end
  end

  defp active_key_user(key_id) do
    case Repo.get(McpApiKey, key_id) do
      %McpApiKey{status: "active", user_id: user_id} when is_binary(user_id) -> user_id
      _ -> nil
    end
  end

  # Controller-level identity verification (same opts the transport plug uses)
  # so gating runs BEFORE the transport session.
  defp verified_claims(conn, path) do
    case bearer_token(conn) do
      nil ->
        {:error, :no_token}

      token ->
        resource = "https://#{conn.host}#{path}"

        case MCPConfig.auth_opts(expected_audience: resource)[:verifier] do
          {NoizuPromptLingua.MCP.DualTokenVerifier, vopts} ->
            NoizuPromptLingua.MCP.DualTokenVerifier.verify(token, conn_info(conn), vopts)

          _ ->
            {:error, :verifier_unavailable}
        end
    end
  end

  defp bearer_token(conn) do
    case Enum.find(conn.req_headers, fn {h, _} -> h in ["authorization", "Authorization"] end) do
      {_, value} ->
        case String.split(value, " ", parts: 2) do
          ["Bearer" <> _, token] -> String.trim(token)
          _ -> nil
        end

      nil ->
        nil
    end
  end

  defp conn_info(conn),
    do: %{method: conn.method, peer: conn.remote_ip, headers: conn.req_headers}

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
    # Guarded mount (B4): malformed jsonrpc framing answers -32600 inline.
    |> NoizuPromptLinguaWeb.MCP.TransportPlug.call(opts)
  end

  def mcp_context(conn) do
    base = %{custom_scope_slug: conn.assigns[:custom_scope_slug]}

    case conn.assigns[:custom_scope_org_id] do
      nil -> base
      org_id -> Map.put(base, :custom_scope_org_id, org_id)
    end
  end
end
