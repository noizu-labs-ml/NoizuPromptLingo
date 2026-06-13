# Phase 2: Production Node.js MCP Server Scaffold

Complete, runnable TypeScript MCP server with tests, Docker, CI/CD, rate limiting, and structured logging. Uses `@modelcontextprotocol/sdk` v1.29.0.

> For spec design before scaffolding, see **trl-mcp-architect** (`references/specification-checklist.md`).

## Project Structure

```
my-mcp-server/
  src/
    server.ts           # Server initialization, transport setup
    tools/
      index.ts          # Tool registry
      example.ts        # Example tool with error handling
    middleware/
      rate-limiter.ts   # Token bucket rate limiter
      logger.ts         # Structured JSON logging
    config.ts           # Environment-based configuration
  test/
    unit/
      tools.test.ts     # Unit tests for tool logic
    integration/
      server.test.ts    # Integration tests via MCP protocol
  package.json
  tsconfig.json
  Dockerfile
  docker-compose.yml
  .github/workflows/ci.yml
  .env.example
  README.md
```

## Files

### src/config.ts

```typescript
// src/config.ts
import { z } from "zod";

const envSchema = z.object({
  MCP_SERVER_NAME: z.string().default("my-mcp-server"),
  MCP_SERVER_VERSION: z.string().default("0.1.0"),
  MCP_TRANSPORT: z.enum(["stdio", "streamable-http"]).default("stdio"),
  MCP_HTTP_PORT: z.coerce.number().default(3000),
  MCP_HTTP_HOST: z.string().default("0.0.0.0"),
  LOG_LEVEL: z.enum(["debug", "info", "warn", "error"]).default("info"),
  RATE_LIMIT_MAX_TOKENS: z.coerce.number().default(100),
  RATE_LIMIT_REFILL_RATE: z.coerce.number().default(10),
  RATE_LIMIT_REFILL_INTERVAL_MS: z.coerce.number().default(1000),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
});

export type Config = z.infer<typeof envSchema>;

let _config: Config | null = null;

export function getConfig(): Config {
  if (!_config) {
    _config = envSchema.parse(process.env);
  }
  return _config;
}

export function resetConfig(): void {
  _config = null;
}
```

### src/middleware/logger.ts

```typescript
// src/middleware/logger.ts
import { getConfig } from "../config.js";

export type LogLevel = "debug" | "info" | "warn" | "error";

const LOG_LEVELS: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
};

export interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  tool?: string;
  duration_ms?: number;
  params_hash?: string;
  error?: string;
  [key: string]: unknown;
}

function shouldLog(level: LogLevel): boolean {
  const config = getConfig();
  return LOG_LEVELS[level] >= LOG_LEVELS[config.LOG_LEVEL];
}

function hashParams(params: Record<string, unknown>): string {
  const str = JSON.stringify(params);
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash + char) | 0;
  }
  return Math.abs(hash).toString(36);
}

function emit(entry: LogEntry): void {
  if (!shouldLog(entry.level)) return;
  // Write structured JSON to stderr (stdout is reserved for MCP protocol)
  process.stderr.write(JSON.stringify(entry) + "\n");
}

export function logToolCall(
  tool: string,
  params: Record<string, unknown>,
  startTime: number,
  error?: Error
): void {
  const duration_ms = Date.now() - startTime;
  const entry: LogEntry = {
    timestamp: new Date().toISOString(),
    level: error ? "error" : "info",
    message: error ? `Tool call failed: ${tool}` : `Tool call completed: ${tool}`,
    tool,
    duration_ms,
    params_hash: hashParams(params),
  };
  if (error) {
    entry.error = error.message;
  }
  emit(entry);
}

export function log(level: LogLevel, message: string, extra?: Record<string, unknown>): void {
  emit({
    timestamp: new Date().toISOString(),
    level,
    message,
    ...extra,
  });
}
```

### src/middleware/rate-limiter.ts

