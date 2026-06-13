<!-- 
  Source: https://modelcontextprotocol.io/specification/draft/schema
  Fetched: 2026-06-13
  Status: DRAFT (2026-07-28-RC)
  WARNING: This is draft content and may change before final release.
-->

# Schema Reference

## JSON-RPC

### `JSONRPCErrorResponse`
A response to a request that indicates an error occurred.

**Properties:**
- `jsonrpc`: `"2.0"` (required)
- `id?`: `RequestId` (optional)
- `error`: `Error` (required)

### `JSONRPCMessage`
Refers to any valid JSON-RPC object that can be decoded off the wire, or encoded to be sent.

**Type:** `JSONRPCRequest | JSONRPCNotification | JSONRPCResponse`

### `JSONRPCNotification`
A notification which does not expect a response.

**Properties:**
- `method`: `string` (required)
- `params?`: `{ [key: string]: any }` (optional)
- `jsonrpc`: `"2.0"` (required)

### `JSONRPCRequest`
A request that expects a response.

**Properties:**
- `method`: `string` (required)
- `params?`: `{ [key: string]: any }` (optional)
- `jsonrpc`: `"2.0"` (required)
- `id`: `RequestId` (required)

### `JSONRPCResponse`
A response to a request, containing either the result or error.

**Type:** `JSONRPCResultResponse | JSONRPCErrorResponse`

### `JSONRPCResultResponse`
A successful (non-error) response to a request.

**Properties:**
- `jsonrpc`: `"2.0"` (required)
- `id`: `RequestId` (required)
- `result`: `Result` (required)

## Common Types

### `Annotations`
Optional annotations for the client. The client can use annotations to inform how objects are used or displayed.

**Properties:**
- `audience?`: `Role[]` - Describes who the intended audience of this object or data is
- `priority?`: `number` - Describes how important this data is for operating the server (1 = most important, 0 = least important)
- `lastModified?`: `string` - The moment the resource was last modified, as an ISO 8601 formatted string

### `Cursor`
An opaque token used to represent a cursor for pagination.

**Type:** `string`

### `EmptyResult`
A result that indicates success but carries no data.

**Type:** `Result`

### `Icon`
An optionally-sized icon that can be displayed in a user interface.

**Properties:**
- `src`: `string` (required) - A standard URI pointing to an icon resource (HTTP/HTTPS URL or data: URI with Base64-encoded image data)
- `mimeType?`: `string` - Optional MIME type override (e.g., "image/png", "image/jpeg", "image/svg+xml")
- `sizes?`: `string[]` - Optional array of sizes (e.g., "48x48", "96x96", "any")
- `theme?`: `"light" | "dark"` - Optional specifier for the theme this icon is designed for

### `InputResponseRequestParams`
Common params for any request.

**Properties:**
- `_meta`: `RequestMetaObject` (required, inherited from RequestParams)
- `inputResponses?`: `InputResponses`
- `requestState?`: `string`

### `JSONArray`
**Type:** `JSONValue[]`

### `JSONObject`
**Type:** `{ [key: string]: JSONValue }`

### `JSONValue`
**Type:** `string | number | boolean | null | JSONObject | JSONArray`

### `LoggingLevel`
The severity of a log message (maps to syslog message severities per RFC-5424).

**Type:** `"debug" | "info" | "notice" | "warning" | "error" | "critical" | "alert" | "emergency"`

**Note:** Deprecated as of protocol version 2026-07-28 (SEP-2577).

### `MetaObject`
Represents the contents of a `_meta` field, which clients and servers use to attach additional metadata to their interactions.

**Type:** `Record<string, unknown>`

Key naming rules:
- **Prefix** (optional): Series of labels separated by dots, followed by a slash. Labels must start with a letter and end with a letter or digit. Interior characters may be letters, digits, or hyphens.
- Any prefix where the second label is `modelcontextprotocol` or `mcp` is reserved for MCP use.
- **Name** (unless empty): Must start and end with alphanumeric characters. Interior characters may be alphanumeric, hyphens, underscores, or dots.

