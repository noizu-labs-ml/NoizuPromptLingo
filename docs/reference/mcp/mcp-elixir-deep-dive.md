# MCP Wire Protocol & Elixir Ecosystem — Deep Dive

**Compiled: May 2026**

---

# Part 1: MCP Wire Protocol Technical Reference

## 1. Protocol Overview

**MCP** (Model Context Protocol) is an open protocol created by **Anthropic** that standardizes communication between LLM applications and external tool/resource providers. Inspired by LSP (Language Server Protocol) but designed for AI application ecosystems.

**Current spec version**: `2025-03-26` (supersedes `2024-11-05`)

**Authoritative schema**: [schema.ts](https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-03-26/schema.ts) (TypeScript source of truth) with auto-generated JSON Schema companion.

### Architecture: Host / Client / Server

```
┌─────────────────────────────────────┐
│         Application Host            │
│  ┌─────────┐ ┌─────────┐ ┌───────┐ │
│  │Client 1 │ │Client 2 │ │Client3│ │
│  └────┬────┘ └────┬────┘ └───┬───┘ │
└───────┼───────────┼──────────┼─────┘
        │           │          │
   ┌────▼────┐ ┌────▼────┐ ┌──▼──────┐
   │Server 1 │ │Server 2 │ │Server 3 │
   │Files/Git│ │Database │ │Ext APIs │
   └─────────┘ └─────────┘ └─────────┘
```

| Component | Role |
|-----------|------|
| **Host** | LLM application (e.g., Claude Desktop, an IDE). Creates/manages clients, enforces security, handles user authorization. |
| **Client** | Connector within the host. Each client maintains a 1:1 stateful session with one server. |
| **Server** | Provides context and capabilities (tools, resources, prompts). Operates independently. |

Key design principle: **Servers cannot see the full conversation or other servers.** The host controls all cross-server interaction.

---

## 2. Transport Layers

MCP is transport-agnostic but defines two standard transports. Custom transports are allowed.

### 2.0 SSE Wire Format (W3C/WHATWG Primer)

MIME type: `text/event-stream`. Encoding: UTF-8 (always).

**Stream structure** — a sequence of lines separated by LF (`\n`), CR (`\r`), or CRLF (`\r\n`):

| Line form | Interpretation |
|-----------|---------------|
| `:anything` | Comment (ignored). Useful as keep-alive. |
| `field: value` | Set field. One leading space after colon is stripped. |
| `field` (no colon) | Set field with empty string value. |
| *(empty line)* | **Dispatch** the accumulated event, reset buffers. |

**Fields:**

| Field | Behavior |
|-------|----------|
| `event` | Sets event type. Default if absent: `"message"`. |
| `data` | Appends value + `\n` to data buffer. Multiple `data:` lines concatenate with LF. Trailing LF stripped on dispatch. |
| `id` | Sets last event ID. Sent back as `Last-Event-ID` header on reconnect. |
| `retry` | If all ASCII digits, sets reconnection time in milliseconds. |

**Event dispatch** — on blank line, if data buffer is non-empty, event fires with type (or `"message"`), data (trailing LF removed), and lastEventId. Then type and data buffers reset; lastEventId persists.

**Reconnection** — on connection drop, `EventSource` waits `retry` ms then reconnects with `Last-Event-ID` header. HTTP 204 = fatal (do not reconnect). HTTP 200 with wrong Content-Type = fatal.

---

### 2.1 stdio Transport

Client launches the server as a **subprocess**. Communication over stdin/stdout.

| Aspect | Detail |
|--------|--------|
| **Direction** | Client writes to server's `stdin`; server writes to `stdout` |
| **Delimiter** | Newline-delimited. Messages MUST NOT contain embedded newlines |
| **Logging** | Server MAY write UTF-8 to `stderr` for logging |
| **Batching** | JSON-RPC batch arrays supported |
| **Shutdown** | Client closes stdin, waits, then SIGTERM, then SIGKILL |

**When to use**: Local tools, CLI integrations, subprocess-based servers.

**Pros**: Simple, no network stack, no authentication needed, low latency.
**Cons**: Local only, single client per server process, no web deployment.

---

### 2.2 HTTP+SSE Transport (Deprecated — spec 2024-11-05)

The original HTTP transport. **Replaced by Streamable HTTP in 2025-03-26** but still relevant for backwards compatibility.

#### Endpoints

Two HTTP endpoints:

1. **SSE endpoint** (GET) — client connects, receives SSE stream. URL is known to client upfront (configured).
2. **POST endpoint** — client sends JSON-RPC messages here. URL is **not known** until the server sends it via the SSE stream.

#### SSE Event Types

Exactly two event types:

