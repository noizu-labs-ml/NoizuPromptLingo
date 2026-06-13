# MCP Transport Layer Reference

This document covers the Model Context Protocol transport layer specification
in implementation-level detail. It is based on the published specifications at
modelcontextprotocol.io (versions 2025-03-26, 2025-06-18, and 2025-11-25) and
the TypeScript SDK reference implementation.

---

## Table of Contents

1. [Overview](#overview)
2. [JSON-RPC 2.0 Message Format](#json-rpc-20-message-format)
3. [Stdio Transport](#stdio-transport)
4. [Streamable HTTP Transport](#streamable-http-transport)
5. [Session Management](#session-management)
6. [SSE Wire Format](#sse-wire-format)
7. [Resumability and Redelivery](#resumability-and-redelivery)
8. [Security Considerations](#security-considerations)
9. [Authorization (HTTP)](#authorization-http)
10. [Transport Selection Guidance](#transport-selection-guidance)
11. [Spec Version Differences](#spec-version-differences)

---

## Overview

MCP defines two transport mechanisms:

| Transport | Medium | Direction | Use Case |
|-----------|--------|-----------|----------|
| **stdio** | Subprocess stdin/stdout | Local only | CLI tools, IDE integrations, local agents |
| **Streamable HTTP** | HTTP + SSE | Local or remote | Web services, remote servers, multi-client |

Both transports carry the same JSON-RPC 2.0 messages. The transport is
responsible only for framing and delivery; the MCP protocol layer above is
transport-agnostic.

A deprecated **HTTP+SSE** transport existed in spec version 2024-11-05. It used
a GET endpoint to open an SSE stream and a separate POST endpoint advertised via
an initial `endpoint` SSE event. Streamable HTTP replaces it entirely.

---

## JSON-RPC 2.0 Message Format

All MCP messages are UTF-8 encoded JSON-RPC 2.0. There are four message shapes:

### Request

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list",
  "params": {}
}
```

- `id` -- string or integer. MUST NOT be null. MUST be unique per session per
  sender direction (client IDs and server IDs are independent namespaces).
- `params` -- optional object. MCP never uses positional (array) params.

### Successful Response

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "tools": []
  }
}
```

- `id` -- echoes the request ID exactly (same type and value).

### Error Response

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32601,
    "message": "Method not found",
    "data": null
  }
}
```

### Notification

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```

- No `id` field. Notifications are fire-and-forget; no response is expected.

### Standard Error Codes

| Code | Name | Meaning |
|------|------|---------|
| `-32700` | Parse Error | Invalid JSON |
| `-32600` | Invalid Request | Not a valid JSON-RPC request |
| `-32601` | Method Not Found | Method does not exist |
| `-32602` | Invalid Params | Invalid method parameters |
| `-32603` | Internal Error | Internal server error |

### Batching

JSON-RPC 2.0 allows sending an array of messages as a batch. In MCP:

- Spec 2025-03-26: POST body MAY be a single message or an array (batch).
- Spec 2025-06-18+: POST body MUST be a single message. Batching over HTTP was
  removed.
- All versions: The `initialize` request MUST NOT appear in a batch.
- All versions: Implementations MUST accept batches when received (even if they
  do not send them).

---

## Stdio Transport

### Mechanism

The client launches the MCP server as a child process. Communication happens
over the process's standard streams:

```
Client --[stdin]--> Server
Client <--[stdout]-- Server
```

### Message Framing

Messages are **newline-delimited**. Each JSON-RPC message is a single line of
JSON terminated by `\n` (U+000A).

```
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}\n
```

**Rules:**

- Messages MUST NOT contain embedded newlines (the JSON must be compact /
  single-line).
- Each `\n` marks the boundary between messages.
- There is no length prefix, no Content-Length header, and no other framing.

### Stream Discipline

- Server MUST write only valid MCP JSON-RPC messages to `stdout`.
- Client MUST write only valid MCP JSON-RPC messages to the server's `stdin`.
- Server MAY write UTF-8 strings to `stderr` for logging/diagnostics. The
  client MAY capture, forward, or ignore stderr.
- No non-MCP data on stdout or stdin.

### Shutdown Sequence

1. Client sends a `shutdown` request or simply closes the server's stdin.
2. Client waits for the server process to exit.
3. If the server does not exit within a reasonable timeout, client sends
   `SIGTERM`.
4. If still alive, client sends `SIGKILL`.

The server MAY initiate shutdown by closing its stdout and exiting.

### Elixir Implementation Notes

- Use `Port` or `System.cmd` to spawn the server process.
- Read stdout line-by-line; each line is one JSON-RPC message.
- Write to stdin with a trailing `\n` after each JSON blob.
- `Jason.encode!/1` produces compact (no-newline) JSON by default, which is
  correct for stdio framing.

---

## Streamable HTTP Transport

### Single Endpoint Architecture

The server exposes **one HTTP endpoint** (the "MCP endpoint") that handles
three HTTP methods:

| Method | Purpose |
|--------|---------|
| `POST` | Client sends JSON-RPC messages to server |
| `GET` | Client opens SSE stream for server-initiated messages |
| `DELETE` | Client terminates the session |

Example endpoint: `https://example.com/mcp`

The path is implementation-defined. There is no spec-mandated path.

### POST -- Sending Messages to the Server

Every client-to-server JSON-RPC message is sent as an individual HTTP POST.

**Request headers (client MUST send):**

```http
POST /mcp HTTP/1.1
Content-Type: application/json
Accept: application/json, text/event-stream
```

**Conditional headers:**

| Header | When |
|--------|------|
| `Mcp-Session-Id: <id>` | After initialization, if server assigned one |
| `MCP-Protocol-Version: 2025-06-18` | All requests after init (2025-06-18+) |
| `Authorization: Bearer <token>` | If authentication is configured |

**Request body:** A single JSON-RPC message (request, notification, or
response). Not an array.

**Response depends on what was sent:**

| Client sent | Server response |
|-------------|-----------------|
| Notification | `202 Accepted` (no body) |
| Response (to a server request) | `202 Accepted` (no body) |
| Request | `200 OK` with `Content-Type: application/json` (single response) |
| Request | `200 OK` with `Content-Type: text/event-stream` (SSE stream) |

When the server responds with an SSE stream:

- The stream SHOULD eventually include the JSON-RPC response to the request.
- The server MAY send additional JSON-RPC requests and notifications on the
  stream before the response (these SHOULD relate to the originating request,
  e.g. progress notifications or sampling requests).
- After sending the final response, the server SHOULD close the stream.
- The server SHOULD NOT close the stream before sending the response (unless the
  session has expired).

**Important:** Client disconnection from a POST SSE stream does NOT imply
request cancellation. The client MUST send an explicit `notifications/cancelled`
message to cancel a request.

### GET -- Server-Initiated Message Stream

The client MAY open a long-lived SSE stream to receive server-initiated
messages (requests and notifications that are not tied to a specific client
request).

```http
GET /mcp HTTP/1.1
Accept: text/event-stream
Mcp-Session-Id: <session-id>
```

**Server response options:**

- `200 OK` with `Content-Type: text/event-stream` -- opens SSE stream.
- `405 Method Not Allowed` -- server does not support GET (all server messages
  are sent on POST response streams instead).

**Rules for the GET stream:**

- Server MAY send requests and notifications.
- Server MUST NOT send responses on the GET stream (unless resuming a
  disconnected POST stream via `Last-Event-ID`).
- Either side MAY close the stream at any time.
- Multiple simultaneous SSE connections are allowed. The server MUST send each
  message on exactly one stream (no broadcasting).

### DELETE -- Session Termination

```http
DELETE /mcp HTTP/1.1
Mcp-Session-Id: <session-id>
```

- Client SHOULD send DELETE when done with a session.
- Server MAY respond with `405 Method Not Allowed` if it does not support
  client-initiated termination.
- On success, server invalidates the session ID.

### HTTP Status Code Reference

| Code | Meaning in MCP |
|------|----------------|
| `200` | Success with body (JSON or SSE) |
| `202` | Accepted -- notification/response acknowledged, no body |
| `400` | Bad Request -- missing session ID, invalid protocol version, malformed body |
| `401` | Unauthorized -- authentication required or token invalid |
| `403` | Forbidden -- invalid Origin header or insufficient permissions |
| `404` | Not Found -- session has been terminated |
| `405` | Method Not Allowed -- GET or DELETE not supported by this server |
| `429` | Too Many Requests -- rate limiting (implementation-specific) |

---

## Session Management

### Session ID Assignment

1. Server MAY assign a session ID by including it in the response headers of the
   `InitializeResult`:

   ```http
   HTTP/1.1 200 OK
   Content-Type: application/json
   Mcp-Session-Id: abc123-secure-random-token
   ```

2. If assigned, the client MUST include the session ID on all subsequent
   requests.

### Session ID Requirements

- Globally unique.
- Cryptographically secure (use a CSPRNG).
- Visible ASCII characters only: bytes `0x21` through `0x7E`.
- No length restriction specified, but keep it reasonable for HTTP headers.

### Session ID Header Name

| Spec Version | Header Name |
|-------------|-------------|
| 2025-03-26 | `Mcp-Session-Id` |
| 2025-06-18 | `Mcp-Session-Id` |
| 2025-11-25 | `MCP-Session-Id` |

Implementation note: HTTP headers are case-insensitive per RFC 7230. However,
for maximum compatibility an Elixir implementation should normalize on lookup
and send the casing expected by the target spec version.

### Error Handling

| Condition | Server Response |
|-----------|-----------------|
| Session ID missing (when required) | `400 Bad Request` |
| Session ID for terminated session | `404 Not Found` |

When a client receives `404` with a session ID it previously held, it MUST
discard the session and start fresh with a new `initialize` request (without
any session ID header).

### Protocol Version Header (2025-06-18+)

After initialization, the client MUST include:

```http
MCP-Protocol-Version: 2025-06-18
```

on every request. If the server cannot determine the protocol version and this
header is absent, it SHOULD assume `2025-03-26`. If the version is unsupported,
the server returns `400 Bad Request`.

---

## SSE Wire Format

Server-Sent Events follow the W3C EventSource specification. Each event in an
MCP SSE stream uses this format:

```
event: message
id: <event-id>
data: <json-stringified JSON-RPC message>

```

The blank line (double `\n`) terminates the event.

### Field Details

| Field | Required | Value |
|-------|----------|-------|
| `event` | Yes | Always the literal string `message` |
| `id` | Optional | Opaque string; enables resumability (see below) |
| `data` | Yes | Compact JSON string of one JSON-RPC message |

### Example: Tool Result Response

```
event: message
id: evt-001
data: {"jsonrpc":"2.0","id":1,"result":{"content":[{"type":"text","text":"hello"}]}}

```

### Example: Progress Notification Followed by Response

```
event: message
id: evt-002
data: {"jsonrpc":"2.0","method":"notifications/progress","params":{"progressToken":"tok-1","progress":50,"total":100}}

event: message
id: evt-003
data: {"jsonrpc":"2.0","id":1,"result":{"content":[{"type":"text","text":"done"}]}}

```

### Priming Event (2025-11-25+)

The server SHOULD immediately send a priming event when opening an SSE stream.
This event carries an event ID but an empty data field:

```
event: message
id: evt-000
data: 

```

The priming event lets the client capture the initial event ID for reconnection
before any real messages arrive.

### Retry Field (2025-11-25+)

Before closing a connection (without terminating the logical stream), the
server SHOULD send an SSE `retry` field to advise the client on reconnection
delay:

```
retry: 5000

```

The value is in milliseconds. The client MUST respect this value.

---

## Resumability and Redelivery

### Event IDs

- Servers MAY attach an `id` field to SSE events.
- Event IDs MUST be globally unique within the session.
- Event IDs SHOULD encode enough information to identify the originating stream
  (POST response stream vs. GET stream).

### Reconnection

When a client's SSE connection drops:

1. Client issues a GET request to the MCP endpoint with the `Last-Event-ID`
   header set to the last received event ID.
2. Server MAY replay missed messages from the **disconnected stream only**.
3. Server MUST NOT replay messages from other streams.

Reconnection is always via GET with `Last-Event-ID`, regardless of whether the
original stream was a POST response or a GET stream.

### Implementation Strategy for Elixir

Maintain a per-session ordered event log keyed by event ID. On reconnection:

1. Look up the stream that owned the given event ID.
2. Replay all events from that stream after the given ID.
3. If the event ID is unknown or too old, start fresh (no replay).

---

## Security Considerations

### Origin Validation (DNS Rebinding Protection)

Servers MUST validate the `Origin` header on all HTTP requests:

- If `Origin` is present and does not match an expected value, the server MUST
  respond with `403 Forbidden`.
- The response body MAY be a JSON-RPC error object without an `id`.
- This prevents DNS rebinding attacks where a malicious website makes requests
  to a local MCP server.

### Binding Address

Local servers SHOULD bind only to `127.0.0.1` (loopback), not `0.0.0.0` (all
interfaces). This limits the attack surface to local processes.

### TLS

- Remote MCP servers SHOULD use HTTPS.
- All OAuth authorization endpoints MUST use HTTPS.
- OAuth redirect URIs MUST be either localhost or HTTPS.

### Session Hijacking

- Session IDs must be cryptographically random and unguessable.
- Session IDs should be treated as bearer tokens -- anyone who knows the ID can
  impersonate the client.
- Transmit session IDs only over TLS for remote connections.

### Stdio Security

- The stdio transport inherits the security context of the parent process.
- The server runs with the same permissions as the user who launched it.
- Environment variables are the standard mechanism for passing credentials to
  stdio servers (not command-line arguments, which may be visible in process
  listings).

---

## Authorization (HTTP)

Authorization is OPTIONAL. When required, MCP uses OAuth 2.1.

### Flow Summary

1. Client sends a request; server responds `401 Unauthorized`.
2. Client discovers authorization server metadata.
3. Client performs OAuth 2.1 authorization code flow with PKCE.
4. Client includes `Authorization: Bearer <token>` on all subsequent requests.

### Discovery (varies by spec version)

**2025-03-26:**
- `GET /.well-known/oauth-authorization-server` relative to the authorization
  base URL (MCP server URL with path stripped to origin).
- Fallback endpoints if discovery fails: `/authorize`, `/token`, `/register`.

**2025-06-18+:**
- Server MUST implement RFC 9728 (Protected Resource Metadata).
- `GET /.well-known/oauth-protected-resource` on the MCP server itself.
- Server MUST include `WWW-Authenticate` header in 401 responses.
- Client MUST include RFC 8707 `resource` parameter in authorization and token
  requests.
- Authorization server metadata via RFC 8414.

### Key Requirements

- PKCE is REQUIRED for all clients (public and confidential).
- Tokens MUST NOT appear in query strings.
- Dynamic client registration (RFC 7591) is supported.

---

## Transport Selection Guidance

### Use Stdio When

- The server is a local tool or subprocess.
- The client controls the server lifecycle (start/stop).
- Single-client usage (one client per server instance).
- No network exposure needed.
- Simplest implementation path.
- Examples: local file system access, local database tools, IDE extensions.

### Use Streamable HTTP When

- The server is remote or shared across clients.
- Multiple clients connect to one server.
- The server has an independent lifecycle (always running).
- You need authentication and authorization.
- You want web-standard infrastructure (load balancers, proxies, monitoring).
- Examples: SaaS integrations, shared team tools, cloud-hosted MCP services.

### Decision Matrix

| Factor | Stdio | Streamable HTTP |
|--------|-------|-----------------|
| Deployment | Local subprocess | Any HTTP server |
| Clients | Single | Multiple |
| Auth | Environment variables | OAuth 2.1 / Bearer tokens |
| Complexity | Low | Medium-High |
| Resumability | N/A (process-local) | Supported via SSE event IDs |
| Firewalls/NAT | N/A | Standard HTTP traversal |
| Bidirectional | Yes (stdin/stdout) | Yes (POST + SSE streams) |

---

## Spec Version Differences

Summary of transport-relevant changes across published specification versions.

| Feature | 2025-03-26 | 2025-06-18 | 2025-11-25 |
|---------|-----------|-----------|-----------|
| Transport name | Streamable HTTP | Streamable HTTP | Streamable HTTP |
| POST body | Single or batch array | Single message only | Single message only |
| `MCP-Protocol-Version` header | Not required | MUST on all post-init requests | MUST on all post-init requests |
| Session header casing | `Mcp-Session-Id` | `Mcp-Session-Id` | `MCP-Session-Id` |
| SSE priming event | Not specified | Not specified | SHOULD send immediately |
| SSE `retry` field | Not specified | Not specified | SHOULD send before closing |
| Polling/reconnect | Not specified | Not specified | Explicit support |
| Origin validation | MUST validate | MUST validate | MUST respond 403 |
| Auth discovery | RFC 8414 | RFC 9728 + RFC 8414 | RFC 9728 + RFC 8414 |
| `elicitation` capability | No | Yes | Yes |
| `title` in clientInfo/serverInfo | No | Yes | Yes |

### Backwards Compatibility with Deprecated HTTP+SSE (2024-11-05)

A client can detect whether a server uses old HTTP+SSE or Streamable HTTP:

1. POST an `InitializeRequest` to the server URL with
   `Accept: application/json, text/event-stream`.
2. If the server responds successfully, it supports Streamable HTTP.
3. If the server responds with 4xx (400, 404, or 405), attempt a GET to the
   same URL expecting an SSE stream. If the first SSE event has type `endpoint`,
   the server uses the deprecated HTTP+SSE transport.

---

## References

- MCP Specification (2025-03-26): https://modelcontextprotocol.io/specification/2025-03-26
- MCP Specification (2025-06-18): https://modelcontextprotocol.io/specification/2025-06-18
- MCP Specification (2025-11-25): https://modelcontextprotocol.io/specification/2025-11-25
- Transport spec: https://modelcontextprotocol.io/specification/2025-11-25/basic/transports
- JSON-RPC 2.0: https://www.jsonrpc.org/specification
- SSE (Server-Sent Events): https://html.spec.whatwg.org/multipage/server-sent-events.html
- TypeScript SDK (reference implementation): https://github.com/modelcontextprotocol/typescript-sdk
- Schema definitions: https://github.com/modelcontextprotocol/specification/blob/main/schema/