### `NotificationParams`
Common params for any notification.

**Properties:**
- `_meta?`: `MetaObject`

### `PaginatedRequestParams`
Common params for paginated requests.

**Properties:**
- `_meta`: `RequestMetaObject` (required, inherited from RequestParams)
- `cursor?`: `string` - An opaque token representing the current pagination position

**Example:**
```json
{
  "_meta": {
    "io.modelcontextprotocol/protocolVersion": "2026-07-28",
    "io.modelcontextprotocol/clientInfo": {
      "name": "ExampleClient",
      "version": "1.0.0"
    },
    "io.modelcontextprotocol/clientCapabilities": {}
  },
  "cursor": "eyJwYWdlIjogMn0="
}
```

### `ProgressToken`
A progress token, used to associate progress notifications with the original request.

**Type:** `string | number`

### `RequestId`
A uniquely identifying ID for a request in JSON-RPC.

**Type:** `string | number`

### `RequestMetaObject`
Extends `MetaObject` with additional request-specific fields.

**Properties:**
- `progressToken?`: `ProgressToken` - If specified, the caller is requesting out-of-band progress notifications
- `"io.modelcontextprotocol/protocolVersion"`: `string` (required) - The MCP Protocol Version being used
- `"io.modelcontextprotocol/clientInfo"`: `Implementation` (required) - Identifies the client software making the request
- `"io.modelcontextprotocol/clientCapabilities"`: `ClientCapabilities` (required) - The client's capabilities for this specific request
- `"io.modelcontextprotocol/logLevel"?`: `LoggingLevel` (deprecated) - The desired log level for this request

### `RequestParams`
Common params for any request.

**Properties:**
- `_meta`: `RequestMetaObject` (required)

### `Result`
Common result fields.

**Properties:**
- `_meta?`: `MetaObject`
- `resultType`: `string` (required) - Indicates the type of the result

### `ResultType`
Indicates the type of a `Result` object.

**Type:** `"complete" | "input_required" | string`

- **complete** - The request completed successfully and the result contains the final content
- **input_required** - The request requires additional input and the result contains an `InputRequiredResult` object

### `Role`
The sender or recipient of messages and data in a conversation.

**Type:** `"user" | "assistant"`

## Errors

### `Error`
Base error object.

**Properties:**
- `code`: `number` (required) - The error type that occurred
- `message`: `string` (required) - A short description of the error (limited to a concise single sentence)
- `data?`: `unknown` - Additional information about the error

### `InternalError`
A JSON-RPC error indicating that an internal error occurred on the receiver.

**Code:** `-32603`

**Example:**
```json
{
  "code": -32603,
  "message": "Internal error"
}
```

### `InvalidParamsError`
A JSON-RPC error indicating that the method parameters are invalid or malformed.

**Code:** `-32602`

Used in various contexts:
- **Tools**: Unknown tool name or invalid tool arguments
- **Prompts**: Unknown prompt name or missing required arguments
- **Pagination**: Invalid or expired cursor values
- **Logging**: Invalid log level
- **Elicitation**: Server requests an elicitation mode not declared in client capabilities
- **Sampling**: Missing tool result or tool results mixed with other content

**Examples:**
```json
{
  "code": -32602,
  "message": "Unknown tool: invalid_tool_name"
}
```

```json
{
  "code": -32602,
  "message": "Invalid arguments for tool calculate: Missing required property 'expression'"
}
```

### `InvalidRequestError`
A JSON-RPC error indicating that the request is not a valid request object.

**Code:** `-32600`

Returned when the message structure does not conform to the JSON-RPC 2.0 specification (e.g., missing required fields like `jsonrpc` or `method`).

### `MethodNotFoundError`
A JSON-RPC error indicating that the requested method does not exist or is not available.

