<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/schema -->
<!-- Fetched: 2026-06-13 -->

# Schema Reference

This page provides the TypeScript schema definitions for all MCP protocol types. For the complete source of truth, see the [TypeScript schema](https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-11-25/schema.ts) and [JSON Schema](https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-11-25/schema.json).

## JSON-RPC

### JSONRPCRequest

```typescript
interface JSONRPCRequest {
  method: string;
  params?: { [key: string]: any };
  jsonrpc: "2.0";
  id: RequestId;
}
```

### JSONRPCNotification

```typescript
interface JSONRPCNotification {
  method: string;
  params?: { [key: string]: any };
  jsonrpc: "2.0";
}
```

### JSONRPCResultResponse

```typescript
interface JSONRPCResultResponse {
  jsonrpc: "2.0";
  id: RequestId;
  result: Result;
}
```

### JSONRPCErrorResponse

```typescript
interface JSONRPCErrorResponse {
  jsonrpc: "2.0";
  id?: RequestId;
  error: Error;
}
```

### JSONRPCMessage

```typescript
type JSONRPCMessage = JSONRPCRequest | JSONRPCNotification | JSONRPCResponse
```

## Common Types

### Annotations

```typescript
interface Annotations {
  audience?: Role[];
  priority?: number;
  lastModified?: string;
}
```

### Cursor

```typescript
type Cursor = string
```

### Error

```typescript
interface Error {
  code: number;
  message: string;
  data?: unknown;
}
```

### Icon

```typescript
interface Icon {
  src: string;
  mimeType?: string;
  sizes?: string[];
  theme?: "light" | "dark";
}
```

### LoggingLevel

```typescript
type LoggingLevel = "debug" | "info" | "notice" | "warning" | "error" | "critical" | "alert" | "emergency"
```

### ProgressToken

```typescript
type ProgressToken = string | number
```

### RequestId

```typescript
type RequestId = string | number
```

### Result

```typescript
interface Result {
  _meta?: { [key: string]: unknown };
  [key: string]: unknown;
}
```

### Role

```typescript
type Role = "user" | "assistant"
```

## Content Types

### TextContent

```typescript
interface TextContent {
  type: "text";
  text: string;
  annotations?: Annotations;
  _meta?: { [key: string]: unknown };
}
```

### ImageContent

```typescript
interface ImageContent {
  type: "image";
  data: string;
  mimeType: string;
  annotations?: Annotations;
  _meta?: { [key: string]: unknown };
}
```

### AudioContent

```typescript
interface AudioContent {
  type: "audio";
  data: string;
  mimeType: string;
  annotations?: Annotations;
  _meta?: { [key: string]: unknown };
}
```

### ResourceLink

```typescript
interface ResourceLink {
  type: "resource_link";
  uri: string;
  name: string;
  title?: string;
  description?: string;
  mimeType?: string;
  icons?: Icon[];
  annotations?: Annotations;
  size?: number;
  _meta?: { [key: string]: unknown };
}
```

### EmbeddedResource

```typescript
interface EmbeddedResource {
  type: "resource";
  resource: TextResourceContents | BlobResourceContents;
  annotations?: Annotations;
  _meta?: { [key: string]: unknown };
}
```

### TextResourceContents

```typescript
interface TextResourceContents {
  uri: string;
  mimeType?: string;
  text: string;
  _meta?: { [key: string]: unknown };
}
```

### BlobResourceContents

```typescript
interface BlobResourceContents {
  uri: string;
  mimeType?: string;
  blob: string;
  _meta?: { [key: string]: unknown };
}
```

### ContentBlock

```typescript
type ContentBlock = TextContent | ImageContent | AudioContent | ResourceLink | EmbeddedResource
```

## Completion

### CompleteRequest

```typescript
interface CompleteRequestParams {
  _meta?: { progressToken?: ProgressToken; [key: string]: unknown };
  ref: PromptReference | ResourceTemplateReference;
  argument: { name: string; value: string };
  context?: { arguments?: { [key: string]: string } };
}
```

### CompleteResult

```typescript
interface CompleteResult {
  _meta?: { [key: string]: unknown };
  completion: {
    values: string[];
    total?: number;
    hasMore?: boolean;
  };
}
```

### PromptReference

```typescript
interface PromptReference {
  type: "ref/prompt";
  name: string;
  title?: string;
}
```

### ResourceTemplateReference

```typescript
interface ResourceTemplateReference {
  type: "ref/resource";
  uri: string;
}
```

## Elicitation

### ElicitRequestParams

```typescript
type ElicitRequestParams = ElicitRequestFormParams | ElicitRequestURLParams
```

### ElicitResult

```typescript
interface ElicitResult {
  _meta?: { [key: string]: unknown };
  action: "accept" | "decline" | "cancel";
  content?: { [key: string]: string | number | boolean | string[] };
}
```

### ElicitRequestFormParams

```typescript
interface ElicitRequestFormParams {
  task?: TaskMetadata;
  _meta?: { progressToken?: ProgressToken; [key: string]: unknown };
  mode?: "form";
  message: string;
  requestedSchema: {
    $schema?: string;
    type: "object";
    properties: { [key: string]: PrimitiveSchemaDefinition };
    required?: string[];
  };
}
```

### ElicitRequestURLParams

```typescript
interface ElicitRequestURLParams {
  task?: TaskMetadata;
  _meta?: { progressToken?: ProgressToken; [key: string]: unknown };
  mode: "url";
  message: string;
  elicitationId: string;
  url: string;
}
```

> Note: This is a summary of key schema types. For the complete schema reference with all types, see the [full TypeScript schema](https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-11-25/schema.ts).
