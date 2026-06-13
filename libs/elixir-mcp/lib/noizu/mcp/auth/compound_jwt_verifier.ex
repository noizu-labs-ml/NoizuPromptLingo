defmodule Noizu.MCP.Auth.CompoundJWTVerifier do
    @moduledoc """
    Built-in compound JWT verifier for dual-auth MCP tokens.

    Verifies a JWT that binds both an **API key** (app-level credential) and a
    **user identity** (from an IdP like Authentik) into a single bearer token.
    This lets MCP tool handlers enforce per-user permissions via
    `ctx.assigns.auth_claims`.

    ## Token format

    The JWT payload must contain:

      * `"sub"` — user identifier (UUID or IdP subject)
      * `"api_key_id"` — the MCP API key UUID
      * `"iss"` — issuer (validated if configured)
      * `"exp"` — expiration timestamp

    Optional claims (`"email"`, `"name"`, `"scopes"`) are passed through to
    `auth_claims` if present.

    ## Configuration

        forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
          server: MyApp.MCP,
          auth: [
            verifier: {Noizu.MCP.Auth.CompoundJWTVerifier, [
              secret: "hmac-shared-secret",     # or {secret_fn_mod, secret_fn_name}
              issuer: "my-app",                  # optional — reject if iss doesn't match
              validate_api_key: &MyApp.Auth.api_key_active?/1  # fn(api_key_id) → boolean
            ]}
          ]

    ## Options

      * `:secret` — HMAC signing secret (binary) or `{module, function}` that
        returns the secret at runtime (for env-var lookup). **Required.**
      * `:issuer` — expected `"iss"` claim. Tokens with a different issuer are
        rejected. Optional.
      * `:algorithms` — allowed JWS algorithms (default `["HS256"]`).
      * `:validate_api_key` — `fun(api_key_id) → boolean` called after signature
        verification to confirm the API key is still active. When omitted, the
        `api_key_id` claim is trusted without a DB lookup.
    """

    @behaviour Noizu.MCP.Auth.TokenVerifier

    @impl true
    def verify(token, _conn_info, opts) when is_list(opts) do
      with {:ok, jwk} <- resolve_jwk(opts),
           algorithms <- Keyword.get(opts, :algorithms, ["HS256"]),
           {true, %JOSE.JWT{fields: claims}, _jws} <- JOSE.JWT.verify_strict(jwk, algorithms, token),
           :ok <- check_expiry(claims),
           :ok <- check_issuer(claims, Keyword.get(opts, :issuer)),
           :ok <- check_api_key_id(claims),
           :ok <- validate_api_key(claims["api_key_id"], Keyword.get(opts, :validate_api_key)) do
        {:ok, claims}
      else
        {false, _, _} -> {:error, :invalid_token}
        {:error, :invalid_token} -> {:error, :invalid_token}
        {:error, :expired} -> {:error, :invalid_token}
        {:error, :bad_issuer} -> {:error, :invalid_token}
        {:error, :missing_api_key} -> {:error, :invalid_token}
        {:error, :api_key_revoked} -> {:error, :invalid_token}
        {:error, :missing_secret} -> {:error, :invalid_token}
        _ -> {:error, :invalid_token}
      end
    end

    defp resolve_jwk(opts) do
      case Keyword.fetch(opts, :secret) do
        {:ok, secret} when is_binary(secret) ->
          {:ok, JOSE.JWK.from_oct(secret)}

        {:ok, {mod, fun}} ->
          case apply(mod, fun, []) do
            secret when is_binary(secret) -> {:ok, JOSE.JWK.from_oct(secret)}
            _ -> {:error, :missing_secret}
          end

        {:ok, fun} when is_function(fun, 0) ->
          case fun.() do
            secret when is_binary(secret) -> {:ok, JOSE.JWK.from_oct(secret)}
            _ -> {:error, :missing_secret}
          end

        _ ->
          {:error, :missing_secret}
      end
    end

    defp check_expiry(%{"exp" => exp}) when is_number(exp) do
      if System.system_time(:second) < exp, do: :ok, else: {:error, :expired}
    end

    defp check_expiry(_), do: :ok

    defp check_issuer(_claims, nil), do: :ok

    defp check_issuer(%{"iss" => iss}, expected) when iss == expected, do: :ok

    defp check_issuer(%{"iss" => _}, _expected), do: {:error, :bad_issuer}

    defp check_issuer(_claims, _expected), do: {:error, :bad_issuer}

    defp check_api_key_id(%{"api_key_id" => id}) when is_binary(id), do: :ok

    defp check_api_key_id(_), do: {:error, :missing_api_key}

    defp validate_api_key(_api_key_id, nil), do: :ok

    defp validate_api_key(api_key_id, fun) when is_function(fun, 1) do
      if fun.(api_key_id), do: :ok, else: {:error, :api_key_revoked}
    end

    defp validate_api_key(api_key_id, {mod, fun}) do
      if apply(mod, fun, [api_key_id]), do: :ok, else: {:error, :api_key_revoked}
    end
  end