```typescript
// src/middleware/rate-limiter.ts
import { getConfig } from "../config.js";

interface TokenBucket {
  tokens: number;
  lastRefill: number;
}

const buckets = new Map<string, TokenBucket>();

function refill(bucket: TokenBucket): void {
  const config = getConfig();
  const now = Date.now();
  const elapsed = now - bucket.lastRefill;
  const intervals = Math.floor(elapsed / config.RATE_LIMIT_REFILL_INTERVAL_MS);

  if (intervals > 0) {
    bucket.tokens = Math.min(
      config.RATE_LIMIT_MAX_TOKENS,
      bucket.tokens + intervals * config.RATE_LIMIT_REFILL_RATE
    );
    bucket.lastRefill = now;
  }
}

export function checkRateLimit(key: string = "global"): { allowed: boolean; retryAfterMs?: number } {
  const config = getConfig();

  let bucket = buckets.get(key);
  if (!bucket) {
    bucket = { tokens: config.RATE_LIMIT_MAX_TOKENS, lastRefill: Date.now() };
    buckets.set(key, bucket);
  }

  refill(bucket);

  if (bucket.tokens >= 1) {
    bucket.tokens -= 1;
    return { allowed: true };
  }

  const retryAfterMs = config.RATE_LIMIT_REFILL_INTERVAL_MS;
  return { allowed: false, retryAfterMs };
}

export function resetRateLimiter(): void {
  buckets.clear();
}
```

### src/tools/example.ts

```typescript
// src/tools/example.ts
import { z } from "zod";

// --- Exported handler logic (testable in isolation) ---

export interface TimestampResult {
  timezone: string;
  formatted: string;
  iso: string;
  epoch: number;
  error?: string;
}

export async function handleGetTimestamp(params: {
  timezone?: string;
}): Promise<TimestampResult> {
  const tz = params.timezone ?? "UTC";
  try {
    const now = new Date();
    const formatted = now.toLocaleString("en-US", { timeZone: tz });
    return {
      timezone: tz,
      formatted,
      iso: now.toISOString(),
      epoch: now.getTime(),
    };
  } catch (error) {
    return {
      timezone: tz,
      formatted: "",
      iso: "",
      epoch: 0,
      error: error instanceof Error ? error.message : String(error),
    };
  }
}

export interface StringStatsResult {
  characters: number;
  words: number;
  lines: number;
  character_frequency?: Record<string, number>;
}

export async function handleStringStats(params: {
  text: string;
  include_frequency?: boolean;
}): Promise<StringStatsResult> {
  const { text, include_frequency } = params;
  const result: StringStatsResult = {
    characters: text.length,
    words: text.trim() === "" ? 0 : text.trim().split(/\s+/).length,
    lines: text.split("\n").length,
  };

  if (include_frequency) {
    const freq: Record<string, number> = {};
    for (const ch of text.toLowerCase()) {
      if (/[a-z0-9]/.test(ch)) {
        freq[ch] = (freq[ch] ?? 0) + 1;
      }
    }
    result.character_frequency = freq;
  }

  return result;
}

// --- Tool definitions (schema + handler wired together) ---

export const exampleToolDefs = {
  get_timestamp: {
    name: "get_timestamp" as const,
    description: "Returns the current date and time, optionally in a specific timezone",
    schema: {
      timezone: z
        .string()
        .optional()
        .describe("IANA timezone name (e.g., 'America/New_York'). Defaults to UTC."),
    },
    handler: handleGetTimestamp,
  },
  string_stats: {
    name: "string_stats" as const,
    description: "Analyzes a string and returns character count, word count, and line count",
    schema: {
      text: z.string().describe("The text to analyze"),
      include_frequency: z
        .boolean()
        .optional()
        .describe("Include character frequency analysis. Defaults to false."),
    },
    handler: handleStringStats,
  },
};
```

### src/tools/index.ts

