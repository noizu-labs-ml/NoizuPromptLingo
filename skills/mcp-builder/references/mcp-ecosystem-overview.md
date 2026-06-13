# MCP Ecosystem Overview

Comprehensive reference for the Model Context Protocol ecosystem: specification, SDKs, transports, clients, registries, and patterns.

> This is the "kitchen sink" reference. For focused guidance, see the dedicated references: [sdk-reference-nodejs.md](sdk-reference-nodejs.md), [sdk-reference-python.md](sdk-reference-python.md), [transport-guide.md](transport-guide.md), [discovery-mechanisms.md](discovery-mechanisms.md).

---

## Protocol Specification Summary

### What MCP Is

The Model Context Protocol (MCP) is an open standard for connecting AI models to external tools, data sources, and services. It defines a client-server architecture where:

- **Clients** (LLM applications like Claude Desktop, Cursor, VS Code) connect to servers
- **Servers** expose **tools**, **resources**, and **prompt templates** to clients
- Communication uses **JSON-RPC 2.0** over a transport layer (stdio or HTTP)

The protocol is maintained by Anthropic and the open-source community. The current stable specification version is **2025-03-26**.

### Protocol Primitives

MCP defines three primitive types that servers can expose:

| Primitive | Purpose | Client Interaction |
|---|---|---|
| **Tools** | Executable functions the model can invoke | Model decides when to call; client sends `tools/call` |
| **Resources** | Data the client can read (files, database records, API responses) | Client fetches via `resources/read`; model can request |
| **Prompts** | Reusable prompt templates with parameters | User selects from menu; client sends `prompts/get` |

### JSON-RPC 2.0 Message Format

All MCP communication uses JSON-RPC 2.0:

```json
// Request (client -> server)
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "get_weather",
    "arguments": { "city": "Seattle" }
  }
}

// Response (server -> client)
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      { "type": "text", "text": "Seattle: 62F, partly cloudy" }
    ]
  }
}

// Notification (no id, no response expected)
{
  "jsonrpc": "2.0",
  "method": "notifications/tools/list_changed"
}
```

### Capabilities Negotiation

On connection, client and server exchange capabilities:

1. Client sends `initialize` with its supported capabilities
2. Server responds with its capabilities (which primitives it supports, protocol version)
3. Client sends `initialized` notification
4. Normal operation begins

```json
// Server capabilities example
{
  "capabilities": {
    "tools": { "listChanged": true },
    "resources": { "subscribe": true, "listChanged": true },
    "prompts": { "listChanged": true }
  },
  "protocolVersion": "2025-03-26",
  "serverInfo": {
    "name": "my-server",
    "version": "1.0.0"
  }
}
```

### Tool Definition Schema

Tools are defined with JSON Schema for input validation:

```json
{
  "name": "search_issues",
  "description": "Search GitHub issues by query string",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": { "type": "string", "description": "Search query" },
      "state": { "type": "string", "enum": ["open", "closed", "all"], "default": "open" },
      "limit": { "type": "integer", "minimum": 1, "maximum": 100, "default": 10 }
    },
    "required": ["query"]
  }
}
```

### Resource URI Scheme

Resources use URI-based addressing:

```
file:///path/to/document.md
postgres://localhost/mydb/users
github://owner/repo/issues/42
custom://my-data-source/collection/item
```

Servers define which URI templates they support. Clients can list available resources and read specific URIs.

### Error Handling

MCP uses standard JSON-RPC error codes plus MCP-specific extensions:

| Code | Meaning |
|---|---|
| -32700 | Parse error (malformed JSON) |
| -32600 | Invalid request |
| -32601 | Method not found |
| -32602 | Invalid params |
| -32603 | Internal error |
| -32000 to -32099 | Server-defined errors |

Tool calls can also return `isError: true` in the result to indicate application-level errors (the tool executed but the operation failed).

---

## SDK Landscape

### Official SDKs

| SDK | Language | Package | Version | Maintainer |
|---|---|---|---|---|
| TypeScript SDK | TypeScript/JavaScript | `@modelcontextprotocol/sdk` | v1.29.0 | Anthropic |
| Python SDK | Python | `modelcontextprotocol` | v1.26.0 | Anthropic |

### High-Level Wrappers

| SDK | Language | Package | Version | Maintainer | Key Feature |
|---|---|---|---|---|---|
| FastMCP | Python | `fastmcp` | v3.2.4 | Prefect/PrefectHQ | Decorator-based API, tool versioning, MultiAuth, Prefab UI |

### Community SDKs

| Language | Package | Notes |
|---|---|---|
| Go | `github.com/mark3labs/mcp-go` | Mature, widely used |
| Rust | `rust-mcp-sdk` | Active development |
| Java/Kotlin | `io.modelcontextprotocol:kotlin-sdk` | JVM ecosystem |
| C# / .NET | `ModelContextProtocol` | .NET ecosystem |
| Ruby | `mcp-rb` | Early stage |
| Swift | `swift-mcp` | Apple ecosystem |

