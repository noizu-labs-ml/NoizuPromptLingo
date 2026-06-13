# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-06-13

Initial release. Targets MCP specification revision **2025-11-25**
(negotiates down to 2025-06-18; 2025-03-26 is deliberately unsupported —
it would require JSON-RPC batching, which later revisions removed).

### Server

- `use Noizu.MCP.Server` with declarative `tool` / `resource` /
  `resource_template` / `prompt` registration; capabilities derived
  automatically from what you register or implement.
- Hidden items: `hidden: true` on any tool/prompt/resource/resource-template
  definition or registration (`visible: false` is an alias for tools) omits
  it from list responses while leaving it callable by name; `include_hidden:`
  on the `Features.*.list_registered` helpers enables session-gated listings,
  and the built-in `Noizu.MCP.Server.Tools.Catalog` discovery tool exposes
  full definitions of unpublished items to agents.
- Toolkits: `use Noizu.MCP.Server.Toolkit` defines many tools in one module
  via `@mcp` function annotations (arity 0–2), with data-form input/output
  specs or raw JSON Schemas; registration opts
  (`hidden:`/`visible:`/`category:`) apply to the whole kit. All tool modules
  share one runtime protocol — `__mcp_tools__/0` returning normalized
  `Noizu.MCP.Server.Tool.Spec` descriptors.
- Category metadata: `category: "..."` on tools (toolkit default, per-`@mcp`,
  classic `use` option, or registration override) rides in `_meta.category`
  on the wire and is filterable through the catalog tool.
- Compile-time `input`/`output` field DSL compiling to JSON Schema
  (2020-12), validated with [JSV](https://hex.pm/packages/jsv); handlers
  receive atom-keyed, default-applied, enum-cast arguments. Raw JSON
  Schema escape hatch (`input_schema %{...}`), also accepted as raw JSON
  text decoded at compile time.
- Input-validation failures return `isError: true` tool results per
  SEP-1303 so models can self-correct.
- Resources with RFC 6570 templates, subscriptions and fan-out
  (`notify_resource_updated/1`), prompts with arguments, completion,
  pagination with opaque cursors, `logging/setLevel`, list-changed
  notifications (`notify_changed/1`).
- Behaviour-only escape hatch: every DSL-generated callback
  (`handle_list_tools/2`, `handle_call_tool/3`, …) can be hand-written.
- Handlers run in supervised Tasks — slow tools never block ping,
  cancellation, or progress; crashes are sanitized.
- `Noizu.MCP.Ctx`: progress, logging, cancellation checks, per-session
  state, and server-initiated `sample/2`, `elicit/3`, `list_roots/1`.

### Inspector

- `mix mcp.client` Mix task launching `Noizu.MCP.Inspector` — a native
  localhost-only HTML MCP client analogous to the official `mcp dev` tool.
  Supports three target modes: in-process `use Noizu.MCP.Server` module,
  stdio subprocess (with `--cd`/`--env`), and remote Streamable HTTP
  (`--url`/`--bearer`).
- Browser UI (vanilla ES modules, no build step) with tabs: Connection,
  Tools (JSON-Schema-generated forms, inline progress, cancel), Resources
  (read, subscribe, template expansion + completion), Prompts (args +
  completion, message preview), History (raw JSON-RPC frame log),
  Notifications, and Pending.
- Pending tab parks server-initiated sampling and elicitation requests for
  human-in-the-loop responses; tool calls run with infinite timeout while
  parked.
- REST + SSE bridge with per-session 500-event ring buffer (`Last-Event-ID`
  replay) and seven SSE event types: `frame`, `notification`, `progress`,
  `call_result`, `pending_request`, `pending_resolved`, `status`.
- Config export endpoint produces `claude_desktop`-style entries for the
  current target.
- Security: binds `127.0.0.1` only; random 256-bit bearer token per run
  required on every `/api` call; localhost `Origin` check on SSE; module
  targets resolve only already-loaded atoms.
- `Noizu.MCP.Inspector.start_link/1` for programmatic embedding.

### Client

- `Noizu.MCP.Client`: sync calls, async request handles with cancel,
  per-request timeouts, progress callbacks, automatic pagination.
- `Noizu.MCP.Client.Handler` behaviour answering server-initiated
  sampling, elicitation, and roots requests.

### Transports

- stdio (server and client) with automatic Logger-to-stderr diversion on
  the server side.
- Streamable HTTP server as a Plug (Phoenix-mountable or standalone on
  Bandit): sessions, adaptive JSON↔SSE responses, general GET stream,
  `Last-Event-ID` resumability backed by a bounded event store, origin
  validation, DELETE teardown.
- Streamable HTTP client on Req: ordered POSTs, SSE streaming, GET
  stream with reconnect/resume.
- In-memory `Noizu.MCP.Transport.Test` pair plus the `Noizu.MCP.Test`
  helper module (async-safe ExUnit testing).

### Authorization (OAuth 2.1)

- Resource-server enforcement: `Noizu.MCP.Auth.TokenVerifier` behaviour,
  `WWW-Authenticate` challenges, `insufficient_scope`, RFC 9728
  protected-resource metadata plug.
- Client strategies: `Noizu.MCP.Auth.Static` (bearer) and
  `Noizu.MCP.Auth.OAuth` (RFC 9728 + RFC 8414/OIDC discovery, PKCE S256,
  RFC 8707 resource indicators, refresh, scope step-up) with a
  host-app `authorize_user` callback for the browser leg.
