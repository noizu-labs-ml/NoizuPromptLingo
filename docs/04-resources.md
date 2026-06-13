# MCP Resources Specification

Reference documentation for implementing the **Resources** capability of the
Model Context Protocol (MCP), based on the 2025-03-26 specification.

> **Baseline note:** this document describes the **2025-03-26** revision. The
> library targets **2025-11-25**; deltas (e.g. `title` fields, resource links
> in tool results, icons) are in
> [07-changelog-2025-06-18.md](07-changelog-2025-06-18.md) and
> [08-changelog-2025-11-25.md](08-changelog-2025-11-25.md).

---

## 1. Overview

Resources are a standardized way for MCP servers to expose **read-only data**
to clients. They provide contextual information to language models such as file
contents, database schemas, API responses, or any application-specific data.

Each resource is uniquely identified by a URI (RFC 3986).

**How resources differ from other MCP primitives:**

| Primitive  | Control     | Description                                          |
|------------|-------------|------------------------------------------------------|
| Resources  | Application | Host application decides how/when to incorporate     |
| Tools      | Model       | LLM discovers and invokes autonomously               |
| Prompts    | User        | User explicitly selects (e.g. slash commands)         |

Resources are **read-only**. Clients fetch them; they do not mutate server
state. For operations that produce side effects, use Tools instead.

---

## 2. Capabilities Declaration

Servers that support resources MUST declare the `resources` capability during
initialization. Two optional sub-capabilities control notification behavior:

| Sub-capability | Description                                                |
|----------------|------------------------------------------------------------|
| `subscribe`    | Server supports per-resource change subscriptions          |
| `listChanged`  | Server emits notifications when the resource list changes  |

```json
{
  "capabilities": {
    "resources": {}
  }
}
```

With both optional features enabled:

```json
{
  "capabilities": {
    "resources": {
      "subscribe": true,
      "listChanged": true
    }
  }
}
```

---

## 3. Resource URIs

Resources use RFC 3986 URIs as identifiers. The protocol supports both
standard and custom URI schemes.

### Standard Schemes

| Scheme     | Usage                                                         |
|------------|---------------------------------------------------------------|
| `https://` | Web-accessible resources the client could fetch directly      |
| `file://`  | Filesystem-like resources (need not map to physical files)    |
| `git://`   | Git version control integration                               |

### Custom Schemes

Servers may define custom URI schemes for domain-specific resources:

```
db://production/users/schema
postgres://localhost/mydb/tables/users
resource://example/config
screen://main/dashboard
```

### Examples

```
file:///project/src/main.rs
file:///var/log/app.log
https://api.example.com/v1/status
git://repo/branch/path/to/file.py
db://warehouse/analytics/query-results
```

---

## 4. Resource Data Types

### Resource

Describes a known, concrete resource returned by `resources/list`.

```typescript
interface Resource {
  uri: string;              // REQUIRED -- unique URI identifier
  name: string;             // REQUIRED -- human-readable name
  description?: string;     // optional -- description for the model
  mimeType?: string;        // optional -- IANA MIME type
  size?: integer;           // optional -- raw content size in bytes (before encoding)
  annotations?: Annotations; // optional -- client hints
}
```

### ResourceTemplate

Describes a parameterized resource pattern returned by `resources/templates/list`.

```typescript
interface ResourceTemplate {
  uriTemplate: string;      // REQUIRED -- URI template per RFC 6570
  name: string;             // REQUIRED -- human-readable name
  description?: string;     // optional -- description for the model
  mimeType?: string;        // optional -- MIME type for all matching resources
  annotations?: Annotations; // optional -- client hints
}
```

---

## 5. Resource Content Types

Resource contents come in two variants: text and binary (blob).

### Base Type

```typescript
interface ResourceContents {
  uri: string;        // REQUIRED -- the resource URI
  mimeType?: string;  // optional -- IANA MIME type
}
```

### TextResourceContents

For text-based resources (source code, configuration, logs, JSON, etc.).

```typescript
interface TextResourceContents extends ResourceContents {
  text: string;       // REQUIRED -- UTF-8 text content
}
```

```json
{
  "uri": "file:///project/src/main.rs",
  "mimeType": "text/x-rust",
  "text": "fn main() {\n    println!(\"Hello world!\");\n}"
}
```

### BlobResourceContents

For binary resources (images, PDFs, compiled artifacts, etc.).
The `blob` field contains **base64-encoded** data.

```typescript
interface BlobResourceContents extends ResourceContents {
  blob: string;       // REQUIRED -- base64-encoded binary data
}
```

```json
{
  "uri": "file:///project/assets/logo.png",
  "mimeType": "image/png",
  "blob": "iVBORw0KGgoAAAANSUhEUgAAAAUA..."
}
```

---

## 6. Resource Discovery -- `resources/list`

Clients discover available resources by calling `resources/list`. This method
supports pagination via opaque cursor tokens.

### Request

```typescript
interface ListResourcesRequest {
  method: "resources/list";
  params?: {
    cursor?: string;    // opaque pagination token from a previous response
  };
}
```

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "resources/list",
  "params": {}
}
```

With pagination cursor:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "resources/list",
  "params": {
    "cursor": "eyJwYWdlIjogMn0="
  }
}
```

