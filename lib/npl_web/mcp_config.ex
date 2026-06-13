defmodule NPLWeb.MCPConfig do
  def auth_opts do
    [
      verifier: {Noizu.MCP.Auth.CompoundJWTVerifier, [
        secret: {NoizuPromptLingua.MCPAuth, :secret},
        issuer: "tobor-locker",
        validate_api_key: &NoizuPromptLingua.MCPAuth.api_key_active?/1
      ]}
    ]
  end

  def plug_opts(server) do
    [server: server, origins: :any, auth: auth_opts()]
  end
end
