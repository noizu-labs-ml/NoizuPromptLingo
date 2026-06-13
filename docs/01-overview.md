# MCP Specification Overview

Reference documentation for the Model Context Protocol (MCP), compiled from the
official specification at [modelcontextprotocol.io](https://modelcontextprotocol.io)
and the [specification repository](https://github.com/modelcontextprotocol/specification).

Target audience: implementers building an MCP library in Elixir/OTP.

---

## 1. What MCP Is

The **Model Context Protocol (MCP)** is an open protocol that standardizes how
LLM applications connect to external data sources and tools. It was created at
**Anthropic** by David Soria Parra and Justin Spahr-Summers, publicly announced
and open-sourced on **November 25, 2024**.

MCP draws direct inspiration from the **Language Server Protocol (LSP)**. Just as
LSP standardized how editors talk to language tooling, MCP standardizes how AI
applications talk to context providers -- solving the N x M integration problem
where every AI app previously needed custom connectors for every data source.

### Goals

- Provide a single, standard protocol for connecting LLMs to external context
  and capabilities.
- Make servers easy to build and highly composable.
- Enforce security boundaries: servers cannot read the full conversation or see
  into other servers.
- Support progressive feature adoption through capability negotiation.
- Maintain user consent and control over data access and tool execution.

### Version History

| Version        | Date              | Notes                                      |
|----------------|-------------------|--------------------------------------------|
| `2024-11-05`   | November 5, 2024  | Initial specification release              |
| `2025-03-26`   | March 26, 2025    | Major update (OAuth 2.1, Streamable HTTP, tool annotations, batching) |
| `2025-06-18`   | June 18, 2025     | Removed batching; added elicitation, structured tool output, resource links, RFC 9728/8707 auth hardening — see [07-changelog-2025-06-18.md](07-changelog-2025-06-18.md) |
| `2025-11-25`   | November 25, 2025 | SEP-1303 validation-as-results, icons, experimental tasks, auth clarifications — see [08-changelog-2025-11-25.md](08-changelog-2025-11-25.md) |

The protocol version is a **date string** (e.g., `"2025-11-25"`) used during the
initialization handshake.

**This library targets `2025-11-25`** and negotiates down to `2025-06-18`.
`2025-03-26` and earlier are deliberately unsupported (they require JSON-RPC
batching, which later revisions removed).

### Authoritative Schema

The canonical type definitions live in the TypeScript schema at:

```
https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-11-25/schema.ts
```

A machine-readable JSON Schema is generated from it at:

```
https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-11-25/schema.json
```

A copy is vendored in this repo at `priv/spec/2025-11-25/schema.json` and used
by the conformance test suite.

---

## 2. Architecture

MCP uses a **host / client / server** architecture.

```
Host Process (e.g., Claude Desktop, an IDE)
  |
  +-- MCP Client A  <--1:1-->  MCP Server A  (e.g., filesystem)
  |
  +-- MCP Client B  <--1:1-->  MCP Server B  (e.g., database)
  |
  +-- MCP Client C  <--1:1-->  MCP Server C  (e.g., external API)
```

### Host

The host is the user-facing application that embeds LLM capabilities. It:

- Creates and manages multiple MCP client instances.
- Controls client connection permissions and lifecycle.
- Enforces security policies and user consent requirements.
- Handles user authorization decisions.
- Coordinates AI/LLM integration and sampling.
- Aggregates context across clients.

Examples: Claude Desktop, VS Code with Copilot, Cursor, custom AI applications.

### Client

An MCP client is a connector that lives inside the host process. Each client:

- Maintains a **1:1 stateful session** with exactly one MCP server.
- Handles protocol negotiation and capability exchange.
- Routes protocol messages bidirectionally.
- Manages subscriptions and notifications.
- Maintains security boundaries between servers.

A host creates one client per server connection. Clients are not shared across
servers.

### Server

An MCP server provides context and capabilities to the LLM through three
primitives (resources, tools, prompts). Servers:

- Expose capabilities via the MCP protocol.
- Operate independently with focused responsibilities.
- Can request LLM sampling through the client (if the client advertises the
  capability).
- May be local processes (stdio) or remote services (HTTP).

---

## 3. JSON-RPC 2.0 Foundation

All MCP messages are **UTF-8 encoded JSON-RPC 2.0**. There are three message
types: requests, responses, and notifications.

### Request

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list",
  "params": {}
}
```

- `id` -- string or integer, MUST NOT be null. MUST be unique within the session
  for the sender (i.e., the requestor must not reuse an ID that is still
  in-flight).
- `method` -- the RPC method name.
- `params` -- optional, method-specific parameters.

### Response (success)

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": { ... }
}
```

### Response (error)

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32602,
    "message": "Invalid params",
    "data": { ... }
  }
}
```

- Exactly one of `result` or `error` MUST be present, never both.
- Error `code` MUST be an integer.

### Notification

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```

