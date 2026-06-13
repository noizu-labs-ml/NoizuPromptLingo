# Worked Example: GitHub Status MCP Server

End-to-end walkthrough building a GitHub Status MCP server from prototype to production.

> This example uses the GitHub Status API (https://www.githubstatus.com/api/v2), which is public, requires no authentication, and has stable endpoints -- ideal for a learning exercise.

---

## Phase 1: Quick Prototype

**Goal:** Working stdio server with 3 tools, tested in Claude Desktop, in under 2 hours.

### Step 1: Fill Out the Brief

Using `assets/mcp-server-brief-worksheet.md`:

| Field | Value |
|---|---|
| Problem Statement | LLM agents need to check GitHub service health during debugging workflows |
| Target Consumers | Claude Desktop, Claude Code |
| Proposed Tools | `get_status`, `get_incidents`, `get_component_status` |
| Data Sources | GitHub Status API v2 (public, no auth) |
| Deployment Target | Local (stdio) initially, Docker (HTTP) later |
| Auth Requirements | None (public API) |
| Timeline | Phase 1 today, Phase 2 this week |

### Step 2: Choose SDK and Transport

| Decision | Choice | Rationale |
|---|---|---|
| Language | TypeScript | Larger MCP ecosystem, more examples to reference |
| SDK | `@modelcontextprotocol/sdk` v1.29.0 | Official, well-tested |
| Transport | stdio | Phase 1 prototype, testing with Claude Desktop |

### Step 3: Scaffold the Prototype

```bash
mkdir github-status-mcp && cd github-status-mcp
npm init -y
npm install @modelcontextprotocol/sdk zod
npm install -D tsx typescript @types/node
```

### Step 4: Implement (Minimal)

```typescript
#!/usr/bin/env node
// src/server.ts

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const API_BASE = "https://www.githubstatus.com/api/v2";

const server = new McpServer({
  name: "github-status",
  version: "0.1.0",  // Prototype version
});

server.tool(
  "get_status",
  "Get current GitHub system status summary",
  {},
  async () => {
    const res = await fetch(`${API_BASE}/status.json`);
    const data = await res.json();
    return { content: [{ type: "text", text: JSON.stringify(data, null, 2) }] };
  }
);

server.tool(
  "get_incidents",
  "Get recent GitHub incidents",
  { limit: z.number().int().min(1).max(50).default(5) },
  async ({ limit }) => {
    const res = await fetch(`${API_BASE}/incidents.json`);
    const data = await res.json();
    const incidents = data.incidents.slice(0, limit);
    return { content: [{ type: "text", text: JSON.stringify(incidents, null, 2) }] };
  }
);

server.tool(
  "get_component_status",
  "Get status of a specific GitHub component",
  { component_name: z.string().describe("Component name, e.g. 'Git Operations'") },
  async ({ component_name }) => {
    const res = await fetch(`${API_BASE}/components.json`);
    const data = await res.json();
    const match = data.components.find(
      (c: any) => c.name.toLowerCase() === component_name.toLowerCase()
    );
    if (!match) {
      const available = data.components.map((c: any) => c.name).join(", ");
      return {
        content: [{ type: "text", text: `Not found. Available: ${available}` }],
        isError: true,
      };
    }
    return { content: [{ type: "text", text: JSON.stringify(match, null, 2) }] };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Step 5: Test with Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "github-status": {
      "command": "npx",
      "args": ["tsx", "/Users/you/github-status-mcp/src/server.ts"]
    }
  }
}
```

Restart Claude Desktop. Test each tool:

1. "What's the current GitHub status?" -- should invoke `get_status`
2. "Show me the last 3 GitHub incidents" -- should invoke `get_incidents` with limit=3
3. "What's the status of Git Operations?" -- should invoke `get_component_status`
4. "What's the status of NonexistentService?" -- should return error with available components

### Step 6: Evaluate Prototype

**Questions to answer:**

- Do the tool names feel natural when the model uses them? **Yes** -- the model picked the right tools.
- Are the response formats useful? **Partially** -- raw JSON is verbose, could be summarized.
- Missing tools? **Maybe** -- `get_scheduled_maintenances` could be useful.
- Tool too broad? **No** -- each has a clear, single purpose.

**Decision:** Interface is good. Add response formatting in Phase 2. Proceed to production.

---

## Phase 2: Production

**Goal:** Hardened server with Streamable HTTP transport, Docker image, tests, monitoring.

### Step 1: Apply the Architect Checklist

> See **trl-mcp-architect** (`references/specification-checklist.md`) for the full checklist.

Key specification decisions:

**Tool Specifications:**

| Tool | Inputs | Output Format | Error Cases |
|---|---|---|---|
| `get_status` | (none) | `{ indicator, description, updated_at }` | API unreachable, rate limited |
| `get_incidents` | `limit: int (1-50, default 5)` | Array of `{ name, status, impact, created_at, updated_at }` | API unreachable, invalid limit |
| `get_component_status` | `component_name: string` | `{ name, status, description, updated_at }` | Component not found (list available), API unreachable |

**Error Taxonomy:**

| Error | Tool Result | HTTP Status |
|---|---|---|
| Component not found | `isError: true` with available list | 200 (application error) |
| API unreachable | `isError: true` with message | 200 (application error) |
| Invalid parameters | Protocol error (SDK handles) | 200 (JSON-RPC error) |

**Transport:** Streamable HTTP on port 3000, `/mcp` endpoint.

**Auth:** None for Phase 2 (public API, no sensitive data). Would add Bearer token if deploying for a team.

**Resources:** Add `github-status://components` resource for component list.

### Step 2: Apply the Security Checklist

Using `references/security-checklist.md`:

| Category | Status | Notes |
|---|---|---|
| Input validation | PASS | Zod schemas enforce all constraints |
| Secrets management | N/A | No secrets (public API) |
| Authentication | DEFERRED | No sensitive data; add if deploying for a team |
| Rate limiting | PASS | Add per-session rate limit (30 req/min) |
| Audit logging | PASS | Structured JSON logging to stderr |
| CORS | PASS | Configured for HTTP transport |
| Supply chain | PASS | Lockfile committed, `npm audit` clean |
| Prompt injection | LOW RISK | GitHub Status API returns structured data, not user-generated content |
| SSRF | N/A | No user-supplied URLs |
| Path traversal | N/A | No file operations |

### Step 3: Production Implementation

The full production server is in `references/sdk-reference-nodejs.md` under "Complete Production Server Example." Key additions over the prototype:

1. **Structured logging** -- JSON format to stderr with levels
2. **HTTP client management** -- Connection pooling, timeouts
3. **Dual transport** -- stdio and Streamable HTTP via environment variable
4. **Health endpoint** -- `GET /health` for monitoring
5. **Error handling** -- `isError: true` for all failure cases, no leaked stack traces
6. **Response formatting** -- Condensed output instead of raw API JSON
7. **Rate limiting** -- 30 requests per minute per session

### Step 4: Testing

```typescript
// test/tools.test.ts
import { describe, it, expect, vi } from "vitest";

describe("get_status", () => {
  it("returns status summary on success", async () => {
    // Mock fetch to return known status
    vi.spyOn(global, "fetch").mockResolvedValueOnce(
      new Response(JSON.stringify({
        status: { indicator: "none", description: "All Systems Operational" }
      }))
    );

    const result = await invokeGetStatus();
    expect(result.content[0].text).toContain("All Systems Operational");
    expect(result.isError).toBeUndefined();
  });

  it("returns error on API failure", async () => {
    vi.spyOn(global, "fetch").mockRejectedValueOnce(new Error("Network error"));

    const result = await invokeGetStatus();
    expect(result.isError).toBe(true);
    expect(result.content[0].text).toContain("Failed to fetch");
  });
});

describe("get_component_status", () => {
  it("returns matching component", async () => {
    vi.spyOn(global, "fetch").mockResolvedValueOnce(
      new Response(JSON.stringify({
        components: [
          { name: "Git Operations", status: "operational" },
          { name: "API Requests", status: "operational" },
        ]
      }))
    );

    const result = await invokeGetComponentStatus("Git Operations");
    expect(result.content[0].text).toContain("Git Operations");
  });

  it("returns error with available list for unknown component", async () => {
    vi.spyOn(global, "fetch").mockResolvedValueOnce(
      new Response(JSON.stringify({
        components: [
          { name: "Git Operations", status: "operational" },
        ]
      }))
    );

    const result = await invokeGetComponentStatus("Nonexistent");
    expect(result.isError).toBe(true);
    expect(result.content[0].text).toContain("Git Operations");
  });
});
```

### Step 5: Containerize

```dockerfile
FROM node:22-slim AS build
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY tsconfig.json .
COPY src/ src/
RUN npx tsc

FROM node:22-slim
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json .

ENV MCP_TRANSPORT=http
ENV MCP_PORT=3000
ENV LOG_LEVEL=info

EXPOSE 3000

USER node
CMD ["node", "dist/server.js"]
```

```bash
docker build -t github-status-mcp .
docker run -p 3000:3000 github-status-mcp
```

### Step 6: Deploy and Verify

1. Deploy Docker image to your target (Docker Compose, Kubernetes, cloud)
2. Verify health endpoint: `curl http://localhost:3000/health`
3. Test with Claude Desktop using HTTP transport:

```json
{
  "mcpServers": {
    "github-status": {
      "url": "http://localhost:3000/mcp"
    }
  }
}
```

4. Run all three tools through Claude Desktop
5. Check logs for structured output
6. Verify rate limiting by calling tools rapidly

### Final Project Structure

```
github-status-mcp/
  src/
    server.ts          # Main server with tools
  test/
    tools.test.ts      # Tool unit tests
  Dockerfile
  docker-compose.yml   # Optional
  package.json
  package-lock.json
  tsconfig.json
  README.md            # Setup instructions for each client
```

---

## Phase Transition Summary

| Aspect | Phase 1 | Phase 2 |
|---|---|---|
| Transport | stdio | Streamable HTTP + stdio |
| Error handling | Basic try/catch | Structured with `isError`, no leaks |
| Logging | `console.log` | Structured JSON to stderr |
| Testing | Manual via Claude Desktop | Automated (vitest) + manual |
| Packaging | Source only | Docker image |
| Configuration | Hardcoded | Environment variables |
| Auth | None | None (public API), ready to add |
| Monitoring | None | Health endpoint + structured logs |
| Time invested | ~90 minutes | ~6 hours |
