# Streamable HTTP Deployment

The Streamable HTTP transport is a plug: `Noizu.MCP.Transport.StreamableHTTP.Plug`.
It requires the optional `:plug` dependency (and `:bandit` or any other Plug
server to run on).

## Mounting

```elixir
# Phoenix — forward from your router (outside pipelines that parse the body!)
forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug, server: MyApp.MCP

# Plug.Router
forward "/mcp", to: Noizu.MCP.Transport.StreamableHTTP.Plug, init_opts: [server: MyApp.MCP]

# Standalone Bandit
children = [
  MyApp.MCP,   # the server's supervision tree must be running
  {Bandit, plug: {Noizu.MCP.Transport.StreamableHTTP.Plug, server: MyApp.MCP}, port: 4040}
]
```

> #### Body parsing {: .warning}
>
> The plug reads the raw request body itself. Don't route it through
> `Plug.Parsers` (in Phoenix, `forward` from the router rather than mounting
> inside `:api` pipelines that already parsed JSON).

## Options

| Option | Default | Meaning |
|--------|---------|---------|
| `server` | — (required) | the `use Noizu.MCP.Server` module |
| `origins` | `:localhost` | allowed `Origin` values: `:localhost`, `:any`, or a list of origins |
| `idle_timeout` | 30 min | session expiry with no client activity |
| `request_timeout` | 300 000 ms | per-request budget before the connection gives up |
| `init_timeout` | 30 000 ms | budget for the initialize handshake |
| `keepalive` | 25 000 ms | SSE comment interval on the GET stream |
| `sse_commit_after` | 200 ms | grace period before a POST response commits to SSE |
| `context` | `nil` | `{mod, fun}` mapping `conn` → assigns map at session creation |
| `auth` | `nil` | OAuth resource-server config — see [Authentication](authentication.md) |

## What the plug implements

Per the 2025-11-25 spec:

- **POST** — JSON-RPC requests/notifications/responses. Responses come back
  as `application/json` when they're quick and message-free, or upgrade to
  an SSE stream when the handler emits progress/logs/server-requests (or
  exceeds `sse_commit_after`).
- **GET** — the general SSE stream for unsolicited server→client messages
  (subscriptions, list-changed). One per session; duplicates get `409`.
- **DELETE** — explicit session termination.
- `Mcp-Session-Id` issuance at initialize, `404` after expiry/termination
  (clients re-initialize transparently), `MCP-Protocol-Version` header
  validation, `Origin` allowlisting (`403`).

## Resumability

Messages destined for SSE streams are buffered in a per-server
`Noizu.MCP.Server.EventStore` (bounded ETS ring buffer, 1000 events per
session). A client that reconnects with `Last-Event-ID` receives everything
it missed; on gap (buffer overrun) clients should re-sync by re-listing.
The official client in this library handles both automatically.

## Passing request context to handlers

```elixir
forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
  server: MyApp.MCP,
  context: {MyApp.MCPContext, :assigns}

defmodule MyApp.MCPContext do
  def assigns(conn) do
    %{remote_ip: conn.remote_ip, tenant: conn.assigns[:tenant]}
  end
end
```

The returned map is merged into `ctx.assigns` for every handler in that
session. (With `auth:` configured, verified claims arrive at
`ctx.assigns.auth_claims` without any extra wiring.)

## Scaling notes

Sessions are **node-local** (Registry + ETS). Behind a load balancer you
need sticky routing on the `Mcp-Session-Id` header (or a single node).
Session loss on deploy is benign-by-spec: clients get `404` and
re-initialize. Distributed session stores are a post-1.0 extension point.