| `event:` value | `data:` content | When sent |
|----------------|-----------------|-----------|
| `endpoint` | A URI string (the POST endpoint URL) | **First event** after SSE connection opens |
| `message` | A complete JSON-RPC message (JSON object) | Every subsequent server-to-client message |

#### Connection Lifecycle

```
1. Client opens GET to SSE endpoint
   → Server responds 200 OK, Content-Type: text/event-stream

2. Server sends first SSE event:
   event: endpoint
   data: /rpc          ← (or any URI, possibly absolute)

3. Client now knows where to POST. Sends InitializeRequest:
   POST /rpc
   Content-Type: application/json
   Body: {"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}

4. Server sends InitializeResult via SSE:
   event: message
   data: {"jsonrpc":"2.0","id":1,"result":{...}}

5. Client sends InitializedNotification:
   POST /rpc   Body: {"jsonrpc":"2.0","method":"notifications/initialized"}

6. Normal message exchange follows same pattern.
7. Client closes SSE connection to terminate.
```

#### Client -> Server: HTTP POST

- Method: `POST`
- URL: the URI received in the `endpoint` event
- Header: `Content-Type: application/json`
- Body: a single JSON-RPC message (request, response, or notification)
- **The server does not return JSON-RPC in the POST response body.** Returns `202 Accepted`. All server messages come via the SSE stream.

#### Server -> Client: SSE `message` events

Each JSON-RPC message is one SSE event:

```
event: message
data: {"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2024-11-05",...}}

```

(Blank line terminates the event.)

#### Reconnection

Standard SSE reconnection applies. Server must re-send the `endpoint` event on reconnection. Session persistence across reconnects is implementation-defined.

#### Complete Raw HTTP Trace (Deprecated HTTP+SSE)

```http
——— Step 1: Client opens SSE connection ———

GET /sse HTTP/1.1
Host: localhost:3000
Accept: text/event-stream
Origin: http://localhost:8080
Cache-Control: no-cache
Connection: keep-alive

HTTP/1.1 200 OK
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive

event: endpoint
data: /messages

——— Step 2: Client sends initialize ———

POST /messages HTTP/1.1
Host: localhost:3000
Content-Type: application/json
Origin: http://localhost:8080
Content-Length: 143

{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"my-client","version":"1.0"}}}

HTTP/1.1 202 Accepted
Content-Length: 0

——— Server sends InitializeResult on SSE stream ———

event: message
data: {"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"my-server","version":"1.0"}}}

——— Step 3: Client sends initialized notification ———

POST /messages HTTP/1.1
Host: localhost:3000
Content-Type: application/json
Origin: http://localhost:8080
Content-Length: 55

{"jsonrpc":"2.0","method":"notifications/initialized"}

HTTP/1.1 202 Accepted
Content-Length: 0

——— Step 4: Client calls a tool ———

POST /messages HTTP/1.1
Host: localhost:3000
Content-Type: application/json
Origin: http://localhost:8080
Content-Length: 98

{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_weather","arguments":{"city":"London"}}}

HTTP/1.1 202 Accepted
Content-Length: 0

——— Server sends tool result on SSE stream ———

event: message
data: {"jsonrpc":"2.0","id":2,"result":{"content":[{"type":"text","text":"Cloudy, 15°C"}]}}

——— Step 5: Client disconnects ———

(Client closes the SSE TCP connection)
```

---

### 2.3 Streamable HTTP Transport (spec 2025-03-26)

The modern HTTP transport. **Single MCP endpoint** accepting POST, GET, and optionally DELETE.

#### Single Endpoint

No separate SSE endpoint. No `endpoint` event. No URL discovery step. Example: `https://example.com/mcp`

#### SSE Event Type

Exactly **one** event type: `message`

```
event: message
data: <JSON-RPC message or JSON-RPC batch array>
```

The `event: message` field is always present. The `data:` field contains a single JSON-RPC object or a JSON-RPC batch array.

#### HTTP Methods

| Method | Purpose |
|--------|---------|
| `POST` | Client sends JSON-RPC messages. Response is either `application/json` or `text/event-stream`. |
| `GET` | Client opens a standalone SSE stream for server-initiated messages. |
| `DELETE` | Client terminates a session. |

#### POST: Client -> Server Messages

**Request:**

```http
POST /mcp HTTP/1.1
Host: example.com
Content-Type: application/json
Accept: application/json, text/event-stream
Mcp-Session-Id: 1868a90c-...
Origin: https://client.example.com
Content-Length: ...

<JSON-RPC message or batch array>
```

Required headers:
- `Content-Type: application/json`
- `Accept: application/json, text/event-stream` (client MUST list both)
- `Mcp-Session-Id: <id>` (MUST be present after initialization, if server assigned one)

**POST body** is one of:
- A single JSON-RPC request, notification, or response
- A batch array of requests and/or notifications
- A batch array of responses

