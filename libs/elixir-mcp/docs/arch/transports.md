# Transport Layer

## Overview

Transports are split into two behaviours: server-side sinks (`Noizu.MCP.Transport` — write-only, message-level) and client-side transports (`Noizu.MCP.Transport.Client` — bidirectional, owns the connection).

## Server transports (sinks)

Server transports implement `send_message/3` to write encoded JSON-RPC to the wire. The Session holds a `{module, state}` sink tuple.

### Stdio (`Transport.Stdio`)

Reads newline-delimited JSON-RPC from stdin, writes to stdout. Creates one implicit session at startup. Logger output is diverted to stderr to avoid corrupting the protocol stream.

### Streamable HTTP (`Transport.StreamableHTTP.Plug`)

A Plug handling POST/GET/DELETE on a single MCP endpoint:

- **POST** — JSON-RPC request/notification. `initialize` creates a session and returns `Mcp-Session-Id`. Responses are `application/json` unless progress/logging flows, which upgrades to SSE.
- **GET** — Opens the general SSE stream for server→client notifications. Supports `Last-Event-ID` resumability via `EventStore`.
- **DELETE** — Terminates the session.

Origin validation guards against DNS-rebinding (configurable: `:localhost`, `:any`, or allowlist).

### Test (`Transport.Test`)

In-process message passing for tests. No serialization overhead, but messages cross the encode/decode boundary for fidelity.

## Client transports

Client transports implement `start_link/2`, `send_message/3`, and `close/1`. They deliver inbound messages to the owning `Noizu.MCP.Client` GenServer.

### Stdio.Client (`Transport.Stdio.Client`)

Spawns an MCP server as a subprocess via Erlang Port. Sends newline-delimited JSON-RPC to stdin, reads from stdout. Subprocess stderr is inherited.

### StreamableHTTP.Client (`Transport.StreamableHTTP.Client`)

Req-based HTTP client. POSTs each outbound message; handles both JSON and SSE responses. Maintains the `Mcp-Session-Id` header. Opens a long-lived GET stream for unsolicited server→client traffic. Supports auth strategies via the `Auth.ClientStrategy` behaviour.

### Test.Client (`Transport.Test.Client`)

Connects a Client to a Server in the same VM via direct message passing.

## SSE codec (`Transport.SSE`)

Shared encoder/decoder for Server-Sent Events. Used by both the Streamable HTTP Plug (server-side encoding) and the StreamableHTTP.Client (client-side incremental parsing).

## EventStore

`Noizu.MCP.Server.EventStore` is a bounded per-session ETS ring buffer (default 1000 events) that backs `Last-Event-ID` resumability for Streamable HTTP. Node-local; multi-node deployments need sticky sessions or a custom store.
