# MCP Discovery Mechanisms

How MCP clients discover, configure, and connect to servers.

> For transport configuration details, see [transport-guide.md](transport-guide.md). For client-specific setup, see [mcp-ecosystem-overview.md](mcp-ecosystem-overview.md).

---

## Discovery Overview

MCP currently relies primarily on manual configuration. Automated discovery is emerging but not standardized. The landscape:

| Mechanism | Status | Scope |
|---|---|---|
| Manual configuration files | Stable, universal | Per-client |
| Registry catalogs (Smithery, mcp.run) | Active, growing | Cross-client |
| Dynamic discovery (DNS-SD, well-known) | Proposals / drafts | Future |
| Capability advertisement | Built into protocol | Per-connection |

---

## 1. Manual Configuration

The dominant discovery mechanism today. Each client reads a JSON configuration file that lists MCP servers.

### Claude Desktop

**File location:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- Linux: `~/.config/claude/claude_desktop_config.json`

**Format:**

```json
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["path/to/server.js"],
      "env": {
        "API_KEY": "sk-..."
      }
    }
  }
}
```

**Fields for stdio:**

| Field | Required | Description |
|---|---|---|
| `command` | Yes | Executable to run |
| `args` | No | Arguments array |
| `env` | No | Environment variables (merged with system env) |
| `cwd` | No | Working directory for the process |

**Fields for HTTP:**

| Field | Required | Description |
|---|---|---|
| `url` | Yes | Server endpoint URL |
| `headers` | No | HTTP headers (e.g., Authorization) |

### Claude Code

**File locations (in precedence order):**
1. `.claude/settings.json` (project-level)
2. `~/.claude/settings.json` (user-level)

**Format:**

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["/path/to/server.py"],
      "env": {
        "API_TOKEN": "..."
      }
    }
  }
}
```

### VS Code (GitHub Copilot)

**File:** VS Code `settings.json` (workspace or user level)

```json
{
  "github.copilot.chat.mcp.servers": {
    "my-server": {
      "command": "node",
      "args": ["server.js"]
    }
  }
}
```

### Cursor

**File:** `.cursor/mcp.json` in project root

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"]
    }
  }
}
```

### Continue

**File:** `~/.continue/config.json`

```json
{
  "experimental": {
    "mcpServers": {
      "my-server": {
        "command": "python",
        "args": ["server.py"]
      }
    }
  }
}
```

### Configuration Portability

There is no universal configuration format. Each client uses its own schema and file location. To distribute an MCP server, you must provide setup instructions for each target client.

**Pattern for README.md:**

```markdown
## Setup

### Claude Desktop
Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:
\```json
{ "mcpServers": { "my-server": { ... } } }
\```

### Cursor
Add to `.cursor/mcp.json`:
\```json
{ "mcpServers": { "my-server": { ... } } }
\```
```

---

## 2. Registry Patterns

Registries provide searchable catalogs of MCP servers with installation instructions.

### Smithery (smithery.ai)

- Curated catalog of MCP servers
- Each listing includes: description, tools list, installation commands per client
- One-click install for supported clients
- Quality review process for listed servers

**Listing a server:**
1. Publish your server to npm or as a Docker image
2. Submit to Smithery with a server manifest
3. Smithery generates client-specific install instructions

### mcp.run

- WebAssembly-sandboxed MCP server hosting
- Servers run in isolated WASM containers on mcp.run's infrastructure
- Users connect via Streamable HTTP
- No local installation required

**Publishing to mcp.run:**
1. Compile your server to WebAssembly (WASI target)
2. Upload to mcp.run
3. Users get a unique URL to add to their client config

### MCP Hub (mcphub.io)

- Community-contributed directory
- Less curated than Smithery
- Aggregates servers from GitHub, npm, PyPI

### Glama (glama.ai/mcp/servers)

- Aggregated directory with search and categorization
- Pulls from multiple sources
- Provides standardized metadata

### Registry Metadata

There is no standard MCP server manifest format yet. Registries typically extract metadata from:

- `package.json` (npm packages)
- `pyproject.toml` (Python packages)
- README.md (descriptions, tool lists)
- Source code analysis (tool definitions)

A proposed standard manifest might look like:

```json
{
  "mcpVersion": "2025-03-26",
  "name": "github-status",
  "version": "1.0.0",
  "description": "GitHub Status API integration",
  "transport": ["stdio", "streamable-http"],
  "tools": [
    {
      "name": "get_status",
      "description": "Get current GitHub system status"
    }
  ],
  "install": {
    "npm": "npx github-status-mcp",
    "docker": "docker run -p 3000:3000 github-status-mcp"
  }
}
```