- MUST NOT include an `id` field.
- The receiver MUST NOT send a response to a notification.

### Batching

- Implementations MAY support *sending* JSON-RPC batches (arrays of messages).
- Implementations MUST support *receiving* JSON-RPC batches.

### Standard Error Codes

| Code     | Meaning                              |
|----------|--------------------------------------|
| `-32700` | Parse error (malformed JSON)         |
| `-32600` | Invalid request                      |
| `-32601` | Method not found                     |
| `-32602` | Invalid params                       |
| `-32603` | Internal error                       |
| `-32002` | Resource not found (MCP-specific)    |

---

## 4. Protocol Lifecycle

The protocol has three phases: **initialization**, **operation**, and
**shutdown**.

### 4.1 Initialization

Initialization is a three-step handshake.

**Step 1 -- Client sends `initialize` request:**

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
      "name": "MyElixirHost",
      "version": "1.0.0"
    }
  }
}
```

**Step 2 -- Server responds with its capabilities:**

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
    "instructions": "Optional natural-language instructions for the LLM"
  }
}
```

**Step 3 -- Client sends `initialized` notification:**

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```

**Rules:**

- The `initialize` request MUST NOT be part of a JSON-RPC batch.
- The client SHOULD NOT send requests (other than `ping`) before receiving the
  server's initialize response.
- The server SHOULD NOT send requests (other than `ping` and `logging`) before
  receiving the `initialized` notification.

### 4.2 Version Negotiation

- The client sends its supported protocol version (SHOULD be the latest it
  supports).
- If the server supports that version, it responds with the same version string.
- If the server does not support it, it responds with a version it does support
  (SHOULD be its latest).
- If the client does not support the server's counter-offer, it SHOULD
  disconnect.

**Error example (unsupported version):**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32602,
    "message": "Unsupported protocol version",
    "data": {
      "supported": ["2024-11-05"],
      "requested": "2025-03-26"
    }
  }
}
```

### 4.3 Capability Negotiation

Both client and server declare what features they support during initialization.
Only features corresponding to declared capabilities may be used.

**Client capabilities:**

| Capability     | Sub-options      | Description                          |
|----------------|------------------|--------------------------------------|
| `roots`        | `listChanged`    | Client can provide filesystem roots  |
| `sampling`     | (none)           | Client supports LLM sampling requests |
| `experimental` | (varies)         | Non-standard experimental features   |

**Server capabilities:**

| Capability     | Sub-options               | Description                         |
|----------------|---------------------------|-------------------------------------|
| `prompts`      | `listChanged`             | Server provides prompt templates    |
| `resources`    | `subscribe`, `listChanged`| Server provides readable resources  |
| `tools`        | `listChanged`             | Server provides callable tools      |
| `logging`      | (none)                    | Server supports structured logging  |
| `completions`  | (none)                    | Server supports argument completion |
| `experimental` | (varies)                  | Non-standard experimental features  |

