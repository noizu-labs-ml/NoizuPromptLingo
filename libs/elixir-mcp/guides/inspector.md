# Inspector (`mix mcp.client`)

`mix mcp.client` launches `Noizu.MCP.Inspector` — a localhost-only
single-page HTML client for exploring and exercising MCP servers
interactively. It covers the same ground as the official `mcp dev` / MCP
Inspector tool but runs inside your Elixir project with no separate install.

It supports three target modes:

- **In-process module** — connects directly to a `use Noizu.MCP.Server`
  module running in the same VM (no subprocess, no HTTP).
- **Stdio subprocess** — spawns an arbitrary command as a stdio MCP server.
- **Remote Streamable HTTP** — connects to any MCP server over HTTP.

Requires the optional `:bandit` and `:plug` dependencies (add `:req` for
`--url` targets).

## Dependencies

```elixir
# mix.exs (dev only)
{:bandit, "~> 1.5", only: :dev},
{:plug,   "~> 1.16", only: :dev},

# add this too if you need --url targets:
{:req, "~> 0.5", only: :dev}
```

## Quickstart

### No target — pick one in the browser

```sh
mix mcp.client
```

Launches the inspector with no connection; the Connection tab offers a target
picker — a dropdown of MCP server modules discovered in the running VM (any
module exporting `__mcp__/1` from applications depending on `:noizu_mcp`),
plus stdio-command and HTTP-URL forms. You can switch targets at any time
from the same panel; switching tears down the old session and resets every
tab.

### In-process server module

The most common use case during development — connects directly without
spawning any subprocess:

```sh
mix mcp.client MyApp.MCP
```

The inspector starts on port 6274 (default), prints a tokenized URL, and
opens your browser automatically:

```
MCP inspector running at:

    http://127.0.0.1:6274/?token=<random>

Target: in-process MyApp.MCP
Press Ctrl-C to stop.
```

### External stdio server

```sh
mix mcp.client --stdio "npx -y @modelcontextprotocol/server-everything"

# with working directory and environment variables
mix mcp.client --stdio "node server.js" \
  --cd /path/to/server \
  --env NODE_ENV=development \
  --env DEBUG=mcp
```

### Remote Streamable HTTP server