**Code:** `-32601`

In MCP, a server returns this error when:
- A client invokes a method the server does not implement
- A genuinely unknown method is called
- A method gated behind a server capability the server did not advertise is called

**Example:**
```json
{
  "code": -32601,
  "message": "Prompts not supported",
  "data": {
    "reason": "Server does not support the prompts capability"
  }
}
```

### `MISSING_REQUIRED_CLIENT_CAPABILITY`
Error code returned when a server requires a client capability that was not declared in the request's `clientCapabilities`.

**Code:** `-32003`

### `MissingRequiredClientCapabilityError`
Returned when processing a request requires a capability the client did not declare in `clientCapabilities`. For HTTP, the response status code MUST be `400 Bad Request`.

**Properties:**
- `jsonrpc`: `"2.0"`
- `id?`: `RequestId`
- `error`: `Error & { code: -32003; data: { requiredCapabilities: ClientCapabilities } }`

**Example:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32003,
    "message": "Server requires the elicitation capability for this request",
    "data": {
      "requiredCapabilities": {
        "elicitation": {}
      }
    }
  }
}
```

### `ParseError`
A JSON-RPC error indicating that invalid JSON was received by the server.

**Code:** `-32700`

**Example:**
```json
{
  "code": -32700,
  "message": "Parse error: Invalid JSON"
}
```

### `UNSUPPORTED_PROTOCOL_VERSION`
Error code returned when the request's protocol version is not supported by the server.

**Code:** `-32004`

### `UnsupportedProtocolVersionError`
Returned when the request's protocol version is unknown to the server or unsupported. For HTTP, the response status code MUST be `400 Bad Request`.

**Properties:**
- `jsonrpc`: `"2.0"`
- `id?`: `RequestId`
- `error`: `Error & { code: -32004; data: { supported: string[]; requested: string } }`

**Example:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32004,
    "message": "Unsupported protocol version",
    "data": {
      "supported": ["2026-07-28", "2025-11-25"],
      "requested": "1900-01-01"
    }
  }
}
```

## Content

### `AudioContent`
Audio provided to or from an LLM.

**Properties:**
- `type`: `"audio"` (required)
- `data`: `string` (required) - The base64-encoded audio data
- `mimeType`: `string` (required) - The MIME type of the audio
- `annotations?`: `Annotations` - Optional annotations for the client
- `_meta?`: `MetaObject`

**Example:**
```json
{
  "type": "audio",
  "data": "UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=",
  "mimeType": "audio/wav"
}
```

### `BlobResourceContents`
**Properties:**
- `uri`: `string` (required) - The URI of this resource
- `mimeType?`: `string` - The MIME type of this resource
- `_meta?`: `MetaObject`
- `blob`: `string` (required) - A base64-encoded string representing the binary data

**Example:**
```json
{
  "uri": "file:///example.png",
  "mimeType": "image/png",
  "blob": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
}
```

### `ContentBlock`
**Type:** `TextContent | ImageContent | AudioContent | ResourceLink | EmbeddedResource`

### `EmbeddedResource`
The contents of a resource, embedded into a prompt or tool call result.

**Properties:**
- `type`: `"resource"` (required)
- `resource`: `TextResourceContents | BlobResourceContents` (required)
- `annotations?`: `Annotations` - Optional annotations for the client
- `_meta?`: `MetaObject`

**Example:**
```json
{
  "type": "resource",
  "resource": {
    "uri": "file:///project/src/main.rs",
    "mimeType": "text/x-rust",
    "text": "fn main() {\n    println!(\"Hello world!\");\n}"
  },
  "annotations": {
    "audience": ["user", "assistant"],
    "priority": 0.7,
    "lastModified": "2025-05-03T14:30:00Z"
  }
}
```

### `ImageContent`
An image provided to or from an LLM.