**Response rules by input type:**

| POST body contains | Server response |
|--------------------|-----------------|
| Only notifications and/or responses | `202 Accepted` with no body |
| Any JSON-RPC request(s) | Either `Content-Type: application/json` or `Content-Type: text/event-stream` |

**When server returns `application/json`:**

```http
HTTP/1.1 200 OK
Content-Type: application/json
Mcp-Session-Id: 1868a90c-...

{"jsonrpc":"2.0","id":1,"result":{...}}
```

**When server returns `text/event-stream`:**

```http
HTTP/1.1 200 OK
Content-Type: text/event-stream
Mcp-Session-Id: 1868a90c-...

event: message
data: {"jsonrpc":"2.0","id":1,"result":{...}}

```

Within the SSE stream:
- Server SHOULD eventually send one JSON-RPC response per each request in the POST body
- Responses MAY be batched (JSON array in `data:` field)
- Server MAY send JSON-RPC requests and notifications to the client before sending responses (e.g., progress, logging)
- Server SHOULD close the stream after sending all responses
- Server SHOULD NOT close before all responses are sent (unless session expires)

#### GET: Server-Initiated SSE Stream

```http
GET /mcp HTTP/1.1
Host: example.com
Accept: text/event-stream
Mcp-Session-Id: 1868a90c-...
Origin: https://client.example.com
```

Response: `200 OK` with `Content-Type: text/event-stream`, or `405 Method Not Allowed`.

On the GET stream:
- Server MAY send JSON-RPC requests and notifications (MAY be batched)
- Messages SHOULD be unrelated to any concurrent POST request
- Server MUST NOT send JSON-RPC responses (unless resuming a broken POST stream)
- Either side MAY close the stream at any time

#### DELETE: Session Termination

```http
DELETE /mcp HTTP/1.1
Host: example.com
Mcp-Session-Id: 1868a90c-...
Origin: https://client.example.com
```

Response: `200 OK` or `405 Method Not Allowed`.

#### Session Management (`Mcp-Session-Id`)

1. Client sends `POST` with `InitializeRequest` (no session ID yet)
2. Server MAY include `Mcp-Session-Id` header in the `InitializeResult` response
3. If returned, client MUST include `Mcp-Session-Id` on ALL subsequent requests (POST, GET, DELETE)
4. Server SHOULD respond `400 Bad Request` to non-init requests missing the header
5. Server MAY terminate sessions at any time -> responds `404 Not Found`
6. Client receiving `404` MUST start a new session
7. Client SHOULD send `DELETE` when done

Session ID: globally unique, cryptographically secure (UUID/JWT), visible ASCII only (0x21-0x7E).

#### Multiple Connections

- Client MAY be connected to multiple SSE streams simultaneously
- Server MUST send each message on only ONE stream (no broadcast/duplication)

#### Resumability and Redelivery

```
id: msg-001
event: message
data: {"jsonrpc":"2.0","method":"notifications/progress","params":{...}}

id: msg-002
event: message
data: {"jsonrpc":"2.0","id":1,"result":{...}}

```

Rules:
- Server MAY attach `id:` to SSE events
- IDs MUST be globally unique across all streams within a session
- Client reconnects via GET with `Last-Event-ID`:

```http
GET /mcp HTTP/1.1
Accept: text/event-stream
Mcp-Session-Id: 1868a90c-...
Last-Event-ID: msg-001
```

- Server MAY replay messages after the given ID (only from the disconnected stream)
- Server MUST NOT replay messages from a different stream

#### Batching Over SSE

**Individual events:**
```
event: message
data: {"jsonrpc":"2.0","method":"notifications/progress","params":{"token":"abc","progress":50}}

event: message
data: {"jsonrpc":"2.0","id":1,"result":{"content":[{"type":"text","text":"done"}]}}

```

**Batched in one event:**
```
event: message
data: [{"jsonrpc":"2.0","method":"notifications/progress","params":{"token":"abc","progress":50}},{"jsonrpc":"2.0","id":1,"result":{"content":[{"type":"text","text":"done"}]}}]

```

Both valid. `data:` contains either a JSON object or a JSON array.

#### Error Responses

| Condition | HTTP Status |
|-----------|-------------|
| Malformed input | `400 Bad Request` |
| Missing session ID | `400 Bad Request` |
| Invalid/expired session | `404 Not Found` |
| GET not supported | `405 Method Not Allowed` |
| DELETE not supported | `405 Method Not Allowed` |

#### Disconnection Semantics

- Disconnection SHOULD NOT be interpreted as cancellation
- To cancel, client SHOULD send `CancelledNotification` explicitly
- To avoid message loss, server MAY use resumable streams (SSE `id:` fields)

#### Backwards Compatibility

