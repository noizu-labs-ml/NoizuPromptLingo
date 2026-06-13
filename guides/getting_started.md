# Getting Started

`noizu_mcp` implements the [Model Context Protocol](https://modelcontextprotocol.io)
— both the **server** side (expose tools, resources, and prompts to AI
applications) and the **client** side (consume MCP servers from Elixir). It
targets spec revision **2025-11-25** and negotiates down to 2025-06-18.

## Installation

```elixir
# mix.exs
defp deps do
  [
    {:noizu_mcp, "~> 0.1"},
    # Optional — only if you serve or consume Streamable HTTP:
    {:plug, "~> 1.16"},
    {:bandit, "~> 1.5"},
    {:req, "~> 0.5"}
  ]
end
```

The HTTP dependencies are optional: a stdio-only server needs none of them,
an HTTP server needs `plug` (and `bandit` if it runs standalone), and an
HTTP client needs `req`.

## Your first server

A server is a module that registers components. A tool is a module with a
schema and a `call/2` function:

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

  @impl true
  def call(%{location: location, units: units}, _ctx) do
    {:ok, "21.5°#{if units == :celsius, do: "C", else: "F"} and clear in #{location}"}
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

There is nothing else to declare: the `tools` capability (and every other
capability) is derived from what you register.

## Running it

Over **stdio** — add it to your supervision tree and start the VM with the
transport attached:

```elixir
# application.ex
children = [
  {MyApp.MCP, transport: :stdio}
]
```

```sh
claude mcp add myapp -- mix run --no-halt
```

Over **Streamable HTTP** — mount the plug in Phoenix or run it on Bandit:

```elixir
# Phoenix router
forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug, server: MyApp.MCP

# or standalone — supervise the server, then the listener
children = [
  MyApp.MCP,
  {Bandit, plug: {Noizu.MCP.Transport.StreamableHTTP.Plug, server: MyApp.MCP}, port: 4040}
]
```

```sh
claude mcp add --transport http myapp http://localhost:4040/mcp
```

## Testing it

`Noizu.MCP.Test` connects an in-memory client straight to your server —
no transport, `async: true` safe:

```elixir
defmodule MyApp.MCPTest do
  use ExUnit.Case, async: true
  import Noizu.MCP.Test

  test "get_weather" do
    client = connect(MyApp.MCP)
    assert {:ok, result} = call_tool(client, "get_weather", %{"location" => "NYC"})
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "NYC"
  end
end
```

## Where to next

- [Tools & Schemas](tools.md) — the field DSL, validation, return contracts
- [Resources & Prompts](resources_and_prompts.md) — resources, templates, subscriptions, prompts, completion
- [The Handler Context](handler_context.md) — progress, logging, cancellation, sampling/elicitation
- [Consuming Servers](client.md) — the client API
- [Streamable HTTP](streamable_http.md) and [stdio](stdio.md) — transport deployment guides
- [Authentication](authentication.md) — OAuth 2.1 on both sides
- [Testing](testing.md) — the full test toolkit
