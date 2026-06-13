# Noizu MCP

[Model Context Protocol](https://modelcontextprotocol.io) for Elixir — **server
and client** — targeting spec revision **2025-11-25** (negotiates down to
2025-06-18).

- 🧩 **Declarative components** — tools (compile-time schema DSL → JSON Schema,
  validated atom-keyed args via [JSV](https://hex.pm/packages/jsv), 2020-12
  dialect), resources + RFC 6570 templates + subscriptions, prompts, completion
- 🧰 **Toolkits** — many small tools in one module via `@mcp` function
  annotations, with schemas as plain data or raw JSON text
- 🗂️ **Hidden items & discovery** — `hidden: true` keeps any tool, prompt, or
  resource callable but unlisted; a built-in catalog tool plus `category`
  metadata (`_meta.category`) give agents a discovery surface
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
> covered by 240+ tests including real-subprocess stdio e2e and Bandit HTTP
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

## Toolkits: multiple tools per module

For a bundle of small tools, skip the one-module-per-tool ceremony:
`use Noizu.MCP.Server.Toolkit` turns `@mcp`-annotated functions into tools,
with schemas declared as plain data (or raw JSON text):

```elixir
defmodule MyApp.Toolkit do
  use Noizu.MCP.Server.Toolkit, category: "Utility"   # default category

  @mcp name: "files.read", category: "Files", description: "Read a file",
       input: [path: [type: :string, required: true]]
  def read_file(%{path: path}, _ctx) do
    case File.read(path) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, "read failed: #{reason}"}
    end
  end

  @mcp description: "Server time (name derives from the function)"
  def server_time, do: {:ok, to_string(DateTime.utc_now())}

  @mcp visible: false   # hidden from tools/list, still callable
  @mcp input: """
  {"type": "object", "properties": {"q": {"type": "string"}}}
  """
  def lookup(args, _ctx), do: {:ok, args["q"] || ""}
end

defmodule MyApp.MCP do
  use Noizu.MCP.Server, name: "myapp", version: "1.0.0"

  tool MyApp.Toolkit              # registers every annotated function
  # tool MyApp.Toolkit, category: "Admin", hidden: true  # opts apply kit-wide
end
```

Annotated functions take `(args, ctx)`, `(args)`, or no arguments. The
data-form `input:` spec gives you the same validated, atom-keyed,
default-applied, enum-cast arguments as the classic `input do ... end` DSL; a
map or JSON-text string is treated as a raw JSON Schema instead. `category:`
rides on the wire in `_meta.category` and is filterable through the catalog
tool below. Full details — `@mcp` option table, merge semantics, the three
schema forms — in the
[Toolkits, Categories & Hidden Tools](guides/toolkits_and_discovery.md) guide.

## Hidden tools & discovery

Mark any tool, prompt, resource, or resource template `hidden: true` to omit it
from `tools/list` / `prompts/list` / `resources/list` responses while keeping
it fully callable by name via `tools/call`, `prompts/get`, and
`resources/read` — useful for internal, privileged, or agent-only surface area
you don't want crowding the default listing.

```elixir
defmodule MyApp.Tools.Internal do
  use Noizu.MCP.Server.Tool,
    name: "internal_tool",
    description: "Agent-only tool",
    hidden: true
  # ...
end

defmodule MyApp.MCP do
  use Noizu.MCP.Server, name: "myapp", version: "1.0.0"

  tool MyApp.Tools.Internal                       # hidden via module flag
  tool MyApp.Tools.GetWeather, hidden: true      # hidden via registration override
  tool Noizu.MCP.Server.Tools.Catalog, hidden: true
end
```

The registration-level `hidden:` option overrides the module default in either
direction (`visible: false` is accepted as an alias for `hidden: true`; for
toolkit registrations it applies to every tool in the kit). The built-in
`Noizu.MCP.Server.Tools.Catalog` tool lets agents discover unpublished items:
it returns full wire definitions (input schemas included) for everything
registered, each tagged with a `"hidden"` flag, with
`type`/`query`/`category`/`include_hidden` filters.

Call dispatch never consults the hidden flag, so hidden items resolve whether
or not they were listed. For session-gated visibility (an "unlock" flow),
override `handle_list_tools/2` with `include_hidden:` driven by session state
and push `notify_changed(:tools)` when it flips — worked example in the
[Toolkits, Categories & Hidden Tools](guides/toolkits_and_discovery.md) guide.

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

## Inspector

`mix mcp.client` launches a native HTML inspector (similar to the official
MCP Inspector) for exploring and exercising MCP servers interactively — tools
with auto-generated forms, resources, prompts, raw JSON-RPC history,
notifications, and a **Pending** tab for answering server-initiated sampling
and elicitation requests without writing any handler code.

```sh
# launch with no target and pick/switch servers inside the app
mix mcp.client

# in-process server module
mix mcp.client MyApp.MCP

# spawn an external stdio server
mix mcp.client --stdio "npx -y @modelcontextprotocol/server-everything"

# connect to a remote Streamable HTTP server
mix mcp.client --url http://localhost:4040/mcp --bearer TOKEN
```

Add `:bandit` and `:plug` (dev-only) to use it; `:req` is also required for
`--url` targets. See [guides/inspector.md](guides/inspector.md) for the full
option reference, tab tour, sampling/elicitation walkthrough, security notes,
and programmatic embedding via `Noizu.MCP.Inspector.start_link/1`.

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
Tools & Schemas · Toolkits & Discovery · Resources & Prompts · the Handler
Context · Client · Streamable HTTP · stdio · Authentication · Testing ·
MCP Inspector — plus a cheatsheet.

## Examples

- [`examples/echo_stdio`](https://github.com/noizu-labs/noizu-mcp/tree/main/examples/echo_stdio)
  — minimal stdio server, ready for `claude mcp add`
- [`examples/no_dsl_server`](https://github.com/noizu-labs/noizu-mcp/tree/main/examples/no_dsl_server)
  — behaviour-only server (no macros), hand-written schemas and dynamic dispatch
- [`examples/http_kitchen_sink`](https://github.com/noizu-labs/noizu-mcp/tree/main/examples/http_kitchen_sink)
  — Streamable HTTP server on Bandit exercising the full feature surface
  (progress, cancellation, sampling, subscriptions, templates, completion,
  a toolkit module, hidden tools + the catalog discovery tool)
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