**Client** supporting both transports:
1. Try `POST` with `InitializeRequest` (with `Accept: application/json, text/event-stream`)
2. If success -> Streamable HTTP
3. If 4xx -> `GET` same URL, expect SSE stream with `endpoint` event -> old HTTP+SSE

**Server** supporting both: host old SSE + POST endpoints alongside the new MCP endpoint.

#### Complete Raw HTTP Trace (Streamable HTTP)

```http
——— Step 1: Initialize (POST, server returns JSON) ———

POST /mcp HTTP/1.1
Host: example.com
Content-Type: application/json
Accept: application/json, text/event-stream
Origin: https://client.example.com
Content-Length: 152

{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"my-client","version":"1.0"}}}

HTTP/1.1 200 OK
Content-Type: application/json
Mcp-Session-Id: 1868a90c-8bef-4e45-a4f7-953de4578d42

{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2025-03-26","capabilities":{"tools":{}},"serverInfo":{"name":"my-server","version":"2.0"}}}

——— Step 2: Initialized notification ———

POST /mcp HTTP/1.1
Host: example.com
Content-Type: application/json
Accept: application/json, text/event-stream
Mcp-Session-Id: 1868a90c-8bef-4e45-a4f7-953de4578d42
Origin: https://client.example.com
Content-Length: 55

{"jsonrpc":"2.0","method":"notifications/initialized"}

HTTP/1.1 202 Accepted

——— Step 3: Tool call (POST, server returns SSE stream) ———

POST /mcp HTTP/1.1
Host: example.com
Content-Type: application/json
Accept: application/json, text/event-stream
Mcp-Session-Id: 1868a90c-8bef-4e45-a4f7-953de4578d42
Origin: https://client.example.com
Content-Length: 98

{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_weather","arguments":{"city":"London"}}}

HTTP/1.1 200 OK
Content-Type: text/event-stream
Mcp-Session-Id: 1868a90c-8bef-4e45-a4f7-953de4578d42

id: evt-001
event: message
data: {"jsonrpc":"2.0","method":"notifications/progress","params":{"progressToken":"t1","progress":50,"total":100}}

id: evt-002
event: message
data: {"jsonrpc":"2.0","id":2,"result":{"content":[{"type":"text","text":"Cloudy, 15°C"}]}}

——— Step 4: Open standalone SSE stream (GET) ———

GET /mcp HTTP/1.1
Host: example.com
Accept: text/event-stream
Mcp-Session-Id: 1868a90c-8bef-4e45-a4f7-953de4578d42
Origin: https://client.example.com

HTTP/1.1 200 OK
Content-Type: text/event-stream

id: evt-003
event: message
data: {"jsonrpc":"2.0","method":"notifications/resources/updated","params":{"uri":"file:///data.json"}}

——— Step 5: Server sends sampling request to client via GET stream ———

id: evt-004
event: message
data: {"jsonrpc":"2.0","id":"s1","method":"sampling/createMessage","params":{"messages":[{"role":"user","content":{"type":"text","text":"Summarize the data"}}],"maxTokens":500}}

——— Client responds to server's request via POST ———

POST /mcp HTTP/1.1
Host: example.com
Content-Type: application/json
Accept: application/json, text/event-stream
Mcp-Session-Id: 1868a90c-8bef-4e45-a4f7-953de4578d42
Origin: https://client.example.com
Content-Length: 133

{"jsonrpc":"2.0","id":"s1","result":{"role":"assistant","content":{"type":"text","text":"The data shows..."},"model":"claude-3","stopReason":"endTurn"}}

HTTP/1.1 202 Accepted

——— Step 6: Reconnect with Last-Event-ID after broken GET stream ———

GET /mcp HTTP/1.1
Host: example.com
Accept: text/event-stream
Mcp-Session-Id: 1868a90c-8bef-4e45-a4f7-953de4578d42
Last-Event-ID: evt-004
Origin: https://client.example.com

HTTP/1.1 200 OK
Content-Type: text/event-stream

id: evt-005
event: message
data: {"jsonrpc":"2.0","method":"notifications/resources/updated","params":{"uri":"file:///other.json"}}

——— Step 7: Client terminates session ———

DELETE /mcp HTTP/1.1
Host: example.com
Mcp-Session-Id: 1868a90c-8bef-4e45-a4f7-953de4578d42
Origin: https://client.example.com

HTTP/1.1 200 OK
```

---

### 2.4 Transport Comparison