### Response

```typescript
interface ListResourcesResult {
  resources: Resource[];
  nextCursor?: string;    // present if more pages are available
  _meta?: object;
}
```

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "resources": [
      {
        "uri": "file:///project/src/main.rs",
        "name": "main.rs",
        "description": "Primary application entry point",
        "mimeType": "text/x-rust"
      },
      {
        "uri": "file:///project/src/lib.rs",
        "name": "lib.rs",
        "description": "Library root module",
        "mimeType": "text/x-rust"
      }
    ],
    "nextCursor": "eyJwYWdlIjogMn0="
  }
}
```

---

## 7. Reading Resources -- `resources/read`

Clients read resource contents by URI. The response `contents` field is an
**array** -- a single read may return multiple content items (e.g. a directory
listing could return several file contents).

### Request

```typescript
interface ReadResourceRequest {
  method: "resources/read";
  params: {
    uri: string;          // REQUIRED -- URI of resource to read
  };
}
```

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "resources/read",
  "params": {
    "uri": "file:///project/src/main.rs"
  }
}
```

### Response (text resource)

```typescript
interface ReadResourceResult {
  contents: (TextResourceContents | BlobResourceContents)[];
  _meta?: object;
}
```

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "contents": [
      {
        "uri": "file:///project/src/main.rs",
        "mimeType": "text/x-rust",
        "text": "fn main() {\n    println!(\"Hello world!\");\n}"
      }
    ]
  }
}
```

### Response (binary resource)

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "contents": [
      {
        "uri": "file:///project/assets/logo.png",
        "mimeType": "image/png",
        "blob": "iVBORw0KGgoAAAANSUhEUgAAAAUA..."
      }
    ]
  }
}
```

---

## 8. Resource Templates -- `resources/templates/list`

Resource templates expose parameterized resources using **URI Templates
(RFC 6570)**. Template arguments may be auto-completed through the MCP
completion API.

### Request

```typescript
interface ListResourceTemplatesRequest {
  method: "resources/templates/list";
  params?: {
    cursor?: string;      // opaque pagination token
  };
}
```

```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "resources/templates/list",
  "params": {}
}
```

### Response

```typescript
interface ListResourceTemplatesResult {
  resourceTemplates: ResourceTemplate[];
  nextCursor?: string;
  _meta?: object;
}
```

```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "result": {
    "resourceTemplates": [
      {
        "uriTemplate": "file:///{path}",
        "name": "Project Files",
        "description": "Access files in the project directory",
        "mimeType": "application/octet-stream"
      },
      {
        "uriTemplate": "db://production/{table}/schema",
        "name": "Database Table Schema",
        "description": "JSON schema for a database table"
      },
      {
        "uriTemplate": "git://repo/{branch}/{path}",
        "name": "Git File at Branch",
        "description": "Access a file from a specific git branch"
      }
    ]
  }
}
```

### Template Expansion

Clients expand templates by substituting parameter values into the URI template
before calling `resources/read`. For example, given the template
`db://production/{table}/schema`, a client would read:

```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "resources/read",
  "params": {
    "uri": "db://production/users/schema"
  }
}
```

---

## 9. Resource Subscriptions

When the server declares `"subscribe": true` in its resources capability,
clients can subscribe to change notifications for individual resources.

### Subscribe -- `resources/subscribe`

```typescript
interface SubscribeRequest {
  method: "resources/subscribe";
  params: {
    uri: string;          // REQUIRED -- URI to subscribe to
  };
}
```

```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "resources/subscribe",
  "params": {
    "uri": "file:///project/src/main.rs"
  }
}
```

The server responds with an empty result on success:

```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "result": {}
}
```

### Unsubscribe -- `resources/unsubscribe`

```typescript
interface UnsubscribeRequest {
  method: "resources/unsubscribe";
  params: {
    uri: string;          // REQUIRED
  };
}
```

```json
{
  "jsonrpc": "2.0",
  "id": 7,
  "method": "resources/unsubscribe",
  "params": {
    "uri": "file:///project/src/main.rs"
  }
}
```

### Update Notification -- `notifications/resources/updated`

The server sends this notification when a subscribed resource changes.
This is a JSON-RPC **notification** (no `id` field, no response expected).

```typescript
interface ResourceUpdatedNotification {
  method: "notifications/resources/updated";
  params: {
    uri: string;          // REQUIRED -- URI of updated resource
  };
}
```

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/resources/updated",
  "params": {
    "uri": "file:///project/src/main.rs"
  }
}
```

**Expected client behavior:** Upon receiving this notification, re-read the
resource via `resources/read` to get the updated contents.

---

## 10. Resource List Changes -- `notifications/resources/list_changed`

When the server declares `"listChanged": true` in its resources capability, it
sends this notification whenever the set of available resources changes (new
resources added, existing resources removed, metadata updated).

```typescript
interface ResourceListChangedNotification {
  method: "notifications/resources/list_changed";
  params?: {
    _meta?: object;
  };
}
```

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/resources/list_changed"
}
```

