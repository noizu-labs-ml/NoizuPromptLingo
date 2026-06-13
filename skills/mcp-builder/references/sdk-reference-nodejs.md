# TypeScript SDK Reference

Version-pinned reference for `@modelcontextprotocol/sdk` v1.29.0.

> For Python/FastMCP, see [sdk-reference-python.md](sdk-reference-python.md). For transport selection guidance, see [transport-guide.md](transport-guide.md).

---

## Installation

```bash
npm install @modelcontextprotocol/sdk
# or
yarn add @modelcontextprotocol/sdk
# or
pnpm add @modelcontextprotocol/sdk
```

**Peer dependencies:** `zod` (for schema definition)

```bash
npm install zod
```

**Recommended tsconfig settings:**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "./dist"
  }
}
```

---

## API Levels

The SDK provides two API levels:

| Level | Class | Use Case |
|---|---|---|
| **High-level** | `McpServer` | Most projects. Handles protocol details, schema validation, routing. |
| **Low-level** | `Server` | Maximum control. You handle message routing, validation, lifecycle. |

Use `McpServer` unless you have a specific reason to go lower.

---

## Server Creation

### High-Level API (McpServer)

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";

const server = new McpServer({
  name: "my-server",
  version: "1.0.0",
  capabilities: {
    tools: {},
    resources: {},
    prompts: {},
  },
});
```

### Low-Level API (Server)

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  { name: "my-server", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "greet",
      description: "Say hello",
      inputSchema: {
        type: "object",
        properties: { name: { type: "string" } },
        required: ["name"],
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "greet") {
    return {
      content: [{ type: "text", text: `Hello, ${request.params.arguments.name}!` }],
    };
  }
  throw new Error(`Unknown tool: ${request.params.name}`);
});
```

---

## Tool Registration

### Basic Tool

```typescript
import { z } from "zod";

server.tool(
  "get_weather",
  "Get current weather for a city",
  {
    city: z.string().describe("City name"),
    units: z.enum(["celsius", "fahrenheit"]).default("celsius").describe("Temperature units"),
  },
  async ({ city, units }) => {
    const weather = await fetchWeather(city, units);
    return {
      content: [{ type: "text", text: JSON.stringify(weather, null, 2) }],
    };
  }
);
```

### Tool with Complex Schema

```typescript
server.tool(
  "search_issues",
  "Search GitHub issues",
  {
    query: z.string().min(1).describe("Search query"),
    repo: z.string().regex(/^[\w-]+\/[\w-]+$/).describe("owner/repo format"),
    state: z.enum(["open", "closed", "all"]).default("open"),
    labels: z.array(z.string()).optional().describe("Filter by labels"),
    limit: z.number().int().min(1).max(100).default(10),
  },
  async ({ query, repo, state, labels, limit }) => {
    const issues = await searchGitHubIssues(repo, query, { state, labels, limit });
    return {
      content: [{ type: "text", text: formatIssues(issues) }],
    };
  }
);
```

### Tool with Error Handling

```typescript
server.tool(
  "create_issue",
  "Create a GitHub issue",
  {
    repo: z.string(),
    title: z.string().min(1).max(256),
    body: z.string().optional(),
  },
  async ({ repo, title, body }) => {
    try {
      const issue = await createGitHubIssue(repo, title, body);
      return {
        content: [{ type: "text", text: `Created issue #${issue.number}: ${issue.url}` }],
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: `Failed to create issue: ${error.message}` }],
        isError: true,
      };
    }
  }
);
```

---

## Resource Registration

### Static Resource

```typescript
server.resource(
  "config",
  "config://app/settings",
  { description: "Application configuration", mimeType: "application/json" },
  async () => ({
    contents: [
      {
        uri: "config://app/settings",
        mimeType: "application/json",
        text: JSON.stringify(getConfig()),
      },
    ],
  })
);
```

### Resource Template (Parameterized)

```typescript
server.resource(
  "issue",
  "github://issues/{number}",
  { description: "GitHub issue by number" },
  async (uri, { number }) => {
    const issue = await getIssue(parseInt(number));
    return {
      contents: [
        {
          uri: uri.href,
          mimeType: "application/json",
          text: JSON.stringify(issue),
        },
      ],
    };
  }
);
```

---

## Prompt Registration

```typescript
server.prompt(
  "code_review",
  "Generate a code review prompt",
  {
    language: z.string().describe("Programming language"),
    focus: z.enum(["security", "performance", "readability", "all"]).default("all"),
  },
  async ({ language, focus }) => ({
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `Review the following ${language} code with focus on ${focus}. Provide specific, actionable feedback.`,
        },
      },
    ],
  })
);
```

---

## Transport Configuration

### stdio Transport

```typescript
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const transport = new StdioServerTransport();
await server.connect(transport);
```

Full entry point for a stdio server:

```typescript
#!/usr/bin/env node
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({ name: "my-server", version: "1.0.0" });

