defmodule NoizuPromptLingua.Plugs.AuthenticatedMCP do
  use Plug.Builder

  plug Noizu.MCP.Transport.StreamableHTTP.Plug,
    server: NoizuPromptLingua.MCP,
    origins: :any,
    auth: [
      verifier: {Noizu.MCP.Auth.CompoundJWTVerifier, [
        secret: {NoizuPromptLingua.MCPAuth, :secret},
        issuer: "tobor-locker",
        validate_api_key: &NoizuPromptLingua.MCPAuth.api_key_active?/1
      ]}
    ]
end
