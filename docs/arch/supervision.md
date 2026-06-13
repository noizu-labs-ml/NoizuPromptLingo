# Supervision Tree

Each `use Noizu.MCP.Server` module (e.g. `MyApp.MCP`) starts as a `Supervisor` with this shape:

```
MyApp.MCP (Supervisor, one_for_one)
├── MyApp.MCP.Registry              # Session lookup (Registry, :unique)
├── MyApp.MCP.TaskSupervisor        # Handler execution (Task.Supervisor)
├── MyApp.MCP.SessionSupervisor     # Per-client sessions (DynamicSupervisor)
└── Noizu.MCP.Transport.Stdio       # Only when transport: :stdio
```

## Components

**Registry** — Keyed by `{:session, session_id}`. Used for session lookup, list-changed fan-out (`notify_changed/1`), and resource-updated notifications.

**TaskSupervisor** — Every feature request (tools/call, resources/read, etc.) runs as a `Task.Supervisor.async_nolink` task. This isolates handler crashes from the session process and enables cancellation via `Process.exit(pid, :kill)`.

**SessionSupervisor** — `DynamicSupervisor` managing `Noizu.MCP.Server.Session` GenServers. Each connected client gets one session. Sessions are `:temporary` — they don't restart on crash.

**Stdio Transport** — When `transport: :stdio` is passed, `Noizu.MCP.Transport.Stdio` starts as a child and automatically creates one implicit session. It reads newline-delimited JSON-RPC from stdin and writes responses to stdout.

## Session startup

Transports call `Noizu.MCP.Server.Supervisor.start_session/2` which adds a `Session` to the `SessionSupervisor`. The session receives a **sink** (`{module, term}`) — the transport's callback for writing outbound messages.
