# Transport Protocol Guide

Comparison and selection guidance for MCP transport protocols.

> For SDK-specific transport configuration, see [sdk-reference-nodejs.md](sdk-reference-nodejs.md) or [sdk-reference-python.md](sdk-reference-python.md).

---

## Transport Overview

MCP separates the application protocol (JSON-RPC 2.0) from the transport layer. Three transports exist:

| Transport | Status | Direction | Session Model |
|---|---|---|---|
| **stdio** | Stable | Bidirectional (stdin/stdout) | 1:1 (one client per process) |
| **Streamable HTTP** | Stable (2025-03-26 spec) | HTTP POST + optional SSE | N:1 (multiple clients per server, session-based) |
| **SSE** | **Deprecated** (mid-2026) | HTTP GET (SSE) + HTTP POST | N:1 |

---

## stdio

### When to Use

- Local developer tools (filesystem, git, database access)
- IDE extensions (VS Code, Cursor, Cline)
- Desktop application integrations (Claude Desktop)
- Prototyping and testing (Phase 1 builds)
- Tools that access local machine resources (files, processes, environment)

### How It Works

The client spawns the MCP server as a child process. Communication flows over stdin (client-to-server) and stdout (server-to-client). Each message is a complete JSON-RPC object terminated by a newline.

```
[Client Process]
    |
    |-- spawn --> [Server Process]
    |                |
    |-- stdin ------>|   (JSON-RPC requests)
    |<-- stdout -----|   (JSON-RPC responses)
    |    stderr ---->|   (logging, not protocol)
```

### Configuration Example (Claude Desktop)

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "node",
      "args": ["/path/to/filesystem-server/dist/index.js"],
      "env": {
        "HOME": "/Users/me"
      }
    }
  }
}
```

### Limitations

| Limitation | Impact | Workaround |
|---|---|---|
| Single client per server instance | Cannot share a server across applications | Each client spawns its own instance |
| No network access | Server must run on same machine as client | Use Streamable HTTP for remote |
| Process lifecycle tied to client | Server dies when client exits | Stateless design, persist externally |
| No built-in auth | Anyone who can spawn the process has full access | OS-level permissions, process isolation |
| Platform differences | stdin/stdout handling varies (Windows vs Unix) | SDKs abstract this, but edge cases exist |

### Performance Characteristics

| Metric | Typical Value |
|---|---|
| Latency (per call) | < 1ms (IPC overhead only) |
| Throughput | Limited by JSON serialization, typically > 1000 calls/sec |
| Memory | Server process memory (typically 30-100MB for Node.js, 20-50MB for Python) |
| Startup time | 100ms-2s depending on runtime and dependencies |

### Security Profile

- **Attack surface:** Minimal. Only the spawning client can communicate.
- **Auth:** None needed (process isolation provides access control).
- **Secrets:** Server inherits client's environment. Use `env` block in config to pass specific variables.
- **Risks:** Server has same OS permissions as client. A malicious server could access any file the user can.

---

## Streamable HTTP

### When to Use

- Remote services accessible over the network
- Multi-client servers (shared team tools, public APIs)
- Microservice architectures
- Cloud-deployed MCP servers
- Servers that need to outlive any single client session
- Production deployments with monitoring, logging, and scaling requirements

### How It Works

A single HTTP endpoint (e.g., `/mcp`) handles all MCP traffic. The protocol uses POST requests for client-to-server communication. The server can respond in two ways:

1. **Immediate response:** Standard HTTP JSON response for request-response patterns
2. **SSE stream:** For long-running operations or server-initiated notifications

Session management uses the `Mcp-Session-Id` header:

```
1. Client sends POST without session ID (initialize request)
2. Server assigns session ID, returns in Mcp-Session-Id header
3. Client includes Mcp-Session-Id in all subsequent requests
4. Server tracks state per session
```

### Request Flow

```
Client                              Server (/mcp)
  |                                    |
  |-- POST (no session) -------------->|
  |   { "method": "initialize" }       |
  |<-- 200 + Mcp-Session-Id: abc ------| 
  |   { "result": { capabilities } }   |
  |                                    |
  |-- POST (Mcp-Session-Id: abc) ----->|
  |   { "method": "tools/list" }       |
  |<-- 200 ----------------------------|
  |   { "result": { tools: [...] } }   |
  |                                    |
  |-- POST (Mcp-Session-Id: abc) ----->|
  |   { "method": "tools/call" }       |
  |<-- 200 (SSE stream) ---------------|
  |   event: message                   |
  |   data: { progress: 50% }         |
  |   event: message                   |
  |   data: { "result": ... }         |