**Expected client behavior:** Re-call `resources/list` to refresh the
resource inventory.

---

## 11. Embedded Resources

Resources can be embedded directly in **tool call results** and **prompt
messages** using the `"resource"` content type. This allows servers to
attach resource-backed data inline.

### EmbeddedResource Type

```typescript
interface EmbeddedResource {
  type: "resource";                                        // REQUIRED, literal
  resource: TextResourceContents | BlobResourceContents;   // REQUIRED
  annotations?: Annotations;                               // optional
}
```

### In Tool Results

A tool's `CallToolResult.content[]` array may include embedded resources
alongside text and image content:

```json
{
  "jsonrpc": "2.0",
  "id": 8,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Found the configuration file:"
      },
      {
        "type": "resource",
        "resource": {
          "uri": "file:///project/config.toml",
          "mimeType": "application/toml",
          "text": "[server]\nport = 8080\nhost = \"0.0.0.0\""
        }
      }
    ],
    "isError": false
  }
}
```

### In Prompt Messages

A prompt's `GetPromptResult.messages[].content` may reference resources to
incorporate server-managed content (documentation, code samples, reference
material):

```json
{
  "role": "user",
  "content": {
    "type": "resource",
    "resource": {
      "uri": "file:///project/README.md",
      "mimeType": "text/markdown",
      "text": "# My Project\n\nA sample project..."
    }
  }
}
```

Embedded resources with binary data:

```json
{
  "type": "resource",
  "resource": {
    "uri": "file:///project/diagram.png",
    "mimeType": "image/png",
    "blob": "iVBORw0KGgoAAAANSUhEUgAAAAUA..."
  }
}
```

Embedded resources MUST include a valid URI, the appropriate content field
(`text` or `blob`), and SHOULD include a `mimeType`.

---

## 12. Method and Notification Reference

| Direction        | Type         | Method                                |
|------------------|--------------|---------------------------------------|
| client -> server | request      | `resources/list`                      |
| client -> server | request      | `resources/read`                      |
| client -> server | request      | `resources/templates/list`            |
| client -> server | request      | `resources/subscribe`                 |
| client -> server | request      | `resources/unsubscribe`               |
| server -> client | notification | `notifications/resources/updated`     |
| server -> client | notification | `notifications/resources/list_changed`|

---

## 13. Message Flow

```
Client                                    Server
  |                                         |
  |--- resources/list ---------------------->|
  |<-------------- list of resources --------|
  |                                         |
  |--- resources/templates/list ------------>|
  |<-------------- list of templates --------|
  |                                         |
  |--- resources/read --------------------->|
  |<-------------- resource contents --------|
  |                                         |
  |--- resources/subscribe ---------------->|
  |<-------------- ok ----------------------|
  |                                         |
  |      (resource changes on server)       |
  |                                         |
  |<-- notifications/resources/updated -----|
  |                                         |
  |--- resources/read --------------------->|
  |<-------------- updated contents ---------|
  |                                         |
  |      (resource list changes)            |
  |                                         |
  |<-- notifications/resources/list_changed -|
  |                                         |
  |--- resources/list --------------------->|
  |<-------------- updated list -------------|
```

---

## 14. Error Handling

Standard JSON-RPC error codes apply:

| Code     | Meaning           |
|----------|-------------------|
| `-32002` | Resource not found|
| `-32602` | Invalid params    |
| `-32603` | Internal error    |

Example error response:

```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "error": {
    "code": -32002,
    "message": "Resource not found",
    "data": {
      "uri": "file:///nonexistent.txt"
    }
  }
}
```

---

## 15. Security Considerations

1. **URI Validation** -- Servers MUST validate all resource URIs to prevent
   path traversal and injection attacks.
2. **Access Control** -- Servers SHOULD implement access controls for
   sensitive resources.
3. **Binary Encoding** -- Binary data MUST be properly base64-encoded in
   `BlobResourceContents`.
4. **Permission Checks** -- Resource permissions SHOULD be verified before
   any read or subscribe operation.

---

## 16. Implementation Notes for Elixir

When implementing resources in an Elixir MCP library, consider:

- **Resource Registry** -- Use a behaviour or protocol to let server
  implementations register resources and templates declaratively.
- **URI Matching** -- Resource template expansion (RFC 6570) can be handled
  by parsing URI templates at registration time and matching incoming URIs
  against registered patterns.
- **Subscription State** -- Track active subscriptions per-connection using
  a `MapSet` of URIs. When a resource changes, broadcast
  `notifications/resources/updated` only to subscribed connections.
- **Pagination** -- Support cursor-based pagination for `resources/list` and
  `resources/templates/list`. Cursors should be opaque tokens (e.g.
  base64-encoded offset or key).
- **Content Detection** -- Determine whether to return `TextResourceContents`
  or `BlobResourceContents` based on the resource's MIME type. Text types
  (`text/*`, `application/json`, `application/xml`, etc.) should use text;
  everything else should use base64-encoded blob.
- **Multiple Contents** -- The `ReadResourceResult.contents` field is a list.
  A single `resources/read` call may return multiple content items (e.g. when
  reading a directory or a composite resource).