**Properties:**
- `type`: `"image"` (required)
- `data`: `string` (required) - The base64-encoded image data
- `mimeType`: `string` (required) - The MIME type of the image
- `annotations?`: `Annotations` - Optional annotations for the client
- `_meta?`: `MetaObject`

**Example:**
```json
{
  "type": "image",
  "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
  "mimeType": "image/png",
  "annotations": {
    "audience": ["user", "assistant"]
  }
}
```

### `TextContent`
Text provided to or from an LLM.

**Properties:**
- `type`: `"text"` (required)
- `text`: `string` (required) - The text content
- `annotations?`: `Annotations` - Optional annotations for the client
- `_meta?`: `MetaObject`

### `TextResourceContents`
The text contents of a resource.

**Properties:**
- `uri`: `string` (required) - The URI of this resource
- `mimeType?`: `string` - The MIME type of this resource
- `_meta?`: `MetaObject`
- `text`: `string` (required) - The text of the item

### `ResourceLink`
A link to a resource, provided as context to the LLM.

**Properties:**
- `type`: `"resource_link"` (required)
- `uri`: `string` (required) - The URI of the resource
- `name?`: `string` - Optional name for the resource
- `description?`: `string` - Optional description
- `mimeType?`: `string` - Optional MIME type
- `annotations?`: `Annotations`
- `_meta?`: `MetaObject`

## Tools

### `Tool`
Definition of a tool that the client can call.

**Properties:**
- `name`: `string` (required) - Unique identifier for the tool
- `title?`: `string` - Optional human-readable name for display
- `description?`: `string` - Human-readable description of functionality
- `icons?`: `Icon[]` - Optional array of icons
- `inputSchema`: `object` (required) - JSON Schema defining expected parameters
- `outputSchema?`: `object` - Optional JSON Schema defining expected output structure
- `annotations?`: `ToolAnnotations` - Optional properties describing tool behavior
- `_meta?`: `MetaObject`

### `ToolAnnotations`
Additional properties describing tool behavior.

**Properties:**
- `title?`: `string` - Human-readable title
- `readOnlyHint?`: `boolean` - If true, the tool does not modify its environment
- `destructiveHint?`: `boolean` - If true, the tool may perform destructive updates
- `idempotentHint?`: `boolean` - If true, calling the tool with the same arguments always yields the same result
- `openWorldHint?`: `boolean` - If true, the tool may interact with the "open world"

### `CallToolRequest`
Request to invoke a tool.

**Properties:**
- `method`: `"tools/call"` (required)
- `params`: (required)
  - `name`: `string` (required) - The name of the tool to call
  - `arguments?`: `Record<string, unknown>` - Arguments to pass to the tool
  - `_meta`: `RequestMetaObject` (required)
  - `inputResponses?`: `InputResponses`
  - `requestState?`: `string`

### `CallToolResult`
Result of a tool invocation.

**Properties:**
- `resultType`: `"complete"` (required)
- `content?`: `ContentBlock[]` - Unstructured content items
- `structuredContent?`: `JSONValue` - Structured content conforming to outputSchema
- `isError?`: `boolean` - Whether the tool call ended in an error
- `_meta?`: `MetaObject`

### `ListToolsRequest`
Request to list available tools.

**Properties:**
- `method`: `"tools/list"` (required)
- `params`: `PaginatedRequestParams`

### `ListToolsResult`
Result of listing tools.

**Properties:**
- `resultType`: `"complete"` (required)
- `tools`: `Tool[]` (required) - Array of available tools
- `nextCursor?`: `Cursor` - Pagination cursor for next page
- `ttlMs`: `number` (required) - Freshness hint in milliseconds
- `cacheScope`: `"public" | "private"` (required)
- `_meta?`: `MetaObject`

### `ToolUseContent`
A request from an LLM to invoke a tool (used in sampling).

