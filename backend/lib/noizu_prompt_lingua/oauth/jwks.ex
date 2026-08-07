defmodule NoizuPromptLingua.OAuth.Jwks do
  @moduledoc """
  MCP JWT signing keyring and JWKS document (Phase 0 key hygiene).

  Prefer an asymmetric private key from config/env (`MCP_JWT_PRIVATE_KEY` PEM).
  When absent (dev/test), generate an ephemeral RSA key and cache it in
  `:persistent_term` so mint + JWKS stay consistent for the process lifetime.

  Production should always set `MCP_JWT_PRIVATE_KEY` (and optionally
  `MCP_JWT_KID`). Until then, asymmetric mint is still available via the
  ephemeral key, and legacy HS256 verification remains for older tokens.
  """

  @pt_key {__MODULE__, :signing_entry}

  @type signing_entry :: %{
          kid: String.t(),
          alg: String.t(),
          jwk: JOSE.JWK.t(),
          source: :configured | :ephemeral
        }

  @doc "Public JWKS document (`{\"keys\": [...]}`)."
  def document do
    entry = signing_entry()
    public = JOSE.JWK.to_public(entry.jwk)
    {_kty, key_map} = JOSE.JWK.to_map(public)

    key =
      key_map
      |> Map.put("kid", entry.kid)
      |> Map.put("alg", entry.alg)
      |> Map.put("use", "sig")

    %{"keys" => [key]}
  end

  @doc "Signing entry used for new MCP access tokens."
  def signing_entry do
    case :persistent_term.get(@pt_key, :undefined) do
      :undefined ->
        entry = load_signing_entry()
        :persistent_term.put(@pt_key, entry)
        entry

      entry ->
        entry
    end
  end

  @doc "Resolve a verification JWK by kid (falls back to current public key)."
  def verify_jwk(kid) when is_binary(kid) do
    entry = signing_entry()

    if entry.kid == kid or kid == "" do
      {:ok, JOSE.JWK.to_public(entry.jwk), entry.alg}
    else
      # Phase 0: single active key. Rotation store lands with the full AS.
      {:error, :unknown_kid}
    end
  end

  def verify_jwk(_), do: verify_jwk(signing_entry().kid)

  @doc "Forget cached key (tests)."
  def reset! do
    :persistent_term.erase(@pt_key)
    :ok
  end

  defp load_signing_entry do
    cfg = Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])
    kid = Keyword.get(cfg, :kid) || System.get_env("MCP_JWT_KID") || "mcp-1"
    alg = Keyword.get(cfg, :signing_alg, "RS256")

    case Keyword.get(cfg, :private_key_pem) || System.get_env("MCP_JWT_PRIVATE_KEY") do
      pem when is_binary(pem) and pem != "" ->
        jwk = JOSE.JWK.from_pem(pem)
        %{kid: kid, alg: alg, jwk: jwk, source: :configured}

      _ ->
        jwk = JOSE.JWK.generate_key({:rsa, 2048})
        %{kid: kid, alg: "RS256", jwk: jwk, source: :ephemeral}
    end
  end
end
