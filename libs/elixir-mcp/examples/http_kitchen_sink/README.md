# http_kitchen_sink

A Streamable HTTP MCP server showing the full `noizu_mcp` feature surface,
mounted via `Plug.Router` on Bandit:

- **Tools**: `echo` (DSL input schema with enum/defaults, progress),
  `long_task` (~2s in 4 steps, progress notifications over SSE, cooperative
  cancellation via `Noizu.MCP.Ctx.cancelled?/1`), `consult_llm`
  (server→client sampling with graceful `isError` fallback when the client
  lacks the `sampling` capability)
- **Toolkit** (`HttpKitchenSink.Toolkit` — several tools in one module via
  `@mcp` annotations): `util.reverse` (data-form input spec, category
  "Utility") and `server_time` (arity-0, category "Time")
- **Hidden tools** — omitted from `tools/list` but callable by name:
  `util.checksum` (`visible: false`, JSON-text input schema) and `catalog`
  (the built-in `Noizu.MCP.Server.Tools.Catalog` discovery tool registered
  with `hidden: true`; call it for full definitions of everything, hidden
  items included, with `type`/`query`/`category`/`include_hidden` filters)
- **Resources**: `config://app` (subscribable JSON) and a `note://{id}`
  resource template with argument completion
- **Prompt**: `brainstorm`, whose `style` argument supports
  `completion/complete` via the `complete: [...]` static-list sugar

## Run

```sh
mix deps.get
mix run --no-halt
```

The MCP endpoint is `http://localhost:4040/mcp` (plus a plain `GET /health`).

Add it to Claude Code:

```sh
claude mcp add --transport http kitchen-sink http://localhost:4040/mcp
```

## Try it with curl

Initialize (the session id comes back in the `mcp-session-id` response
header — `-i` shows it):

```sh
curl -i -X POST http://localhost:4040/mcp \
  -H 'content-type: application/json' \
  -H 'accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{
        "protocolVersion":"2025-11-25",
        "capabilities":{},
        "clientInfo":{"name":"curl","version":"0.0.0"}}}'
```

Then (replace `$SID` with the returned session id):

```sh
curl -X POST http://localhost:4040/mcp \
  -H 'content-type: application/json' \
  -H 'accept: application/json, text/event-stream' \
  -H "mcp-session-id: $SID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized"}'

curl -X POST http://localhost:4040/mcp \
  -H 'content-type: application/json' \
  -H 'accept: application/json, text/event-stream' \
  -H "mcp-session-id: $SID" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{
        "name":"echo","arguments":{"message":"hi","repeat":2,"mode":"loud"}}}'
```

Call `long_task` with a `"_meta":{"progressToken":"p1"}` in `params` to watch
the response upgrade to an SSE stream of progress notifications.

Discover the hidden tools (the `catalog` tool itself never appears in
`tools/list`, but answers by name):

```sh
curl -X POST http://localhost:4040/mcp \
  -H 'content-type: application/json' \
  -H 'accept: application/json, text/event-stream' \
  -H "mcp-session-id: $SID" \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{
        "name":"catalog","arguments":{"type":"tools"}}}'
```

Each entry in the structured result carries a `"hidden"` flag (and a
`"category"` where declared) — then call `util.checksum` directly even though
it was never listed.

## Mounting in Phoenix instead

This example uses a bare `Plug.Router`, but in a Phoenix app it is one line
in your router:

```elixir
forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug, server: HttpKitchenSink.MCP
```

## OAuth

To protect the endpoint as an OAuth 2.1 resource server, pass the plug's
`auth:` option:

```elixir
forward "/mcp",
  to: Noizu.MCP.Transport.StreamableHTTP.Plug,
  init_opts: [
    server: HttpKitchenSink.MCP,
    auth: [
      verifier: {MyApp.MyVerifier, []},
      resource_metadata: "https://example.com/.well-known/oauth-protected-resource"
    ]
  ]
```

The verifier implements the `Noizu.MCP.Auth.TokenVerifier` behaviour (see its
moduledoc); verified claims reach handlers as `ctx.assigns[:auth_claims]`.
This example intentionally leaves auth off.