### 4.4 Normal Operation

After initialization, both sides exchange messages according to negotiated
capabilities. Either side may send requests and notifications. Pagination is
supported on all list operations via `cursor`/`nextCursor` parameters.

### 4.5 Timeouts

- Implementations SHOULD establish timeouts for all sent requests.
- On timeout, the sender SHOULD issue a `notifications/cancelled` notification
  and stop waiting for the response.
- SDKs SHOULD allow per-request timeout configuration.
- Timeout MAY be reset on receipt of progress notifications, but a maximum
  overall timeout SHOULD be enforced.

### 4.6 Shutdown

**stdio transport:**

1. Client closes the server's stdin.
2. Client waits for the server process to exit.
3. Client sends SIGTERM if the server does not exit.
4. Client sends SIGKILL if SIGTERM is not honored.

**HTTP transport:**

1. Client closes HTTP connections.
2. Client SHOULD send an HTTP DELETE to the MCP endpoint with the
   `Mcp-Session-Id` header to explicitly terminate the session.

---

## 5. Transports

MCP defines two standard transport mechanisms.

### 5.1 stdio

The client launches the MCP server as a **child process**.

- Server reads JSON-RPC messages from **stdin**.
- Server writes JSON-RPC messages to **stdout**.
- Messages are delimited by **newlines** and MUST NOT contain embedded newlines.
- Messages may be single JSON-RPC messages or JSON-RPC batch arrays.
- Server MAY write UTF-8 strings to **stderr** for logging/diagnostics.
- Server MUST NOT write non-MCP content to stdout.
- Client MUST NOT write non-MCP content to the server's stdin.

Best for: local integrations, command-line tools, same-machine communication.

### 5.2 Streamable HTTP

Introduced in `2025-03-26`, replacing the older HTTP+SSE dual-endpoint transport
from `2024-11-05`.

The server exposes a **single HTTP endpoint** (e.g., `https://example.com/mcp`).

**Client to server (POST):**

- Every JSON-RPC message from the client is an HTTP POST to the endpoint.
- The client MUST include `Accept: application/json, text/event-stream`.
- The body may be a single request, notification, or response, or a batch array.
- If the input contains only notifications/responses: server returns
  `202 Accepted` with no body.
- If the input contains requests: server returns either
  `Content-Type: application/json` (single response) or
  `Content-Type: text/event-stream` (SSE stream with potentially multiple
  responses).

**Server to client (GET for SSE stream):**

- Client MAY issue an HTTP GET to the endpoint to open an SSE stream for
  server-initiated messages (requests and notifications).
- Server returns `Content-Type: text/event-stream` or `405 Method Not Allowed`.
- Server MUST NOT send responses on the GET stream (unless resuming a
  disconnected stream).

**Session management:**

- Server MAY assign a session ID via `Mcp-Session-Id` response header on the
  `initialize` result.
- Client MUST include `Mcp-Session-Id` on all subsequent requests.
- Missing/invalid session ID returns `400 Bad Request`.
- Server MAY terminate a session; subsequent requests receive `404 Not Found`.
- Client can DELETE the endpoint with the session header to explicitly terminate.
- Session IDs must be globally unique, cryptographically secure, and contain only
  visible ASCII characters (0x21-0x7E).

**Resumability:**

- Servers MAY attach `id` fields to SSE events.
- Clients can resume a disconnected stream via `Last-Event-ID` header on GET.
- Event IDs are scoped per stream.

**Security requirements (HTTP):**

- Servers MUST validate the `Origin` header to prevent DNS rebinding attacks.
- Local servers MUST bind to localhost only.
- Servers SHOULD implement authentication (see Section 7).

**Backward compatibility with HTTP+SSE (2024-11-05):**

- Clients: POST the `initialize` request to the URL. If the server returns 4xx,
  fall back to the old protocol: issue a GET for an SSE stream and wait for an
  `endpoint` event.
