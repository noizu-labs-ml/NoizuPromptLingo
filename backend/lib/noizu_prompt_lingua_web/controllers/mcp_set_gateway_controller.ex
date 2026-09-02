defmodule NoizuPromptLinguaWeb.MCPSetGatewayController do
  @moduledoc """
  Tool-set gateway (PRD-N3 §4.4) — mirrors `CustomMCPGatewayController`
  serve/audience-bind mechanics for the `mcp_tool_sets` surface:

      /org/:org_slug/set/:set_slug/mcp                          (org / group sets)
      /org/:org_slug/project/:project_slug/set/:set_slug/mcp    (project sets)

  Gates, in order:

    * `:noizu_prompt_lingua, :tool_sets_enabled` — false ⇒ 404 (default unset ⇒
      404, AC-N3-9; dev flips the flag in config/dev.exs).
    * org + set resolution — unknown org / unknown slug / inactive or expired
      set ⇒ 404 (AC-N3-2 family, one shared body — no existence oracle).
    * project-set binding — `set.project_id == project.id` else 404 (FR-3-6b).
    * `settings.allow_api_keys == false` + API-key identity ⇒ HTTP authz error
      BEFORE session serving (FR-3-7; default missing key ⇒ allowed).
    * audience membership (FR-3-6): org/project sets require org membership;
      group sets require an ACTIVE membership carrying the set's role group
      (`expires_at` respected). Any gate miss ⇒ 404 indistinguishable from an
      unknown slug (no existence leak).

  Verified N3 finding (PRD open question 2): the legacy custom org gateway
  (`CustomMCPGatewayController.handle_org/2`) performs NO caller membership
  check — trust-by-slug. This controller enforces membership from day one; the
  legacy behavior stays frozen until N5.

  Identity is established by verifying the bearer token at the controller
  level (`DualTokenVerifier`, same opts the transport plug uses) so gating can
  run BEFORE the transport session; an unverifiable token skips the identity
  gates and falls through to the plug's RFC 6750 challenge (401 — never a 404,
  so 401s leak nothing about set existence).
  """

  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.MCP.DualTokenVerifier
  alias NoizuPromptLingua.MCP.ToolSetEndpoint
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Projects
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.MCPToolSet
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLinguaWeb.MCPConfig

  @doc "Org / group sets: `/org/:org_slug/set/:set_slug/mcp`."
  def handle_org(conn, %{"org_slug" => org_slug, "set_slug" => set_slug}) do
    path = "/org/#{org_slug}/set/#{set_slug}/mcp"
    metadata = %{"set_org_slug" => org_slug, "set_slug" => set_slug}
    gate(conn, org_slug, nil, set_slug, path, metadata)
  end

  @doc "Project sets: `/org/:org_slug/project/:project_slug/set/:set_slug/mcp`."
  def handle_org_project(conn, %{
        "org_slug" => org_slug,
        "project_slug" => project_slug,
        "set_slug" => set_slug
      }) do
    path = "/org/#{org_slug}/project/#{project_slug}/set/#{set_slug}/mcp"

    metadata = %{
      "set_org_slug" => org_slug,
      "set_project_slug" => project_slug,
      "set_slug" => set_slug
    }

    gate(conn, org_slug, project_slug, set_slug, path, metadata)
  end

  # ── gate pipeline ─────────────────────────────────────────────────────────

  defp gate(conn, org_slug, project_slug, set_slug, path, metadata) do
    # B1: read the RESOLVED flag (config/runtime.exs, TOOL_SETS_ENABLED,
    # default true) — the old `get_env(..., false)` default silently 404'd
    # the set gateway in every env that did not set the flag at compile time.
    if ToolSets.enabled?() do
      with {:ok, org_id} <- Organizations.resolve_org_id(org_slug),
           %MCPToolSet{} = tool_set <- ToolSets.get_for_request(org_id, set_slug),
           :ok <- project_gate(project_slug, tool_set, org_id) do
        authenticated_gate(conn, tool_set, org_id, path, metadata)
      else
        _ -> not_found(conn)
      end
    else
      not_found(conn)
    end
  end

  # Project-set shape: exact project binding (FR-3-6b) — the URL's project must
  # be the set's own. Unknown project ⇒ same 404 (FR-3-9).
  defp project_gate(nil, %MCPToolSet{}, _org_id), do: :ok

  defp project_gate(project_slug, %MCPToolSet{project_id: set_project_id}, org_id) do
    case Projects.get_project_by_slug(org_id, project_slug) do
      %{id: project_id} when project_id == set_project_id -> :ok
      _ -> {:gate_miss, :project_mismatch}
    end
  end

  defp authenticated_gate(conn, tool_set, org_id, path, metadata) do
    case verified_claims(conn, path) do
      {:ok, claims} ->
        with :ok <- allow_api_keys_gate(tool_set, claims),
             :ok <- membership_gate(tool_set, org_id, claims) do
          serve(conn, tool_set, path, org_id, metadata)
        else
          {:authz, message} -> authorization_error(conn, message)
          _ -> not_found(conn)
        end

      _ ->
        # No/invalid bearer: defer to the transport plug's RFC 6750 challenge.
        serve(conn, tool_set, path, org_id, metadata)
    end
  end

  # FR-3-7: API keys refused when the set opts out; missing key (default true)
  # allows them (N2a FR-2A-5).
  defp allow_api_keys_gate(%MCPToolSet{} = tool_set, claims) do
    allowed? = (tool_set.settings || %{}) |> Map.get("allow_api_keys", true)

    if allowed? == false and authenticator(claims) == :api_key do
      {:authz, "api keys not allowed on this set"}
    else
      :ok
    end
  end

  defp authenticator(%{"api_key_id" => id}) when is_binary(id) and id != "", do: :api_key
  defp authenticator(_), do: :oauth

  # Audience membership (FR-3-6): the caller's USER identity (API-key owner or
  # OAuth `sub`) must hold an active membership; group sets additionally bind
  # the set's role group (FR-3-8). Any miss ⇒ 404 (no existence leak).
  defp membership_gate(%MCPToolSet{group_id: group_id}, org_id, claims) do
    case member_ref(claims) do
      nil ->
        {:gate_miss, :no_identity}

      ref ->
        opts = if group_id, do: [group_id: group_id], else: []

        if ScopedMemberships.active_member?("organization", org_id, ref, opts),
          do: :ok,
          else: {:gate_miss, :not_member}
    end
  end

  defp member_ref(%{"api_key_id" => key_id}) when is_binary(key_id) do
    # The key's OWNER (Schema.MCPApiKey belongs_to :user) is the gating
    # identity — DB-resolved, never a client-supplied claim.
    case active_key_user(key_id) do
      nil -> nil
      user_id -> %{type: :user, id: user_id}
    end
  end

  defp member_ref(%{"sub" => sub}) when is_binary(sub) and sub != "",
    do: %{type: :user, id: sub}

  defp member_ref(_), do: nil

  defp active_key_user(key_id) do
    case Repo.get(McpApiKey, key_id) do
      %McpApiKey{status: "active", user_id: user_id} when is_binary(user_id) -> user_id
      _ -> nil
    end
  end

  # ── identity verification (controller-level, pre-session) ────────────────

  defp verified_claims(conn, path) do
    case bearer_token(conn) do
      nil ->
        {:error, :no_token}

      token ->
        resource = "https://#{conn.host}#{path}"

        case MCPConfig.auth_opts(expected_audience: resource)[:verifier] do
          {DualTokenVerifier, vopts} ->
            DualTokenVerifier.verify(token, conn_info(conn), vopts)

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

  # ── serving (mirror of CustomMCPGatewayController.serve/4) ───────────────

  defp serve(conn, tool_set, path, org_id, metadata) do
    resource = "https://#{conn.host}#{path}"

    opts =
      MCPConfig.plug_opts_for_tool_set(ToolSetEndpoint, resource, path, metadata)
      |> Keyword.put(:context, {__MODULE__, :mcp_context})
      |> Noizu.MCP.Transport.StreamableHTTP.Plug.init()

    conn
    |> Plug.Conn.assign(:set_slug, tool_set.slug)
    |> Plug.Conn.assign(:set_org_id, org_id)
    |> Map.put(:path_info, [])
    # Guarded mount (B4): malformed jsonrpc framing answers -32600 inline.
    |> NoizuPromptLinguaWeb.MCP.TransportPlug.call(opts)
  end

  @doc "Route-coordinate stash for the MCP context (legacy introspection surface)."
  def mcp_context(conn) do
    %{
      set_slug: conn.assigns[:set_slug],
      set_org_id: conn.assigns[:set_org_id]
    }
  end

  # ── error bodies ──────────────────────────────────────────────────────────

  # AC-N3-2: every 404 in the family shares ONE body — unknown org, unknown
  # slug, inactive/expired set, project mismatch, non-member/expired
  # membership, flag off. No oracle between them.
  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "MCP tool set not found"})
  end

  defp authorization_error(conn, message) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: message})
  end
end
