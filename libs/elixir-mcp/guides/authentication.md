# Authentication (OAuth 2.1)

MCP's authorization model (HTTP transports only): the MCP server is an OAuth
2.1 **resource server**; tokens are issued by an external authorization
server discovered via RFC 9728 protected-resource metadata. `noizu_mcp`
implements both halves — enforcement on the server, the full flow on the
client. It never implements an authorization server.

## Server side: enforcing tokens

Implement `Noizu.MCP.Auth.TokenVerifier` and hand it to the plug:

```elixir
defmodule MyApp.MCPTokenVerifier do
  @behaviour Noizu.MCP.Auth.TokenVerifier

  @impl true
  def verify(token, _conn_info, _opts) do
    case MyApp.Auth.verify_jwt(token) do
      # IMPORTANT: validate audience (RFC 8707) — the token must be *for this server*
      {:ok, %{"aud" => "https://api.example.com/mcp"} = claims} ->
        if "mcp" in String.split(claims["scope"] || "", " "),
          do: {:ok, claims},
          else: {:error, :insufficient_scope, %{scope: "mcp"}}

      _ ->
        {:error, :invalid_token}
    end
  end
end

forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
  server: MyApp.MCP,
  auth: [
    verifier: {MyApp.MCPTokenVerifier, []},
    resource_metadata: "https://api.example.com/.well-known/oauth-protected-resource"
  ]
```

The plug then:

- rejects missing/invalid tokens with **401** + a `WWW-Authenticate: Bearer`
  challenge carrying `resource_metadata` (how clients bootstrap discovery)
- rejects `{:error, :insufficient_scope, %{scope: ...}}` with **403** and a
  `scope` hint (how clients know to step up)
- on success exposes the claims to every handler as
  `ctx.assigns.auth_claims`

One adjacent caution: hiding tools from `tools/list` (`hidden: true`, see
[Toolkits, Categories & Hidden Tools](toolkits_and_discovery.md)) is
presentation, not authorization — hidden tools remain callable by name.
Enforce real permissions here (token scopes, `ctx.assigns.auth_claims`
checks inside handlers), never via listing visibility.

Serve the RFC 9728 document next to it:

```elixir
forward "/.well-known/oauth-protected-resource", Noizu.MCP.Auth.ProtectedResourceMetadataPlug,
  resource: "https://api.example.com/mcp",
  authorization_servers: ["https://auth.example.com"],
  scopes_supported: ["mcp"]
```

## Client side

### Static tokens

For machine-to-machine setups where you already hold a credential:

```elixir
transport: {:streamable_http,
  url: "https://api.example.com/mcp",
  auth: {Noizu.MCP.Auth.Static, token: System.fetch_env!("MCP_TOKEN")}}
```

### Full OAuth 2.1 flow

`Noizu.MCP.Auth.OAuth` runs the whole chain on the first 401:
`WWW-Authenticate` → RFC 9728 resource metadata (falling back to the
default well-known path on the MCP origin) → RFC 8414 / OIDC authorization
server discovery → PKCE (S256) authorization request with `state` and the
RFC 8707 `resource` indicator → code exchange → automatic refresh and
scope step-up on later 401/403s.

One thing cannot live in a library: putting the authorization URL in front
of a human. You supply that as the `authorize_user` callback:

```elixir
transport: {:streamable_http,
  url: "https://api.example.com/mcp",
  auth: {Noizu.MCP.Auth.OAuth,
    client_id: "my-client",
    redirect_uri: "http://localhost:8914/callback",
    scope: "mcp",
    authorize_user: &MyApp.OAuthBrowser.run/1}}
```

`authorize_user` receives the fully-built authorization URL and must return
`{:ok, %{"code" => code, "state" => state}}` — typically by opening the
browser and catching the redirect on a loopback listener (the
`redirect_uri` above). Return `{:error, reason}` to abort.

> #### Validate this seam early {: .tip}
>
> `authorize_user` is the API most likely to evolve before 1.0. If you wire
> it into a real product, please report friction.

### Custom strategies

Anything token-shaped can implement `Noizu.MCP.Auth.ClientStrategy`:
`init/1` (receives your opts plus `:mcp_url`), `headers/1` (returns headers
+ updated state), and `handle_unauthorized/3` (parse the challenge, refresh
or re-acquire, return `{:retry, state}` or `{:error, reason, state}`). The
transport retries a request at most twice after `{:retry, _}`.