- Servers: may host both old-style and new-style endpoints.

---

## 6. Core Primitives

MCP servers expose three types of primitives, each with a different interaction
model.

### 6.1 Resources (Application-Controlled)

Resources represent contextual data that the host application manages. The host
decides how and when to attach resource content to the LLM context.

**Capability:** `resources` with optional `subscribe` and `listChanged`.

**Resource definition fields:**

| Field         | Type    | Required | Description                        |
|---------------|---------|----------|------------------------------------|
| `uri`         | string  | yes      | Unique URI (RFC 3986)              |
| `name`        | string  | yes      | Display name                       |
| `title`       | string  | no       | Human-readable title               |
| `description` | string  | no       | Description                        |
| `mimeType`    | string  | no       | MIME type of the content            |
| `size`        | integer | no       | Size in bytes                      |
| `annotations` | object  | no       | `audience`, `priority`, `lastModified` |

**URI schemes:** `file://`, `https://`, `git://`, or custom schemes per RFC 3986.

**Methods:**

| Method                                 | Direction       | Type         | Description                        |
|----------------------------------------|-----------------|--------------|------------------------------------|
| `resources/list`                       | Client->Server  | Request      | List available resources (paginated) |
| `resources/read`                       | Client->Server  | Request      | Read resource contents by URI      |
| `resources/templates/list`             | Client->Server  | Request      | List URI templates (RFC 6570, paginated) |
| `resources/subscribe`                  | Client->Server  | Request      | Subscribe to change notifications  |
| `resources/unsubscribe`                | Client->Server  | Request      | Unsubscribe                        |
| `notifications/resources/list_changed` | Server->Client  | Notification | The resource list has changed       |
| `notifications/resources/updated`      | Server->Client  | Notification | A subscribed resource has changed   |

**Read response content:**

- Text: `{ "uri": "...", "mimeType": "text/plain", "text": "content" }`
- Binary: `{ "uri": "...", "mimeType": "image/png", "blob": "<base64>" }`

**Error:** Resource not found returns code `-32002`.

### 6.2 Tools (Model-Controlled)

Tools are functions that the LLM can discover and invoke to take actions.

**Capability:** `tools` with optional `listChanged`.

**Tool definition fields:**

| Field          | Type        | Required | Description                           |
|----------------|-------------|----------|---------------------------------------|
| `name`         | string      | yes      | Unique identifier                     |
| `title`        | string      | no       | Human-readable display name           |
| `description`  | string      | yes      | Description of functionality          |
| `inputSchema`  | JSON Schema | yes      | Defines expected input parameters     |
| `outputSchema` | JSON Schema | no       | Defines expected structured output    |
| `annotations`  | object      | no       | Behavioral metadata (see below)       |

**Tool annotations** (clients MUST treat as untrusted from untrusted servers):

| Annotation         | Type    | Default | Description                            |
|--------------------|---------|---------|----------------------------------------|
| `title`            | string  | --      | Human-readable display name            |
| `readOnlyHint`     | boolean | false   | Tool does not modify state             |
| `destructiveHint`  | boolean | true    | Tool may perform destructive operations |
| `idempotentHint`   | boolean | false   | Repeated identical calls are safe      |
| `openWorldHint`    | boolean | true    | Tool interacts with external entities  |

**Methods:**

| Method                              | Direction       | Type         | Description                 |
|-------------------------------------|-----------------|--------------|-----------------------------|
| `tools/list`                        | Client->Server  | Request      | List available tools (paginated) |
| `tools/call`                        | Client->Server  | Request      | Invoke a tool by name       |
| `notifications/tools/list_changed`  | Server->Client  | Notification | The tool list has changed    |

**`tools/call` request:**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "get_weather",
    "arguments": { "location": "New York" }
  }
}
```

**`tools/call` response:**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "content": [
      { "type": "text", "text": "Temperature: 72F, Partly cloudy" }
    ],
    "isError": false
  }
}
```