---

## 3. Dynamic Discovery (Proposals)

These mechanisms are under discussion or in draft stages. They are not yet part of the stable specification.

### DNS-SD (DNS Service Discovery)

**Concept:** Servers register themselves via mDNS/DNS-SD on the local network. Clients discover available servers automatically.

```
_mcp._tcp.local.  ->  my-mcp-server.local:3000
```

**Status:** Proposed. Useful for local network scenarios (home lab, office LAN). Not applicable to internet-scale discovery.

### Well-Known URIs

**Concept:** Organizations publish their MCP servers at a well-known URL:

```
https://example.com/.well-known/mcp-servers.json
```

Response:
```json
{
  "servers": [
    {
      "name": "company-tools",
      "url": "https://mcp.example.com/tools",
      "description": "Internal company tools",
      "tools": ["search_docs", "create_ticket", "get_calendar"]
    }
  ]
}
```

**Status:** Draft proposal. Would enable organizational discovery (an IT department publishes available servers, and employee clients auto-discover them).

### HTTP Link Headers

**Concept:** HTTP responses include `Link` headers pointing to MCP server endpoints:

```
Link: <https://mcp.example.com/tools>; rel="mcp-server"; title="Company Tools"
```

**Status:** Conceptual. Would enable website-level discovery (visit a website, and your AI assistant discovers available MCP tools).

---

## 4. Capability Advertisement

Once a client connects to a server (via any discovery method), the server advertises its capabilities through the MCP protocol itself.

### Initialize Handshake

```json
// Client -> Server
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-03-26",
    "capabilities": {
      "roots": { "listChanged": true }
    },
    "clientInfo": {
      "name": "claude-desktop",
      "version": "1.0.0"
    }
  }
}

// Server -> Client
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2025-03-26",
    "capabilities": {
      "tools": { "listChanged": true },
      "resources": { "subscribe": true, "listChanged": true },
      "prompts": { "listChanged": true }
    },
    "serverInfo": {
      "name": "github-status",
      "version": "1.0.0"
    }
  }
}
```

### Tool Discovery

After initialization, the client discovers available tools:

```json
// Client -> Server
{ "jsonrpc": "2.0", "id": 2, "method": "tools/list" }

// Server -> Client
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "tools": [
      {
        "name": "get_status",
        "description": "Get current GitHub system status",
        "inputSchema": { "type": "object", "properties": {} }
      }
    ]
  }
}
```

### Dynamic Updates

If the server's capabilities change at runtime (tools added/removed), it sends a notification:

```json
{ "jsonrpc": "2.0", "method": "notifications/tools/list_changed" }
```

The client then re-fetches the tool list. This enables dynamic tool registration -- servers that add or remove tools based on context.

---

## 5. Multi-Server Orchestration

Clients typically connect to multiple MCP servers simultaneously.

### Client-Side Management

```json
{
  "mcpServers": {
    "filesystem": { "command": "node", "args": ["fs-server.js"] },
    "github": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-github"] },
    "database": { "command": "python", "args": ["db-server.py"] }
  }
}
```

The client:
1. Spawns/connects to each server independently
2. Collects tool lists from all servers
3. Presents a unified tool set to the model
4. Routes tool calls to the correct server based on tool name

### Tool Name Conflicts

If multiple servers register tools with the same name, behavior is client-dependent:

| Client | Behavior |
|---|---|
| Claude Desktop | Last server wins (overwrite) |
| Most clients | Undefined / varies |

**Best practice:** Use namespaced tool names to avoid conflicts:
- `github_search_issues` instead of `search_issues`
- `slack_send_message` instead of `send_message`

### Connection Lifecycle

Clients manage server connections independently:
- Servers can be connected/disconnected at runtime (some clients support this)
- A failing server does not affect other servers
- Clients may retry failed connections with backoff
- Session state is per-server, not shared across servers

### Server Composition vs. Multi-Server

Two approaches to providing multiple capabilities:

| Approach | Pros | Cons |
|---|---|---|
| Multiple independent servers | Separation of concerns, independent deployment, mix languages | More config, tool name conflicts, no shared state |
| Single composite server | Unified namespace, shared state, single config entry | Monolithic, single language, single failure domain |

> For composing multiple servers into a unified interface without building a new server, see [virtual-mcp-architecture.md](virtual-mcp-architecture.md) (Phase 3).