**Properties:**
- `type`: `"tool_use"` (required)
- `id`: `string` (required) - Unique identifier for this tool use
- `name`: `string` (required) - Name of the tool to call
- `input`: `Record<string, unknown>` (required) - Arguments for the tool
- `_meta?`: `MetaObject`

### `ToolResultContent`
The result of a tool invocation (used in sampling).

**Properties:**
- `type`: `"tool_result"` (required)
- `toolUseId`: `string` (required) - The ID of the tool use this result corresponds to
- `content?`: `ContentBlock[]` - The result content
- `isError?`: `boolean` - Whether the tool call resulted in an error
- `_meta?`: `MetaObject`

## Prompts

### `Prompt`
A prompt template that can be requested from the server.

**Properties:**
- `name`: `string` (required)
- `title?`: `string` - Human-readable name for display
- `description?`: `string`
- `icons?`: `Icon[]`
- `arguments?`: `PromptArgument[]`
- `_meta?`: `MetaObject`

### `PromptArgument`
An argument for a prompt template.

**Properties:**
- `name`: `string` (required)
- `description?`: `string`
- `required?`: `boolean`

### `PromptMessage`
A message within a prompt response.

**Properties:**
- `role`: `Role` (required)
- `content`: `ContentBlock | ContentBlock[]` (required)
- `_meta?`: `MetaObject`

### `PromptReference`
A reference to a prompt defined by the server.

**Properties:**
- `type`: `"ref/prompt"` (required)
- `name`: `string` (required)

### `GetPromptRequest`
Request to get a specific prompt.

**Properties:**
- `method`: `"prompts/get"` (required)
- `params`: (required)
  - `name`: `string` (required)
  - `arguments?`: `Record<string, string>`
  - `_meta`: `RequestMetaObject` (required)
  - `inputResponses?`: `InputResponses`
  - `requestState?`: `string`

### `GetPromptResult`
Result of getting a prompt.

**Properties:**
- `resultType`: `"complete"` (required)
- `description?`: `string`
- `messages`: `PromptMessage[]` (required)
- `_meta?`: `MetaObject`

### `ListPromptsRequest`
Request to list available prompts.

**Properties:**
- `method`: `"prompts/list"` (required)
- `params`: `PaginatedRequestParams`

### `ListPromptsResult`
Result of listing prompts.

**Properties:**
- `resultType`: `"complete"` (required)
- `prompts`: `Prompt[]` (required)
- `nextCursor?`: `Cursor`
- `ttlMs`: `number` (required)
- `cacheScope`: `"public" | "private"` (required)
- `_meta?`: `MetaObject`

## Resources

### `Resource`
A resource available from the server.

**Properties:**
- `uri`: `string` (required)
- `name`: `string` (required)
- `title?`: `string` - Human-readable name for display
- `description?`: `string`
- `icons?`: `Icon[]`
- `mimeType?`: `string`
- `size?`: `number` - Size in bytes
- `annotations?`: `Annotations`
- `_meta?`: `MetaObject`

### `ResourceTemplate`
A template for resources with parameterized URIs.

**Properties:**
- `uriTemplate`: `string` (required)
- `name`: `string` (required)
- `title?`: `string`
- `description?`: `string`
- `icons?`: `Icon[]`
- `mimeType?`: `string`
- `annotations?`: `Annotations`
- `_meta?`: `MetaObject`

### `ResourceTemplateReference`
A reference to a resource template defined by the server.

**Properties:**
- `type`: `"ref/resource"` (required)
- `uri`: `string` (required)

### `ReadResourceRequest`
Request to read a resource.

**Properties:**
- `method`: `"resources/read"` (required)
- `params`: (required)
  - `uri`: `string` (required)
  - `_meta`: `RequestMetaObject` (required)
  - `inputResponses?`: `InputResponses`
  - `requestState?`: `string`

### `ReadResourceResult`
Result of reading a resource.