**Content types in tool results:**

- `text` -- `{ "type": "text", "text": "..." }`
- `image` -- `{ "type": "image", "data": "<base64>", "mimeType": "image/png" }`
- `audio` -- `{ "type": "audio", "data": "<base64>", "mimeType": "audio/wav" }`
- `resource` -- `{ "type": "resource", "resource": { "uri": "...", "mimeType": "...", "text": "..." } }`
- `resource_link` -- `{ "type": "resource_link", "uri": "...", "name": "...", "mimeType": "..." }`

**Structured output:** When `outputSchema` is defined, the response includes both
`content` (backward-compatible text serialization) and `structuredContent` (the
typed object matching the schema). Servers MUST conform to the schema; clients
SHOULD validate.

**Error handling:** Two distinct error types:

1. **Protocol errors** -- JSON-RPC error response (e.g., `-32602` for unknown
   tool or invalid arguments).
2. **Tool execution errors** -- Successful JSON-RPC response with
   `isError: true` in the result and error details in `content`.

### 6.3 Prompts (User-Controlled)

Prompts are templated messages and workflows that users invoke directly (e.g.,
slash commands, menu items).

**Capability:** `prompts` with optional `listChanged`.

**Prompt definition fields:**

| Field         | Type   | Required | Description                   |
|---------------|--------|----------|-------------------------------|
| `name`        | string | yes      | Unique identifier             |
| `title`       | string | no       | Human-readable display name   |
| `description` | string | no       | Description                   |
| `arguments`   | array  | no       | Argument definitions          |

Each argument: `{ "name": "...", "description": "...", "required": true|false }`

**Methods:**

| Method                               | Direction       | Type         | Description                  |
|--------------------------------------|-----------------|--------------|------------------------------|
| `prompts/list`                       | Client->Server  | Request      | List available prompts (paginated) |
| `prompts/get`                        | Client->Server  | Request      | Get prompt messages with arguments |
| `notifications/prompts/list_changed` | Server->Client  | Notification | The prompt list has changed    |

**`prompts/get` response:**

```json
{
  "result": {
    "description": "Code review prompt",
    "messages": [
      {
        "role": "user",
        "content": { "type": "text", "text": "Please review this code: ..." }
      }
    ]
  }
}
```

**PromptMessage content types:** `text`, `image`, `audio`, embedded `resource`.
Roles are `"user"` or `"assistant"`.

### 6.4 Sampling (Server-Initiated LLM Requests)

Sampling allows servers to request LLM completions **from** the client. This
enables agentic behaviors where the server drives multi-step LLM interactions
without needing its own API keys.

**Capability (client-side):** `sampling: {}`

**Method:** `sampling/createMessage` -- server sends this request TO the client.

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "sampling/createMessage",
  "params": {
    "messages": [
      { "role": "user", "content": { "type": "text", "text": "Summarize this data" } }
    ],
    "modelPreferences": {
      "hints": [{ "name": "claude-3-sonnet" }],
      "intelligencePriority": 0.8,
      "speedPriority": 0.5,
      "costPriority": 0.3
    },
    "systemPrompt": "You are a helpful assistant.",
    "maxTokens": 500
  }
}
```

**Response:**

```json
{
  "result": {
    "role": "assistant",
    "content": { "type": "text", "text": "Here is the summary..." },
    "model": "claude-3-sonnet-20240307",
    "stopReason": "endTurn"
  }
}
```

**Model preferences:**

- `hints` -- array of `{ name: string }`, substring-matched model names in
  preference order. Advisory only; the client makes the final selection and MAY
  map to equivalent models from different providers.
- `costPriority` (0-1) -- higher values prefer cheaper models.
- `speedPriority` (0-1) -- higher values prefer faster models.
- `intelligencePriority` (0-1) -- higher values prefer more capable models.

**Human-in-the-loop:** Clients SHOULD present sampling requests to the user for
approval. Users may modify the prompt before it reaches the LLM and review the
response before it is returned to the server.

**Additional request fields:** `temperature`, `stopSequences`, `metadata`,
`includeContext`.

### 6.5 Roots (Client-Provided Filesystem Boundaries)

Roots tell the server which filesystem locations it should operate within.

**Capability (client-side):** `roots` with optional `listChanged`.

**Methods:**

| Method                              | Direction       | Type         | Description                    |
|-------------------------------------|-----------------|--------------|--------------------------------|
| `roots/list`                        | Server->Client  | Request      | Server requests filesystem roots |
| `notifications/roots/list_changed`  | Client->Server  | Notification | Client notifies roots changed   |

**Root definition:** `{ "uri": "file:///path/to/project", "name": "My Project" }`

URIs MUST use the `file://` scheme.

