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
        opts = packaging_opts(conn, params)
        servers = NoizuPromptLingua.MCPServers.for_host(host, packaging, opts)
        ala_carte = if packaging == :setup, do: NoizuPromptLingua.MCPServers.ala_carte(host), else: []

        default_scope =
          if packaging == :setup do
            NoizuPromptLingua.MCPServers.setup_scope(opts)
            |> NoizuPromptLingua.MCPCustomScopes.scope_json(host)
          end

        issuer =
          try do
            NoizuPromptLingua.OAuth.AuthorizationServer.issuer_url()
          rescue
            _ -> "https://#{host}"
          end

        mcp_url =
          case default_scope do
            %{url: url} when is_binary(url) -> url
            _ ->
              case List.first(servers) do
                %{url: url} when packaging == :setup and is_binary(url) -> url
                _ -> "https://#{host}/mcp"
              end
          end

        conn
        |> put_status(:ok)
        |> json(%{
          host: host,
          servers: servers,
          ala_carte: ala_carte,
          default_scope: default_scope,
          oauth: %{
            issuer: issuer,
            mcp_url: mcp_url,
            authorization_server_metadata:
              "#{String.trim_trailing(issuer, "/")}/.well-known/oauth-authorization-server"
          },
          legacy_api_key_mint_enabled: NoizuPromptLingua.MCP.LegacyKeys.mint_enabled?()
        })

      :error ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid packaging; expected 'core+custom', 'all-in-one', or 'setup'"})
    end
  end

  def mcp_custom_scope_catalog(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{groups: NoizuPromptLingua.MCPCustomScopes.catalog()})
  end

  def show_default_mcp(conn, _params) do
    case current_user_id(conn) do
      nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "authentication required"})

      user_id ->
        scope = NoizuPromptLingua.MCPCustomScopes.ensure_account_default(user_id)

        conn
        |> put_status(:ok)
        |> json(%{scope: NoizuPromptLingua.MCPCustomScopes.scope_json(scope, mcp_host(conn))})
    end
  end

  def update_default_mcp(conn, params) do
    case current_user_id(conn) do
      nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "authentication required"})

      user_id ->
        scope = NoizuPromptLingua.MCPCustomScopes.ensure_account_default(user_id)
        config = default_mcp_config(params)

        case NoizuPromptLingua.MCPCustomScopes.update(scope, %{"config" => config},
               actor_id: user_id
             ) do
          {:ok, updated} ->
            conn
            |> put_status(:ok)
            |> json(%{scope: NoizuPromptLingua.MCPCustomScopes.scope_json(updated, mcp_host(conn))})

          {:error, :confirmation_required, groups} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{
              error: "confirmation required to disable required core group(s)",
              required_groups: groups,
              confirm_required: true
            })

          {:error, %Ecto.Changeset{} = cs} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: Ecto.Changeset.traverse_errors(cs, fn {msg, _} -> msg end)})
        end
    end
  end

  defp default_mcp_config(%{"scope" => %{"config" => config}}) when is_map(config), do: config
  defp default_mcp_config(%{"config" => config}) when is_map(config), do: config
  defp default_mcp_config(_), do: %{}

  defp mcp_host(conn) do
    Application.get_env(:noizu_prompt_lingua, :frontend_url)
    |> derive_host() ||
      derive_host(conn) ||
      "localhost"
  end

  defp parse_packaging(nil), do: {:ok, :default}
  defp parse_packaging("core+custom"), do: {:ok, :core_custom}
  defp parse_packaging("all-in-one"), do: {:ok, :all_in_one}
  defp parse_packaging("setup"), do: {:ok, :setup}
  defp parse_packaging(_), do: :error

  defp packaging_opts(conn, params) do
    []
    |> maybe_opt(:organization_id, Map.get(params, "organization_id"))
    |> maybe_opt(:project_id, Map.get(params, "project_id"))
    |> maybe_opt(:user_id, current_user_id(conn))
  end

  defp current_user_id(conn) do
    case Guardian.Plug.current_resource(conn) do
      %{user: {:ref, _, id}} when is_binary(id) -> id
      %{user: %{id: id}} when is_binary(id) -> id
      _ -> nil
    end
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
  def mint_mcp_token(conn, params) do
    if not NoizuPromptLingua.MCP.LegacyKeys.mint_enabled?() do
      conn
      |> put_status(:gone)
      |> json(NoizuPromptLingua.MCP.LegacyKeys.disabled_response())
    else
      do_mint_mcp_token(conn, params)
    end
  end

  defp do_mint_mcp_token(conn, params) do
    raw_key = params["key"]
    resource = params["resource"] || params["aud"]
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)

    cond do
      not is_binary(raw_key) or raw_key == "" ->
        conn |> put_status(:bad_request) |> json(%{error: "key required"})

      true ->
        case MCPApiKeys.verify_api_key(raw_key) do
          nil ->
            conn |> put_status(:unauthorized) |> json(%{error: "invalid or expired API key"})

          api_key ->
            if api_key.user_id == user.id do
              mcp_user = %{id: user.id, email: user.email, name: user.user_name}

              mint_opts =
                if is_binary(resource) and resource != "" do
                  [resource: resource]
                else
                  []
                end

              {:ok, token, expires_at} =
                NoizuPromptLingua.Token.mint(mcp_user, api_key, mint_opts)

              conn
              |> put_status(:ok)
              |> json(%{
                token: token,
                expires_at: DateTime.to_iso8601(expires_at),
                token_type: "Bearer",
                expires_in: max(DateTime.diff(expires_at, DateTime.utc_now()), 0)
              })
            else
              # Key exists but belongs to a different user — never reveal that.
              conn |> put_status(:unauthorized) |> json(%{error: "invalid or expired API key"})
            end
        end
    end
  end

  def list_mcp_keys(conn, _params) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)

    keys =
      MCPApiKeys.list_for_user(user.id)
      |> Enum.map(&mcp_key_json/1)

    conn |> put_status(:ok) |> json(%{keys: keys})
  end

  @doc """
  One-step CLI setup: create an API key and mint a JWT in the same request.
  """
  def create_mcp_setup_key(conn, params) do
    if not NoizuPromptLingua.MCP.LegacyKeys.create_enabled?() do
      conn
      |> put_status(:gone)
      |> json(NoizuPromptLingua.MCP.LegacyKeys.disabled_response())
    else
      key_params = Map.get(params, "key") || params
      user = resolve_setup_user(conn)

      if is_nil(user) do
        conn |> put_status(:unauthorized) |> json(%{error: "authentication required"})
      else
        do_create_mcp_setup_key(conn, params, key_params, user)
      end
    end
  end

  defp do_create_mcp_setup_key(conn, params, key_params, user) do
      label = Map.get(key_params, "label") || Map.get(params, "label") || "default"
      resource = params["resource"] || params["aud"] || key_params["resource"]

      case MCPApiKeys.parse_expires_at(Map.get(key_params, "expires_at") || params["expires_at"]) do
        {:ok, expires_at} ->
          case MCPApiKeys.generate_api_key(user.id, label, expires_at: expires_at) do
            {:ok, key, raw_key} ->
              mcp_user = %{id: user.id, email: user.email, name: user.user_name}

              mint_opts =
                if is_binary(resource) and resource != "" do
                  [resource: resource]
                else
                  []
                end

              {:ok, token, expires_at_tok} =
                NoizuPromptLingua.Token.mint(mcp_user, key, mint_opts)

              conn
              |> put_status(:created)
              |> json(%{
                key: mcp_key_json(key),
                raw_key: raw_key,
                token: token,
                expires_at: DateTime.to_iso8601(expires_at_tok),
                token_type: "Bearer",
                expires_in: max(DateTime.diff(expires_at_tok, DateTime.utc_now()), 0)
              })

            {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
              conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

            {:error, reason} ->
              conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
          end

        :error ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "expires_at must be a future ISO8601 timestamp"})
      end
  end

  defp resolve_setup_user(conn) do
    case Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{} = session ->
        resolve_user_from_session(session)

      %{user: {:ref, _, id}} when is_binary(id) ->
        Repo.get(UserSchema, id)

      %{user: %{id: id}} when is_binary(id) ->
        Repo.get(UserSchema, id)

      _ ->
        nil
    end
  end

  def create_mcp_key(conn, %{"key" => key_params}) do
    if not NoizuPromptLingua.MCP.LegacyKeys.create_enabled?() do
      conn
      |> put_status(:gone)
      |> json(NoizuPromptLingua.MCP.LegacyKeys.disabled_response())
    else
      session = Guardian.Plug.current_resource(conn)
      user = resolve_user_from_session(session)
      label = Map.get(key_params, "label", "default")

      with {:ok, expires_at} <- MCPApiKeys.parse_expires_at(Map.get(key_params, "expires_at")) do
        opts =
          case Map.get(key_params, "toolset_config") do
            nil -> [expires_at: expires_at]
            config -> [expires_at: expires_at, toolset_config: config]
          end

        case MCPApiKeys.generate_api_key(user.id, label, opts) do
          {:ok, key, raw_key} ->
            conn
            |> put_status(:created)
            |> json(%{key: mcp_key_json(key), raw_key: raw_key})

          {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
      else
        :error ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "expires_at must be a future ISO8601 timestamp"})
      end
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

  # Per-key toolset management (the caller's own keys) — symmetric with the
  # Key.* MCP tools. Responses are masked (prefix only; raw values never returned).

  def show_mcp_key(conn, %{"id" => id}) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)

    case owned_mcp_key(user.id, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Key not found"})

      key ->
        conn |> put_status(:ok) |> json(%{key: mcp_key_json(key)})
    end
  end

  def update_mcp_key(conn, %{"id" => id} = params) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)

    case owned_mcp_key(user.id, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Key not found"})

      key ->
        with {:ok, key} <- apply_mcp_key_updates(key, params) do
          conn |> put_status(:ok) |> json(%{key: mcp_key_json(key)})
        else
          {:error, %Ecto.Changeset{} = cs} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
    end
  end

  def clone_mcp_key(conn, %{"id" => id} = params) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)

    case owned_mcp_key(user.id, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Key not found"})

      key ->
        label = Map.get(params, "label")

        with {:ok, key, raw_key} <-
               MCPApiKeys.clone(key, user_id: user.id, label: label) do
          conn |> put_status(:created) |> json(%{key: mcp_key_json(key), raw_key: raw_key})
        else
          {:error, %Ecto.Changeset{} = cs} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})

          {:error, reason} ->
            conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
        end
    end
  end

  defp owned_mcp_key(user_id, id) do
    case MCPApiKeys.get(id) do
      %{user_id: ^user_id} = key -> key
      _ -> nil
    end
  end

  defp apply_mcp_key_updates(key, params) do
    attrs =
      %{}
      |> maybe_put_param(:label, params["label"])
      |> maybe_put_param(:status, params["status"])
      |> maybe_put_param(:toolset_config, params["toolset_config"])

    with {:ok, key} <- MCPApiKeys.update(key, attrs, owner_id: key.user_id) do
      apply_mcp_key_scope_copy(key, params["toolset_from_scope"])
    end
  end

  defp apply_mcp_key_scope_copy(key, nil), do: {:ok, key}

  defp apply_mcp_key_scope_copy(key, scope_ref) do
    MCPApiKeys.copy_toolset_from(key, scope_ref)
  end

  defp maybe_put_param(attrs, _key, nil), do: attrs
  defp maybe_put_param(attrs, key, value), do: Map.put(attrs, key, value)

  defp mcp_key_json(key) do
    %{
      id: key.id,
      label: key.label,
      key_prefix: key.key_prefix,
      status: key.status,
      last_used_at: key.last_used_at,
      expires_at: key.expires_at,
      toolset_config: key.toolset_config,
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
