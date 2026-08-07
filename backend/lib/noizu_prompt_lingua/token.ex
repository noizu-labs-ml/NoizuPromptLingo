defmodule NoizuPromptLingua.Token do
  @moduledoc """
  Mints MCP JWTs from a user + API key.

  Phase 0 key hygiene:
  - Prefer **asymmetric** signing (RS256 via `NoizuPromptLingua.OAuth.Jwks`)
  - Default TTL **7 days** (was 30)
  - Optional RFC 8707 `aud` / `resource` binding
  - Legacy HS256 still verifiable for already-issued tokens; new mints use
    JWKS unless `alg: :hs256` is forced (tests / emergency)

  Verification is performed by `NoizuPromptLingua.MCP.DualTokenVerifier` on the
  MCP gateway (not here).
  """

  alias NoizuPromptLingua.OAuth.Jwks

  # 7 days — Phase 0 reduced from 30d; Phase 2 shortens delegated tokens further.
  @default_ttl_seconds 7 * 24 * 3600
  @issuer "tobor-locker"

  @doc """
  Mint an MCP access token.

  Options:
  - `:resource` / `:aud` — audience (MCP resource URL)
  - `:ttl_seconds` — override default TTL
  - `:alg` — `:rs256` (default) or `:hs256` (legacy)
  """
  def mint(user, api_key, opts \\ [])

  def mint(%{id: user_id, email: email, name: name}, %{id: api_key_id}, opts)
      when is_list(opts) do
    now = System.system_time(:second)
    ttl = Keyword.get(opts, :ttl_seconds) || configured_ttl()
    exp = now + ttl

    claims =
      %{
        "sub" => to_string(user_id),
        "email" => email,
        "name" => name,
        "api_key_id" => to_string(api_key_id),
        "iss" => issuer(),
        "iat" => now,
        "exp" => exp,
        "token_version" => 1
      }
      |> maybe_put_aud(opts)

    {token, _meta} = sign(claims, opts)
    {:ok, token, DateTime.from_unix!(exp)}
  end

  def issuer, do: Application.get_env(:noizu_prompt_lingua, :mcp_oauth, []) |> Keyword.get(:issuer, @issuer)

  def default_ttl_seconds, do: configured_ttl()

  defp configured_ttl do
    Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
    |> Keyword.get(:access_token_ttl_seconds, @default_ttl_seconds)
  end

  defp maybe_put_aud(claims, opts) do
    aud = Keyword.get(opts, :aud) || Keyword.get(opts, :resource)

    if is_binary(aud) and aud != "" do
      Map.put(claims, "aud", aud)
    else
      claims
    end
  end

  defp sign(claims, opts) do
    case Keyword.get(opts, :alg, :rs256) do
      :hs256 ->
        jwk = JOSE.JWK.from_oct(NoizuPromptLingua.MCPAuth.secret())
        {_, token} = JOSE.JWT.sign(jwk, %{"alg" => "HS256"}, claims) |> JOSE.JWS.compact()
        {token, %{alg: "HS256"}}

      _ ->
        entry = Jwks.signing_entry()

        header = %{
          "alg" => entry.alg,
          "kid" => entry.kid,
          "typ" => "JWT"
        }

        {_, token} = JOSE.JWT.sign(entry.jwk, header, claims) |> JOSE.JWS.compact()
        {token, %{alg: entry.alg, kid: entry.kid}}
    end
  end
end