---

## 7. Utilities

### Ping

Either side can send a `ping` request to check connection health.

```json
{ "jsonrpc": "2.0", "id": 99, "method": "ping" }
```

Response: `{ "jsonrpc": "2.0", "id": 99, "result": {} }`

### Cancellation

Either side can cancel an in-progress request via notification:

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/cancelled",
  "params": {
    "requestId": 1,
    "reason": "User cancelled"
  }
}
```

- MUST NOT cancel the `initialize` request.
- Fire-and-forget semantics; the receiver must handle race conditions gracefully
  (the result may already be in flight).

### Progress

A requester includes `_meta.progressToken` in the request params. The receiver
sends progress notifications:

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/progress",
  "params": {
    "progressToken": "token-from-request",
    "progress": 50,
    "total": 100,
    "message": "Processing items..."
  }
}
```

- `progress` MUST increase monotonically.
- `total` and `message` are optional.
- Values MAY be floating point.

### Logging

**Capability (server-side):** `logging: {}`

Client sets minimum level: `logging/setLevel` with `{ "level": "warning" }`.

Server sends log messages:

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/message",
  "params": {
    "level": "error",
    "logger": "database",
    "data": "Connection timeout after 30s"
  }
}
```

**Log levels** (RFC 5424 / syslog): `debug`, `info`, `notice`, `warning`,
`error`, `critical`, `alert`, `emergency`.

### Completion (Autocompletion)

**Capability (server-side):** `completions: {}`

Provides argument autocompletion for prompts and resource URI templates.

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "completion/complete",
  "params": {
    "ref": { "type": "ref/prompt", "name": "code_review" },
    "argument": { "name": "language", "value": "py" }
  }
}
```

Response:

```json
{
  "result": {
    "completion": {
      "values": ["python", "pytorch", "pyside"],
      "total": 10,
      "hasMore": true
    }
  }
}
```

Reference types: `ref/prompt` (by name) or `ref/resource` (by URI). Maximum 100
values per response.

---

## 8. Authorization (HTTP Transports Only)

Authorization is **OPTIONAL**. When implemented:

- Based on **OAuth 2.1** with PKCE required for all clients.
- Supports **Authorization Code** grant (human users) and **Client Credentials**
  grant (machine-to-machine).
- Server metadata discovery via `GET /.well-known/oauth-authorization-server`
  (RFC 8414).
- **Dynamic Client Registration** (RFC 7591) SHOULD be supported, enabling
  clients to connect to unknown servers without pre-registration.
- Access tokens sent via `Authorization: Bearer <token>` on every HTTP request.
- Session ID (`Mcp-Session-Id`) is separate from OAuth tokens.
- When the server requires auth, it responds with `HTTP 401 Unauthorized`.

**Fallback endpoints** (when metadata discovery is unavailable): `/authorize`,
`/token`, `/register`.

**stdio transports** SHOULD retrieve credentials from the environment instead of
implementing OAuth.

---

## 9. Complete Method Reference