```typescript
// src/tools/index.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { exampleToolDefs } from "./example.js";
import { logToolCall } from "../middleware/logger.js";
import { checkRateLimit } from "../middleware/rate-limiter.js";

export function registerTools(server: McpServer): void {
  for (const tool of Object.values(exampleToolDefs)) {
    server.tool(
      tool.name,
      tool.description,
      tool.schema,
      async (params) => {
        const startTime = Date.now();

        // Rate limiting
        const rateCheck = checkRateLimit(tool.name);
        if (!rateCheck.allowed) {
          logToolCall(tool.name, params, startTime, new Error("Rate limited"));
          return {
            content: [
              {
                type: "text" as const,
                text: JSON.stringify({
                  error: "Rate limited",
                  retry_after_ms: rateCheck.retryAfterMs,
                }),
              },
            ],
            isError: true,
          };
        }

        try {
          const result = await tool.handler(params as never);
          logToolCall(tool.name, params, startTime);
          return {
            content: [
              {
                type: "text" as const,
                text: JSON.stringify(result, null, 2),
              },
            ],
          };
        } catch (error) {
          const err = error instanceof Error ? error : new Error(String(error));
          logToolCall(tool.name, params, startTime, err);
          return {
            content: [
              {
                type: "text" as const,
                text: JSON.stringify({ error: err.message }),
              },
            ],
            isError: true,
          };
        }
      }
    );
  }
}
```

### src/server.ts

```typescript
// src/server.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { getConfig } from "./config.js";
import { registerTools } from "./tools/index.js";
import { log } from "./middleware/logger.js";
import http from "node:http";

export function createServer(): McpServer {
  const config = getConfig();

  const server = new McpServer({
    name: config.MCP_SERVER_NAME,
    version: config.MCP_SERVER_VERSION,
  });

  registerTools(server);

  return server;
}

async function startStdio(server: McpServer): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  log("info", "Server running on stdio transport");
}

async function startHttp(server: McpServer): Promise<void> {
  const config = getConfig();

  const httpServer = http.createServer(async (req, res) => {
    // Health check endpoint
    if (req.url === "/health" && req.method === "GET") {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ status: "ok", version: config.MCP_SERVER_VERSION }));
      return;
    }

    // Readiness endpoint
    if (req.url === "/ready" && req.method === "GET") {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ ready: true }));
      return;
    }

    // MCP endpoint
    if (req.url === "/mcp" && req.method === "POST") {
      const transport = new StreamableHTTPServerTransport({
        sessionIdGenerator: () => crypto.randomUUID(),
      });

      res.on("close", () => {
        transport.close();
      });

      await server.connect(transport);
      await transport.handleRequest(req, res);
      return;
    }

    res.writeHead(404);
    res.end("Not found");
  });

  httpServer.listen(config.MCP_HTTP_PORT, config.MCP_HTTP_HOST, () => {
    log("info", `Server running on http://${config.MCP_HTTP_HOST}:${config.MCP_HTTP_PORT}`);
  });
}

async function main(): Promise<void> {
  const config = getConfig();
  const server = createServer();

  log("info", `Starting ${config.MCP_SERVER_NAME} v${config.MCP_SERVER_VERSION}`, {
    transport: config.MCP_TRANSPORT,
    environment: config.NODE_ENV,
  });

  if (config.MCP_TRANSPORT === "streamable-http") {
    await startHttp(server);
  } else {
    await startStdio(server);
  }
}

main().catch((error) => {
  log("error", "Fatal error", { error: String(error) });
  process.exit(1);
});
```

### test/unit/tools.test.ts

```typescript
// test/unit/tools.test.ts
import { describe, it, expect } from "vitest";
import { handleGetTimestamp, handleStringStats } from "../../src/tools/example.js";