**Properties:**
- `resultType`: `"complete"` (required)
- `contents`: `(TextResourceContents | BlobResourceContents)[]` (required)
- `ttlMs`: `number` (required)
- `cacheScope`: `"public" | "private"` (required)
- `_meta?`: `MetaObject`

### `ListResourcesRequest`
Request to list available resources.

**Properties:**
- `method`: `"resources/list"` (required)
- `params`: `PaginatedRequestParams`

### `ListResourcesResult`
Result of listing resources.

**Properties:**
- `resultType`: `"complete"` (required)
- `resources`: `Resource[]` (required)
- `nextCursor?`: `Cursor`
- `ttlMs`: `number` (required)
- `cacheScope`: `"public" | "private"` (required)
- `_meta?`: `MetaObject`

### `ListResourceTemplatesRequest`
Request to list resource templates.

**Properties:**
- `method`: `"resources/templates/list"` (required)
- `params`: `PaginatedRequestParams`

### `ListResourceTemplatesResult`
Result of listing resource templates.

**Properties:**
- `resultType`: `"complete"` (required)
- `resourceTemplates`: `ResourceTemplate[]` (required)
- `nextCursor?`: `Cursor`
- `ttlMs`: `number` (required)
- `cacheScope`: `"public" | "private"` (required)
- `_meta?`: `MetaObject`

## Sampling

### `CreateMessageRequest`
Request to sample/create a message from the LLM.

**Properties:**
- `method`: `"sampling/createMessage"` (required)
- `params`: (required)
  - `messages`: `SamplingMessage[]` (required)
  - `modelPreferences?`: `ModelPreferences`
  - `systemPrompt?`: `string`
  - `includeContext?`: `"none" | "thisServer" | "allServers"`
  - `temperature?`: `number`
  - `maxTokens`: `number` (required)
  - `stopSequences?`: `string[]`
  - `metadata?`: `Record<string, unknown>`
  - `tools?`: `SamplingTool[]`
  - `toolChoice?`: `ToolChoice`

**Note:** Deprecated as of protocol version 2026-07-28 (SEP-2577).

### `SamplingMessage`
A message for sampling requests.

**Properties:**
- `role`: `Role` (required)
- `content`: `ContentBlock | ContentBlock[]` (required)
- `_meta?`: `MetaObject`

### `SamplingTool`
A tool definition for use in sampling requests.

**Properties:**
- `name`: `string` (required)
- `description?`: `string`
- `inputSchema`: `object` (required)

### `ToolChoice`
Controls tool use behavior in sampling.

**Properties:**
- `mode`: `"auto" | "required" | "none"` (required)

### `ModelPreferences`
Preferences for model selection in sampling.

**Properties:**
- `hints?`: `ModelHint[]`
- `costPriority?`: `number` - 0-1, higher prefers cheaper models
- `speedPriority?`: `number` - 0-1, higher prefers faster models
- `intelligencePriority?`: `number` - 0-1, higher prefers more capable models
- `_meta?`: `MetaObject`

### `ModelHint`
A hint for model selection.

**Properties:**
- `name?`: `string` - Substring that can match model names flexibly

### `CreateMessageResult`
Result of a message creation/sampling request.

**Properties:**
- `role`: `Role` (required)
- `content`: `ContentBlock | ContentBlock[]` (required)
- `model`: `string` (required) - Name of the model that generated the message
- `stopReason?`: `string` - e.g., "endTurn", "stopSequence", "maxTokens", "toolUse"
- `_meta?`: `MetaObject`

## Elicitation

### `ElicitRequest`
Request for user input via elicitation.

**Properties:**
- `method`: `"elicitation/create"` (required)
- `params`: (required)
  - `mode?`: `"form" | "url"` - Defaults to "form" if omitted
  - `message`: `string` (required)
  - `requestedSchema?`: `object` - JSON Schema for form mode
  - `url?`: `string` - URL for url mode
  - `elicitationId?`: `string` - Unique ID for url mode

### `ElicitResult`
Result of an elicitation request.