| Method                                 | Direction       | Type         | Description                          |
|----------------------------------------|-----------------|--------------|--------------------------------------|
| `initialize`                           | Client->Server  | Request      | Start session, negotiate capabilities |
| `notifications/initialized`            | Client->Server  | Notification | Client ready for normal operation    |
| `ping`                                 | Either          | Request      | Connection health check              |
| `notifications/cancelled`              | Either          | Notification | Cancel an in-progress request        |
| `notifications/progress`               | Either          | Notification | Progress update for a request        |
| `resources/list`                       | Client->Server  | Request      | List available resources             |
| `resources/templates/list`             | Client->Server  | Request      | List resource URI templates          |
| `resources/read`                       | Client->Server  | Request      | Read resource content                |
| `resources/subscribe`                  | Client->Server  | Request      | Subscribe to resource changes        |
| `resources/unsubscribe`                | Client->Server  | Request      | Unsubscribe from resource changes    |
| `notifications/resources/list_changed` | Server->Client  | Notification | Resource list changed                |
| `notifications/resources/updated`      | Server->Client  | Notification | Subscribed resource changed          |
| `tools/list`                           | Client->Server  | Request      | List available tools                 |
| `tools/call`                           | Client->Server  | Request      | Invoke a tool                        |
| `notifications/tools/list_changed`     | Server->Client  | Notification | Tool list changed                    |
| `prompts/list`                         | Client->Server  | Request      | List available prompts               |
| `prompts/get`                          | Client->Server  | Request      | Get prompt with arguments            |
| `notifications/prompts/list_changed`   | Server->Client  | Notification | Prompt list changed                  |
| `sampling/createMessage`               | Server->Client  | Request      | Request LLM completion               |
| `roots/list`                           | Server->Client  | Request      | List filesystem roots                |
| `notifications/roots/list_changed`     | Client->Server  | Notification | Roots changed                        |
| `logging/setLevel`                     | Client->Server  | Request      | Set minimum log level                |
| `notifications/message`                | Server->Client  | Notification | Log message                          |
| `completion/complete`                  | Client->Server  | Request      | Get autocompletion suggestions       |

---

## 10. Implementation Notes for Elixir/OTP

### Existing Elixir Implementations

Several community MCP implementations exist on the BEAM:

- **ExMCP** ([GitHub](https://github.com/azmaveth/ex_mcp)) -- client + server
  with Phoenix/Plug integration.
- **Anubis MCP** ([GitHub](https://github.com/zoedsoupe/anubis-mcp)) -- full
  client and server leveraging OTP concurrency.
- **elixir-mcp** ([GitHub](https://github.com/arjan/elixir-mcp)) -- modular
  protocol implementation and server.
- **erlmcp** ([GitHub](https://github.com/erlsci/erlmcp)) -- OTP-compliant
  Erlang implementation.

### OTP Design Considerations

- **GenServer per session** -- each MCP client-server session maps naturally to a
  GenServer maintaining connection state and capabilities.
- **Supervision** -- a host supervisor can manage multiple client GenServers, one
  per server connection.
- **stdio transport** -- use `Port` or `:erlang.open_port/2` for subprocess
  management. Parse newline-delimited JSON-RPC from stdout.
- **HTTP transport** -- use `Plug` or `Phoenix` for the server endpoint. For the
  client, use an HTTP client library with SSE streaming support.
- **Capability tracking** -- store negotiated capabilities in GenServer state to
  gate method dispatch.
- **Pagination** -- implement cursor-based pagination using opaque cursor tokens.
- **JSON-RPC** -- consider a dedicated module for encoding/decoding JSON-RPC 2.0
  messages, handling batches, and routing by method name.

### Key Specification References

- Spec: https://modelcontextprotocol.io/specification/2025-03-26
- TypeScript schema: https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-03-26/schema.ts
- JSON Schema: https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-03-26/schema.json
- Protocol repo: https://github.com/modelcontextprotocol/specification
