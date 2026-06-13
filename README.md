# Noizu MCP

[Model Context Protocol](https://modelcontextprotocol.io) for Elixir — **server
and client** — targeting spec revision **2025-11-25** (negotiates down to
2025-06-18).

- 🧩 **Declarative components** — tools (compile-time schema DSL → JSON Schema,
  validated atom-keyed args via [JSV](https://hex.pm/packages/jsv), 2020-12
  dialect), resources + RFC 6570 templates + subscriptions, prompts, completion
- ⚙️ **Behaviour-driven core** — every macro is sugar over plain callbacks you
  can implement by hand
- 🔌 **Transports**: stdio and Streamable HTTP (Plug — mount in Phoenix or run
  standalone on Bandit) on both the server and the client side
- ↔️ **Full bidirectionality**: server handlers can `sample`, `elicit`, and
  `list_roots` against the connected client mid-call
- 🔐 **OAuth 2.1**: resource-server enforcement (`TokenVerifier`,
  `WWW-Authenticate`, RFC 9728 metadata) and a full client flow (discovery,
  PKCE S256, refresh, `resource` indicators, scope step-up)
- 🧪 **First-class testing** with `Noizu.MCP.Test` over an in-memory transport
  (`async: true` safe), plus conformance checks against the official spec schema
- 📈 Concurrent request handling per session — slow tools never block ping,
  cancellation, or progress

> Status: pre-release (0.1.x). All protocol features above are implemented and
> covered by 160+ tests including real-subprocess stdio e2e and Bandit HTTP
> round-trips. Pre-1.0 API may still move.

## Quickstart: a stdio server

```elixir
# mix.exs
{:noizu_mcp, "~> 0.1"}
```

Define a tool and a server:

```elixir
defmodule MyApp.Tools.GetWeather do
  use Noizu.MCP.Server.Tool,
    name: "get_weather",
    description: "Get current weather for a location",
    annotations: [read_only_hint: true]

  input do
    field :location, :string, required: true, description: "City name or zip code"
    field :units, :enum, values: [:celsius, :fahrenheit], default: :celsius
  end

  output do
    field :temperature, :number, required: true
    field :conditions, :string, required: true
  end

  @impl true
  def call(%{location: location, units: _units}, ctx) do
    Noizu.MCP.Ctx.report_progress(ctx, 0.5, message: "querying provider")
    {:ok, %{temperature: 21.5, conditions: "clear over #{location}"}}
  end
end

defmodule MyApp.MCP do
  use Noizu.MCP.Server,
    name: "myapp",
    version: "1.0.0",
    instructions: "Weather tools for MyApp."

  tool MyApp.Tools.GetWeather
end
```

Run it over stdio from your application supervisor:

```elixir
children = [
  {MyApp.MCP, transport: :stdio}
]
```

Register with Claude Code:

```sh
claude mcp add myapp -- mix run --no-halt
```

Arguments arrive **validated and atom-keyed** (defaults applied, enums cast to
atoms). Validation failures are returned to the model as `isError: true` tool
results it can self-correct from. Return values can be a string, a structured
map (validated against `output`), `Noizu.MCP.Types.Content` blocks, or a full
`ToolResult`; `{:error, "msg"}` produces an execution error, raising produces a
sanitized one.

> **stdout is sacred.** On stdio transports, anything printed to stdout
> corrupts the protocol stream. The transport automatically diverts the default
> Logger handler to stderr — avoid `IO.puts/1` in handler code, and prefer OTP
> releases over `mix run` in production.

## Streamable HTTP (Phoenix / Bandit)

```elixir
# Phoenix router
forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug, server: MyApp.MCP

# or standalone
{Bandit, plug: {Noizu.MCP.Transport.StreamableHTTP.Plug, server: MyApp.MCP}, port: 4040}
```

Sessions, SSE upgrades, `Last-Event-ID` resumability, origin validation, and
DELETE teardown are handled per spec. Protect it as an OAuth 2.1 resource
server with `auth: [verifier: {MyVerifier, []}, resource_metadata: "..."]`
(see `Noizu.MCP.Auth.TokenVerifier`).

## Consuming servers (client)

```elixir
children = [
  {Noizu.MCP.Client,
   name: MyApp.FS,
   transport: {:stdio, command: "npx", args: ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]},
   # or: transport: {:streamable_http, url: "https://api.example.com/mcp",
   #                 auth: {Noizu.MCP.Auth.Static, token: token}}
   handler: MyApp.MCPHandler}   # answers sampling/elicitation; see Noizu.MCP.Client.Handler
]

{:ok, tools}  = Noizu.MCP.Client.list_tools(MyApp.FS)
{:ok, result} = Noizu.MCP.Client.call_tool(MyApp.FS, "read_file", %{"path" => "/tmp/a.txt"},
                  timeout: 60_000, progress: fn p -> IO.inspect(p) end)
```

## Testing your server

```elixir
defmodule MyApp.MCPTest do
  use ExUnit.Case, async: true
  import Noizu.MCP.Test

  setup do: %{client: connect(MyApp.MCP)}

  test "get_weather", %{client: client} do
    assert {:ok, result} = call_tool(client, "get_weather", %{"location" => "NYC"})
    assert result.structured["temperature"]
    assert_progress(client)
  end
end
```

## Escape hatch: no macros

Everything the DSL generates is an overridable callback:

```elixir
defmodule MyApp.RawMCP do
  use Noizu.MCP.Server, name: "raw", version: "1.0.0"

  @impl true
  def handle_list_tools(_cursor, _ctx),
    do: {:ok, [%Noizu.MCP.Types.Tool{name: "echo"}], nil}

  @impl true
  def handle_call_tool("echo", args, _ctx), do: {:ok, inspect(args)}
end
```

## Documentation

Guides on [hexdocs](https://hexdocs.pm/noizu_mcp): Getting Started ·
Tools & Schemas · Resources & Prompts · the Handler Context · Client ·
Streamable HTTP · stdio · Authentication · Testing — plus a cheatsheet.

## Examples

- [`examples/echo_stdio`](https://github.com/noizu-labs/noizu-mcp/tree/main/examples/echo_stdio)
  — minimal stdio server, ready for `claude mcp add`
- [`examples/no_dsl_server`](https://github.com/noizu-labs/noizu-mcp/tree/main/examples/no_dsl_server)
  — behaviour-only server (no macros), hand-written schemas and dynamic dispatch
- [`examples/http_kitchen_sink`](https://github.com/noizu-labs/noizu-mcp/tree/main/examples/http_kitchen_sink)
  — Streamable HTTP server on Bandit exercising the full feature surface
  (progress, cancellation, sampling, subscriptions, templates, completion)
- [`examples/agent_client`](https://github.com/noizu-labs/noizu-mcp/tree/main/examples/agent_client)
  — client demo: spawns `echo_stdio` over stdio, lists and calls tools with
  progress, answers elicitations

## Development

```sh
mix test                 # unit + integration + spec conformance
mix test --include e2e   # also drive examples/echo_stdio as a real subprocess
```

## License

MIT
