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
- Compile-time `input`/`output` field DSL compiling to JSON Schema
  (2020-12), validated with [JSV](https://hex.pm/packages/jsv); handlers
  receive atom-keyed, default-applied, enum-cast arguments. Raw JSON
  Schema escape hatch (`input_schema %{...}`).
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
