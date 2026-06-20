defmodule NoizuPromptLinguaWeb.MCPConfig do
  @moduledoc """
  Shared options for mounting MCP servers via
  `Noizu.MCP.Transport.StreamableHTTP.Plug`.

  Requests must present a Bearer MCP JWT (minted at `POST /api/mcp/token` from
  an active MCP API key). The `CompoundJWTVerifier` checks the HS256 signature
  against the shared Guardian/MCP secret, the `tobor-locker` issuer, expiry, and
  that the token's `api_key_id` still points at an active key row.
  """

  @doc "Auth opts: verify Bearer MCP JWTs minted from active API keys."
  def auth_opts do
    [
      verifier:
        {Noizu.MCP.Auth.CompoundJWTVerifier,
         [
           secret: {NoizuPromptLingua.MCPAuth, :secret},
           issuer: NoizuPromptLingua.Token.issuer(),
           validate_api_key: &NoizuPromptLingua.MCPAuth.api_key_active?/1
         ]}
    ]
  end

  def plug_opts(server) do
    [server: server, origins: :any, auth: auth_opts()]
  end
end
