defmodule NoizuPromptLinguaWeb.AuthController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Guardian
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLingua.MCPApiKeys

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    alias NoizuPromptLingua.Auth.TokenStore

    case Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}) do
      {:ok, claims} ->
        jti = claims["jti"]

        if jti && TokenStore.valid_refresh_jti?(jti) do
          case Guardian.resource_from_claims(claims) do
            {:ok, session} ->
              TokenStore.revoke_refresh_jti(jti)

              {:ok, access_token, _} =
                Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour})

              {:ok, new_refresh_token, %{"jti" => new_jti}} =
                Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day})

              TokenStore.store_refresh_jti(new_jti)

              conn
              |> put_status(:ok)
              |> json(%{access_token: access_token, refresh_token: new_refresh_token})

            {:error, _} ->
              conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
          end
        else
          conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
        end

      {:error, _} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
    end
  end

  def me(conn, _params) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)
    orgs = Organizations.list_user_organizations(user.id)

    conn
    |> put_status(:ok)
    |> json(%{user: serialize_user(user), organizations: orgs})
  end

  defp resolve_user_from_session(%NoizuPromptLingua.Users.Sessions.UserSession{} = session) do
    case session.user do
      {:ref, _, id} ->
        {:ok, user} = NoizuPromptLingua.Users.get_user(id, Noizu.Context.system())
        user

      %NoizuPromptLingua.Users.User{} = user ->
        user
    end
  end

  # Serialize from the Ecto schema (DB columns) so role/bio are always
  # present — the versioned entity loader does not map every column, which
  # left role and bio missing from GET /auth/me (the api.me() call).
  defp serialize_user(user) do
    u = Repo.get(UserSchema, user.id) || user

    %{
      id: u.id,
      email: u.email,
      user_name: u.user_name,
      handle: u.handle,
      role: u.role,
      bio: u.bio,
      status: u.status,
      verified: u.verified
    }
  end

  # ── User-scoped MCP API keys ──────────────────────────────────────────────────

  def mcp_config(conn, params) do
    # Frontend host may differ from the backend host (separate deployments),
    # so prefer the configured frontend URL when deriving MCP connection URLs.
    host =
      Application.get_env(:noizu_prompt_lingua, :frontend_url)
      |> derive_host() ||
        derive_host(conn) ||
        "localhost"

    # `packaging` selects the endpoint set. Missing param → :default, whose output
    # is byte-identical to the pre-packaging behavior.
    case parse_packaging(Map.get(params, "packaging")) do
      {:ok, packaging} ->
        servers = NoizuPromptLingua.MCPServers.for_host(host, packaging, packaging_opts(params))
        conn |> put_status(:ok) |> json(%{host: host, servers: servers})

      :error ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid packaging; expected 'core+custom' or 'all-in-one'"})
    end
  end

  defp parse_packaging(nil), do: {:ok, :default}
  defp parse_packaging("core+custom"), do: {:ok, :core_custom}
  defp parse_packaging("all-in-one"), do: {:ok, :all_in_one}
  defp parse_packaging(_), do: :error

  defp packaging_opts(params) do
    []
    |> maybe_opt(:organization_id, Map.get(params, "organization_id"))
    |> maybe_opt(:project_id, Map.get(params, "project_id"))
  end

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, value), do: Keyword.put(opts, key, value)

  defp derive_host(nil), do: nil

  defp derive_host(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) and host != "" -> host
      _ -> nil
    end
  end

  defp derive_host(conn) do
    case conn.host do
      host when is_binary(host) and host != "" -> host
      _ -> nil
    end
  end

  @doc """
  Mints an MCP JWT from a pasted raw API key, scoped to the logged-in user.

  Unlike the unauthenticated bootstrap (`POST /api/mcp/token`), this requires a
  valid session and refuses to mint for a key whose owner is not the caller.
  This lets a logged-in user recover setup access for a key whose raw value
  they still hold, without recreating it.
  """
  def mint_mcp_token(conn, %{"key" => raw_key}) when is_binary(raw_key) and raw_key != "" do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)

    case MCPApiKeys.verify_api_key(raw_key) do
      nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "invalid or expired API key"})

      api_key ->
        if api_key.user_id == user.id do
          mcp_user = %{id: user.id, email: user.email, name: user.user_name}
          {:ok, token, expires_at} = NoizuPromptLingua.Token.mint(mcp_user, api_key)

          conn
          |> put_status(:ok)
          |> json(%{token: token, expires_at: DateTime.to_iso8601(expires_at)})
        else
          # Key exists but belongs to a different user — never reveal that.
          conn |> put_status(:unauthorized) |> json(%{error: "invalid or expired API key"})
        end
    end
  end

  def mint_mcp_token(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "key required"})
  end

  def list_mcp_keys(conn, _params) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)

    keys =
      MCPApiKeys.list_for_user(user.id)
      |> Enum.map(&mcp_key_json/1)

    conn |> put_status(:ok) |> json(%{keys: keys})
  end

  def create_mcp_key(conn, %{"key" => key_params}) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)
    label = Map.get(key_params, "label", "default")

    case MCPApiKeys.generate_api_key(user.id, label) do
      {:ok, key, raw_key} ->
        conn
        |> put_status(:created)
        |> json(%{key: mcp_key_json(key), raw_key: raw_key})

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def revoke_mcp_key(conn, %{"id" => id}) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)

    case MCPApiKeys.list_for_user(user.id) |> Enum.find(fn k -> k.id == id end) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Key not found"})

      key ->
        case MCPApiKeys.revoke(id) do
          {:ok, key} ->
            conn |> put_status(:ok) |> json(%{key: mcp_key_json(key)})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
    end
  end

  defp mcp_key_json(key) do
    %{
      id: key.id,
      label: key.label,
      key_prefix: key.key_prefix,
      status: key.status,
      last_used_at: key.last_used_at,
      expires_at: key.expires_at,
      inserted_at: key.inserted_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
