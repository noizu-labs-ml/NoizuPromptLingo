defmodule NoizuPromptLingua.OAuth.TokenExchange do
  @moduledoc """
  RFC 8693 token exchange for delegated MCP access tokens.

  A harness holding a user-grade access (or refresh-derived) token exchanges
  it for a short-lived, audience-bound MCP access token with an `act` chain:

      sub: user:<id>
      act: { "sub": "client:<client_id>", "agent": "..." }
      aud: https://sessions.tobor.locker/mcp
      exp: ~5 minutes
  """

  alias NoizuPromptLingua.OAuth.{AuthorizationServer, Clients, Grants, Jwks}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  @delegated_ttl 300
  @grant_type "urn:ietf:params:oauth:grant-type:token-exchange"
  @access_token_type "urn:ietf:params:oauth:token-type:access_token"

  def grant_type, do: @grant_type

  def exchange(params) when is_map(params) do
    with {:ok, client} <- fetch_client(params["client_id"]),
         :ok <- Clients.authenticate_client(client, params["client_secret"]),
         :ok <- require_exchange_allowed(client),
         subject_token when is_binary(subject_token) <- params["subject_token"],
         :ok <- check_token_type(params["subject_token_type"]),
         resource when is_binary(resource) and resource != "" <-
           params["resource"] || params["audience"],
         {:ok, subject_claims} <- verify_subject_token(subject_token),
         {:ok, user} <- user_from_claims(subject_claims),
         :ok <- ensure_grant(user.id, client.client_id, resource, subject_claims),
         act <- build_act(client, params, subject_claims) do
      mint_delegated(%{
        user: user,
        client_id: client.client_id,
        resource: resource,
        scope: params["scope"] || subject_claims["scope"] || "mcp",
        grant_id: subject_claims["grant_id"] || lookup_grant_id(user.id, client.client_id, resource),
        act: act
      })
    else
      nil -> {:error, :invalid_request}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :invalid_request}
    end
  end

  def exchange(_), do: {:error, :invalid_request}

  defp mint_delegated(ctx) do
    access_ttl = delegated_ttl()
    now = System.system_time(:second)
    exp = now + access_ttl

    claims =
      %{
        "sub" => "user:#{ctx.user.id}",
        "email" => ctx.user.email,
        "name" => ctx.user.user_name || ctx.user.email,
        "iss" => AuthorizationServer.issuer_url(),
        "iat" => now,
        "exp" => exp,
        "client_id" => ctx.client_id,
        "scope" => ctx.scope,
        "token_version" => 2,
        "token_use" => "mcp_access",
        "user_id" => to_string(ctx.user.id),
        "aud" => ctx.resource,
        "act" => ctx.act
      }
      |> maybe_put("grant_id", ctx.grant_id)

    entry = Jwks.signing_entry()
    header = %{"alg" => entry.alg, "kid" => entry.kid, "typ" => "JWT"}
    {_, access_token} = JOSE.JWT.sign(entry.jwk, header, claims) |> JOSE.JWS.compact()

    {:ok,
     %{
       access_token: access_token,
       issued_token_type: @access_token_type,
       token_type: "Bearer",
       expires_in: access_ttl,
       scope: ctx.scope
     }}
  end

  defp verify_subject_token(token) do
    # Accept our own JWTs (user-grade or prior delegated) via DualTokenVerifier crypto path.
    opts = [
      secret: {NoizuPromptLingua.MCPAuth, :secret},
      issuer: AuthorizationServer.jwt_issuers(),
      validate_api_key: fn _ -> true end,
      require_aud: false
    ]

    case NoizuPromptLingua.MCP.DualTokenVerifier.verify(
           token,
           %{method: "POST", peer: nil, headers: []},
           opts
         ) do
      {:ok, claims} -> {:ok, claims}
      _ -> {:error, :invalid_grant}
    end
  end

  defp user_from_claims(%{"user_id" => id}) when is_binary(id) do
    case Repo.get(User, id) do
      nil -> {:error, :invalid_grant}
      user -> {:ok, user}
    end
  end

  defp user_from_claims(%{"sub" => "user:" <> id}) do
    case Repo.get(User, id) do
      nil -> {:error, :invalid_grant}
      user -> {:ok, user}
    end
  end

  defp user_from_claims(%{"sub" => id}) when is_binary(id) do
    # Legacy API-key tokens use bare UUID sub
    case Repo.get(User, id) do
      nil -> {:error, :invalid_grant}
      user -> {:ok, user}
    end
  end

  defp user_from_claims(_), do: {:error, :invalid_grant}

  defp ensure_grant(user_id, client_id, resource, claims) do
    grant_id = claims["grant_id"]

    cond do
      is_binary(grant_id) and Grants.get_active(grant_id) != nil ->
        :ok

      Grants.find_active(user_id, client_id, resource) != nil ->
        :ok

      # Auto-create standing grant on first exchange when subject token is valid
      # (user already authorized the client via code flow for any resource).
      true ->
        _ = Grants.approve!(user_id, client_id, resource, claims["scope"] || "mcp")
        :ok
    end
  end

  defp lookup_grant_id(user_id, client_id, resource) do
    case Grants.find_active(user_id, client_id, resource) do
      nil -> nil
      g -> g.grant_id
    end
  end

  defp build_act(client, params, subject_claims) do
    agent = params["actor_token"] || params["agent"] || subject_claims["agent"]

    base = %{"sub" => "client:#{client.client_id}"}

    base =
      if is_binary(agent) and agent != "" do
        Map.put(base, "agent", agent)
      else
        base
      end

    # Nest prior act chain if present (RFC 8693)
    case subject_claims["act"] do
      %{} = prior -> Map.put(base, "act", prior)
      _ -> base
    end
  end

  defp fetch_client(nil), do: {:error, :invalid_client}

  defp fetch_client(client_id) do
    case Clients.get_active(client_id) do
      nil -> {:error, :invalid_client}
      client -> {:ok, client}
    end
  end

  defp require_exchange_allowed(%{grant_types: types}) do
    # Allow if explicitly listed or if client has authorization_code (default DCR clients).
    if @grant_type in types or "authorization_code" in types do
      :ok
    else
      {:error, :unauthorized_client}
    end
  end

  defp check_token_type(nil), do: :ok
  defp check_token_type(@access_token_type), do: :ok
  defp check_token_type("access_token"), do: :ok
  defp check_token_type(_), do: {:error, :invalid_request}

  defp delegated_ttl do
    Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
    |> Keyword.get(:delegated_access_ttl_seconds, @delegated_ttl)
  end

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, _k, ""), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)
end
