defmodule NoizuPromptLingua.OAuth.TokenService do
  @moduledoc """
  Authorization-code + refresh_token grant handlers and access-token minting.
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.OAuth.{AuthorizationServer, Clients, Grants, Jwks, Pkce}
  alias NoizuPromptLingua.Schema.{OAuthAuthorizationCode, OAuthRefreshToken, Users.User}

  # Phase 1: 1 hour access tokens (Phase 2 shortens delegated tokens further).
  @access_ttl 3600
  @code_ttl 600
  @refresh_ttl 30 * 24 * 3600

  # ── Authorization code ───────────────────────────────────────────────────

  def issue_code!(attrs) do
    raw = "ac_" <> random_id(32)
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    %OAuthAuthorizationCode{}
    |> OAuthAuthorizationCode.changeset(%{
      code_hash: hash(raw),
      client_id: attrs.client_id,
      user_id: attrs.user_id,
      redirect_uri: attrs.redirect_uri,
      resource: attrs.resource,
      scope: attrs.scope || "mcp",
      code_challenge: attrs.code_challenge,
      code_challenge_method: "S256",
      grant_id: attrs.grant_id,
      expires_at: DateTime.add(now, @code_ttl, :second),
      inserted_at: now
    })
    |> Repo.insert!()

    raw
  end

  def exchange_code(params) do
    with {:ok, client} <- fetch_client(params["client_id"]),
         :ok <- Clients.authenticate_client(client, params["client_secret"]),
         :ok <- require_grant_type(client, "authorization_code"),
         raw_code when is_binary(raw_code) <- params["code"],
         verifier when is_binary(verifier) <- params["code_verifier"],
         redirect_uri when is_binary(redirect_uri) <- params["redirect_uri"],
         %OAuthAuthorizationCode{} = code_row <- get_code(raw_code),
         :ok <- validate_code(code_row, client.client_id, redirect_uri),
         :ok <- Pkce.verify_s256(verifier, code_row.code_challenge),
         :ok <- consume_code(code_row),
         resource <- params["resource"] || code_row.resource,
         {:ok, user} <- get_user(code_row.user_id) do
      mint_tokens(%{
        user: user,
        client_id: client.client_id,
        resource: resource,
        scope: code_row.scope,
        grant_id: code_row.grant_id
      })
    else
      nil -> {:error, :invalid_grant}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :invalid_request}
    end
  end

  def refresh(params) do
    with {:ok, client} <- fetch_client(params["client_id"]),
         :ok <- Clients.authenticate_client(client, params["client_secret"]),
         :ok <- require_grant_type(client, "refresh_token"),
         raw when is_binary(raw) <- params["refresh_token"],
         %OAuthRefreshToken{} = row <- get_refresh(raw),
         :ok <- validate_refresh(row, client.client_id),
         {:ok, user} <- get_user(row.user_id) do
      # Rotate refresh token
      revoke_refresh(row)

      mint_tokens(%{
        user: user,
        client_id: client.client_id,
        resource: params["resource"] || row.resource,
        scope: row.scope,
        grant_id: row.grant_id
      })
    else
      nil -> {:error, :invalid_grant}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :invalid_request}
    end
  end

  def revoke(params) do
    token = params["token"]
    hint = params["token_type_hint"]

    cond do
      not is_binary(token) or token == "" ->
        :ok

      hint == "refresh_token" or String.starts_with?(token, "rt_") ->
        case get_refresh(token) do
          nil -> :ok
          row -> revoke_refresh(row)
        end

        :ok

      true ->
        # Access tokens are short-lived JWTs — revocation is grant-level.
        # If a refresh token was sent without hint, try it.
        case get_refresh(token) do
          nil -> :ok
          row -> revoke_refresh(row)
        end

        :ok
    end
  end

  def mint_tokens(%{user: user, client_id: client_id} = ctx) do
    resource = Map.get(ctx, :resource)
    scope = Map.get(ctx, :scope) || "mcp"
    grant_id = Map.get(ctx, :grant_id)

    access_ttl = access_ttl_seconds()
    now = System.system_time(:second)
    exp = now + access_ttl

    claims =
      %{
        "sub" => "user:#{user.id}",
        "email" => user.email,
        "name" => user.user_name || user.email,
        "iss" => AuthorizationServer.issuer_url(),
        "iat" => now,
        "exp" => exp,
        "client_id" => client_id,
        "scope" => scope,
        "token_version" => 2,
        "token_use" => "access"
      }
      |> maybe_put("aud", resource)
      |> maybe_put("grant_id", grant_id)
      |> Map.put("user_id", to_string(user.id))

    entry = Jwks.signing_entry()
    header = %{"alg" => entry.alg, "kid" => entry.kid, "typ" => "JWT"}
    {_, access_token} = JOSE.JWT.sign(entry.jwk, header, claims) |> JOSE.JWS.compact()

    raw_refresh = "rt_" <> random_id(32)
    now_dt = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    %OAuthRefreshToken{}
    |> OAuthRefreshToken.changeset(%{
      token_hash: hash(raw_refresh),
      client_id: client_id,
      user_id: user.id,
      grant_id: grant_id,
      resource: resource,
      scope: scope,
      expires_at: DateTime.add(now_dt, @refresh_ttl, :second)
    })
    |> Repo.insert!()

    {:ok,
     %{
       access_token: access_token,
       token_type: "Bearer",
       expires_in: access_ttl,
       refresh_token: raw_refresh,
       scope: scope
     }}
  end

  # ── internals ────────────────────────────────────────────────────────────

  defp fetch_client(nil), do: {:error, :invalid_client}

  defp fetch_client(client_id) do
    case Clients.get_active(client_id) do
      nil -> {:error, :invalid_client}
      client -> {:ok, client}
    end
  end

  defp require_grant_type(%{grant_types: types}, grant) do
    if grant in types, do: :ok, else: {:error, :unauthorized_client}
  end

  defp get_code(raw) do
    Repo.one(from c in OAuthAuthorizationCode, where: c.code_hash == ^hash(raw))
  end

  defp validate_code(row, client_id, redirect_uri) do
    now = DateTime.utc_now()

    cond do
      row.client_id != client_id -> {:error, :invalid_grant}
      row.redirect_uri != redirect_uri -> {:error, :invalid_grant}
      not is_nil(row.consumed_at) -> {:error, :invalid_grant}
      DateTime.compare(row.expires_at, now) != :gt -> {:error, :invalid_grant}
      true -> :ok
    end
  end

  defp consume_code(row) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    case row
         |> OAuthAuthorizationCode.changeset(%{consumed_at: now})
         |> Repo.update() do
      {:ok, _} -> :ok
      _ -> {:error, :invalid_grant}
    end
  end

  defp get_refresh(raw) do
    Repo.one(from t in OAuthRefreshToken, where: t.token_hash == ^hash(raw))
  end

  defp validate_refresh(row, client_id) do
    now = DateTime.utc_now()

    cond do
      row.client_id != client_id -> {:error, :invalid_grant}
      not is_nil(row.revoked_at) -> {:error, :invalid_grant}
      DateTime.compare(row.expires_at, now) != :gt -> {:error, :invalid_grant}
      row.grant_id && is_nil(Grants.get_active(row.grant_id)) -> {:error, :invalid_grant}
      true -> :ok
    end
  end

  defp revoke_refresh(row) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    row
    |> OAuthRefreshToken.changeset(%{revoked_at: now})
    |> Repo.update()

    :ok
  end

  defp get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :invalid_grant}
      user -> {:ok, user}
    end
  end

  defp access_ttl_seconds do
    Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
    |> Keyword.get(:oauth_access_ttl_seconds, @access_ttl)
  end

  defp hash(raw), do: :crypto.hash(:sha256, raw) |> Base.encode16(case: :lower)
  defp random_id(n), do: :crypto.strong_rand_bytes(n) |> Base.url_encode64(padding: false)
  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, _k, ""), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)
end
