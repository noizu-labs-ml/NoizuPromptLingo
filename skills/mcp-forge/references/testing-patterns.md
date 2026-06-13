# MCP Server Testing Patterns

Comprehensive testing strategies for MCP servers across both TypeScript and Python.

## Testing Pyramid for MCP Servers

```
         /\
        /  \       Contract tests (schema validation)
       /----\
      /      \     Integration tests (MCP protocol)
     /--------\
    /          \   Unit tests (tool logic)
   /------------\
  / Smoke tests  \ (server starts, responds to initialize)
 /________________\
```

## 1. Unit Tests

Test tool handler logic in isolation, mocking external dependencies.

### TypeScript (vitest)

```typescript
// test/unit/tools.test.ts
import { describe, it, expect, vi } from "vitest";

// Extract tool logic into testable functions
// In src/tools/example.ts, export the handler separately:
//   export async function handleGetTimestamp(params: { timezone?: string }) { ... }

import { handleGetTimestamp } from "../../src/tools/example.js";

describe("get_timestamp handler", () => {
  it("returns UTC timestamp by default", async () => {
    const result = await handleGetTimestamp({});
    expect(result.timezone).toBe("UTC");
    expect(result.iso).toMatch(/^\d{4}-\d{2}-\d{2}T/);
    expect(result.epoch).toBeTypeOf("number");
  });

  it("returns timestamp in specified timezone", async () => {
    const result = await handleGetTimestamp({ timezone: "America/New_York" });
    expect(result.timezone).toBe("America/New_York");
  });

  it("returns error for invalid timezone", async () => {
    const result = await handleGetTimestamp({ timezone: "Invalid/Zone" });
    expect(result.error).toBeDefined();
  });
});

// Mocking external dependencies
describe("tool with external API", () => {
  it("handles API call", async () => {
    // Mock an external client
    const mockClient = {
      getData: vi.fn().mockResolvedValue({ status: "ok", data: [1, 2, 3] }),
    };

    const result = await handleToolWithApi(mockClient, { query: "test" });
    expect(mockClient.getData).toHaveBeenCalledWith("test");
    expect(result.data).toHaveLength(3);
  });

  it("handles API failure gracefully", async () => {
    const mockClient = {
      getData: vi.fn().mockRejectedValue(new Error("API timeout")),
    };

    const result = await handleToolWithApi(mockClient, { query: "test" });
    expect(result.error).toContain("API timeout");
  });
});
```

### Python (pytest)

```python
# tests/test_tools.py
import pytest
from unittest.mock import AsyncMock, patch


def test_get_timestamp_utc():
    """Handler returns UTC timestamp by default."""
    from src.tools.example import handle_get_timestamp

    result = handle_get_timestamp(timezone_name="UTC")
    assert result["timezone"] == "UTC"
    assert "iso" in result
    assert isinstance(result["epoch"], int)


def test_get_timestamp_invalid_timezone():
    """Handler returns error for invalid timezone."""
    from src.tools.example import handle_get_timestamp

    result = handle_get_timestamp(timezone_name="Invalid/Zone")
    assert "error" in result


@pytest.mark.asyncio
async def test_tool_with_external_api():
    """Tool handles external API calls."""
    mock_client = AsyncMock()
    mock_client.get_data.return_value = {"status": "ok", "items": [1, 2, 3]}

    from src.tools.example import handle_api_tool

    result = await handle_api_tool(mock_client, query="test")
    mock_client.get_data.assert_called_once_with("test")
    assert len(result["items"]) == 3


@pytest.mark.asyncio
async def test_tool_api_failure():
    """Tool degrades gracefully on API failure."""
    mock_client = AsyncMock()
    mock_client.get_data.side_effect = TimeoutError("API timeout")

    from src.tools.example import handle_api_tool

    result = await handle_api_tool(mock_client, query="test")
    assert "error" in result
```

## 2. Integration Tests

Test via the MCP protocol -- start a server, connect a client, call tools.

