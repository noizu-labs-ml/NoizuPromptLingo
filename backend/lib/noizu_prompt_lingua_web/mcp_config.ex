defmodule NoizuPromptLinguaWeb.MCPConfig do
  @moduledoc """
  Shared options for mounting MCP servers via
  `Noizu.MCP.Transport.StreamableHTTP.Plug`.

  Requests must present a Bearer MCP JWT (minted at `POST /api/mcp/token` from
  an active MCP API key, or later via OAuth). `DualTokenVerifier` accepts:

  - Phase 0+ RS256 (JWKS) tokens with optional `aud`
  - Legacy HS256 compound JWTs (`api_key_id` + shared secret)

  Both paths require an active `api_key_id` when that claim is present.
  """

  @doc "Auth opts: dual-path MCP JWT verification."
  def auth_opts(extra_verifier_opts \\ []) do
    oauth = Application.get_env(:noizu_prompt_lingua, :mcp_oauth, [])

    verifier_opts =
      [
        secret: {NoizuPromptLingua.MCPAuth, :secret},
        issuer: NoizuPromptLingua.Token.issuer(),
        validate_api_key: &NoizuPromptLingua.MCPAuth.api_key_active?/1,
        require_aud: Keyword.get(oauth, :require_aud, false),
        public_scheme: Keyword.get(oauth, :public_scheme, "https")
      ] ++ extra_verifier_opts

    auth = [
      verifier: {NoizuPromptLingua.MCP.DualTokenVerifier, verifier_opts}
    ]

    case Keyword.get(oauth, :resource_metadata_url) do
      url when is_binary(url) and url != "" ->
        Keyword.put(auth, :resource_metadata, url)

      _ ->
        auth
    end
  end

  def plug_opts(server, extra_verifier_opts \\ []) do
    [server: server, origins: :any, auth: auth_opts(extra_verifier_opts)]
  end
end
