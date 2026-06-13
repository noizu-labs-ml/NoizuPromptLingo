# Architecture Summary

Noizu MCP is an Elixir MCP (Model Context Protocol) library using JSON-RPC 2.0. Provides both server and client implementations sharing a common sans-IO state machine (Peer).

**Server DSL** — `use Noizu.MCP.Server` + `tool/resource/prompt` macros define servers. Capabilities auto-derived at compile time. Behaviour callbacks available as escape hatch.

**Client** — `Noizu.MCP.Client` GenServer wrapping Peer in client role. Manages transport lifecycle, handshake queuing, and server-initiated request dispatch (sampling, elicitation). Capabilities derived from Handler callbacks.

**Session** — One GenServer per connected client (server side). Delegates protocol state to Peer, spawns handler tasks via Task.Supervisor. Handles cancellation, progress, logging, resource subscriptions.

**Peer** — Pure state machine (no I/O). Ingests JSON-RPC messages, returns effects. Manages handshake, request tracking, cancellation. Shared between server and client roles.

**Transports** — Three pairs: Stdio/Stdio.Client (subprocess stdin/stdout), StreamableHTTP.Plug/StreamableHTTP.Client (POST/GET/DELETE + SSE, Req-based), Test/Test.Client (in-process). SSE codec shared. EventStore backs Last-Event-ID resumability.

**Auth** — ClientStrategy behaviour with OAuth 2.1 (PKCE, RFC 9728 discovery, token refresh) and Static (bearer token) implementations. Client-side; plugged into StreamableHTTP.Client.

**Feature modules** — Tools, Resources, Prompts, Completion. Dispatch registered components, validate inputs via JSV schema, call user callbacks.

**Supervision** — Server module → Supervisor with Registry, TaskSupervisor, DynamicSupervisor (sessions), optional EventStore, optional Stdio transport. Client is a standalone GenServer.

**Inspector** — `Noizu.MCP.Inspector` supervisor (launched via `mix mcp.client`): Registry + DynamicSupervisor for sessions + Bandit on 127.0.0.1. Each session owns a `Noizu.MCP.Client` wrapped in `TapTransport` (mirrors frames for History tab); `Inspector.Handler` parks sampling/elicitation for browser responses (Pending tab). REST + SSE bridge with 500-event ring buffer. Random bearer token + localhost Origin check per run.

**Key decisions** — Sans-IO peer for testability; shared peer for both roles; task-per-request for responsiveness; macro DSL with behaviour escape hatch; persistent_term schema cache; EventStore for SSE resumability.
