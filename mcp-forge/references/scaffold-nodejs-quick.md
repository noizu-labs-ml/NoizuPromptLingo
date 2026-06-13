# Phase 1: Quick Node.js MCP Server Scaffold

Complete, runnable TypeScript MCP server using `@modelcontextprotocol/sdk` v1.29.0 with stdio transport. Copy these files, run `npm install && npm run build && npm start`.

> For spec design before scaffolding, see **trl-mcp-architect** (`references/specification-checklist.md`).

## Files

### src/index.ts

```typescript
// src/index.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "my-mcp-server",
  version: "0.1.0",
});

// Tool 1: Get current timestamp with optional timezone
server.tool(
  "get_timestamp",
  "Returns the current date and time, optionally in a specific timezone",
  {
    timezone: z
      .string()
      .optional()
      .describe("IANA timezone name (e.g., 'America/New_York'). Defaults to UTC."),
  },
  async ({ timezone }) => {
    try {
      const tz = timezone ?? "UTC";
      const now = new Date();
      const formatted = now.toLocaleString("en-US", { timeZone: tz });
      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify(
              {
                timezone: tz,
                formatted,
                iso: now.toISOString(),
                epoch: now.getTime(),
              },
              null,
              2
            ),
          },
        ],
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return {
        content: [{ type: "text" as const, text: `Error: ${message}` }],
        isError: true,
      };
    }
  }
);

// Tool 2: Calculate string statistics
server.tool(
  "string_stats",
  "Analyzes a string and returns character count, word count, and line count",
  {
    text: z.string().describe("The text to analyze"),
    include_frequency: z
      .boolean()
      .optional()
      .describe("Include character frequency analysis. Defaults to false."),
  },
  async ({ text, include_frequency }) => {
    const chars = text.length;
    const words = text.trim() === "" ? 0 : text.trim().split(/\s+/).length;
    const lines = text.split("\n").length;

    const result: Record<string, unknown> = {
      characters: chars,
      words,
      lines,
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

    return {
      content: [
        {
          type: "text" as const,
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error(`${server.server.name} v${server.server.version} running on stdio`);
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
```

### package.json

```json
{
  "name": "my-mcp-server",
  "version": "0.1.0",
  "description": "MCP server scaffold — Phase 1 quick prototype",
  "type": "module",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsc --watch",
    "test": "vitest run",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.29.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
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

### test/smoke.test.ts

```typescript
// test/smoke.test.ts
import { describe, it, expect } from "vitest";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

function createTestServer(): McpServer {
  const server = new McpServer({
    name: "my-mcp-server",
    version: "0.1.0",
  });

  server.tool(
    "get_timestamp",
    "Returns the current date and time",
    {
      timezone: z.string().optional(),
    },
    async ({ timezone }) => {
      const tz = timezone ?? "UTC";
      const now = new Date();
      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify({
              timezone: tz,
              formatted: now.toLocaleString("en-US", { timeZone: tz }),
              iso: now.toISOString(),
              epoch: now.getTime(),
            }),
          },
        ],
      };
    }
  );

  server.tool(
    "string_stats",
    "Analyzes a string",
    {
      text: z.string(),
      include_frequency: z.boolean().optional(),
    },
    async ({ text, include_frequency }) => {
      const chars = text.length;
      const words = text.trim() === "" ? 0 : text.trim().split(/\s+/).length;
      const lines = text.split("\n").length;
      const result: Record<string, unknown> = { characters: chars, words, lines };
      if (include_frequency) {
        const freq: Record<string, number> = {};
        for (const ch of text.toLowerCase()) {
          if (/[a-z0-9]/.test(ch)) freq[ch] = (freq[ch] ?? 0) + 1;
        }
        result.character_frequency = freq;
      }
      return {
        content: [{ type: "text" as const, text: JSON.stringify(result) }],
      };
    }
  );

  return server;
}

describe("MCP Server Smoke Tests", () => {
  it("should list available tools", async () => {
    const server = createTestServer();
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();

    await server.connect(serverTransport);

    const client = new Client({ name: "test-client", version: "1.0.0" });
    await client.connect(clientTransport);

    const { tools } = await client.listTools();
    expect(tools).toHaveLength(2);

    const toolNames = tools.map((t) => t.name);
    expect(toolNames).toContain("get_timestamp");
    expect(toolNames).toContain("string_stats");

    await client.close();
    await server.close();
  });

  it("should call get_timestamp tool", async () => {
    const server = createTestServer();
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();

    await server.connect(serverTransport);

    const client = new Client({ name: "test-client", version: "1.0.0" });
    await client.connect(clientTransport);

    const result = await client.callTool({
      name: "get_timestamp",
      arguments: { timezone: "UTC" },
    });

    expect(result.content).toHaveLength(1);
    const parsed = JSON.parse((result.content as Array<{ text: string }>)[0].text);
    expect(parsed.timezone).toBe("UTC");
    expect(parsed.iso).toBeDefined();
    expect(parsed.epoch).toBeTypeOf("number");

    await client.close();
    await server.close();
  });

  it("should call string_stats tool", async () => {
    const server = createTestServer();
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();

    await server.connect(serverTransport);

    const client = new Client({ name: "test-client", version: "1.0.0" });
    await client.connect(clientTransport);

    const result = await client.callTool({
      name: "string_stats",
      arguments: { text: "hello world", include_frequency: true },
    });

    const parsed = JSON.parse((result.content as Array<{ text: string }>)[0].text);
    expect(parsed.characters).toBe(11);
    expect(parsed.words).toBe(2);
    expect(parsed.lines).toBe(1);
    expect(parsed.character_frequency).toBeDefined();
    expect(parsed.character_frequency.l).toBe(3);

    await client.close();
    await server.close();
  });
});
```

### .env.example

```bash
# .env.example
# Server configuration
MCP_SERVER_NAME=my-mcp-server
MCP_SERVER_VERSION=0.1.0

# Add your API keys and secrets below
# API_KEY=your-api-key-here
```

### README.md

````markdown
# my-mcp-server

MCP server scaffold -- Phase 1 quick prototype.

## Prerequisites

- Node.js >= 20
- npm

## Setup

```bash
npm install
npm run build
```

## Run

```bash
npm start
```

The server communicates over stdio. Connect it to an MCP client (Claude Desktop, Cursor, etc.) by adding it to your client configuration.

### Claude Desktop Configuration

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-mcp-server": {
      "command": "node",
      "args": ["/absolute/path/to/dist/index.js"]
    }
  }
}
```

## Development

```bash
npm run dev       # Watch mode (recompiles on change)
npm run typecheck # Type checking without emitting
npm test          # Run smoke tests
```

## Tools

| Tool | Description |
|------|-------------|
| `get_timestamp` | Returns current date/time with optional timezone |
| `string_stats` | Analyzes text: character count, word count, line count |
````
