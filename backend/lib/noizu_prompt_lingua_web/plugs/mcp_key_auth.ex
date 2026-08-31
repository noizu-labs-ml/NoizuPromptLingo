defmodule NoizuPromptLinguaWeb.Plugs.McpKeyAuth do
  @moduledoc """
  Per-consumer MCP API key authentication over plain HTTP (W7 component plane).

  Accepts either:

  1. the **raw** MCP API key (bcrypt-verified via `NoizuPromptLingua.MCPApiKeys
     .verify_api_key/1` — the same secret `POST /api/mcp/token` exchanges), or
  2. a minted **MCP JWT** whose claims carry `api_key_id` (verified via
     `NoizuPromptLingua.MCP.DualTokenVerifier`).

  On success the key owner becomes the request identity: a synthetic
  `%UserSession{}` is installed as the Guardian current resource and
  `:auth_method` is set to `:api_key`, so `NoizuPromptLinguaWeb.AuthPipeline`
  skips JWT verification — exactly the contract `ApiKeyAuth` established for
  fixed service keys. The resolved key is exposed as `conn.assigns.mcp_api_key`
  (per-key toolset config reads) and `conn.assigns.mcp_api_key_id`.

  Two modes:

    * `require: true` — keyed-only endpoints (component registry). No/invalid
      key halts with 401.
    * `require: false` — pass-through. With no key the conn proceeds unchanged
      so the normal Guardian pipeline can authenticate it; a resolved key
      upgrades the request. Used to admit MCP keys to specific existing
      user-session endpoints (boards/tickets listings consumed by the
      embedded queue-board component).

  Authorization is NOT granted here beyond the owner's existing memberships:
  org-scoped controllers still run their own role checks against the key
  owner, which scopes reads to orgs the key's owner can see.
  """

  @behaviour Plug
  import Plug.Conn
  import Guardian.Plug, only: [put_current_resource: 2]

  alias NoizuPromptLingua.MCP.DualTokenVerifier
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey

  @impl true
  def init(opts), do: %{require: Keyword.get(opts, :require, false)}

  @impl true
  def call(conn, %{require: require}) do
    case resolve_key(conn) do
      {:ok, key} ->
        authenticate(conn, key)

      nil when require ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "Authentication required"}))
        |> halt()

      nil ->
        conn
    end
  end

  # Raw key first (bcrypt), then MCP JWT claims → api_key_id → active key.
  defp resolve_key(conn) do
    case extract_key(conn) do
      token when is_binary(token) and token != "" ->
        case MCPApiKeys.verify_api_key(token) do
          %McpApiKey{} = key -> {:ok, key}
          _ -> key_from_jwt(conn, token)
        end

      _ ->
        nil
    end
  end

  defp key_from_jwt(conn, token) do
    case DualTokenVerifier.verify(token, conn, []) do
      {:ok, %{"api_key_id" => api_key_id}} when is_binary(api_key_id) ->
        case Repo.get(McpApiKey, api_key_id) do
          %McpApiKey{status: "active"} = key -> {:ok, key}
          _ -> nil
        end

      _ ->
        nil
    end
  rescue
    _ -> nil
  end

  defp extract_key(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token | _] -> String.trim(token)
      _ -> get_req_header(conn, "x-api-key") |> List.first()
    end
  end

  defp authenticate(conn, key) do
    case load_user(key.user_id) do
      {:ok, user} when user != nil ->
        session = build_session(user, key)

        conn
        |> put_current_resource(session)
        |> assign(:auth_method, :api_key)
        |> assign(:mcp_api_key, key)
        |> assign(:mcp_api_key_id, key.id)

      _ ->
        # Key resolves but its owner no longer exists — treat as anonymous.
        conn
    end
  end

  defp load_user(user_id) do
    try do
      NoizuPromptLingua.Users.get_user(user_id, Noizu.Context.system())
    rescue
      _ -> nil
    end
  end

  defp build_session(user, key) do
    %NoizuPromptLingua.Users.Sessions.UserSession{
      id: nil,
      user: {:ref, NoizuPromptLingua.Users.User, user.id},
      status: :active,
      details: %{auth_method: :mcp_api_key, api_key_id: key.id}
    }
  end
end