describe("handleGetTimestamp", () => {
  it("returns UTC timestamp by default", async () => {
    const result = await handleGetTimestamp({});
    expect(result.timezone).toBe("UTC");
    expect(result.iso).toMatch(/^\d{4}-\d{2}-\d{2}T/);
    expect(result.epoch).toBeTypeOf("number");
    expect(result.error).toBeUndefined();
  });

  it("returns timestamp in specified timezone", async () => {
    const result = await handleGetTimestamp({ timezone: "America/New_York" });
    expect(result.timezone).toBe("America/New_York");
    expect(result.formatted).toBeTruthy();
  });

  it("returns error for invalid timezone", async () => {
    const result = await handleGetTimestamp({ timezone: "Invalid/Zone" });
    expect(result.error).toBeDefined();
  });
});

describe("handleStringStats", () => {
  it("counts characters, words, and lines", async () => {
    const result = await handleStringStats({ text: "hello world" });
    expect(result.characters).toBe(11);
    expect(result.words).toBe(2);
    expect(result.lines).toBe(1);
  });

  it("handles empty string", async () => {
    const result = await handleStringStats({ text: "" });
    expect(result.characters).toBe(0);
    expect(result.words).toBe(0);
    expect(result.lines).toBe(1);
  });

  it("counts multiline text", async () => {
    const result = await handleStringStats({ text: "line1\nline2\nline3" });
    expect(result.lines).toBe(3);
  });

  it("includes character frequency when requested", async () => {
    const result = await handleStringStats({
      text: "hello",
      include_frequency: true,
    });
    expect(result.character_frequency).toBeDefined();
    expect(result.character_frequency!.l).toBe(2);
    expect(result.character_frequency!.h).toBe(1);
  });

  it("excludes character frequency by default", async () => {
    const result = await handleStringStats({ text: "hello" });
    expect(result.character_frequency).toBeUndefined();
  });
});
```

### test/integration/server.test.ts

```typescript
// test/integration/server.test.ts
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { createServer } from "../../src/server.js";

describe("MCP Server Integration", () => {
  let client: Client;
  let cleanup: () => Promise<void>;

  beforeAll(async () => {
    const server = createServer();
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    await server.connect(serverTransport);

    client = new Client({ name: "test-client", version: "1.0.0" });
    await client.connect(clientTransport);

    cleanup = async () => {
      await client.close();
      await server.close();
    };
  });

  afterAll(async () => {
    await cleanup();
  });

  it("lists all registered tools", async () => {
    const { tools } = await client.listTools();
    expect(tools.length).toBeGreaterThanOrEqual(2);

    const names = tools.map((t) => t.name);
    expect(names).toContain("get_timestamp");
    expect(names).toContain("string_stats");
  });

  it("tool descriptions are non-empty", async () => {
    const { tools } = await client.listTools();
    for (const tool of tools) {
      expect(tool.description.length).toBeGreaterThan(0);
    }
  });

  it("calls get_timestamp successfully", async () => {
    const result = await client.callTool({
      name: "get_timestamp",
      arguments: { timezone: "UTC" },
    });

    expect(result.isError).toBeFalsy();
    const parsed = JSON.parse((result.content as Array<{ text: string }>)[0].text);
    expect(parsed.timezone).toBe("UTC");
    expect(parsed.epoch).toBeTypeOf("number");
  });

  it("calls string_stats successfully", async () => {
    const result = await client.callTool({
      name: "string_stats",
      arguments: { text: "hello world", include_frequency: true },
    });

    expect(result.isError).toBeFalsy();
    const parsed = JSON.parse((result.content as Array<{ text: string }>)[0].text);
    expect(parsed.characters).toBe(11);
    expect(parsed.words).toBe(2);
    expect(parsed.character_frequency.l).toBe(3);
  });

  it("returns error for unknown tool", async () => {
    await expect(
      client.callTool({ name: "nonexistent", arguments: {} })
    ).rejects.toThrow();
  });
});
```

### package.json

```json
{
  "name": "my-mcp-server",
  "version": "0.1.0",
  "description": "MCP server -- Phase 2 production build",
  "type": "module",
  "main": "dist/server.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/server.js",
    "dev": "tsc --watch",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/ test/",
    "typecheck": "tsc --noEmit",
    "docker:build": "docker build -t my-mcp-server .",
    "docker:run": "docker run --rm -it my-mcp-server"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.29.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "@vitest/coverage-v8": "^3.0.0",
    "eslint": "^9.0.0",
    "typescript": "^5.7.0",
    "vitest": "^3.0.0"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "test"]
}
```

### Dockerfile

```dockerfile
# Dockerfile
# Stage 1: Build
FROM node:22-slim AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --ignore-scripts