// ... register tools, resources, prompts ...

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Streamable HTTP Transport

```typescript
import express from "express";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";

const app = express();
app.use(express.json());

// Map of session ID to transport
const transports = new Map<string, StreamableHTTPServerTransport>();

app.post("/mcp", async (req, res) => {
  const sessionId = req.headers["mcp-session-id"] as string | undefined;

  if (sessionId && transports.has(sessionId)) {
    // Existing session
    const transport = transports.get(sessionId)!;
    await transport.handleRequest(req, res);
  } else if (!sessionId) {
    // New session (initialize request)
    const transport = new StreamableHTTPServerTransport({
      sessionIdGenerator: () => crypto.randomUUID(),
      onsessioninitialized: (id) => {
        transports.set(id, transport);
      },
    });

    // Clean up on close
    transport.onclose = () => {
      if (transport.sessionId) {
        transports.delete(transport.sessionId);
      }
    };

    const mcpServer = createServer(); // Your server factory
    await mcpServer.connect(transport);
    await transport.handleRequest(req, res);
  } else {
    res.status(400).json({ error: "Invalid session" });
  }
});

app.listen(3000, () => {
  console.log("MCP server listening on http://localhost:3000/mcp");
});
```

---

## Error Handling Patterns

### Application-Level Errors (Tool Failed)

Return `isError: true` in the tool result. The model sees the error and can decide how to proceed.

```typescript
return {
  content: [{ type: "text", text: `API returned 404: resource not found` }],
  isError: true,
};
```

### Protocol-Level Errors

Throw `McpError` for protocol violations:

```typescript
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";

throw new McpError(ErrorCode.InvalidParams, "Parameter 'repo' must be in owner/repo format");
throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
throw new McpError(ErrorCode.InternalError, "Database connection failed");
```

### Global Error Handler

```typescript
server.onerror = (error) => {
  console.error("[MCP Error]", error);
  // Send to your error tracking service
};
```

---

## Middleware and Hooks

### Lifecycle Hooks

```typescript
// Called when a client connects
server.onconnection = (transport) => {
  console.log("Client connected");
};

// Called when a client disconnects
server.onclose = () => {
  console.log("Client disconnected");
};
```

### Request Logging (Low-Level API)

With the `Server` class, you can intercept all requests:

```typescript
const originalHandler = server.getRequestHandler(CallToolRequestSchema);
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const start = Date.now();
  console.log(`[${new Date().toISOString()}] Tool call: ${request.params.name}`);

  try {
    const result = await originalHandler(request);
    console.log(`[${new Date().toISOString()}] Tool call completed in ${Date.now() - start}ms`);
    return result;
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Tool call failed:`, error);
    throw error;
  }
});
```

---

## Complete Minimal Server Example

A fully working server you can run in under 5 minutes:

```typescript
#!/usr/bin/env node
// file: server.ts
// Run: npx tsx server.ts

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "hello-world",
  version: "1.0.0",
});

server.tool(
  "greet",
  "Say hello to someone",
  { name: z.string().describe("Name to greet") },
  async ({ name }) => ({
    content: [{ type: "text", text: `Hello, ${name}! Welcome to MCP.` }],
  })
);

