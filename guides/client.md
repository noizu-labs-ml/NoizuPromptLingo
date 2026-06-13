# Consuming Servers (Client)

`Noizu.MCP.Client` is a supervised GenServer: one client per server
connection, addressable by name or pid.

```elixir
children = [
  {Noizu.MCP.Client,
   name: MyApp.FS,
   transport: {:stdio,
     command: "npx",
     args: ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]},
   handler: MyApp.MCPHandler,
   client_info: %{name: "myapp", version: "1.0.0"}}
]
```

Transports:

```elixir
transport: {:stdio, command: "...", args: [...]}
transport: {:streamable_http, url: "https://api.example.com/mcp"}
transport: {:streamable_http, url: ..., auth: {Noizu.MCP.Auth.Static, token: token}}
transport: {MyTransport, opts}          # any Noizu.MCP.Transport.Client impl
```

Requests issued before the handshake completes are queued; use
`Noizu.MCP.Client.await_ready(client, timeout)` when you need to block on
connection (e.g. in scripts).

## Calling tools

```elixir
{:ok, tools} = Noizu.MCP.Client.list_tools(MyApp.FS)

{:ok, result} =
  Noizu.MCP.Client.call_tool(MyApp.FS, "read_file", %{"path" => "/tmp/a.txt"},
    timeout: 60_000,
    progress: fn %{"progress" => p} -> ProgressBar.update(p) end)

result.content      # [%Noizu.MCP.Types.Content{}]
result.structured   # structuredContent map or nil
result.is_error     # execution errors come back as results, not {:error, _}
```

Passing `progress:` automatically attaches a progress token; the callback
runs in its own task. A request that exceeds `timeout:` is **cancelled on
the server** (`notifications/cancelled`) and returns `{:error, :timeout}`.

## The rest of the surface

```elixir
{:ok, resources} = Noizu.MCP.Client.list_resources(client)
{:ok, templates} = Noizu.MCP.Client.list_resource_templates(client)
{:ok, contents}  = Noizu.MCP.Client.read_resource(client, "config://app")
:ok = Noizu.MCP.Client.subscribe_resource(client, "config://app")
:ok = Noizu.MCP.Client.unsubscribe_resource(client, "config://app")

{:ok, prompts} = Noizu.MCP.Client.list_prompts(client)
{:ok, %{messages: messages}} = Noizu.MCP.Client.get_prompt(client, "code_review", %{"code" => src})

{:ok, completion} =
  Noizu.MCP.Client.complete(client, {:prompt, "code_review"}, "style", "fr")

:ok = Noizu.MCP.Client.set_log_level(client, :warning)
{:ok, %{}} = Noizu.MCP.Client.ping(client)

Noizu.MCP.Client.server_info(client)          # %{name: ..., version: ...}
Noizu.MCP.Client.server_capabilities(client)
Noizu.MCP.Client.instructions(client)
```

`list_*` functions auto-paginate by default; pass `page: :first` (then
`page: cursor`) for manual paging. Generic escape hatches: `request/4`,
`notify/3`.

## Async requests

```elixir
ref = Noizu.MCP.Client.async(client, "tools/call", %{"name" => "slow", "arguments" => %{}})
# ... do other work ...
case Noizu.MCP.Client.await(client, ref, 5_000) do
  {:ok, result} -> result
  {:error, :timeout} -> Noizu.MCP.Client.cancel(client, ref, "took too long")
end
```

## Handling server-initiated requests

Servers may call **you**: LLM sampling, user elicitation, roots listing.
Implement `Noizu.MCP.Client.Handler` — the capabilities you implement are
the capabilities the client advertises:

```elixir
defmodule MyApp.MCPHandler do
  @behaviour Noizu.MCP.Client.Handler

  @impl true
  def handle_sampling(params, _state) do
    text = MyApp.LLM.complete(params["messages"], max_tokens: params["maxTokens"])
    {:ok, %{"role" => "assistant",
            "content" => %{"type" => "text", "text" => text},
            "model" => "my-model"}}
  end

  @impl true
  def handle_elicitation(%{"message" => msg}, _state) do
    case MyApp.UI.confirm(msg) do
      {:confirmed, fields} -> {:ok, :accept, fields}
      :declined -> {:ok, :decline}
      :dismissed -> {:ok, :cancel}
    end
  end

  @impl true
  def handle_notification(method, params, _state) do
    Phoenix.PubSub.broadcast(MyApp.PubSub, "mcp", {method, params})
    :ok
  end
end
```

Pass it as `handler: MyApp.MCPHandler` or `handler: {MyApp.MCPHandler, state}`.
Handler callbacks run in supervised tasks — blocking is fine.

Roots are managed on the client itself (the server is notified of changes
automatically):

```elixir
:ok = Noizu.MCP.Client.set_roots(client, [%Noizu.MCP.Types.Root{uri: "file:///work", name: "work"}])
```

Or implement `list_roots/1` on the handler for dynamic roots. To mirror raw
server notifications to a process instead of (or in addition to) a handler,
pass `on_notification: pid` — messages arrive as
`{:mcp_notification, method, params}`.

## Errors

All functions return `{:ok, _} | {:error, reason}` where `reason` is a
`%Noizu.MCP.Error{}` (protocol error from the server), `:timeout`,
`:closed`, or a transport-specific term. Telemetry mirrors the server:
`[:noizu_mcp, :client, :request, :start | :stop | :exception]`.