### TypeScript

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
    expect(tools.length).toBeGreaterThan(0);

    for (const tool of tools) {
      expect(tool.name).toBeDefined();
      expect(tool.description).toBeDefined();
      expect(tool.inputSchema).toBeDefined();
    }
  });

  it("calls a tool and receives valid response", async () => {
    const result = await client.callTool({
      name: "get_timestamp",
      arguments: { timezone: "UTC" },
    });

    expect(result.content).toBeDefined();
    expect(Array.isArray(result.content)).toBe(true);
    expect(result.isError).toBeFalsy();
  });

  it("returns error for invalid tool arguments", async () => {
    const result = await client.callTool({
      name: "string_stats",
      arguments: { text: 12345 }, // should be string
    });

    expect(result.isError).toBe(true);
  });

  it("returns error for unknown tool", async () => {
    await expect(
      client.callTool({ name: "nonexistent_tool", arguments: {} })
    ).rejects.toThrow();
  });
});
```

### Python

```python
# tests/test_server.py
import pytest
from fastmcp import Client


@pytest.fixture
def client():
    from src.server import mcp
    return Client(mcp)


@pytest.mark.asyncio
async def test_list_tools(client):
    """Server lists all registered tools."""
    async with client:
        tools = await client.list_tools()
    assert len(tools) > 0
    for tool in tools:
        assert tool.name
        assert tool.description


@pytest.mark.asyncio
async def test_call_tool(client):
    """Tool returns valid response."""
    async with client:
        result = await client.call_tool("get_timestamp", {"timezone_name": "UTC"})
    assert result is not None


@pytest.mark.asyncio
async def test_tool_error_handling(client):
    """Tool handles invalid input gracefully."""
    async with client:
        result = await client.call_tool(
            "get_timestamp", {"timezone_name": "Not/A/Zone"}
        )
    text = str(result)
    assert "error" in text.lower() or "unknown" in text.lower()
```

## 3. Smoke Tests

Minimal verification that the server starts and responds to the MCP initialize handshake.

### TypeScript

```typescript
// test/smoke.test.ts
import { describe, it, expect } from "vitest";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { createServer } from "../src/server.js";

describe("Smoke Tests", () => {
  it("server starts and completes initialization", async () => {
    const server = createServer();
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();

    await server.connect(serverTransport);

    const client = new Client({ name: "smoke-test", version: "1.0.0" });
    await client.connect(clientTransport);

    // If we get here, initialization succeeded
    const { tools } = await client.listTools();
    expect(tools.length).toBeGreaterThan(0);

    await client.close();
    await server.close();
  });
});
```

### Python

```python
# tests/test_smoke.py
import pytest
from fastmcp import Client


@pytest.mark.asyncio
async def test_server_starts():
    """Server starts and responds to initialization."""
    from src.server import mcp

    client = Client(mcp)
    async with client:
        tools = await client.list_tools()
    assert len(tools) > 0
```

## 4. Contract Tests

Validate that tool schemas match a specification document. Useful when the spec is defined in trl-mcp-architect and the implementation must conform.

### TypeScript

```typescript
// test/contract/schema.test.ts
import { describe, it, expect } from "vitest";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { createServer } from "../../src/server.js";

// Load the spec (could be from a JSON file, YAML, etc.)
const TOOL_SPEC = {
  get_timestamp: {
    description: /current date and time/i,
    requiredParams: [],
    optionalParams: ["timezone"],
  },
  string_stats: {
    description: /character count.*word count/i,
    requiredParams: ["text"],
    optionalParams: ["include_frequency"],
  },
};

describe("Contract Tests", () => {
  it("all specified tools are registered", async () => {
    const server = createServer();
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    await server.connect(serverTransport);

    const client = new Client({ name: "contract-test", version: "1.0.0" });
    await client.connect(clientTransport);

    const { tools } = await client.listTools();
    const toolNames = tools.map((t) => t.name);

    for (const specName of Object.keys(TOOL_SPEC)) {
      expect(toolNames).toContain(specName);
    }

    await client.close();
    await server.close();
  });

  it("tool schemas match spec", async () => {
    const server = createServer();
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    await server.connect(serverTransport);

    const client = new Client({ name: "contract-test", version: "1.0.0" });
    await client.connect(clientTransport);

    const { tools } = await client.listTools();

    for (const [name, spec] of Object.entries(TOOL_SPEC)) {
      const tool = tools.find((t) => t.name === name);
      expect(tool).toBeDefined();
      expect(tool!.description).toMatch(spec.description);

      const required = tool!.inputSchema.required ?? [];
      for (const param of spec.requiredParams) {
        expect(required).toContain(param);
      }

      const properties = Object.keys(tool!.inputSchema.properties ?? {});
      for (const param of spec.optionalParams) {
        expect(properties).toContain(param);
      }
    }

    await client.close();
    await server.close();
  });
});
```

### Python

```python
# tests/test_contract.py
import pytest
import re
from fastmcp import Client

