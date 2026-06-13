# Architecture Summary

Noizu MCP is an Elixir MCP (Model Context Protocol) library using JSON-RPC 2.0. Architecture is layered: Transport → Session → Peer (sans-IO state machine) → Feature modules → User callbacks.

**Server DSL** — `use Noizu.MCP.Server` + `tool/resource/prompt` macros define servers. Capabilities auto-derived at compile time. Behaviour callbacks available as escape hatch.

**Session** — One GenServer per connected client. Delegates protocol state to Peer, spawns handler tasks via Task.Supervisor. Handles cancellation, progress, logging, resource subscriptions.

**Peer** — Pure state machine (no I/O). Ingests JSON-RPC messages, returns effects. Manages handshake, request tracking, cancellation. Shared between server and client roles.

**Transport** — Server sink behaviour (Stdio, Test) and Client behaviour. Message-level, not socket-level.

**Feature modules** — Tools, Resources, Prompts, Completion. Dispatch registered components, validate inputs via JSV schema, call user callbacks.

**Supervision** — Server module → Supervisor with Registry, TaskSupervisor, DynamicSupervisor (sessions), optional Stdio transport.

**Key decisions** — Sans-IO peer for testability; task-per-request for responsiveness; macro DSL with behaviour escape hatch; persistent_term schema cache.