| Aspect | HTTP+SSE (2024-11-05) | Streamable HTTP (2025-03-26) |
|--------|----------------------|------------------------------|
| Endpoints | 2 (SSE + POST, separate URLs) | 1 (single MCP endpoint) |
| POST endpoint discovery | Via `event: endpoint` on SSE stream | None needed — same URL |
| SSE event types | `endpoint`, `message` | `message` only |
| POST response body | Empty (202) — all replies via SSE | JSON **or** SSE stream |
| Session ID | Not specified | `Mcp-Session-Id` header |
| GET for server-initiated msgs | N/A (SSE stream always open) | Optional GET to MCP endpoint |
| Batching | Not specified | Fully supported |
| Resumability | Not specified | `id:` field + `Last-Event-ID` |
| Session termination | Close SSE connection | `DELETE` to MCP endpoint |

---

## 3. Message Format

All messages use **JSON-RPC 2.0**, MUST be **UTF-8 encoded**.

### 3.1 Request

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "get_weather",
    "arguments": { "location": "NYC" }
  }
}
```

### 3.2 Successful Response

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [{ "type": "text", "text": "72°F, partly cloudy" }],
    "isError": false
  }
}
```

### 3.3 Error Response

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32602,
    "message": "Unknown tool: invalid_tool_name",
    "data": { "available": ["get_weather", "search"] }
  }
}
```

### 3.4 Notification (one-way)

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/tools/list_changed"
}
```

### Standard Error Codes

| Code | Meaning |
|------|---------|
| `-32700` | Parse error |
| `-32600` | Invalid request |
| `-32601` | Method not found |
| `-32602` | Invalid params |
| `-32603` | Internal error |
| `-32002` | Resource not found (MCP-specific) |

---

## 4. Protocol Lifecycle

### Phase 1: Initialization

**Client sends `initialize` request:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-03-26",
    "capabilities": {
      "roots": { "listChanged": true },
      "sampling": {}
    },
    "clientInfo": {
      "name": "ExampleClient",
      "version": "1.0.0"
    }
  }
}
```

**Server responds:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2025-03-26",
    "capabilities": {
      "logging": {},
      "prompts": { "listChanged": true },
      "resources": { "subscribe": true, "listChanged": true },
      "tools": { "listChanged": true }
    },
    "serverInfo": {
      "name": "ExampleServer",
      "version": "1.0.0"
    },
    "instructions": "Optional instructions for the client"
  }
}
```

**Client sends `initialized` notification:**

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```

Rules:
- `initialize` MUST NOT be in a JSON-RPC batch
- Client SHOULD NOT send non-ping requests before receiving response
- Server SHOULD NOT send non-ping/non-logging requests before `initialized`

### Version Negotiation

- Client sends latest version it supports
- Server responds with same version (if supported) or its own latest
- If incompatible, client SHOULD disconnect

### Capability Negotiation

| Side | Capability | Description |
|------|-----------|-------------|
| **Client** | `roots` | Filesystem roots; `listChanged` sub-cap |
| **Client** | `sampling` | Server-initiated LLM sampling |
| **Server** | `tools` | Callable tools; `listChanged` |
| **Server** | `resources` | Resources; `subscribe`, `listChanged` |
| **Server** | `prompts` | Prompt templates; `listChanged` |
| **Server** | `logging` | Structured log messages |
| **Server** | `completions` | Argument auto-completion |

### Phase 2: Operation

Normal bidirectional JSON-RPC messaging per negotiated capabilities.

### Phase 3: Shutdown

Transport-level disconnection:
- **stdio**: Close stdin -> wait -> SIGTERM -> SIGKILL
- **HTTP**: Close connections. Client SHOULD send HTTP DELETE with session ID.

### Ping (keepalive)

```json
{ "jsonrpc": "2.0", "id": "123", "method": "ping" }
// Response
{ "jsonrpc": "2.0", "id": "123", "result": {} }
```

---

## 5. Core Protocol Features

### 5.1 Tools

**Model-controlled** — the LLM discovers and invokes tools.

#### Discovery: `tools/list`

```json
{
  "result": {
    "tools": [{
      "name": "get_weather",
      "description": "Get current weather for a location",
      "inputSchema": {
        "type": "object",
        "properties": { "location": { "type": "string" } },
        "required": ["location"]
      }
    }],
    "nextCursor": "next-page"
  }
}
```

#### Invocation: `tools/call`

```json
{ "method": "tools/call",
  "params": { "name": "get_weather", "arguments": { "location": "New York" } } }

// Response
{ "result": {
    "content": [{ "type": "text", "text": "72°F, partly cloudy" }],
    "isError": false
} }
```

Result content types: `text`, `image` (base64), `audio` (base64), `resource` (embedded URI).

Tool execution errors: `"isError": true` in result. Protocol errors: standard JSON-RPC error.

### 5.2 Resources

**Application-driven** — host determines how to use them.

#### Discovery: `resources/list`, `resources/templates/list`

```json
{
  "result": {
    "resources": [{
      "uri": "file:///project/src/main.rs",
      "name": "main.rs",
      "description": "Primary entry point",
      "mimeType": "text/x-rust"
    }]
  }
}
```

#### Reading: `resources/read`

```json
// Text
{ "result": { "contents": [{ "uri": "file:///src/main.rs",
  "mimeType": "text/x-rust", "text": "fn main() { ... }" }] } }