```sh
mix mcp.client --url http://localhost:4040/mcp

# with a bearer token
mix mcp.client --url https://api.example.com/mcp --bearer my-token
```

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--port PORT` | `6274` | HTTP port; `0` picks a random free port |
| `--no-open` | — | Skip auto-opening the browser |
| `--stdio CMD` | — | Spawn `CMD` (shell-split) as a stdio server |
| `--cd DIR` | — | Working directory for the stdio subprocess |
| `--env K=V` | — | Environment variable for stdio subprocess (repeatable) |
| `--url URL` | — | Streamable HTTP target URL |
| `--bearer TOKEN` | — | Bearer token for `--url` targets |
| `--name NAME` | `noizu-mcp-inspector` | Advertised client name |
| `--version VSN` | library version | Advertised client version |

## UI Tab Tour

### Connection

Shows server info, negotiated capabilities, and server instructions.
Displays the connection target descriptor. Provides a **Config export**
button that generates a `claude_desktop`-style config entry for the current
target.

### Tools

Lists every tool exposed by the server. Each tool shows its description and
a form generated from the JSON Schema input definition. Fill in the fields
and click **Run** — progress appears inline and a **Cancel** button is
available for long-running calls. Results appear below the form.

### Resources

Lists resources and resource templates. You can read a resource URI
directly, subscribe/unsubscribe to change notifications, and expand RFC 6570
templates with arguments; completion suggestions are requested from the
server as you type.

### Prompts

Lists prompts with their argument schemas. Fill in arguments (with
server-side completion) and preview the rendered message list.

### History

Scrollable log of raw JSON-RPC frames in both directions — useful for
debugging protocol issues or verifying request/response structure.

### Notifications

Real-time log of `notifications/*` messages from the server (resource
updates, list changes, log messages). Filterable by log level.

### Pending

When the server calls back into the client (sampling or elicitation), the
request appears here and blocks until you answer. See the sampling and
elicitation walkthrough below.

## Sampling and Elicitation Walkthrough

Some MCP servers call back into the client mid-tool-call to request LLM
inference (**sampling**) or human input (**elicitation**). The inspector
handles both without requiring you to write a handler.

1. Trigger a tool call that initiates a sampling or elicitation request.
2. The **Pending** tab badge increments; the tool call stays in-progress.
3. Open the **Pending** tab. Each parked request shows its kind and params.
4. For **sampling**: review the message list and model preferences, fill in
   a response message, and click **Submit**.
5. For **elicitation**: review the prompt and schema, fill in the fields (or
   click **Decline** / **Cancel**), then click **Accept**.
6. The server call unblocks and completes.

Tool calls run with infinite timeout while a pending request is parked, so
there is no race between human think-time and server timeouts.

## Things Worth Poking

- **Progress + cancellation** — call a slow tool with the Tools tab; watch
  inline progress and hit **Cancel** mid-run.
- **Hidden tools** — items registered `hidden: true` won't appear in the
  tool list, but you can still invoke them by name. A registered
  `Noizu.MCP.Server.Tools.Catalog` tool returns full definitions of
  everything, hidden included — see
  [Toolkits, Categories & Hidden Tools](toolkits_and_discovery.md).
- **Validation behaviour** — send arguments that violate the input schema
  and confirm you get an `isError: true` result (SEP-1303), not a protocol
  error.
- **Subscriptions** — subscribe to a subscribable resource in the Resources
  tab, then trigger `MyApp.MCP.notify_resource_updated/1` from an IEx shell
  and watch the update arrive in the Notifications tab.

## Security Notes

- The inspector binds exclusively to `127.0.0.1`. It never listens on
  external interfaces.
- A random 256-bit bearer token is generated per run and required on every
  `/api` request. Without the token in the URL, the UI cannot load.
- The SSE bridge validates the `Origin` header to localhost to prevent
  cross-origin access from other browser tabs.
- Browser-supplied target descriptors for module connections only accept
  already-loaded atoms — the server never calls `String.to_atom/1` on
  untrusted input.
- Frames larger than 64 KB are truncated in the History tab (a preview and
  byte count are shown instead).

## Programmatic Embedding

`mix mcp.client` is a thin wrapper. You can start `Noizu.MCP.Inspector`
directly from a supervision tree or a Mix task of your own:

```elixir
token = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

{:ok, _pid} =
  Noizu.MCP.Inspector.start_link(
    token:   token,
    port:    6274,
    # optional:
    target:      {:module, MyApp.MCP}, # omit to pick a target in the browser
    name:        MyApp.Inspector,      # OTP name; defaults to Noizu.MCP.Inspector
    client_info: %{name: "myapp-inspector", version: "1.0.0"}
  )

url = "#{Noizu.MCP.Inspector.url(MyApp.Inspector)}?token=#{token}"
```

Other target forms:

```elixir
# stdio subprocess
target: {:stdio, "node server.js",
                 args: ["--port", "9000"],
                 env: %{"NODE_ENV" => "dev"},
                 cd: "/path/to/server"}

# remote Streamable HTTP
target: {:url, "https://api.example.com/mcp", bearer: "my-token"}
target: {:url, "https://api.example.com/mcp",
               headers: [{"authorization", "Bearer my-token"}]}
```

`Noizu.MCP.Inspector.port/1` and `Noizu.MCP.Inspector.url/1` accept the OTP
name passed as `:name` (or default to `Noizu.MCP.Inspector`). With
`port: 0` the OS picks a free port; call `Noizu.MCP.Inspector.port/1` after
startup to retrieve it.

## How It Works

`Noizu.MCP.Inspector` is a `Supervisor` with three children:

- A `Registry` and `DynamicSupervisor` for sessions.
- A `Bandit` HTTP server (127.0.0.1 only) serving `Inspector.Plug`.

Each browser connection creates an `Inspector.Session` GenServer that owns a
`Noizu.MCP.Client` wrapped in `Inspector.TapTransport`. The tap mirrors
every raw JSON-RPC frame to the session process, which fans them out to
browser SSE subscribers (History tab). Server-initiated sampling and
elicitation requests are intercepted by `Inspector.Handler`, which parks
them in the session until the browser responds.

Fast operations (list tools, read resource, get prompt) bypass the session
process and call `Noizu.MCP.Client` directly — a slow tool call cannot delay
event fan-out or other requests.

The SSE stream carries seven event types: `frame`, `notification`,
`progress`, `call_result`, `pending_request`, `pending_resolved`, and
`status`. A 500-event ring buffer supports `Last-Event-ID` reconnect replay.

## Using the Official MCP Inspector

If you prefer the upstream [MCP Inspector](https://github.com/modelcontextprotocol/inspector)
(`npx @modelcontextprotocol/inspector`), it works with `noizu_mcp` servers
too. For stdio targets, compile first so Mix output doesn't corrupt the
stream (`mix compile`, then point the Inspector at `mix run --no-halt`). For
Streamable HTTP targets, the default `origins: :localhost` setting of
`Noizu.MCP.Transport.StreamableHTTP.Plug` admits the locally running
Inspector — see [Streamable HTTP](streamable_http.md) if you need to adjust
allowed origins. For CI and scripted checks, prefer
`Noizu.MCP.Test` helpers — see [Testing](testing.md).
