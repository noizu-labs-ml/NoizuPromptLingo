# MCP Specification: Tools

Reference documentation for implementing the Model Context Protocol (MCP) 2025-03-26
specification covering server-exposed callable tools.

> **Baseline note:** this document describes the **2025-03-26** revision. The
> library targets **2025-11-25**; the relevant deltas — structured tool output
> + `outputSchema` and resource links (2025-06-18), and SEP-1303
> validation-failures-as-`isError`-results plus tool icons (2025-11-25) — are
> in [07-changelog-2025-06-18.md](07-changelog-2025-06-18.md) and
> [08-changelog-2025-11-25.md](08-changelog-2025-11-25.md).

Source: <https://modelcontextprotocol.io/specification/2025-03-26/server/tools>

---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Capability Declaration](#2-capability-declaration)
- [3. Tool Definition Schema](#3-tool-definition-schema)
  - [3.1 Tool Object](#31-tool-object)
  - [3.2 Tool Name Rules](#32-tool-name-rules)
  - [3.3 inputSchema](#33-inputschema)
  - [3.4 outputSchema](#34-outputschema)
  - [3.5 Tool Annotations](#35-tool-annotations)
- [4. Tool Discovery -- `tools/list`](#4-tool-discovery----toolslist)
  - [4.1 Request](#41-request)
  - [4.2 Response](#42-response)
  - [4.3 Pagination](#43-pagination)
- [5. Tool Invocation -- `tools/call`](#5-tool-invocation----toolscall)
  - [5.1 Request](#51-request)
  - [5.2 Response](#52-response)
- [6. Tool Results -- Content Types](#6-tool-results----content-types)
  - [6.1 TextContent](#61-textcontent)
  - [6.2 ImageContent](#62-imagecontent)
  - [6.3 AudioContent](#63-audiocontent)
  - [6.4 EmbeddedResource](#64-embeddedresource)
  - [6.5 structuredContent](#65-structuredcontent)
  - [6.6 Content Annotations](#66-content-annotations)
- [7. Tool List Changes -- `notifications/tools/list_changed`](#7-tool-list-changes----notificationstoolslist_changed)
- [8. Error Handling](#8-error-handling)
  - [8.1 Protocol-Level Errors](#81-protocol-level-errors)
  - [8.2 Tool Execution Errors](#82-tool-execution-errors)
- [9. Human-in-the-Loop](#9-human-in-the-loop)
- [10. Implementation Notes for Elixir](#10-implementation-notes-for-elixir)

---

## 1. Overview

Tools are server-exposed callable functions that enable LLMs to interact with external
systems -- querying databases, calling APIs, performing computations, taking actions in
the real world. Each tool is identified by a unique name and carries metadata describing
its input schema and behavioral annotations.

**Key distinction from Resources and Prompts:**

| Primitive    | Control     | Purpose                          | Side Effects |
|-------------|-------------|----------------------------------|--------------|
| **Tools**    | Model-controlled | Callable actions and computations | Yes (possible) |
| **Resources**| Application-controlled | Read-only data identified by URIs | No           |
| **Prompts**  | User-controlled  | Templated messages and workflows  | No           |

Tools are designed to be **model-controlled** -- the LLM autonomously discovers and
invokes them as needed. The protocol does not mandate any specific user interaction
model for presenting or approving tool calls.

**Direction:** Client calls Server.

| Method                              | Direction        | Description                     |
|-------------------------------------|------------------|---------------------------------|
| `tools/list`                        | Client -> Server | Discover available tools        |
| `tools/call`                        | Client -> Server | Invoke a specific tool          |
| `notifications/tools/list_changed`  | Server -> Client | Signal tool list has changed    |

---

## 2. Capability Declaration

Servers that expose tools MUST declare the `tools` capability during initialization. The
`listChanged` field indicates whether the server will emit notifications when the
available tool set changes.

```json
{
  "capabilities": {
    "tools": {
      "listChanged": true
    }
  }
}
```

If `listChanged` is `true`, the server will send `notifications/tools/list_changed`
when tools are added, removed, or modified. Clients that receive this notification
SHOULD re-issue `tools/list` to refresh their tool catalog.

---

## 3. Tool Definition Schema

### 3.1 Tool Object

A tool definition has the following structure:

```json
{
  "name": "get_weather",
  "description": "Get current weather information for a location",
  "inputSchema": {
    "type": "object",
    "properties": {
      "location": {
        "type": "string",
        "description": "City name or zip code"
      },
      "units": {
        "type": "string",
        "enum": ["celsius", "fahrenheit"],
        "description": "Temperature units"
      }
    },
    "required": ["location"]
  },
  "annotations": {
    "title": "Get Weather",
    "readOnlyHint": true,
    "destructiveHint": false,
    "idempotentHint": true,
    "openWorldHint": true
  }
}
```

**Tool fields:**

| Field          | Type              | Required | Description                                      |
|----------------|-------------------|----------|--------------------------------------------------|
| `name`         | `string`          | Yes      | Unique identifier for the tool                   |
| `description`  | `string`          | No       | Human-readable description for LLM understanding |
| `inputSchema`  | `object`          | Yes      | JSON Schema defining expected parameters         |
| `outputSchema` | `object`          | No       | JSON Schema defining structured output (draft)   |
| `annotations`  | `ToolAnnotations` | No       | Behavioral hints and metadata                    |

### 3.2 Tool Name Rules

- SHOULD be 1--128 characters
- Case-sensitive
- Allowed characters: `A-Z`, `a-z`, `0-9`, `_`, `-`, `.`
- No spaces, commas, or special characters
- MUST be unique within a server

Examples: `getUser`, `DATA_EXPORT_v2`, `admin.tools.list`

### 3.3 inputSchema

The `inputSchema` MUST be a JSON Schema object with `type` set to `"object"`. Properties
describe the individual parameters the tool accepts.

```json
{
  "type": "object",
  "properties": {
    "query": {
      "type": "string",
      "description": "Search query"
    },
    "limit": {
      "type": "integer",
      "description": "Maximum results to return",
      "default": 10
    }
  },
  "required": ["query"]
}
```

**Formal schema for inputSchema:**

| Field        | Type       | Required | Description                           |
|-------------|------------|----------|---------------------------------------|
| `type`       | `"object"` | Yes      | Must be the constant string `"object"`|
| `properties` | `object`   | No       | Map of parameter name to JSON Schema  |
| `required`   | `string[]` | No       | Array of required parameter names     |

For tools that take no parameters:

```json
{
  "type": "object"
}
```

### 3.4 outputSchema

An optional JSON Schema defining the expected structure of `structuredContent` in the
tool result. When present, servers MUST return conforming `structuredContent`. Clients
SHOULD validate results against this schema.

```json
{
  "name": "get_weather_data",
  "description": "Get structured weather data for a location",
  "inputSchema": {
    "type": "object",
    "properties": {
      "location": { "type": "string" }
    },
    "required": ["location"]
  },
  "outputSchema": {
    "type": "object",
    "properties": {
      "temperature": { "type": "number" },
      "conditions": { "type": "string" },
      "humidity": { "type": "number" }
    },
    "required": ["temperature", "conditions", "humidity"]
  }
}
```

Note: `outputSchema` was introduced in a later revision of the spec (draft/2025-11-25).
Implementations targeting the 2025-03-26 baseline may omit it.

### 3.5 Tool Annotations

Annotations provide behavioral hints about tools. All fields are optional. All are
**hints only** -- they are not guaranteed accurate and MUST be considered untrusted
unless the server is trusted.

```json
{
  "annotations": {
    "title": "Delete User Account",
    "readOnlyHint": false,
    "destructiveHint": true,
    "idempotentHint": true,
    "openWorldHint": false
  }
}
```

| Field             | Type      | Default  | Description                                                         |
|-------------------|-----------|----------|---------------------------------------------------------------------|
| `title`           | `string`  | _(none)_ | Human-readable display title for the tool                           |
| `readOnlyHint`    | `boolean` | `false`  | If `true`, the tool does not modify its environment                 |
| `destructiveHint` | `boolean` | `true`   | If `true`, the tool may perform destructive updates (only meaningful when `readOnlyHint` is `false`) |
| `idempotentHint`  | `boolean` | `false`  | If `true`, calling repeatedly with same args has no additional effect (only meaningful when `readOnlyHint` is `false`) |
| `openWorldHint`   | `boolean` | `true`   | If `true`, tool interacts with external open-world entities; if `false`, the domain is closed (e.g., web search = open, memory store = closed) |

**Important:** Clients MUST NOT make security-sensitive decisions based solely on
annotations from untrusted servers. A malicious server could set `readOnlyHint: true`
on a destructive tool.

---

## 4. Tool Discovery -- `tools/list`

### 4.1 Request

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list",
  "params": {
    "cursor": "optional-cursor-value"
  }
}
```

| Field    | Type     | Required | Description                                      |
|----------|----------|----------|--------------------------------------------------|
| `cursor` | `string` | No       | Opaque pagination cursor from a previous response |

The `params` object itself is optional. If omitted or if `cursor` is absent, the server
returns the first page of results.

### 4.2 Response

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "tools": [
      {
        "name": "get_weather",
        "description": "Get current weather information for a location",
        "inputSchema": {
          "type": "object",
          "properties": {
            "location": {
              "type": "string",
              "description": "City name or zip code"
            }
          },
          "required": ["location"]
        },
        "annotations": {
          "title": "Get Weather",
          "readOnlyHint": true,
          "openWorldHint": true
        }
      },
      {
        "name": "send_email",
        "description": "Send an email to a recipient",
        "inputSchema": {
          "type": "object",
          "properties": {
            "to": { "type": "string", "description": "Recipient email" },
            "subject": { "type": "string", "description": "Email subject" },
            "body": { "type": "string", "description": "Email body" }
          },
          "required": ["to", "subject", "body"]
        },
        "annotations": {
          "title": "Send Email",
          "readOnlyHint": false,
          "destructiveHint": false,
          "idempotentHint": false,
          "openWorldHint": true
        }
      }
    ],
    "nextCursor": "page2-cursor-token"
  }
}
```

**ListToolsResult fields:**

| Field        | Type     | Required | Description                                            |
|-------------|----------|----------|--------------------------------------------------------|
| `tools`      | `Tool[]` | Yes      | Array of tool definitions                              |
| `nextCursor` | `string` | No       | Opaque token for the next page; absent if no more pages |
| `_meta`      | `object` | No       | Optional metadata                                      |

### 4.3 Pagination

- Page size is determined by the server
- Cursors are opaque strings -- clients MUST NOT interpret or persist them across sessions
- A missing `nextCursor` means all results have been returned
- An invalid cursor SHOULD result in error code `-32602` (Invalid params)
- Servers SHOULD return tools in a deterministic order
- The tool set MUST NOT vary per-connection or as a side effect of other requests (but
  MAY vary by authorization scope)

---

## 5. Tool Invocation -- `tools/call`

### 5.1 Request

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "get_weather",
    "arguments": {
      "location": "New York",
      "units": "celsius"
    }
  }
}
```

**CallToolRequest params:**

| Field       | Type     | Required | Description                                |
|-------------|----------|----------|--------------------------------------------|
| `name`      | `string` | Yes      | Name of the tool to invoke                 |
| `arguments` | `object` | No       | Key-value map of arguments (omit for no-arg tools) |

### 5.2 Response

**Successful text response:**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Current weather in New York:\nTemperature: 22°C\nConditions: Partly cloudy\nHumidity: 65%"
      }
    ],
    "isError": false
  }
}
```

**Response with image content:**

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Weather map for the requested region:"
      },
      {
        "type": "image",
        "data": "iVBORw0KGgoAAAANSUhEUg...",
        "mimeType": "image/png"
      }
    ]
  }
}
```

**Response with embedded resource:**

```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "result": {
    "content": [
      {
        "type": "resource",
        "resource": {
          "uri": "file:///data/reports/weather-2025-03-26.csv",
          "mimeType": "text/csv",
          "text": "date,temp,humidity\n2025-03-26,22,65\n2025-03-25,19,70"
        }
      }
    ]
  }
}
```

**Error response (tool execution failure):**

```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Failed to fetch weather data: API rate limit exceeded. Please try again in 60 seconds."
      }
    ],
    "isError": true
  }
}
```

**Response with structuredContent (when outputSchema is defined):**

```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"temperature\": 22.5, \"conditions\": \"Partly cloudy\", \"humidity\": 65}"
      }
    ],
    "structuredContent": {
      "temperature": 22.5,
      "conditions": "Partly cloudy",
      "humidity": 65
    }
  }
}
```

**CallToolResult fields:**

| Field              | Type       | Required | Description                                             |
|--------------------|------------|----------|---------------------------------------------------------|
| `content`          | `Content[]`| Yes      | Array of content items (text, image, audio, resource)   |
| `isError`          | `boolean`  | No       | `true` if the tool call resulted in an error; defaults to `false` |
| `structuredContent`| `object`   | No       | Machine-readable result conforming to `outputSchema`    |
| `_meta`            | `object`   | No       | Optional metadata                                       |

---

## 6. Tool Results -- Content Types

Tool results contain an array of content items. Each item has a `type` discriminator.

### 6.1 TextContent

```json
{
  "type": "text",
  "text": "The result of the operation."
}
```

| Field  | Type     | Required | Description         |
|--------|----------|----------|---------------------|
| `type` | `"text"` | Yes      | Content type marker |
| `text` | `string` | Yes      | Text content        |

### 6.2 ImageContent

```json
{
  "type": "image",
  "data": "iVBORw0KGgoAAAANSUhEUg...",
  "mimeType": "image/png"
}
```

| Field      | Type      | Required | Description                   |
|-----------|-----------|----------|-------------------------------|
| `type`     | `"image"` | Yes      | Content type marker           |
| `data`     | `string`  | Yes      | Base64-encoded image data     |
| `mimeType` | `string`  | Yes      | MIME type (e.g., `image/png`) |

### 6.3 AudioContent

```json
{
  "type": "audio",
  "data": "UklGRiQAAABXQVZFZm10...",
  "mimeType": "audio/wav"
}
```

| Field      | Type      | Required | Description                     |
|-----------|-----------|----------|---------------------------------|
| `type`     | `"audio"` | Yes      | Content type marker             |
| `data`     | `string`  | Yes      | Base64-encoded audio data       |
| `mimeType` | `string`  | Yes      | MIME type (e.g., `audio/wav`)   |

### 6.4 EmbeddedResource

Wraps a resource (text or blob) inline in the tool result.

**Text resource:**

```json
{
  "type": "resource",
  "resource": {
    "uri": "file:///logs/app.log",
    "mimeType": "text/plain",
    "text": "2025-03-26 10:00:00 INFO Application started"
  }
}
```

**Blob resource:**

```json
{
  "type": "resource",
  "resource": {
    "uri": "file:///data/export.bin",
    "mimeType": "application/octet-stream",
    "blob": "AQIDBAU..."
  }
}
```

| Field      | Type         | Required | Description                         |
|-----------|-------------|----------|-------------------------------------|
| `type`     | `"resource"` | Yes      | Content type marker                 |
| `resource` | `object`     | Yes      | TextResourceContents or BlobResourceContents |

**TextResourceContents:**

| Field      | Type     | Required | Description         |
|-----------|----------|----------|---------------------|
| `uri`      | `string` | Yes      | Resource URI        |
| `mimeType` | `string` | No       | MIME type           |
| `text`     | `string` | Yes      | Text content        |

**BlobResourceContents:**

| Field      | Type     | Required | Description              |
|-----------|----------|----------|--------------------------|
| `uri`      | `string` | Yes      | Resource URI             |
| `mimeType` | `string` | No       | MIME type                |
| `blob`     | `string` | Yes      | Base64-encoded blob data |

### 6.5 structuredContent

When a tool defines an `outputSchema`, the result includes a `structuredContent` field
alongside the `content` array:

- `structuredContent` is a JSON value conforming to the tool's `outputSchema`
- If `outputSchema` is defined, servers MUST provide conforming `structuredContent`
- Clients SHOULD validate `structuredContent` against the `outputSchema`
- For backward compatibility, servers SHOULD also include a serialized JSON representation
  in a `TextContent` block within the `content` array
- `content` serves human/model readability; `structuredContent` serves machine
  consumption with type safety

### 6.6 Content Annotations

All content types support an optional `annotations` field:

```json
{
  "type": "text",
  "text": "Sensitive user data...",
  "annotations": {
    "audience": ["user"],
    "priority": 0.9
  }
}
```

| Field      | Type       | Description                                          |
|-----------|-----------|------------------------------------------------------|
| `audience` | `string[]` | Who should see this: `"user"`, `"assistant"`, or both |
| `priority` | `number`   | Importance hint, 0.0 (low) to 1.0 (high)            |

---

## 7. Tool List Changes -- `notifications/tools/list_changed`

Servers that declared `listChanged: true` in their `tools` capability send this
notification when tools are added, removed, or modified:

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/tools/list_changed"
}
```

This is a JSON-RPC **notification** -- it has no `id` field and expects no response.

Upon receiving this notification, clients SHOULD re-issue `tools/list` to refresh their
tool catalog.

---

## 8. Error Handling

MCP distinguishes between two error categories for tools.

### 8.1 Protocol-Level Errors

Standard JSON-RPC error responses for structural or routing problems. These indicate
issues at the protocol layer -- unknown tool names, malformed requests, server failures.
LLMs are less likely to self-correct from these.

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "error": {
    "code": -32602,
    "message": "Unknown tool: nonexistent_tool"
  }
}
```

Common error codes:

| Code     | Meaning          | When                                         |
|----------|------------------|----------------------------------------------|
| `-32600` | Invalid request  | Malformed JSON-RPC request                   |
| `-32601` | Method not found | Server does not support tools                |
| `-32602` | Invalid params   | Unknown tool name, invalid cursor, bad args  |
| `-32603` | Internal error   | Server-side processing failure               |

### 8.2 Tool Execution Errors

For errors that originate from the tool's own execution -- API failures, validation
errors, business logic errors. These are reported as successful JSON-RPC responses with
`isError: true` in the result. This allows the LLM to see the error message and
potentially self-correct (e.g., retry with different arguments).

```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Error: File not found at path '/data/missing.csv'. Available files: report.csv, summary.csv"
      }
    ],
    "isError": true
  }
}
```

**Guidelines:**
- Errors finding the tool or validating the request structure -> protocol-level error
- Errors from the tool's own execution -> `isError: true` in result
- Clients SHOULD provide tool execution errors (isError results) to the LLM
- Clients MAY provide protocol-level errors to the LLM

---

## 9. Human-in-the-Loop

The specification states that there SHOULD always be a human in the loop with the ability
to deny tool invocations.

**Applications SHOULD:**

- Provide UI making clear which tools are exposed to the AI model
- Insert clear visual indicators when tools are invoked
- Present confirmation prompts to the user for operations, especially destructive ones
- Show tool inputs to the user before calling the server (prevents malicious or
  accidental data exfiltration)

**Conceptual approval flow:**

```
LLM                     Client                  User                    Server
 |                       |                       |                       |
 |-- tool_use request -->|                       |                       |
 |                       |-- Present for review ->|                       |
 |                       |                       |-- Approve / Deny      |
 |                       |<-- Decision ----------|                       |
 |                       |                       |                       |
 |                       |-- tools/call -------->|---------------------->|
 |                       |<-- result ------------|<----------------------|
 |                       |                       |                       |
 |<-- tool result -------|                       |                       |
```

The `annotations` on tool definitions help clients make informed UI decisions about which
tools to auto-approve (e.g., `readOnlyHint: true` tools) versus which to prompt for
confirmation (e.g., `destructiveHint: true` tools). However, annotations from untrusted
servers MUST NOT be relied upon for security decisions.

---

## 10. Implementation Notes for Elixir

### Module Structure Suggestions

```
lib/mcp/
  server/
    tools.ex            # Tool registry, list/call handlers
    tool.ex             # Tool struct and ToolAnnotations
  types/
    content.ex          # TextContent, ImageContent, AudioContent, EmbeddedResource
```

### Key Type Mappings

| MCP Type           | Elixir Representation                                                                                |
|--------------------|------------------------------------------------------------------------------------------------------|
| `Tool`             | `%MCP.Tool{name: String.t(), description: String.t() \| nil, input_schema: map(), output_schema: map() \| nil, annotations: ToolAnnotations.t() \| nil}` |
| `ToolAnnotations`  | `%MCP.ToolAnnotations{title: String.t() \| nil, read_only_hint: boolean(), destructive_hint: boolean(), idempotent_hint: boolean(), open_world_hint: boolean()}` |
| `CallToolRequest`  | `%{name: String.t(), arguments: map() \| nil}`                                                       |
| `CallToolResult`   | `%MCP.CallToolResult{content: [content()], is_error: boolean(), structured_content: map() \| nil}`    |
| `TextContent`      | `%MCP.Content.Text{type: "text", text: String.t()}`                                                  |
| `ImageContent`     | `%MCP.Content.Image{type: "image", data: String.t(), mime_type: String.t()}`                         |
| `AudioContent`     | `%MCP.Content.Audio{type: "audio", data: String.t(), mime_type: String.t()}`                         |
| `EmbeddedResource` | `%MCP.Content.Resource{type: "resource", resource: resource_body()}`                                  |

### Annotation Defaults

When deserializing tool annotations, apply these defaults for missing fields:

```elixir
defmodule MCP.ToolAnnotations do
  defstruct [
    title: nil,
    read_only_hint: false,
    destructive_hint: true,
    idempotent_hint: false,
    open_world_hint: true
  ]
end
```

### Tool Name Validation

```elixir
@tool_name_pattern ~r/^[A-Za-z0-9_.\-]{1,128}$/

def valid_tool_name?(name) when is_binary(name) do
  Regex.match?(@tool_name_pattern, name)
end
```

### Direction Summary

| Feature | Who declares capability | Who initiates requests | Who sends notifications    |
|---------|------------------------|------------------------|-----------------------------|
| Tools   | Server                 | Client                 | Server (`list_changed`)     |

### Request/Response Method Summary

| JSON-RPC Method                    | Direction        | Has Response | Description                 |
|------------------------------------|------------------|--------------|-----------------------------|
| `tools/list`                       | Client -> Server | Yes          | List available tools        |
| `tools/call`                       | Client -> Server | Yes          | Invoke a tool               |
| `notifications/tools/list_changed` | Server -> Client | No           | Tool catalog changed signal |