// Binary
{ "result": { "contents": [{ "uri": "file:///image.png",
  "mimeType": "image/png", "blob": "base64-encoded-data" }] } }
```

#### Subscriptions

```json
{ "method": "resources/subscribe", "params": { "uri": "file:///src/main.rs" } }
// Server notification on change
{ "method": "notifications/resources/updated", "params": { "uri": "file:///src/main.rs" } }
```

### 5.3 Prompts

**User-controlled** — intended for explicit user selection (slash commands, menus).

```json
// Get
{ "method": "prompts/get", "params": { "name": "code_review",
  "arguments": { "code": "def hello():\n    print('world')" } } }

// Response
{ "result": {
  "messages": [{
    "role": "user",
    "content": { "type": "text", "text": "Please review this Python code:\ndef hello():\n    print('world')" }
  }]
} }
```

### 5.4 Sampling (Server-Initiated LLM Requests)

Allows servers to request LLM completions FROM clients.

```json
// Server -> Client request
{ "method": "sampling/createMessage",
  "params": {
    "messages": [{ "role": "user", "content": { "type": "text", "text": "What is the capital of France?" } }],
    "modelPreferences": {
      "hints": [{ "name": "claude-3-sonnet" }],
      "intelligencePriority": 0.8,
      "speedPriority": 0.5
    },
    "maxTokens": 100
  }
}

// Client responds
{ "result": {
    "role": "assistant",
    "content": { "type": "text", "text": "The capital of France is Paris." },
    "model": "claude-3-sonnet-20240307",
    "stopReason": "endTurn"
} }
```

### 5.5 Roots

Client-provided filesystem boundaries:

```json
{ "result": { "roots": [
  { "uri": "file:///home/user/projects/myproject", "name": "My Project" }
] } }
```

### 5.6 Logging

Structured logging using RFC 5424 severity levels: `debug`, `info`, `notice`, `warning`, `error`, `critical`, `alert`, `emergency`.

```json
{ "method": "notifications/message",
  "params": { "level": "error", "logger": "database",
    "data": { "error": "Connection failed" } } }
```

### 5.7 Progress & Cancellation

```json
// Progress
{ "method": "notifications/progress",
  "params": { "progressToken": "abc123", "progress": 50, "total": 100 } }

// Cancellation
{ "method": "notifications/cancelled",
  "params": { "requestId": "123", "reason": "User cancelled" } }
```

---

## 6. Protocol Versioning

| Version | Date | Status |
|---------|------|--------|
| `2025-03-26` | March 2025 | **Current** |
| `2024-11-05` | November 2024 | Superseded |

Version string format: `YYYY-MM-DD`. Negotiated during initialization.

---

## 7. Security & Authorization

### OAuth 2.1 (HTTP transports)

| Mechanism | Detail |
|-----------|--------|
| **Standard** | OAuth 2.1, RFC 8414, RFC 7591 |
| **PKCE** | REQUIRED for all clients |
| **Token delivery** | `Authorization: Bearer <token>` |
| **Metadata discovery** | `GET /.well-known/oauth-authorization-server` |
| **Dynamic registration** | `POST /register` |
| **Session** | `Mcp-Session-Id` header |

**stdio** SHOULD NOT use OAuth — retrieve credentials from environment.

### Transport Security

- All auth endpoints MUST be HTTPS
- Servers MUST validate `Origin` header (DNS rebinding prevention)
- Local servers SHOULD bind to `127.0.0.1` only

---

---

# Part 2: Elixir MCP Server Libraries

> **Note:** There is **no official Elixir SDK** on the [MCP SDK page](https://modelcontextprotocol.io/docs/sdk). Official SDKs exist for TypeScript, Python, C#, Go, Java, Rust, Swift, Ruby, PHP, and Kotlin. All Elixir implementations are community-driven.

---

## Summary Comparison Table

| Library | Hex Package | Version | Downloads | Stars | Maturity | Transports | Tools | Resources | Prompts | Sampling | License |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **Anubis MCP** | `anubis_mcp` | 1.5.0 | 200,097 | ~130 | Production | StreamableHTTP, SSE, stdio, WS | Yes | Yes | Yes | Partial | LGPL-3.0 |
| **Hermes MCP** | `hermes_mcp` | 0.14.1 | 133,257 | -- | Beta (stalled) | StreamableHTTP, SSE, stdio | Yes | Yes | Yes | -- | MIT |
| **ExMCP** | `ex_mcp` | 0.9.1 | 2,273 | 14 | Beta | HTTP/SSE, stdio, native BEAM | Yes | Yes | Yes | Yes | MIT |
| **EMCP** | `emcp` | 0.3.4 | 14,709 | 30 | Production | StreamableHTTP, stdio | Yes | Yes | Yes | No | MIT |
| **mcp_sse** | `mcp_sse` | 0.1.6 | 13,708 | 64 | Stable (stalled) | SSE only | Yes | No | No | No | Apache-2.0 |
| **Phantom MCP** | `phantom_mcp` | 0.4.5 | 7,925 | 35 | Beta | StreamableHTTP, stdio | Yes | Yes | Yes | No | MIT |
| **ConduitMCP** | `conduit_mcp` | 0.9.3 | 933 | 8 | Beta | StreamableHTTP, SSE | Yes | Yes | Yes | No | Apache-2.0 |
| **MCP (Kim Co.)** | `mcp` | 0.3.0 | 376 | 1 | Experimental | SSE only | Yes | No | No | No | Apache-2.0 |
| **LangChain MCP** | `langchain_mcp` | 0.2.0 | -- | 4 | Beta | N/A (client) | Client bridge | -- | -- | -- | -- |

---

## Tier 1: Production-Ready / High Adoption

### 1. Anubis MCP (formerly Hermes fork)

| Field | Value |
|---|---|
| **Repository** | github.com/zoedsoupe/anubis-mcp |
| **Hex** | `anubis_mcp` ~> 1.5.0 |
| **Downloads** | 200,097 |
| **License** | LGPL-3.0 |
| **Maturity** | **Production** — powers JIM, a Brazilian financial assistant serving hundreds of thousands of users |

Forked from `hermes_mcp` at v0.13.0. Surpassed the original in downloads and features. Described as "LiveView for MCP."

**Features:** Tools (compile-time and runtime), Resources, Prompts. Protocol versions: draft, 2024-11-05, partial 2025-03-26 (missing OAuth).

**Transports:** StreamableHTTP, SSE, stdio, WebSocket

```elixir
# mix.exs
{:anubis_mcp, "~> 1.5.0"}