```

### Configuration Example (Claude Desktop)

```json
{
  "mcpServers": {
    "remote-tools": {
      "url": "https://mcp.example.com/mcp",
      "headers": {
        "Authorization": "Bearer my-token"
      }
    }
  }
}
```

### Limitations

| Limitation | Impact | Workaround |
|---|---|---|
| Requires HTTP infrastructure | More complex setup than stdio | Use frameworks (Express, FastAPI) |
| Session state management | Server must track sessions | Use session store (Redis, in-memory map) |
| Network latency | Higher per-call latency than stdio | Batch operations, local caching |
| CORS required for browser clients | Extra configuration | Configure CORS middleware |
| Firewall/NAT traversal | May need tunneling for dev | Use ngrok, Cloudflare Tunnel |

### Performance Characteristics

| Metric | Typical Value |
|---|---|
| Latency (per call, local) | 1-5ms |
| Latency (per call, remote) | 10-200ms (network dependent) |
| Throughput | Limited by HTTP server capacity, typically 100-10,000 calls/sec |
| Memory per session | 1-10KB baseline + tool state |
| Concurrent sessions | Depends on server; 100-10,000+ typical |

### Security Profile

- **Attack surface:** Network-exposed. Requires authentication, rate limiting, input validation.
- **Auth:** Use Bearer tokens, API keys, or mTLS. FastMCP provides MultiAuth; TypeScript SDK requires manual middleware.
- **Secrets:** Never expose in URL or query params. Use headers or POST body.
- **CORS:** Required if any browser-based client will connect.
- **TLS:** Mandatory for production. Never run MCP over plain HTTP on a network.
- **Rate limiting:** Per-session and per-tool rate limits recommended.
- **Risks:** SSRF if tools make outbound requests based on user input. Prompt injection via tool results. Session hijacking if session IDs are predictable.

> For the full security checklist, see [security-checklist.md](security-checklist.md).

---

## SSE (Deprecated)

### Migration Deadline

SSE transport is deprecated as of the 2025-03-26 specification. Clients are expected to drop SSE support by mid-2026. **Do not build new servers with SSE transport.**

### How It Differed

SSE used two separate channels:
- **GET /sse** -- Server-to-client messages via Server-Sent Events
- **POST /messages** -- Client-to-server messages via HTTP POST

This two-channel design created complexity around:
- Correlating requests and responses across channels
- Managing connection lifecycle
- Handling reconnection

### Migration Path

| SSE Pattern | Streamable HTTP Equivalent |
|---|---|
| GET /sse (event stream) | POST /mcp with SSE response when streaming needed |
| POST /messages (client requests) | POST /mcp (same endpoint handles all requests) |
| Endpoint URL in SSE welcome event | Session ID in Mcp-Session-Id header |
| Automatic reconnection via EventSource | Client re-sends POST with session ID |

### Migration Steps

1. Replace SSE endpoint with single POST endpoint
2. Move from EventSource-based client to fetch/POST-based client
3. Implement session ID tracking via Mcp-Session-Id header
4. Update client configuration from `url` (SSE endpoint) to `url` (Streamable HTTP endpoint)
5. Test with Claude Desktop (supports both during transition)

---

## Decision Matrix

| Use Case | Recommended Transport | Rationale |
|---|---|---|
| Local dev tool (filesystem, git) | stdio | No network needed, simplest setup |
| IDE extension | stdio | Client manages process lifecycle |
| Claude Desktop plugin (local) | stdio | Standard for local tools |
| Team-shared tool server | Streamable HTTP | Multiple clients, persistent |
| Public API wrapper | Streamable HTTP | Network access, auth, scaling |
| Cloud-deployed service | Streamable HTTP | Standard HTTP infrastructure |
| Prototype / POC | stdio | Fastest to build, no infra needed |
| Embedded in web app | Streamable HTTP | Browser clients need HTTP |
| IoT / edge device | stdio (if local) or Streamable HTTP (if remote) | Depends on network topology |
| Existing SSE server | Migrate to Streamable HTTP | SSE deprecated mid-2026 |

---

## Dual Transport Pattern

For maximum flexibility, support both transports in a single codebase:

### TypeScript

```typescript
const transport = process.env.MCP_TRANSPORT === "http" ? "http" : "stdio";

if (transport === "stdio") {
  const t = new StdioServerTransport();
  await server.connect(t);
} else {
  // Set up Express + StreamableHTTPServerTransport
  // (see sdk-reference-nodejs.md for full example)
}
```

### Python (FastMCP)

```python
transport = os.environ.get("MCP_TRANSPORT", "stdio")

if transport == "http":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=3000)
else:
    mcp.run()  # stdio is default
```

This pattern lets you develop locally with stdio and deploy remotely with HTTP using the same server code.