**Properties:**
- `action`: `"accept" | "decline" | "cancel"` (required)
- `content?`: `Record<string, unknown>` - Submitted data (form mode, accept action)
- `_meta?`: `MetaObject`

## Roots

### `Root`
A root directory or location the client wants to expose.

**Properties:**
- `uri`: `string` (required) - Must be a `file://` URI
- `name?`: `string` - Human-readable name

**Note:** Deprecated as of protocol version 2026-07-28 (SEP-2577).

### `ListRootsRequest`
Request to list filesystem roots.

**Properties:**
- `method`: `"roots/list"` (required)

### `ListRootsResult`
Result of listing roots.

**Properties:**
- `roots`: `Root[]` (required)
- `_meta?`: `MetaObject`

## Subscriptions

### `SubscriptionsListenRequest`
Request to open a notification stream.

**Properties:**
- `method`: `"subscriptions/listen"` (required)
- `params`: (required)
  - `_meta`: `RequestMetaObject` (required)
  - `notifications`: `SubscriptionNotificationFilter` (required)

### `SubscriptionNotificationFilter`
Filter for subscription notifications.

**Properties:**
- `toolsListChanged?`: `boolean`
- `promptsListChanged?`: `boolean`
- `resourcesListChanged?`: `boolean`
- `resourceSubscriptions?`: `string[]` - Resource URIs to watch

## Discovery

### `DiscoverRequest`
Request to discover server capabilities.

**Properties:**
- `method`: `"server/discover"` (required)
- `params`: (required)
  - `_meta`: `RequestMetaObject` (required)

### `DiscoverResult`
Result of server discovery.

**Properties:**
- `resultType`: `"complete"` (required)
- `supportedVersions`: `string[]` (required) - Protocol versions the server supports
- `capabilities`: `ServerCapabilities` (required)
- `serverInfo`: `Implementation` (required)
- `instructions?`: `string` - Natural-language guidance for LLMs
- `ttlMs?`: `number` - Freshness hint in milliseconds
- `cacheScope?`: `"public" | "private"`
- `_meta?`: `MetaObject`

## Capabilities

### `ClientCapabilities`
Capabilities advertised by the client.

**Properties:**
- `sampling?`: `SamplingCapability` - Support for LLM sampling (deprecated)
- `elicitation?`: `ElicitationCapability` - Support for user elicitation
- `roots?`: `object` - Support for filesystem roots (deprecated)
- `extensions?`: `Record<string, object>` - Optional extension capabilities
- `_meta?`: `MetaObject`

### `SamplingCapability`
**Properties:**
- `tools?`: `object` - Support for tool use in sampling
- `context?`: `object` - Support for context inclusion (deprecated)

### `ElicitationCapability`
**Properties:**
- `form?`: `object` - Support for form mode
- `url?`: `object` - Support for URL mode

### `ServerCapabilities`
Capabilities advertised by the server.

**Properties:**
- `logging?`: `object` - Support for logging (deprecated)
- `prompts?`: `PromptsCapability` - Support for prompts
- `resources?`: `ResourcesCapability` - Support for resources
- `tools?`: `ToolsCapability` - Support for tools
- `completions?`: `object` - Support for argument completions
- `extensions?`: `Record<string, object>` - Optional extension capabilities
- `_meta?`: `MetaObject`

### `PromptsCapability`
**Properties:**
- `listChanged?`: `boolean` - Whether the server emits prompt list change notifications

### `ResourcesCapability`
**Properties:**
- `listChanged?`: `boolean` - Whether the server emits resource list change notifications
- `subscribe?`: `boolean` - Whether the server supports resource subscriptions

### `ToolsCapability`
**Properties:**
- `listChanged?`: `boolean` - Whether the server emits tool list change notifications

## Implementation

### `Implementation`
Information about a client or server implementation.

**Properties:**
- `name`: `string` (required)
- `version`: `string` (required)
- `icons?`: `Icon[]`
- `_meta?`: `MetaObject`