# Tool definition
defmodule MyApp.Tools.Greeter do
  use Anubis.Server.Component, type: :tool

  schema do
    %{name: {:required, :string}}
  end

  @impl true
  def execute(%{name: name}, frame) do
    {:ok, "Hello, #{name}!", frame}
  end
end

# Server
defmodule MyApp.MCPServer do
  use Anubis.Server,
    name: "my-server",
    version: "1.0.0",
    capabilities: [:tools]

  component MyApp.Tools.Greeter
end

# Phoenix router
forward "/mcp", Anubis.Plug, server: MyApp.MCPServer
```

**OTP Design:** Full supervision tree, GenServer-based, dynamic tool/resource registration at runtime.

---

### 2. Hermes MCP (original, CloudWalk)

| Field | Value |
|---|---|
| **Repository** | github.com/cloudwalk/hermes-mcp |
| **Hex** | `hermes_mcp` ~> 0.14.1 |
| **Downloads** | 133,257 |
| **License** | MIT |
| **Maturity** | **Beta / Stalled** — no updates since Aug 2025 |

API nearly identical to Anubis (since Anubis forked from it). MIT-licensed alternative.

```elixir
{:hermes_mcp, "~> 0.14.1"}

defmodule MyApp.MCPServer do
  use Hermes.Server,
    name: "My MCP Server",
    version: "1.0.0",
    capabilities: [:tools]

  component MyApp.MCPServer.Tools.Greeter
end

# application.ex
children = [
  Hermes.Server.Registry,
  {MyApp.MCPServer, transport: :stdio}
]
```

---

### 3. EMCP

| Field | Value |
|---|---|
| **Repository** | github.com/PJUllrich/emcp |
| **Hex** | `emcp` ~> 0.3.4 |
| **Downloads** | 14,709 |
| **License** | MIT |
| **Maturity** | **Production** — author uses in production |

Minimal, Ruby SDK-inspired. Runs in a Plug, reusing Bandit/Cowboy connections.

```elixir
{:emcp, "~> 0.3.4"}

defmodule MyApp.MCPServer do
  use EMCP.Server,
    name: "my-app",
    version: "1.0.0",
    tools: [MyApp.Tools.Echo]
end
```

Notable: Per-server config via macro, StreamableHTTP silently re-creates expired sessions, Origin validation, pluggable session store.

---

## Tier 2: Solid with Active Development

### 4. ExMCP

| Field | Value |
|---|---|
| **Repository** | github.com/azmaveth/ex_mcp |
| **Hex** | `ex_mcp` ~> 0.9.1 |
| **Downloads** | 2,273 |
| **License** | MIT |
| **Maturity** | **Beta** — most spec-complete |

Claims **100% MCP conformance** (223/223 client, 39/39 server checks). Supports 4 protocol versions. Also implements **Agent Client Protocol (ACP)**.

**Unique: Native BEAM transport** (~15us inter-node calls).

```elixir
{:ex_mcp, "~> 0.9.0"}