### SDK Selection Guide

| Criterion | TypeScript SDK | FastMCP (Python) | Raw Python SDK |
|---|---|---|---|
| **Ecosystem size** | Largest (most examples, servers) | Growing rapidly | Moderate |
| **API ergonomics** | Good (McpServer class) | Excellent (decorators) | Lower-level |
| **Tool versioning** | Manual | Built-in `@tool(version="1.0")` | Manual |
| **Auth** | Manual middleware | Built-in MultiAuth | Manual |
| **Type safety** | Zod schemas | Python type hints + Pydantic | Pydantic |
| **Deployment** | Node.js runtime | Python runtime | Python runtime |
| **Best for** | Production servers, npm distribution | Rapid development, Python shops | Maximum control |

---

## Transport Protocols

### Overview

| Transport | Direction | Use Case | Status |
|---|---|---|---|
| **stdio** | Bidirectional (stdin/stdout) | Local tools, IDE extensions | Stable, recommended for local |
| **Streamable HTTP** | HTTP POST + optional SSE | Remote services, multi-client | Stable, recommended for remote |
| **SSE** | HTTP GET (SSE) + HTTP POST | Remote services | **Deprecated mid-2026**, migrate to Streamable HTTP |

### stdio

The client spawns the server as a subprocess. Messages flow over stdin (client to server) and stdout (server to client). Stderr is available for logging.

```
Client Process
  |
  +--> stdin  --> Server Process
  <-- stdout <--+
       stderr --> (logs)
```

**Advantages:** Zero network configuration, works offline, simple security model (process isolation).
**Limitations:** Single client per server instance, no network access from other machines, requires local installation.

### Streamable HTTP

A single HTTP endpoint handles all communication. The client sends JSON-RPC requests via POST. The server can respond with:
- A single JSON-RPC response (request-response pattern)
- An SSE stream for long-running operations or server-initiated messages

Session management uses the `Mcp-Session-Id` header. The server assigns a session ID on `initialize` and the client includes it in subsequent requests.

```
Client                          Server
  |                               |
  |-- POST /mcp (initialize) ---->|
  |<-- 200 + Mcp-Session-Id ------|
  |                               |
  |-- POST /mcp (tools/call) ---->|
  |<-- 200 (JSON response) -------|
  |                               |
  |-- POST /mcp (long op) ------->|
  |<-- 200 (SSE stream) ----------|
  |<-- event: message             |
  |<-- event: message             |
  |<-- event: done                |
```

**Advantages:** Network-accessible, supports multiple clients, standard HTTP infrastructure (load balancers, auth proxies, monitoring).
**Limitations:** Requires HTTP server setup, session state management, CORS configuration for browser clients.

### SSE (Deprecated)

The legacy remote transport used two separate channels: an SSE connection (GET) for server-to-client messages and a POST endpoint for client-to-server messages. This has been superseded by Streamable HTTP, which unifies both directions on a single endpoint.

**Migration deadline:** Mid-2026. All new servers should use Streamable HTTP.

> For detailed transport comparison and selection guidance, see [transport-guide.md](transport-guide.md).

---

## Client Ecosystem

### Major MCP Clients

| Client | Type | Transport Support | Notes |
|---|---|---|---|
| **Claude Desktop** | Desktop app | stdio, Streamable HTTP | Primary reference client; best MCP support |
| **Claude Code** | CLI agent | stdio, Streamable HTTP | Full MCP integration via settings |
| **VS Code (Copilot)** | IDE extension | stdio | MCP support via GitHub Copilot |
| **Cursor** | IDE | stdio, HTTP | Popular AI IDE with MCP support |
| **Continue** | IDE extension | stdio | Open-source IDE extension |
| **Cline** | IDE extension | stdio | VS Code extension |
| **Windsurf** | IDE | stdio | Codeium's AI IDE |
| **Custom clients** | Any | Any | Build with official SDKs |

### Client Configuration

