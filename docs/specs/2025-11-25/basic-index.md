<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/basic -->
<!-- Fetched: 2026-06-13 -->

# Overview

The Model Context Protocol consists of several key components that work together:

* **Base Protocol**: Core JSON-RPC message types
* **Lifecycle Management**: Connection initialization, capability negotiation, and session control
* **Authorization**: Authentication and authorization framework for HTTP-based transports
* **Server Features**: Resources, prompts, and tools exposed by servers
* **Client Features**: Sampling and root directory lists provided by clients
* **Utilities**: Cross-cutting concerns like logging and argument completion

All implementations **MUST** support the base protocol and lifecycle management components. Other components **MAY** be implemented based on the specific needs of the application.

These protocol layers establish clear separation of concerns while enabling rich interactions between clients and servers. The modular design allows implementations to support exactly the features they need.

## Messages

All messages between MCP clients and servers **MUST** follow the [JSON-RPC 2.0](https://www.jsonrpc.org/specification) specification. The protocol defines these types of messages:

### Requests

Requests are sent from the client to the server or vice versa, to initiate an operation.

```typescript
{
  jsonrpc: "2.0";
  id: string | number;
  method: string;
  params?: {
    [key: string]: unknown;
  };
}
```

* Requests **MUST** include a string or integer ID.
* Unlike base JSON-RPC, the ID **MUST NOT** be `null`.
* The request ID **MUST NOT** have been previously used by the requestor within the same session.

### Responses

Responses are sent in reply to requests, containing either the result or error of the operation.

#### Result Responses

```typescript
{
  jsonrpc: "2.0";
  id: string | number;
  result: {
    [key: string]: unknown;
  }
}
```

* Result responses **MUST** include the same ID as the request they correspond to.
* Result responses **MUST** include a `result` field.
* The `result` **MAY** follow any JSON object structure.

#### Error Responses

```typescript
{
  jsonrpc: "2.0";
  id?: string | number;
  error: {
    code: number;
    message: string;
    data?: unknown;
  }
}
```

* Error responses **MUST** include the same ID as the request they correspond to (except in error cases where the ID could not be read due a malformed request).
* Error responses **MUST** include an `error` field with a `code` and `message`.
* Error codes **MUST** be integers.

### Notifications

Notifications are sent from the client to the server or vice versa, as a one-way message. The receiver **MUST NOT** send a response.

```typescript
{
  jsonrpc: "2.0";
  method: string;
  params?: {
    [key: string]: unknown;
  };
}
```

* Notifications **MUST NOT** include an ID.

## Auth

MCP provides an Authorization framework for use with HTTP. Implementations using an HTTP-based transport **SHOULD** conform to this specification, whereas implementations using STDIO transport **SHOULD NOT** follow this specification, and instead retrieve credentials from the environment.

Additionally, clients and servers **MAY** negotiate their own custom authentication and authorization strategies.

## Schema

The full specification of the protocol is defined as a [TypeScript schema](https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-11-25/schema.ts). This is the source of truth for all protocol messages and structures.

There is also a [JSON Schema](https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-11-25/schema.json), which is automatically generated from the TypeScript source of truth, for use with various automated tooling.

## JSON Schema Usage

The Model Context Protocol uses JSON Schema for validation throughout the protocol.

### Schema Dialect

MCP supports JSON Schema with the following rules:

1. **Default dialect**: When a schema does not include a `$schema` field, it defaults to JSON Schema 2020-12
2. **Explicit dialect**: Schemas MAY include a `$schema` field to specify a different dialect
3. **Supported dialects**: Implementations MUST support at least 2020-12 and SHOULD document which additional dialects they support
4. **Recommendation**: Implementors are RECOMMENDED to use JSON Schema 2020-12.

### Implementation Requirements

* Clients and servers **MUST** support JSON Schema 2020-12 for schemas without an explicit `$schema` field
* Clients and servers **MUST** validate schemas according to their declared or default dialect. They **MUST** handle unsupported dialects gracefully by returning an appropriate error indicating the dialect is not supported.
* Clients and servers **SHOULD** document which schema dialects they support

### Schema Validation

* Schemas **MUST** be valid according to their declared or default dialect

## General fields

### `_meta`

The `_meta` property/parameter is reserved by MCP to allow clients and servers to attach additional metadata to their interactions.

Certain key names are reserved by MCP for protocol-level metadata, as specified below; implementations MUST NOT make assumptions about values at these keys.

**Key name format:** valid `_meta` key names have two segments: an optional **prefix**, and a **name**.

**Prefix:**

* If specified, MUST be a series of labels separated by dots (`.`), followed by a slash (`/`).
  * Labels MUST start with a letter and end with a letter or digit; interior characters can be letters, digits, or hyphens (`-`).
  * Implementations SHOULD use reverse DNS notation (e.g., `com.example/` rather than `example.com/`).
* Any prefix where the second label is `modelcontextprotocol` or `mcp` is **reserved** for MCP use.

**Name:**

* Unless empty, MUST begin and end with an alphanumeric character (`[a-z0-9A-Z]`).
* MAY contain hyphens (`-`), underscores (`_`), dots (`.`), and alphanumerics in between.

### `icons`

The `icons` property provides a standardized way for servers to expose visual identifiers for their resources, tools, prompts, and implementations. Icons enhance user interfaces by providing visual context and improving the discoverability of available functionality.

Icons are represented as an array of `Icon` objects, where each icon includes:

* `src`: A URI pointing to the icon resource (required). This can be:
  * An HTTP/HTTPS URL pointing to an image file
  * A data URI with base64-encoded image data
* `mimeType`: Optional MIME type if the server's type is missing or generic
* `sizes`: Optional array of size specifications (e.g., `["48x48"]`, `["any"]` for scalable formats like SVG, or `["48x48", "96x96"]` for multiple sizes)
* `theme`: Optional theme preference (`light` or `dark`) for the icon background

**Required MIME type support:**

Clients that support rendering icons **MUST** support at least:
* `image/png` - PNG images
* `image/jpeg` (and `image/jpg`) - JPEG images

Clients that support rendering icons **SHOULD** also support:
* `image/svg+xml` - SVG images
* `image/webp` - WebP images

**Security considerations:**

Consumers of icon metadata **MUST** take appropriate security precautions when handling icons to prevent compromise:
* Treat icon metadata and icon bytes as untrusted inputs
* Ensure that the icon URI is either a HTTPS or `data:` URI. Clients **MUST** reject icon URIs that use unsafe schemes
* Be resilient against resource exhaustion attacks
* Fetch icons without credentials
* Verify that icon URIs are from the same origin as the server
* Exercise caution when fetching and rendering icons as the payload **MAY** contain executable content
* Validate MIME types and file contents before rendering

**Usage:**

Icons can be attached to: `Implementation`, `Tool`, `Prompt`, `Resource`

Multiple icons can be provided to support different display contexts and resolutions.