server.tool(
  "add",
  "Add two numbers",
  {
    a: z.number().describe("First number"),
    b: z.number().describe("Second number"),
  },
  async ({ a, b }) => ({
    content: [{ type: "text", text: `${a} + ${b} = ${a + b}` }],
  })
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

**Claude Desktop config:**

```json
{
  "mcpServers": {
    "hello-world": {
      "command": "npx",
      "args": ["tsx", "/absolute/path/to/server.ts"]
    }
  }
}
```

---

## Complete Production Server Example

A production-ready server with Streamable HTTP, environment-based config, structured error handling, and logging:

```typescript
#!/usr/bin/env node
// file: src/server.ts

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { z } from "zod";
import express from "express";
import crypto from "crypto";

// --- Configuration ---
const CONFIG = {
  name: "github-status",
  version: "1.0.0",
  transport: (process.env.MCP_TRANSPORT ?? "stdio") as "stdio" | "http",
  port: parseInt(process.env.MCP_PORT ?? "3000", 10),
  apiBaseUrl: process.env.GITHUB_STATUS_API ?? "https://www.githubstatus.com/api/v2",
  logLevel: process.env.LOG_LEVEL ?? "info",
};

// --- Logging ---
function log(level: string, message: string, data?: Record<string, unknown>) {
  if (level === "debug" && CONFIG.logLevel !== "debug") return;
  const entry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    ...data,
  };
  console.error(JSON.stringify(entry));
}

// --- API Client ---
async function fetchGitHubStatus(endpoint: string): Promise<unknown> {
  const url = `${CONFIG.apiBaseUrl}${endpoint}`;
  log("debug", "Fetching GitHub Status API", { url });

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`GitHub Status API returned ${response.status}: ${response.statusText}`);
  }
  return response.json();
}

// --- Server Factory ---
function createServer(): McpServer {
  const server = new McpServer({
    name: CONFIG.name,
    version: CONFIG.version,
    capabilities: { tools: {} },
  });

  server.tool(
    "get_status",
    "Get current GitHub system status summary",
    {},
    async () => {
      try {
        const status = await fetchGitHubStatus("/status.json");
        return {
          content: [{ type: "text", text: JSON.stringify(status, null, 2) }],
        };
      } catch (error) {
        log("error", "get_status failed", { error: String(error) });
        return {
          content: [{ type: "text", text: `Failed to fetch status: ${error}` }],
          isError: true,
        };
      }
    }
  );

  server.tool(
    "get_incidents",
    "Get recent GitHub incidents",
    {
      limit: z.number().int().min(1).max(50).default(5).describe("Number of incidents to return"),
    },
    async ({ limit }) => {
      try {
        const data = (await fetchGitHubStatus("/incidents.json")) as {
          incidents: unknown[];
        };
        const incidents = data.incidents.slice(0, limit);
        return {
          content: [{ type: "text", text: JSON.stringify(incidents, null, 2) }],
        };
      } catch (error) {
        log("error", "get_incidents failed", { error: String(error) });
        return {
          content: [{ type: "text", text: `Failed to fetch incidents: ${error}` }],
          isError: true,
        };
      }
    }
  );

  server.tool(
    "get_component_status",
    "Get status of a specific GitHub component",
    {
      component_name: z.string().describe("Component name (e.g., 'Git Operations', 'API Requests')"),
    },
    async ({ component_name }) => {
      try {
        const data = (await fetchGitHubStatus("/components.json")) as {
          components: Array<{ name: string; status: string; description: string }>;
        };
        const component = data.components.find(
          (c) => c.name.toLowerCase() === component_name.toLowerCase()
        );
        if (!component) {
          const available = data.components.map((c) => c.name).join(", ");
          return {
            content: [
              { type: "text", text: `Component '${component_name}' not found. Available: ${available}` },
            ],
            isError: true,
          };
        }
        return {
          content: [{ type: "text", text: JSON.stringify(component, null, 2) }],
        };
      } catch (error) {
        log("error", "get_component_status failed", { error: String(error) });
        return {
          content: [{ type: "text", text: `Failed to fetch component: ${error}` }],
          isError: true,
        };
      }
    }
  );

  server.onerror = (error) => {
    log("error", "MCP server error", { error: String(error) });
  };

  return server;
}

// --- Transport Setup ---
async function main() {
  if (CONFIG.transport === "stdio") {
    const server = createServer();
    const transport = new StdioServerTransport();
    await server.connect(transport);
    log("info", "Server started", { transport: "stdio" });
  } else {
    const app = express();
    app.use(express.json());

    const sessions = new Map<string, StreamableHTTPServerTransport>();

    app.post("/mcp", async (req, res) => {
      const sessionId = req.headers["mcp-session-id"] as string | undefined;

      if (sessionId && sessions.has(sessionId)) {
        await sessions.get(sessionId)!.handleRequest(req, res);
      } else if (!sessionId) {
        const transport = new StreamableHTTPServerTransport({
          sessionIdGenerator: () => crypto.randomUUID(),
          onsessioninitialized: (id) => sessions.set(id, transport),
        });
        transport.onclose = () => {
          if (transport.sessionId) sessions.delete(transport.sessionId);
        };
        const server = createServer();
        await server.connect(transport);
        await transport.handleRequest(req, res);
      } else {
        res.status(400).json({ error: "Invalid session" });
      }
    });

    app.get("/health", (_req, res) => {
      res.json({ status: "ok", name: CONFIG.name, version: CONFIG.version });
    });

    app.listen(CONFIG.port, () => {
      log("info", "Server started", { transport: "http", port: CONFIG.port });
    });
  }
}

main().catch((error) => {
  log("error", "Fatal startup error", { error: String(error) });
  process.exit(1);
});
```

**package.json:**

```json
{
  "name": "github-status-mcp",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "node --loader tsx src/server.ts",
    "start:http": "MCP_TRANSPORT=http node --loader tsx src/server.ts",
    "build": "tsc",
    "lint": "eslint src/",
    "test": "vitest"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.29.0",
    "express": "^4.21.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/express": "^5.0.0",
    "@types/node": "^22.0.0",
    "tsx": "^4.19.0",
    "typescript": "^5.6.0",
    "vitest": "^3.0.0"
  }
}
```

> For specification design before building, see **trl-mcp-architect** (`references/specification-checklist.md`). For scaffold generation and deployment, see **trl-mcp-forge** (`references/scaffold-guide.md`).