Most clients use a JSON configuration file to specify servers:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["path/to/server.js"],
      "env": {
        "API_KEY": "..."
      }
    },
    "remote-server": {
      "url": "https://mcp.example.com/sse",
      "headers": {
        "Authorization": "Bearer ..."
      }
    }
  }
}
```

The exact location and format varies by client:
- Claude Desktop: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)
- Claude Code: `.claude/settings.json` or `~/.claude/settings.json`
- VS Code: `settings.json` under `github.copilot.chat.mcp`
- Cursor: `.cursor/mcp.json`

> For full discovery mechanism details, see [discovery-mechanisms.md](discovery-mechanisms.md).

---

## Server Registry Status

### Official MCP Servers

Anthropic maintains a curated list of reference servers:
- GitHub: `github.com/modelcontextprotocol/servers`
- Categories: filesystem, GitHub, GitLab, Google Drive, Slack, PostgreSQL, Puppeteer, and more
- These serve as implementation references and are widely tested

### Community Registries

| Registry | URL | Model |
|---|---|---|
| **Smithery** | smithery.ai | Curated catalog with install commands |
| **mcp.run** | mcp.run | WebAssembly-sandboxed server hosting |
| **MCP Hub** | mcphub.io | Community-contributed directory |
| **Glama** | glama.ai/mcp/servers | Aggregated directory with search |

### Registry Gaps

As of May 2026, no universal registry standard exists. Each registry uses its own metadata format and installation mechanism. The MCP specification does not yet define a standard server manifest format, though proposals are under discussion.

---

## MCP Specification Evolution

| Date | Version / Event | Key Changes |
|---|---|---|
| Nov 2024 | Initial public release | Core protocol: tools, resources, prompts over stdio |
| Dec 2024 | SSE transport added | Remote server support via Server-Sent Events |
| Mar 2025 | 2025-03-26 spec | Streamable HTTP transport, SSE deprecation notice, improved capability negotiation |
| Mid 2025 | SDK maturation | TypeScript SDK reaches v1.x stability, FastMCP v3.x |
| Late 2025 | Client proliferation | VS Code, Cursor, Continue, Windsurf add MCP support |
| Early 2026 | Ecosystem consolidation | Registry efforts, community SDK maturation |
| Mid 2026 | SSE deprecation effective | Clients dropping SSE support, Streamable HTTP standard |

### Anticipated Developments

These are informed expectations, not confirmed features:

- TypeScript SDK v2 (anticipated, major API refinements)
- Standard server manifest format for registries
- Dynamic discovery via DNS-SD or well-known URIs
- Improved multi-server orchestration protocols
- Binary content support improvements
- Server-to-server communication patterns

---

## Common Server Patterns

### Tool-Only Server

The simplest pattern. Server exposes tools, nothing else.

**Use when:** You want an LLM to be able to call functions (API wrappers, calculations, system commands).

```
Server: "github-issues"
Tools:
  - search_issues(query, state, limit)
  - create_issue(title, body, labels)
  - update_issue(number, state, body)
  - add_comment(number, body)
```

### Resource Server

Server exposes readable data, optionally with subscriptions for changes.

**Use when:** You want an LLM to have read access to structured data without executing actions.

```
Server: "docs-browser"
Resources:
  - docs://api/endpoints      (list of API endpoints)
  - docs://api/endpoints/{id} (specific endpoint documentation)
  - docs://changelog           (recent changes)
Subscriptions:
  - docs://changelog (notify client when new entries appear)
```

### Prompt Template Server

Server provides reusable prompt templates with parameterization.

**Use when:** You want to standardize how users interact with specific domains through the LLM.

```
Server: "code-review"
Prompts:
  - review_pr(repo, pr_number, focus_areas)
  - explain_code(file_path, language, depth)
  - suggest_tests(file_path, framework)
```

### Composite Server

Server combines tools, resources, and prompts into a cohesive domain experience.

**Use when:** You are building a comprehensive integration for a specific domain.

```
Server: "project-manager"
Tools:
  - create_task(title, assignee, priority)
  - update_status(task_id, status)
  - assign_task(task_id, user)
Resources:
  - pm://projects           (list all projects)
  - pm://projects/{id}/tasks (tasks for a project)
  - pm://users/{id}/workload (user's current load)
Prompts:
  - sprint_planning(project_id, capacity_hours)
  - standup_summary(project_id, date)
```

### Gateway / Aggregator Server

Server wraps multiple APIs behind a unified MCP interface.

**Use when:** You want to present a single coherent tool set that internally routes to multiple backends.

```
Server: "cloud-ops"
Tools:
  - deploy(service, version, environment)    -> routes to CI/CD API
  - get_metrics(service, timerange)          -> routes to Prometheus
  - get_logs(service, timerange, level)      -> routes to Loki
  - create_alert(service, condition, channel) -> routes to PagerDuty
```

> This pattern is related to but distinct from Phase 3 Virtual MCP. A gateway server is a real deployed server with code; a Virtual MCP is an agent-composed interface without a dedicated server process. See [virtual-mcp-architecture.md](virtual-mcp-architecture.md).

---

## Protocol Limitations and Boundaries

Understanding what MCP does not do is as important as what it does:

| MCP Does | MCP Does Not |
|---|---|
| Client-initiated tool calls | Server-initiated calls to the model |
| Text and structured data responses | Binary streaming (images are base64-encoded) |
| Stateless tool execution | Long-running background jobs (no built-in job tracking) |
| Single-hop client-server | Server-to-server federation |
| Schema-validated inputs | Runtime output validation (server responsibility) |
| Tool discovery via `tools/list` | Automatic tool composition or chaining |

When user requirements hit these boundaries, consider whether MCP is the right protocol or whether a direct API, WebSocket, or gRPC service would be more appropriate.

> For security implications of these boundaries, see [security-checklist.md](security-checklist.md).