## Multi Round-Trip Requests

### `InputRequests`
A map of server-client requests. Keys are server-assigned string identifiers; values are request objects.

**Type:** `Record<string, ElicitRequest | CreateMessageRequest | ListRootsRequest>`

### `InputResponses`
A map of client responses to server requests. Keys correspond to the keys in `InputRequests`.

**Type:** `Record<string, ElicitResult | CreateMessageResult | ListRootsResult>`

### `InputRequiredResult`
A result indicating additional input is needed.

**Properties:**
- `resultType`: `"input_required"` (required)
- `inputRequests?`: `InputRequests` - Server-initiated requests the client must fulfill
- `requestState?`: `string` - Opaque server state; clients MUST NOT inspect or modify
- `_meta?`: `MetaObject`

At least one of `inputRequests` or `requestState` MUST be present.

## Completion

### `CompleteRequest`
Request for argument completion suggestions.

**Properties:**
- `method`: `"completion/complete"` (required)
- `params`: (required)
  - `ref`: `PromptReference | ResourceTemplateReference` (required)
  - `argument`: `{ name: string; value: string }` (required)
  - `context?`: `{ arguments?: Record<string, string> }`
  - `_meta`: `RequestMetaObject` (required)

### `CompleteResult`
Result of a completion request.

**Properties:**
- `resultType`: `"complete"` (required)
- `completion`: (required)
  - `values`: `string[]` (required) - Array of suggestions (max 100)
  - `total?`: `number` - Total matches available
  - `hasMore?`: `boolean` - Whether additional results exist
- `_meta?`: `MetaObject`

## Notifications

### `CancelledNotification`
Notification to cancel an in-flight request.

**Properties:**
- `method`: `"notifications/cancelled"` (required)
- `params`: (required)
  - `requestId`: `RequestId` (required)
  - `reason?`: `string`

### `ProgressNotification`
Notification of progress on an in-flight request.

**Properties:**
- `method`: `"notifications/progress"` (required)
- `params`: (required)
  - `progressToken`: `ProgressToken` (required)
  - `progress`: `number` (required)
  - `total?`: `number`
  - `message?`: `string`

### `LoggingMessageNotification`
Server log message notification (deprecated).

**Properties:**
- `method`: `"notifications/message"` (required)
- `params`: (required)
  - `level`: `LoggingLevel` (required)
  - `logger?`: `string`
  - `data`: `unknown` (required)

### `ToolsListChangedNotification`
Notification that the tools list has changed.

**Properties:**
- `method`: `"notifications/tools/list_changed"` (required)

### `PromptsListChangedNotification`
Notification that the prompts list has changed.

**Properties:**
- `method`: `"notifications/prompts/list_changed"` (required)

### `ResourcesListChangedNotification`
Notification that the resources list has changed.

**Properties:**
- `method`: `"notifications/resources/list_changed"` (required)

### `ResourceUpdatedNotification`
Notification that a specific resource has been updated.

**Properties:**
- `method`: `"notifications/resources/updated"` (required)
- `params`: (required)
  - `uri`: `string` (required)
  - `_meta?`: `MetaObject` - Must include `io.modelcontextprotocol/subscriptionId`

### `SubscriptionsAcknowledgedNotification`
Acknowledgment of a subscriptions/listen request.

**Properties:**
- `method`: `"notifications/subscriptions/acknowledged"` (required)
- `params`: (required)
  - `notifications`: `SubscriptionNotificationFilter` (required) - The subset the server agreed to honor
  - `_meta?`: `MetaObject` - Must include `io.modelcontextprotocol/subscriptionId`

### `ElicitationCompleteNotification`
Notification that a URL mode elicitation interaction is complete.

**Properties:**
- `method`: `"notifications/elicitation/complete"` (required)
- `params`: (required)
  - `elicitationId`: `string` (required)
