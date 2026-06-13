# The Handler Context (`Noizu.MCP.Ctx`)

Every handler — tool `call/2`, resource `read/2`, prompt `get/2`, and every
`handle_*` callback — receives a `%Noizu.MCP.Ctx{}` as its last argument. It
carries session identity, per-session state, and the channel back to the
client.

Handlers run in **supervised Tasks**, never in the session process itself.
A slow tool therefore never blocks ping, cancellation, or progress — and you
may block inside a handler (HTTP calls, `Ctx.sample/2`, …) freely.

## Progress

```elixir
def call(args, ctx) do
  Noizu.MCP.Ctx.report_progress(ctx, 0.25, total: 1.0, message: "fetching")
  # ...
  Noizu.MCP.Ctx.report_progress(ctx, 1.0, total: 1.0)
  {:ok, "done"}
end
```

Progress is sent only when the client supplied a `progressToken` with the
request; otherwise `report_progress/3` is a no-op. Never invent tokens.

## Logging to the client

```elixir
Noizu.MCP.Ctx.info(ctx, "cache miss")
Noizu.MCP.Ctx.log(ctx, :warning, %{"retries" => 3}, logger: "myapp.search")
```

Levels follow the spec (`debug, info, notice, warning, error, critical,
alert, emergency`), each with a convenience function. Messages are filtered
by the client's `logging/setLevel` choice. This is **client-facing** logging
— it does not replace `Logger`.

## Cancellation

Cancellation kills the handler Task, so most handlers need nothing special.
Long loops that must stop *between* units of work can poll:

```elixir
def call(%{items: items}, ctx) do
  Enum.reduce_while(items, [], fn item, acc ->
    if Noizu.MCP.Ctx.cancelled?(ctx),
      do: {:halt, acc},
      else: {:cont, [process(item) | acc]}
  end)
  # ...
end
```

(After cancellation the response is dropped either way — `cancelled?/1` is
about stopping side effects early, not about the reply.)

## Session state

Two scopes, both under `ctx.assigns`:

- `Noizu.MCP.Ctx.assign(ctx, key, value)` — returns an updated ctx for use
  **within** the current handler (and in `init/2`, where it seeds the session).
- `Noizu.MCP.Ctx.put_session(ctx, key, value)` — writes through to the
  session so **subsequent requests** observe it.

```elixir
@impl Noizu.MCP.Server
def init(ctx, _params), do: {:ok, Noizu.MCP.Ctx.assign(ctx, :tenant, :acme)}

def call(args, ctx) do
  Noizu.MCP.Ctx.put_session(ctx, :last_query, args.query)
  {:ok, "tenant=#{ctx.assigns.tenant}"}
end
```

On authenticated HTTP transports the verified token claims appear at
`ctx.assigns.auth_claims` (see [Authentication](authentication.md)).

## Talking back to the client

A server handler can make requests **to** the client mid-call. Each is
capability-checked (`{:error, :capability_not_supported}` when the client
didn't advertise it) and takes its own `timeout:`:

```elixir
# LLM sampling
{:ok, result} =
  Noizu.MCP.Ctx.sample(ctx, %{
    "messages" => [%{"role" => "user", "content" => %{"type" => "text", "text" => q}}],
    "maxTokens" => 200
  }, timeout: 30_000)
result["content"]["text"]

# Elicitation (ask the human)
schema = %{"type" => "object", "properties" => %{"confirm" => %{"type" => "boolean"}},
           "required" => ["confirm"]}

case Noizu.MCP.Ctx.elicit(ctx, "Proceed with deletion?", schema, timeout: 60_000) do
  {:ok, {:accept, %{"confirm" => true}}} -> ...
  {:ok, {:accept, _}} -> ...
  {:ok, :decline} -> ...
  {:ok, :cancel} -> ...
  {:error, reason} -> ...
end

# Client filesystem roots
{:ok, roots} = Noizu.MCP.Ctx.list_roots(ctx, timeout: 5_000)
Enum.map(roots, & &1.uri)
```

These block only the handler Task. They are deliberately unavailable from
the session process itself (returning `{:error, :not_allowed_in_session_process}`)
to prevent deadlock — in practice you only hit this if you call them outside
a handler.

## Telemetry

Server-side requests emit `[:noizu_mcp, :server, :request, :start | :stop |
:exception]` with method/session metadata — attach standard
`:telemetry` handlers for metrics.