COPY tsconfig.json ./
COPY src/ ./src/

RUN npm run build

# Stage 2: Production runtime
FROM node:22-slim AS runtime

RUN groupadd -r mcp && useradd -r -g mcp -m mcp

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force

COPY --from=builder /app/dist ./dist

USER mcp

ENV NODE_ENV=production
ENV MCP_TRANSPORT=stdio

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "process.exit(0)"

ENTRYPOINT ["node", "dist/server.js"]
```

### docker-compose.yml

```yaml
# docker-compose.yml
services:
  mcp-server:
    build: .
    environment:
      - MCP_SERVER_NAME=my-mcp-server
      - MCP_TRANSPORT=streamable-http
      - MCP_HTTP_PORT=3000
      - LOG_LEVEL=debug
      - NODE_ENV=development
    ports:
      - "3000:3000"
    volumes:
      - ./src:/app/src:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
```

### .github/workflows/ci.yml

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint-and-typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run typecheck
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint-and-typecheck
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run test:coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run build

  docker:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: false
          tags: my-mcp-server:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### .env.example

```bash
# .env.example

# Server identity
MCP_SERVER_NAME=my-mcp-server
MCP_SERVER_VERSION=0.1.0

# Transport: stdio or streamable-http
MCP_TRANSPORT=stdio
MCP_HTTP_PORT=3000
MCP_HTTP_HOST=0.0.0.0

# Logging
LOG_LEVEL=info

# Rate limiting
RATE_LIMIT_MAX_TOKENS=100
RATE_LIMIT_REFILL_RATE=10
RATE_LIMIT_REFILL_INTERVAL_MS=1000

# Environment
NODE_ENV=development

# Add your API keys and secrets below
# API_KEY=your-api-key-here
```

### README.md

````markdown
# my-mcp-server

Production-grade MCP server -- Phase 2 build.

## Architecture

```
Client --> Transport (stdio | HTTP) --> McpServer --> Tool Registry --> Tool Handlers
                                                         |
                                                    Rate Limiter
                                                    Logger
```

## Prerequisites

- Node.js >= 20
- npm
- Docker (optional, for containerized deployment)

## Setup

```bash
npm install
cp .env.example .env
# Edit .env with your configuration
```

## Development

```bash
npm run dev         # Watch mode
npm run typecheck   # Type checking
npm test            # Run all tests
npm run test:watch  # Watch mode tests
npm run test:coverage  # Tests with coverage
npm run lint        # Linting
```

## Run

### Stdio (local)

```bash
npm run build
npm start
```

### HTTP (remote)

```bash
MCP_TRANSPORT=streamable-http npm start
```

### Docker

```bash
docker compose up       # Development with hot reload
npm run docker:build    # Build production image
npm run docker:run      # Run production image (stdio)
```

## Configuration

All configuration is via environment variables. See `.env.example` for the full list.

## Tools

| Tool | Description |
|------|-------------|
| `get_timestamp` | Returns current date/time with optional timezone |
| `string_stats` | Analyzes text: character count, word count, line count |

## Claude Desktop Configuration

```json
{
  "mcpServers": {
    "my-mcp-server": {
      "command": "node",
      "args": ["/absolute/path/to/dist/server.js"]
    }
  }
}
```

## CI/CD

GitHub Actions pipeline: lint --> typecheck --> test --> build --> Docker.
See `.github/workflows/ci.yml`.
````
