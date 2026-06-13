# stdio Deployment

## Server side

Attach the stdio transport when starting your server:

```elixir
# application.ex
children = [
  {MyApp.MCP, transport: :stdio}
]
```

Run it under any MCP host:

```sh
claude mcp add myapp -- mix run --no-halt
# or, preferred for production:
claude mcp add myapp -- /path/to/release/bin/myapp start
```

On EOF (the host closing stdin) the transport stops the VM cleanly.

> #### stdout is sacred {: .error}
>
> On stdio transports **stdout carries the protocol**. Any stray output —
> `IO.puts/1`, `IO.inspect/1`, a dependency printing a banner, Mix
> compilation output — corrupts the stream and kills the session.
>
> The transport protects you from the biggest offender automatically: at
> startup it removes Erlang's default Logger handler and re-adds it bound
> to **stderr** (this dance is required — `logger_std_h` refuses to change
> its `:type` at runtime). Everything routed through `Logger` is safe.
>
> What it cannot intercept:
>
> - direct `IO.puts/IO.inspect` to `:stdio` in your code — use
>   `IO.puts(:stderr, ...)` or `Logger`
> - `mix run` compiling at launch — compile first, or better, ship an OTP
>   release
> - `:observer`/`dbg` style tooling output

## Checking stdout purity

```sh
{ printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"smoke","version":"1"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'; sleep 2; } \
  | mix run --no-halt 2>/dev/null
```

Every line of output must be JSON-RPC. Anything else will break real hosts.

## Client side

The client launches servers as subprocesses via an Erlang Port:

```elixir
{Noizu.MCP.Client,
 transport: {:stdio, command: "npx", args: ["-y", "@modelcontextprotocol/server-everything"]}}
```

`command` is resolved against `PATH`. Caveats inherent to Ports:

- BEAM cannot half-close a Port's stdin; on shutdown the transport sends
  **SIGTERM** to the OS pid instead. Well-behaved servers exit on it.
- Line-oriented framing with a 1 MB line buffer — pathological servers
  emitting larger single messages need the HTTP transport.

## Logging in stdio *clients*

The diversion described above applies to stdio **servers** only. If your
app is a CLI that both prints to stdout *and* hosts MCP clients, you're
fine — only the server role claims stdout.