defmodule MyServer do
  use ExMCP.Server

  deftool "greet" do
    meta do
      name "Greet"
      description "Greets a person by name"
    end
    input_schema %{
      type: "object",
      properties: %{name: %{type: "string"}},
      required: ["name"]
    }
  end

  @impl true
  def handle_tool_call("greet", %{"name" => name}, state) do
    {:ok, %{content: [text("Hello, #{name}!")]}, state}
  end
end

# Phoenix
scope "/api/mcp" do
  forward "/", ExMCP.HttpPlug,
    handler: MyApp.MCPHandler,
    sse_enabled: true, cors_enabled: true
end
```

OAuth 2.1 with PKCE, JWT client auth, 88 telemetry events, 3100+ tests.

---

### 5. Phantom MCP

| Field | Value |
|---|---|
| **Repository** | github.com/dbernheisel/phantom_mcp |
| **Hex** | `phantom_mcp` ~> 0.4.5 |
| **Downloads** | 7,925 |
| **License** | MIT |
| **Maturity** | **Beta** — active, 99 commits |

Clean DSL, good auth story, distributed support via Phoenix.PubSub + Tracker.

```elixir
{:phantom_mcp, "~> 0.4.5"}

defmodule MyApp.MCP.Router do
  use Phantom.Router, name: "MyApp", vsn: "1.0"
end

tool :create_question, MyApp.MCP do
  field :study_id, :integer, required: true
  field :label, :string, required: true
end

resource "https://example.com/studies/:study_id/md", :study,
  mime_type: "text/markdown"

prompt :suggest_questions,
  completion_function: :study_complete,
  arguments: [%{name: "study_id", required: true}]
```

Per-session auth with allowlisting. Async tool handlers via `{:noreply, session}` + `Task.async`.

---

### 6. ConduitMCP

| Field | Value |
|---|---|
| **Repository** | github.com/nyo16/conduit_mcp |
| **Hex** | `conduit_mcp` ~> 0.9.3 |
| **Downloads** | 933 |
| **License** | Apache-2.0 |
| **Maturity** | **Beta** |

Three dev patterns (DSL, Manual, Endpoint+Component). MCP Apps support. OAuth 2.1.

```elixir
{:conduit_mcp, "~> 0.9.0"}

defmodule MyApp.MCPServer do
  use ConduitMcp.Server

  tool "greet", "Greet someone" do
    param :name, :string, "Person's name", required: true
    handle fn _conn, params -> text("Hey, #{params["name"]}!") end
  end

  resource "user://{id}" do
    description "User profile"
    mime_type "application/json"
    read fn _conn, params, _opts -> json(MyApp.Users.get!(params["id"])) end
  end
end
```

Dual-layer rate limiting (Hammer), pluggable session stores (ETS/Redis/PG/Mnesia), Prometheus telemetry.

---

## Tier 3: Focused / Niche

| Library | Hex | Notes |
|---|---|---|
| **mcp_sse** | `mcp_sse` ~> 0.1.6 | SSE-only, tools-only. Earliest Elixir MCP impl. 13.7K downloads, 64 stars. Stalled Apr 2025. |
| **MCP (Kim Co.)** | `mcp` ~> 0.3.0 | SSE-only, tools-only. 376 downloads. |
| **LangChain MCP** | `langchain_mcp` ~> 0.2.0 | **Client adapter** bridging MCP servers into LangChain Elixir. Not a server library. |
| **mcp_ex** | `mcp_ex` ~> 0.1.0 | Client-only. 151 downloads. |
| **mcpixir** | `mcpixir` ~> 0.1.0 | Client-only. 117 downloads. |
| **elixir_mcp_server** | 0.1.0 | Reference implementation. 54 downloads. |

---

## Decision Matrix

| If you need... | Use |
|---|---|
| **Battle-tested production** | **Anubis MCP** — most downloads, proven at scale (LGPL-3.0) |
| **MIT license + production** | **EMCP** — minimal, production-used, easy to audit |
| **Maximum spec compliance** | **ExMCP** — 100% conformance, 4 protocol versions, ACP |
| **Best DSL / ergonomics** | **Phantom MCP** or **ConduitMCP** |
| **Native BEAM transport** | **ExMCP** — ~15us inter-node calls |
| **Distributed/clustered** | **Phantom MCP** — PubSub + Tracker |
| **LangChain integration** | **LangChain MCP** |
| **Avoid LGPL** | EMCP, Phantom, ExMCP, ConduitMCP (all MIT/Apache) |