TOOL_SPEC = {
    "get_timestamp": {
        "description_pattern": r"current date and time",
        "required_params": [],
        "optional_params": ["timezone_name"],
    },
    "string_stats": {
        "description_pattern": r"character count.*word count",
        "required_params": ["text"],
        "optional_params": ["include_frequency"],
    },
}


@pytest.mark.asyncio
async def test_all_tools_registered():
    from src.server import mcp
    client = Client(mcp)
    async with client:
        tools = await client.list_tools()
    tool_names = [t.name for t in tools]
    for name in TOOL_SPEC:
        assert name in tool_names, f"Missing tool: {name}"


@pytest.mark.asyncio
async def test_tool_schemas_match_spec():
    from src.server import mcp
    client = Client(mcp)
    async with client:
        tools = await client.list_tools()

    for name, spec in TOOL_SPEC.items():
        tool = next((t for t in tools if t.name == name), None)
        assert tool is not None
        assert re.search(spec["description_pattern"], tool.description, re.IGNORECASE)
```

## 5. Fixtures and Mocking Patterns

### TypeScript: vitest helpers

```typescript
// test/helpers.ts
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";

export interface TestHarness {
  client: Client;
  server: McpServer;
  cleanup: () => Promise<void>;
}

export async function createTestHarness(
  serverFactory: () => McpServer
): Promise<TestHarness> {
  const server = serverFactory();
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();

  await server.connect(serverTransport);

  const client = new Client({ name: "test-client", version: "1.0.0" });
  await client.connect(clientTransport);

  return {
    client,
    server,
    cleanup: async () => {
      await client.close();
      await server.close();
    },
  };
}
```

### Python: pytest fixtures

```python
# tests/conftest.py
import pytest
from fastmcp import Client


@pytest.fixture
def mcp_server():
    """Create a fresh MCP server instance for testing."""
    from src.server import create_server
    return create_server()


@pytest.fixture
def mcp_client(mcp_server):
    """Create a test client connected to the server."""
    return Client(mcp_server)
```

## 6. Testing Transports

### Stdio Testing

For stdio-based servers, use in-memory transports in tests rather than spawning a subprocess:

```typescript
// TypeScript: use InMemoryTransport (shown above)
// This avoids process management complexity in tests.
```

```python
# Python: FastMCP Client accepts the server object directly
# No subprocess needed for testing.
client = Client(mcp)  # Direct in-process connection
```

### HTTP Testing

For Streamable HTTP servers, test the HTTP endpoint directly:

```typescript
// test/integration/http.test.ts
import { describe, it, expect, beforeAll, afterAll } from "vitest";

let serverProcess: { close: () => Promise<void> };
let baseUrl: string;

beforeAll(async () => {
  // Start server on a random port
  const port = 3001 + Math.floor(Math.random() * 1000);
  baseUrl = `http://localhost:${port}`;
  // ... start server
});

afterAll(async () => {
  await serverProcess.close();
});

it("responds to MCP initialize over HTTP", async () => {
  const response = await fetch(`${baseUrl}/mcp`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "initialize",
      params: {
        protocolVersion: "2025-03-26",
        capabilities: {},
        clientInfo: { name: "test", version: "1.0.0" },
      },
    }),
  });

  expect(response.status).toBe(200);
  const data = await response.json();
  expect(data.result.protocolVersion).toBe("2025-03-26");
});
```

## 7. CI Integration

### vitest configuration

```typescript
// vitest.config.ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    testTimeout: 10000,
    hookTimeout: 10000,
    include: ["test/**/*.test.ts"],
    coverage: {
      provider: "v8",
      include: ["src/**/*.ts"],
      exclude: ["src/index.ts"],
      thresholds: {
        statements: 80,
        branches: 70,
        functions: 80,
        lines: 80,
      },
    },
  },
});
```

### pytest configuration

```toml
# In pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
addopts = "--tb=short -q"

[tool.coverage.run]
source = ["src"]

[tool.coverage.report]
fail_under = 80
```

See `references/ci-cd-patterns.md` for full CI pipeline configuration.
