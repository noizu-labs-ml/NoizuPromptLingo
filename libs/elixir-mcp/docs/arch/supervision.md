# Supervision Tree

Each `use Noizu.MCP.Server` module (e.g. `MyApp.MCP`) starts as a `Supervisor` with this shape:

```
MyApp.MCP (Supervisor, one_for_one)
├── MyApp.MCP.Registry              # Session lookup (Registry, :unique)
├── MyApp.MCP.TaskSupervisor        # Handler execution (Task.Supervisor)
├── MyApp.MCP.SessionSupervisor     # Per-client sessions (DynamicSupervisor)
├── MyApp.MCP.EventStore            # Only for Streamable HTTP (ETS ring buffer)
└── Noizu.MCP.Transport.Stdio       # Only when transport: :stdio
```

## Components

**Registry** — Keyed by `{:session, session_id}`. Used for session lookup, list-changed fan-out (`notify_changed/1`), and resource-updated notifications.

**TaskSupervisor** — Every feature request (tools/call, resources/read, etc.) runs as a `Task.Supervisor.async_nolink` task. This isolates handler crashes from the session process and enables cancellation via `Process.exit(pid, :kill)`.

**SessionSupervisor** — `DynamicSupervisor` managing `Noizu.MCP.Server.Session` GenServers. Each connected client gets one session. Sessions are `:temporary` — they don't restart on crash.

**EventStore** — Present when using the Streamable HTTP transport. Bounded per-session ETS ring buffer (default 1000 events) that backs SSE `Last-Event-ID` resumability. Node-local.

**Stdio Transport** — When `transport: :stdio` is passed, `Noizu.MCP.Transport.Stdio` starts as a child and automatically creates one implicit session. It reads newline-delimited JSON-RPC from stdin and writes responses to stdout.

## Session startup

Transports call `Noizu.MCP.Server.Supervisor.start_session/2` which adds a `Session` to the `SessionSupervisor`. The session receives a **sink** (`{module, term}`) — the transport's callback for writing outbound messages.

## Client supervision

`Noizu.MCP.Client` is a standalone GenServer (not a supervisor tree). It starts its own `Task.Supervisor` for handler tasks and the chosen client transport as a linked process.
