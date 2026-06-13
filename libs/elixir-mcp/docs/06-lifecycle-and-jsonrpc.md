# MCP Lifecycle, Capability Negotiation, and JSON-RPC Reference

Reference documentation for implementing the Model Context Protocol (MCP) in Elixir.
Based on MCP specification version **2025-03-26** with notes on changes from **2024-11-05**.

> **Baseline note:** this document describes the **2025-03-26** revision. The
> library targets **2025-11-25** — most importantly, **JSON-RPC batching was
> removed in 2025-06-18** (this library rejects batch arrays), and the
> `MCP-Protocol-Version` HTTP header became required. See
> [07-changelog-2025-06-18.md](07-changelog-2025-06-18.md) and
> [08-changelog-2025-11-25.md](08-changelog-2025-11-25.md).

---

## Table of Contents

1. [JSON-RPC 2.0 Base](#1-json-rpc-20-base)
2. [Protocol Version and Negotiation](#2-protocol-version-and-negotiation)
3. [Initialization Handshake](#3-initialization-handshake)
4. [Client Capabilities](#4-client-capabilities)
5. [Server Capabilities](#5-server-capabilities)
6. [Ping/Pong](#6-pingpong)
7. [Progress Reporting](#7-progress-reporting)
8. [Cancellation](#8-cancellation)
9. [Logging](#9-logging)
10. [Error Handling](#10-error-handling)
11. [Shutdown](#11-shutdown)
12. [Protocol Version History](#12-protocol-version-history)
13. [Complete Method Reference](#13-complete-method-reference)
14. [Key Schema Definitions](#14-key-schema-definitions)

---

## 1. JSON-RPC 2.0 Base

All MCP messages MUST be UTF-8 encoded JSON-RPC 2.0. The protocol defines three
fundamental message types: **requests**, **responses**, and **notifications**.

### Constants

| Constant                 | Value            |
|--------------------------|------------------|
| `LATEST_PROTOCOL_VERSION`| `"2025-03-26"`   |
| `JSONRPC_VERSION`        | `"2.0"`          |

### Core Types

| Type            | Definition         | Notes                                      |
|-----------------|--------------------|--------------------------------------------|
| `RequestId`     | `string \| number` | MUST NOT be `null`; unique per session per sender |
| `ProgressToken` | `string \| number` | Unique across all active requests          |
| `Cursor`        | `string`           | Opaque pagination cursor                   |

### 1.1 Request

A request expects a corresponding response. The `id` field correlates them.

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "some/method",
  "params": {
    "_meta": {
      "progressToken": "tok-1"
    },
    "someField": "value"
  }
}
```

| Field    | Type               | Required | Notes                                          |
|----------|--------------------|----------|-------------------------------------------------|
| `jsonrpc`| `"2.0"`            | yes      | Constant                                        |
| `id`     | `string \| number` | yes      | MUST NOT be null; MUST NOT be reused in session |
| `method` | `string`           | yes      | JSON-RPC method name                            |
| `params` | `object`           | no       | May contain `_meta` sub-object                  |

The `_meta` sub-object within `params` carries protocol-level metadata such as
`progressToken`. Implementations MUST preserve unknown `_meta` fields.

### 1.2 Response (Success)

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "_meta": {},
    "someData": "value"
  }
}
```

| Field    | Type               | Required | Notes                        |
|----------|--------------------|----------|------------------------------|
| `jsonrpc`| `"2.0"`            | yes      | Constant                     |
| `id`     | `string \| number` | yes      | Must match the request `id`  |
| `result` | `object`           | yes      | May contain `_meta`          |

### 1.3 Response (Error)

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32601,
    "message": "Method not found",
    "data": {"detail": "optional extra info"}
  }
}
```

| Field          | Type               | Required | Notes                       |
|----------------|--------------------|----------|-----------------------------|
| `jsonrpc`      | `"2.0"`            | yes      | Constant                    |
| `id`           | `string \| number` | yes      | Must match the request `id` |
| `error.code`   | `integer`          | yes      | Error code                  |
| `error.message`| `string`           | yes      | Human-readable description  |
| `error.data`   | `any`              | no       | Additional error details    |

A response MUST contain either `result` or `error`, never both.

### 1.4 Notification

Notifications are fire-and-forget messages with no `id` and no response expected.

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/some_event",
  "params": {
    "_meta": {}
  }
}
```

| Field    | Type     | Required | Notes                              |
|----------|----------|----------|------------------------------------|
| `jsonrpc`| `"2.0"`  | yes      | Constant                           |
| `method` | `string` | yes      | Notification method name           |
| `params` | `object` | no       | May contain `_meta`                |

A notification MUST NOT include an `id` field.

### 1.5 Batch Messages

Added in protocol version `2025-03-26`.

- `JSONRPCBatchRequest`: array of `JSONRPCRequest | JSONRPCNotification`
- `JSONRPCBatchResponse`: array of `JSONRPCResponse | JSONRPCError`

Implementations MUST support receiving batch messages. Implementations MAY
support sending batch messages. The `initialize` request MUST NOT be part of a batch.

### 1.6 Pagination

Paginated requests accept an optional `cursor: string` parameter. Paginated
responses include an optional `nextCursor: string` in the result. Cursors are
opaque strings -- clients MUST NOT interpret their contents.

---

## 2. Protocol Version and Negotiation

### Current Version

The current protocol version string is **`"2025-03-26"`**.

The previous version is **`"2024-11-05"`**.

### Negotiation Rules

1. The client sends its desired `protocolVersion` in the `initialize` request
   (SHOULD be the latest version it supports).
2. If the server supports that version, it MUST respond with the same version string.
3. If the server does not support the requested version, it responds with a
   different version it does support (SHOULD be its latest).
4. If the client does not support the server's proposed version, it SHOULD disconnect.

Example error when the server cannot support the requested version:

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

---

## 3. Initialization Handshake

The initialization handshake is a three-step process that MUST complete before
any other protocol operations (except `ping`).

```
Client                              Server
  |                                   |
  |--- initialize request ----------->|
  |                                   |
  |<-- InitializeResult --------------|
  |                                   |
  |--- notifications/initialized ---->|
  |                                   |
  |  (normal operation begins)        |
```

### Step 1: Client Sends `initialize` Request

Method: **`"initialize"`**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-03-26",
    "capabilities": {
      "roots": {
        "listChanged": true
      },
      "sampling": {}
    },
    "clientInfo": {
      "name": "ExampleClient",
      "version": "1.0.0"
    }
  }
}
```

**InitializeRequest params:**

| Field             | Type                 | Required | Notes                      |
|-------------------|----------------------|----------|----------------------------|
| `protocolVersion` | `string`             | yes      | Desired protocol version   |
| `capabilities`    | `ClientCapabilities` | yes      | See section 4              |
| `clientInfo`      | `Implementation`     | yes      | Client name and version    |

**Implementation type:**

| Field     | Type     | Required |
|-----------|----------|----------|
| `name`    | `string` | yes      |
| `version` | `string` | yes      |

The `initialize` request MUST NOT be part of a JSON-RPC batch.
The `initialize` request MUST NOT be cancelled.

### Step 2: Server Responds with `InitializeResult`

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2025-03-26",
    "capabilities": {
      "logging": {},
      "prompts": {
        "listChanged": true
      },
      "resources": {
        "subscribe": true,
        "listChanged": true
      },
      "tools": {
        "listChanged": true
      }
    },
    "serverInfo": {
      "name": "ExampleServer",
      "version": "1.0.0"
    },
    "instructions": "This server provides access to project files and build tools."
  }
}
```

**InitializeResult fields:**

| Field             | Type                 | Required | Notes                                  |
|-------------------|----------------------|----------|----------------------------------------|
| `protocolVersion` | `string`             | yes      | Negotiated protocol version            |
| `capabilities`    | `ServerCapabilities` | yes      | See section 5                          |
| `serverInfo`      | `Implementation`     | yes      | Server name and version                |
| `instructions`    | `string`             | no       | Human-readable instructions for client |

### Step 3: Client Sends `initialized` Notification

Method: **`"notifications/initialized"`**

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```

No params required. After this notification, normal operation begins.

### Ordering Constraints

- The client SHOULD NOT send requests (other than `ping`) before the server
  responds to `initialize`.
- The server SHOULD NOT send requests (other than `ping` and `logging`) before
  receiving `notifications/initialized`.

---

## 4. Client Capabilities

The `ClientCapabilities` object declares what protocol features the client supports.
Omitting a key means the capability is not supported.

```json
{
  "roots": {
    "listChanged": true
  },
  "sampling": {},
  "experimental": {
    "myFeature": {
      "version": "0.1"
    }
  }
}
```

### Schema

| Field          | Type     | Required | Notes                                              |
|----------------|----------|----------|----------------------------------------------------|
| `roots`        | `object` | no       | Client supports `roots/list` requests from server  |
| `roots.listChanged` | `boolean` | no  | Client will emit `notifications/roots/list_changed`|
| `sampling`     | `object` | no       | Client supports `sampling/createMessage` from server. Empty object = supported |
| `experimental` | `object` | no       | Map of string keys to objects for experimental features |

### Capability Details

**roots** -- When present, the server may send `roots/list` requests to discover
filesystem roots the client exposes. If `listChanged` is true, the client will
send `notifications/roots/list_changed` when its root list changes.

**sampling** -- When present (even as `{}`), the server may send
`sampling/createMessage` requests to ask the client to perform LLM sampling.
This enables agentic behaviors where the server can request LLM completions
through the client.

**experimental** -- Extension point for non-standard capabilities. Keys are
feature identifiers; values are objects whose schema is feature-specific.

---

## 5. Server Capabilities

The `ServerCapabilities` object declares what protocol features the server supports.
Omitting a key means the capability is not supported.

```json
{
  "logging": {},
  "completions": {},
  "prompts": {
    "listChanged": true
  },
  "resources": {
    "subscribe": true,
    "listChanged": true
  },
  "tools": {
    "listChanged": true
  },
  "experimental": {}
}
```

### Schema

| Field                    | Type      | Required | Notes                                               |
|--------------------------|-----------|----------|-----------------------------------------------------|
| `logging`                | `object`  | no       | Server supports `logging/setLevel` and log messages  |
| `completions`            | `object`  | no       | Server supports `completion/complete` (new in 2025-03-26) |
| `prompts`                | `object`  | no       | Server exposes prompts                               |
| `prompts.listChanged`    | `boolean` | no       | Server will emit `notifications/prompts/list_changed`|
| `resources`              | `object`  | no       | Server exposes resources                             |
| `resources.subscribe`    | `boolean` | no       | Server supports `resources/subscribe`                |
| `resources.listChanged`  | `boolean` | no       | Server will emit `notifications/resources/list_changed` |
| `tools`                  | `object`  | no       | Server exposes tools                                 |
| `tools.listChanged`      | `boolean` | no       | Server will emit `notifications/tools/list_changed`  |
| `experimental`           | `object`  | no       | Map of string keys to objects                        |

### Capability-Method Mapping

| Capability     | Enables Methods                                          |
|----------------|----------------------------------------------------------|
| `logging`      | `logging/setLevel`, `notifications/message`              |
| `completions`  | `completion/complete`                                    |
| `prompts`      | `prompts/list`, `prompts/get`                            |
| `resources`    | `resources/list`, `resources/templates/list`, `resources/read` |
| `tools`        | `tools/list`, `tools/call`                               |

A client MUST NOT call methods for capabilities the server has not declared.
A server SHOULD return error code `-32601` (Method not found) if a client
calls a method for an unsupported capability.

---

## 6. Ping/Pong

Method: **`"ping"`**

Either side (client or server) may send a `ping` request at any time as a
keepalive or liveness check. The receiver MUST respond with an empty result.

Ping is the only request allowed before initialization completes.

### Request

```json
{
  "jsonrpc": "2.0",
  "id": "ping-1",
  "method": "ping"
}
```

### Response

```json
{
  "jsonrpc": "2.0",
  "id": "ping-1",
  "result": {}
}
```

The result is always an empty object `{}`. The protocol does not specify a
timeout -- implementations choose their own keepalive intervals and timeout
thresholds.

---

## 7. Progress Reporting

Progress reporting allows the handler of a request to send incremental progress
updates back to the requester. Both clients and servers may send and receive
progress notifications.

### Requesting Progress

The request sender includes a `progressToken` in the `_meta` of the request params:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "_meta": {
      "progressToken": "progress-42"
    },
    "name": "long_running_tool",
    "arguments": {}
  }
}
```

### Progress Notification

Method: **`"notifications/progress"`**

The request handler sends progress updates referencing the token:

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/progress",
  "params": {
    "progressToken": "progress-42",
    "progress": 50,
    "total": 100,
    "message": "Processing records..."
  }
}
```

**ProgressNotification params:**

| Field           | Type            | Required | Notes                                   |
|-----------------|-----------------|----------|-----------------------------------------|
| `progressToken` | `ProgressToken` | yes      | Must match token from the active request|
| `progress`      | `number`        | yes      | Current progress value                  |
| `total`         | `number`        | no       | Total expected value                    |
| `message`       | `string`        | no       | Human-readable progress description     |

### Rules

- `progress` MUST increase monotonically with each notification for the same token.
- `progress` and `total` MAY be floating point numbers.
- Notifications MUST only reference tokens from currently active requests.
- The handler MAY choose not to send any progress notifications even if a token
  was provided.
- Implementations MAY reset their request timeout clock upon receiving progress.

---

## 8. Cancellation

Method: **`"notifications/cancelled"`**

Either side may cancel a previously-issued request that is still in progress.

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/cancelled",
  "params": {
    "requestId": 1,
    "reason": "User requested cancellation"
  }
}
```

**CancelledNotification params:**

| Field       | Type        | Required | Notes                             |
|-------------|-------------|----------|-----------------------------------|
| `requestId` | `RequestId` | yes      | ID of the request to cancel       |
| `reason`    | `string`    | no       | Human-readable cancellation reason|

### Rules

- MUST only reference requests that were previously issued in the same direction
  (client cancels client-originated requests; server cancels server-originated requests).
- The `initialize` request MUST NOT be cancelled.
- The receiver SHOULD stop processing the request and free associated resources.
- The receiver SHOULD NOT send a response for the cancelled request.
- The receiver MAY ignore the cancellation if the request is unknown, already
  completed, or not cancellable.
- The sender SHOULD ignore any response that arrives after sending cancellation.

---

## 9. Logging

Logging allows the server to send structured log messages to the client. The
server MUST declare the `logging` capability to use these features.

### 9.1 Set Log Level

Method: **`"logging/setLevel"`** (client to server)

Sets the minimum severity level for log messages the server should emit.

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "logging/setLevel",
  "params": {
    "level": "warning"
  }
}
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {}
}
```

| Field   | Type           | Required | Notes              |
|---------|----------------|----------|--------------------|
| `level` | `LoggingLevel` | yes      | Minimum log level  |

### 9.2 Log Message Notification

Method: **`"notifications/message"`** (server to client)

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/message",
  "params": {
    "level": "error",
    "logger": "database",
    "data": {
      "error": "Connection failed",
      "details": {
        "host": "localhost",
        "port": 5432
      }
    }
  }
}
```

| Field    | Type           | Required | Notes                                 |
|----------|----------------|----------|---------------------------------------|
| `level`  | `LoggingLevel` | yes      | Severity of this message              |
| `logger` | `string`       | no       | Logger/component name                 |
| `data`   | `any`          | yes      | Any JSON-serializable log payload     |

The server SHOULD only send messages at or above the currently set log level.

### 9.3 Log Levels

Log levels follow RFC 5424 syslog severity ordering, from most verbose to most severe:

| Level         | Description                    |
|---------------|--------------------------------|
| `"debug"`     | Detailed debugging information |
| `"info"`      | General informational messages |
| `"notice"`    | Normal but significant events  |
| `"warning"`   | Warning conditions             |
| `"error"`     | Error conditions               |
| `"critical"`  | Critical conditions            |
| `"alert"`     | Immediate action needed        |
| `"emergency"` | System is unusable             |

For Elixir implementation, map these to Logger levels:

| MCP Level     | Elixir Logger   |
|---------------|-----------------|
| `"debug"`     | `:debug`        |
| `"info"`      | `:info`         |
| `"notice"`    | `:notice`       |
| `"warning"`   | `:warning`      |
| `"error"`     | `:error`        |
| `"critical"`  | `:critical`     |
| `"alert"`     | `:alert`        |
| `"emergency"` | `:emergency`    |

---

## 10. Error Handling

### 10.1 Standard JSON-RPC Error Codes

| Constant           | Code     | Meaning                         |
|--------------------|----------|---------------------------------|
| `PARSE_ERROR`      | `-32700` | Invalid JSON received           |
| `INVALID_REQUEST`  | `-32600` | Not a valid JSON-RPC request    |
| `METHOD_NOT_FOUND` | `-32601` | Method does not exist or capability not declared |
| `INVALID_PARAMS`   | `-32602` | Invalid method parameters       |
| `INTERNAL_ERROR`   | `-32603` | Internal server/client error    |

### 10.2 MCP-Specific Error Codes

| Code   | Meaning              | Typical Context                                   |
|--------|----------------------|---------------------------------------------------|
| `-32002`| Resource not found  | `resources/read` with unknown URI                 |
| `-1`   | Application error    | General application-level failure (e.g., "User rejected sampling request") |

### 10.3 Error Code Usage by Method

| Situation                          | Error Code |
|------------------------------------|------------|
| Unknown tool name in `tools/call`  | `-32602`   |
| Invalid prompt name in `prompts/get`| `-32602`  |
| Missing required arguments         | `-32602`   |
| Invalid log level                  | `-32602`   |
| Unsupported protocol version       | `-32602`   |
| Capability not supported           | `-32601`   |
| Internal/configuration errors      | `-32603`   |
| Resource URI not found             | `-32002`   |

### 10.4 Tool Execution Errors vs Protocol Errors

Tool execution errors (the tool ran but failed) are NOT protocol errors.
They are returned as successful responses with `isError: true`:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "File not found: /path/to/file"
      }
    ],
    "isError": true
  }
}
```

Protocol errors (invalid params, method not found, etc.) use the JSON-RPC
error response format with `error.code`, `error.message`, and optional `error.data`.

---

## 11. Shutdown

MCP does not define explicit shutdown JSON-RPC methods. Shutdown is handled
at the transport layer.

### 11.1 stdio Transport

1. Client closes stdin to the server subprocess.
2. Client waits for the server process to exit.
3. Client sends `SIGTERM` if the server does not exit within a reasonable time.
4. Client sends `SIGKILL` if the server still does not exit.

The server MAY initiate shutdown by closing its stdout and exiting.

For Elixir: use `Port.close/1` or `System.halt/1` as appropriate.

### 11.2 Streamable HTTP Transport

**Client-initiated shutdown:**

1. Client closes open HTTP connections.
2. Client SHOULD send an HTTP `DELETE` request to the MCP endpoint with the
   `Mcp-Session-Id` header to explicitly terminate the session.
3. Server MAY respond with `405 Method Not Allowed` if it does not support
   client-initiated termination.

**Server-initiated shutdown:**

1. Server MAY terminate a session at any time.
2. Subsequent requests with the terminated session ID receive `404 Not Found`.
3. On receiving a `404` for a session ID, the client MUST start a new session
   with a fresh `initialize` handshake.

### 11.3 Graceful Shutdown Sequence

For a well-behaved implementation:

```
Client                              Server
  |                                   |
  |  (stop sending new requests)      |
  |                                   |
  |--- notifications/cancelled ------>|  (cancel any in-flight requests)
  |                                   |
  |  (wait for pending responses)     |
  |                                   |
  |--- [transport-level close] ------>|
  |                                   |
```

---

## 12. Protocol Version History

### Version `2024-11-05` (Initial Release)

The first published version of MCP. Key characteristics:

- JSON-RPC 2.0 base protocol
- Core features: resources, prompts, tools, sampling, roots
- Transports: **stdio** and **HTTP+SSE** (server-sent events with separate endpoints)
  - SSE endpoint (GET) returned an `endpoint` event with a POST URL
  - Separate SSE and POST endpoints
- Content types: `TextContent` and `ImageContent` only
- No `AudioContent`
- No `Tool.annotations` / `ToolAnnotations`
- No `completions` server capability
- No batch message support
- No `Resource.size` field
- No `instructions` field on `InitializeResult`

### Version `2025-03-26` (Current)

Major changes from `2024-11-05`:

**Transport:**
- **Streamable HTTP** replaces HTTP+SSE as the HTTP transport
  - Single MCP endpoint for both POST and GET
  - Session management via `Mcp-Session-Id` header
  - Resumability via SSE event IDs and `Last-Event-ID`
  - HTTP `DELETE` for session termination
  - `Authorization` header framework for HTTP auth
  - Origin header validation required (DNS rebinding protection)

**Content:**
- Added `AudioContent` type (`type: "audio"`, base64 `data`, `mimeType`)

**Tools:**
- Added `ToolAnnotations` on Tool objects:
  - `title` (string) -- human-readable display title
  - `readOnlyHint` (boolean) -- tool does not modify state
  - `destructiveHint` (boolean) -- tool may perform destructive operations
  - `idempotentHint` (boolean) -- safe to call repeatedly with same arguments
  - `openWorldHint` (boolean) -- tool interacts with external entities

**Server capabilities:**
- Added `completions` capability for `completion/complete` method

**Resources:**
- Added optional `size` field (integer, bytes) on Resource objects

**Protocol:**
- Added JSON-RPC batch message support (MUST support receiving, MAY support sending)
- Added `instructions` field on `InitializeResult` (string, human-readable)

---

## 13. Complete Method Reference

### Client to Server -- Requests

| Method                       | Purpose                                | Requires Capability |
|------------------------------|----------------------------------------|---------------------|
| `initialize`                 | Start session, negotiate capabilities  | (none)              |
| `ping`                       | Keepalive check                        | (none)              |
| `completion/complete`        | Autocomplete arguments                 | `completions`       |
| `logging/setLevel`           | Set minimum log level                  | `logging`           |
| `prompts/list`               | List available prompts (paginated)     | `prompts`           |
| `prompts/get`                | Get a specific prompt with arguments   | `prompts`           |
| `resources/list`             | List available resources (paginated)   | `resources`         |
| `resources/templates/list`   | List resource templates (paginated)    | `resources`         |
| `resources/read`             | Read a resource by URI                 | `resources`         |
| `resources/subscribe`        | Subscribe to resource changes          | `resources.subscribe` |
| `resources/unsubscribe`      | Unsubscribe from resource changes      | `resources.subscribe` |
| `tools/list`                 | List available tools (paginated)       | `tools`             |
| `tools/call`                 | Invoke a tool                          | `tools`             |

### Server to Client -- Requests

| Method                    | Purpose                     | Requires Capability |
|---------------------------|-----------------------------|---------------------|
| `ping`                    | Keepalive check             | (none)              |
| `sampling/createMessage`  | Request LLM generation      | `sampling`          |
| `roots/list`              | List filesystem roots       | `roots`             |

### Client to Server -- Notifications

| Method                              | Purpose                      |
|-------------------------------------|------------------------------|
| `notifications/initialized`         | Initialization complete      |
| `notifications/cancelled`           | Cancel a pending request     |
| `notifications/progress`            | Report progress on a request |
| `notifications/roots/list_changed`  | Client roots list changed    |

### Server to Client -- Notifications

| Method                                 | Purpose                          |
|----------------------------------------|----------------------------------|
| `notifications/cancelled`              | Cancel a pending request         |
| `notifications/progress`               | Report progress on a request     |
| `notifications/message`                | Log message                      |
| `notifications/resources/updated`      | Subscribed resource changed      |
| `notifications/resources/list_changed` | Resource list changed            |
| `notifications/tools/list_changed`     | Tool list changed                |
| `notifications/prompts/list_changed`   | Prompt list changed              |

---

## 14. Key Schema Definitions

### 14.1 Tool

```json
{
  "name": "read_file",
  "description": "Read a file from disk",
  "inputSchema": {
    "type": "object",
    "properties": {
      "path": { "type": "string", "description": "File path" }
    },
    "required": ["path"]
  },
  "annotations": {
    "title": "Read File",
    "readOnlyHint": true,
    "destructiveHint": false,
    "idempotentHint": true,
    "openWorldHint": false
  }
}
```

| Field          | Type              | Required | Notes                     |
|----------------|-------------------|----------|---------------------------|
| `name`         | `string`          | yes      | Tool identifier           |
| `description`  | `string`          | no       | Human-readable description|
| `inputSchema`  | JSON Schema object| yes      | MUST have `type: "object"`|
| `annotations`  | `ToolAnnotations` | no       | Behavioral hints (2025-03-26+) |

### 14.2 ToolAnnotations

| Field             | Type      | Required | Default | Notes                                     |
|-------------------|-----------|----------|---------|-------------------------------------------|
| `title`           | `string`  | no       | --      | Human-readable display title               |
| `readOnlyHint`    | `boolean` | no       | `false` | `true` = tool does not modify state        |
| `destructiveHint` | `boolean` | no       | `true`  | `true` = may be destructive (when not readOnly) |
| `idempotentHint`  | `boolean` | no       | `false` | `true` = safe to retry with same args      |
| `openWorldHint`   | `boolean` | no       | `true`  | `true` = interacts with external entities  |

### 14.3 CallToolResult

```json
{
  "content": [
    { "type": "text", "text": "File contents here..." }
  ],
  "isError": false
}
```

| Field     | Type      | Required | Notes                                    |
|-----------|-----------|----------|------------------------------------------|
| `content` | `array`   | yes      | Array of content objects                 |
| `isError` | `boolean` | no       | `true` = tool execution failed           |

### 14.4 Content Types

**TextContent:**
```json
{ "type": "text", "text": "Hello world", "annotations": { "audience": ["user"], "priority": 0.8 } }
```

**ImageContent:**
```json
{ "type": "image", "data": "<base64>", "mimeType": "image/png", "annotations": {} }
```

**AudioContent** (2025-03-26+):
```json
{ "type": "audio", "data": "<base64>", "mimeType": "audio/wav", "annotations": {} }
```

**EmbeddedResource:**
```json
{ "type": "resource", "resource": { "uri": "file:///path", "text": "contents", "mimeType": "text/plain" }, "annotations": {} }
```

**Annotations** (on content):

| Field      | Type       | Required | Notes                              |
|------------|------------|----------|------------------------------------|
| `audience` | `Role[]`   | no       | `"user"` and/or `"assistant"`      |
| `priority` | `number`   | no       | 0.0 to 1.0, higher = more important|

### 14.5 Resource

```json
{
  "uri": "file:///project/src/main.ex",
  "name": "main.ex",
  "description": "Main application entry point",
  "mimeType": "text/x-elixir",
  "size": 2048,
  "annotations": { "audience": ["user"] }
}
```

| Field         | Type         | Required | Notes                               |
|---------------|--------------|----------|--------------------------------------|
| `uri`         | `string`     | yes      | Resource URI                         |
| `name`        | `string`     | yes      | Human-readable name                  |
| `description` | `string`     | no       | Description                          |
| `mimeType`    | `string`     | no       | MIME type                            |
| `size`        | `integer`    | no       | Size in bytes (2025-03-26+)          |
| `annotations` | `Annotations`| no       | Audience and priority hints          |

### 14.6 Prompt

```json
{
  "name": "code_review",
  "description": "Review code for quality issues",
  "arguments": [
    {
      "name": "code",
      "description": "The code to review",
      "required": true
    }
  ]
}
```

### 14.7 Sampling (CreateMessage)

**CreateMessageRequest params:**

| Field              | Type                | Required | Notes                                |
|--------------------|---------------------|----------|--------------------------------------|
| `messages`         | `SamplingMessage[]` | yes      | Conversation messages                |
| `modelPreferences` | `ModelPreferences`  | no       | Model selection hints                |
| `systemPrompt`     | `string`            | no       | System prompt                        |
| `includeContext`    | `string`            | no       | `"none"`, `"thisServer"`, `"allServers"` |
| `temperature`      | `number`            | no       | Sampling temperature                 |
| `maxTokens`        | `integer`           | yes      | Maximum tokens to generate           |
| `stopSequences`    | `string[]`          | no       | Stop sequences                       |
| `metadata`         | `object`            | no       | Additional metadata                  |

**CreateMessageResult:**

| Field        | Type                   | Required | Notes                          |
|--------------|------------------------|----------|--------------------------------|
| `role`       | `"user" \| "assistant"`| yes      | Role of generated message      |
| `content`    | Content object         | yes      | TextContent, ImageContent, or AudioContent |
| `model`      | `string`               | yes      | Actual model used              |
| `stopReason` | `string`               | no       | `"endTurn"`, `"stopSequence"`, `"maxTokens"`, or custom |

**ModelPreferences:**

| Field                   | Type          | Required | Notes                   |
|-------------------------|---------------|----------|-------------------------|
| `hints`                 | `ModelHint[]` | no       | Ordered by preference   |
| `costPriority`          | `number`      | no       | 0.0 to 1.0              |
| `speedPriority`         | `number`      | no       | 0.0 to 1.0              |
| `intelligencePriority`  | `number`      | no       | 0.0 to 1.0              |

**ModelHint:** `{ name?: string }` -- substring match against model identifiers.

### 14.8 Root

```json
{
  "uri": "file:///home/user/project",
  "name": "My Project"
}
```

| Field  | Type     | Required | Notes                        |
|--------|----------|----------|------------------------------|
| `uri`  | `string` | yes      | MUST be a `file://` URI      |
| `name` | `string` | no       | Human-readable name          |

### 14.9 Completion

**CompleteRequest params:**

```json
{
  "ref": { "type": "ref/prompt", "name": "code_review" },
  "argument": { "name": "language", "value": "eli" }
}
```

| Field      | Type     | Required | Notes                                          |
|------------|----------|----------|-------------------------------------------------|
| `ref`      | `object` | yes      | `{ type: "ref/prompt", name }` or `{ type: "ref/resource", uri }` |
| `argument` | `object` | yes      | `{ name: string, value: string }`              |

**CompleteResult:**

```json
{
  "completion": {
    "values": ["elixir", "elisp", "elm"],
    "total": 3,
    "hasMore": false
  }
}
```

| Field                 | Type       | Required | Notes                |
|-----------------------|------------|----------|----------------------|
| `completion.values`   | `string[]` | yes      | Max 100 items        |
| `completion.total`    | `integer`  | no       | Total available count|
| `completion.hasMore`  | `boolean`  | no       | More results exist   |

---

## Appendix: Full Initialization Exchange Example

A complete initialization exchange between an Elixir MCP client and server:

```json
// 1. Client -> Server: initialize request
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
      "name": "ElixirMCPClient",
      "version": "0.1.0"
    }
  }
}

// 2. Server -> Client: InitializeResult
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2025-03-26",
    "capabilities": {
      "tools": { "listChanged": true },
      "resources": { "subscribe": true, "listChanged": true },
      "prompts": { "listChanged": true },
      "logging": {},
      "completions": {}
    },
    "serverInfo": {
      "name": "ElixirMCPServer",
      "version": "0.1.0"
    },
    "instructions": "This server provides development tools and project resources."
  }
}

// 3. Client -> Server: initialized notification
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}

// 4. Normal operation: Client lists tools
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list"
}

// 5. Server responds with tool list
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "tools": [
      {
        "name": "run_mix",
        "description": "Run a mix task",
        "inputSchema": {
          "type": "object",
          "properties": {
            "task": { "type": "string" },
            "args": { "type": "array", "items": { "type": "string" } }
          },
          "required": ["task"]
        },
        "annotations": {
          "title": "Run Mix Task",
          "readOnlyHint": false,
          "destructiveHint": false,
          "idempotentHint": false,
          "openWorldHint": false
        }
      }
    ]
  }
}

// 6. Client calls a tool with progress token
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "_meta": { "progressToken": "p-1" },
    "name": "run_mix",
    "arguments": { "task": "test", "args": ["--trace"] }
  }
}

// 7. Server sends progress
{
  "jsonrpc": "2.0",
  "method": "notifications/progress",
  "params": {
    "progressToken": "p-1",
    "progress": 3,
    "total": 10,
    "message": "Running test files..."
  }
}

// 8. Server returns tool result
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      { "type": "text", "text": "10 tests, 0 failures" }
    ],
    "isError": false
  }
}
```
