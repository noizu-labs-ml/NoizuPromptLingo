# NPL Three-Tier Tool Architecture

Implementation guide for the NoizuPromptLingua three-tier tool discovery pattern in MCP servers.

## Overview

The three-tier pattern organizes tools by visibility level:

| Tier | Visibility | Registration | Purpose |
|---|---|---|---|
| **Tier 1** | Public | MCP `tools/list` | Core tools visible to all clients |
| **Tier 2** | Hidden | Internal catalog | Callable via ToolCall meta-tool, not in tools/list |
| **Tier 3** | Stub | Metadata only | Not implemented; roadmap/discovery for future tools |

This pattern solves a practical problem: MCP clients display all tools from `tools/list` to the user. With 50+ tools, this becomes unwieldy. The three-tier pattern exposes 5-7 meta-tools (Tier 1) while making the full catalog discoverable through those meta-tools.

## Tier 1: MCP-Registered Tools

These appear in `tools/list` and are directly callable by any MCP client.

### TypeScript Implementation

```typescript
// src/tools/meta-tools.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { toolCatalog, type CatalogEntry } from "./catalog.js";

export function registerMetaTools(server: McpServer): void {
  // ToolSummary: List all tools grouped by category
  server.tool(
    "ToolSummary",
    "List all available tools grouped by hierarchical category. Returns tool names, tiers, and brief descriptions.",
    {
      tier: z
        .enum(["all", "1", "2", "3"])
        .optional()
        .describe("Filter by tier. Default: all"),
      category: z
        .string()
        .optional()
        .describe("Filter by category prefix (e.g., 'Database')"),
    },
    async ({ tier, category }) => {
      let entries = Array.from(toolCatalog.values());

      if (tier && tier !== "all") {
        entries = entries.filter((e) => e.tier === Number(tier));
      }
      if (category) {
        entries = entries.filter((e) =>
          e.category.toLowerCase().startsWith(category.toLowerCase())
        );
      }

      // Group by category
      const groups: Record<string, Array<{ name: string; tier: number; description: string }>> = {};
      for (const entry of entries) {
        const cat = entry.category || "Uncategorized";
        if (!groups[cat]) groups[cat] = [];
        groups[cat].push({
          name: entry.name,
          tier: entry.tier,
          description: entry.description,
        });
      }

      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify(groups, null, 2),
          },
        ],
      };
    }
  );

  // ToolSearch: Search tools by text or intent
  server.tool(
    "ToolSearch",
    "Search for tools by name substring or semantic intent description.",
    {
      query: z.string().describe("Search query -- tool name substring or intent description"),
      mode: z
        .enum(["text", "intent"])
        .optional()
        .describe("Search mode. 'text' for substring match, 'intent' for semantic. Default: text"),
    },
    async ({ query, mode }) => {
      const searchMode = mode ?? "text";
      let results: CatalogEntry[];

      if (searchMode === "text") {
        const q = query.toLowerCase();
        results = Array.from(toolCatalog.values()).filter(
          (e) =>
            e.name.toLowerCase().includes(q) ||
            e.description.toLowerCase().includes(q) ||
            e.tags.some((t) => t.toLowerCase().includes(q))
        );
      } else {
        // Intent mode: return all tools and let the LLM reason about relevance
        // In a production system, this could use embeddings
        results = Array.from(toolCatalog.values()).map((e) => ({
          ...e,
          relevance_hint: `Consider if "${e.description}" matches intent "${query}"`,
        }));
      }

      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify(
              results.map((r) => ({
                name: r.name,
                tier: r.tier,
                category: r.category,
                description: r.description,
                tags: r.tags,
              })),
              null,
              2
            ),
          },
        ],
      };
    }
  );

  // ToolDefinition: Get full schema for a specific tool
  server.tool(
    "ToolDefinition",
    "Get the full JSON Schema definition for a specific tool by name.",
    {
      name: z.string().describe("Exact tool name"),
    },
    async ({ name }) => {
      const entry = toolCatalog.get(name);
      if (!entry) {
        return {
          content: [{ type: "text" as const, text: `Tool not found: ${name}` }],
          isError: true,
        };
      }

      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify(
              {
                name: entry.name,
                tier: entry.tier,
                category: entry.category,
                description: entry.description,
                inputSchema: entry.inputSchema,
                outputSchema: entry.outputSchema,
                tags: entry.tags,
                version: entry.version,
              },
              null,
              2
            ),
          },
        ],
      };
    }
  );

  // ToolHelp: Get usage instructions with examples
  server.tool(
    "ToolHelp",
    "Get detailed usage instructions and examples for a specific tool.",
    {
      name: z.string().describe("Exact tool name"),
    },
    async ({ name }) => {
      const entry = toolCatalog.get(name);
      if (!entry) {
        return {
          content: [{ type: "text" as const, text: `Tool not found: ${name}` }],
          isError: true,
        };
      }

      const help = [
        `# ${entry.name}`,
        "",
        entry.description,
        "",
        `**Tier:** ${entry.tier}`,
        `**Category:** ${entry.category}`,
        `**Tags:** ${entry.tags.join(", ")}`,
        "",
        "## Parameters",
        "```json",
        JSON.stringify(entry.inputSchema, null, 2),
        "```",
        "",
        "## Examples",
        ...(entry.examples ?? []).map(
          (ex) =>
            `### ${ex.description}\n\`\`\`json\n${JSON.stringify(ex.input, null, 2)}\n\`\`\`\nExpected output:\n\`\`\`json\n${JSON.stringify(ex.expectedOutput, null, 2)}\n\`\`\``
        ),
      ];

      return {
        content: [{ type: "text" as const, text: help.join("\n") }],
      };
    }
  );

  // ToolCall: Dispatch hidden (Tier 2) tools by name
  server.tool(
    "ToolCall",
    "Execute a hidden (Tier 2) tool by name. Use ToolSearch or ToolSummary to discover available tools.",
    {
      name: z.string().describe("Exact tool name to call"),
      arguments: z
        .record(z.unknown())
        .optional()
        .describe("Tool arguments as a JSON object"),
    },
    async ({ name, arguments: args }) => {
      const entry = toolCatalog.get(name);
      if (!entry) {
        return {
          content: [{ type: "text" as const, text: `Tool not found: ${name}` }],
          isError: true,
        };
      }

      if (entry.tier === 3) {
        return {
          content: [
            {
              type: "text" as const,
              text: `Tool "${name}" is a Tier 3 stub (not yet implemented). It is on the roadmap.`,
            },
          ],
          isError: true,
        };
      }

      if (!entry.handler) {
        return {
          content: [
            { type: "text" as const, text: `Tool "${name}" has no handler registered.` },
          ],
          isError: true,
        };
      }

      try {
        const result = await entry.handler(args ?? {});
        return {
          content: [
            { type: "text" as const, text: JSON.stringify(result, null, 2) },
          ],
        };
      } catch (error) {
        return {
          content: [
            {
              type: "text" as const,
              text: `Error calling ${name}: ${error instanceof Error ? error.message : String(error)}`,
            },
          ],
          isError: true,
        };
      }
    }
  );
}
```

### Tool Catalog

```typescript
// src/tools/catalog.ts

export interface CatalogExample {
  description: string;
  input: Record<string, unknown>;
  expectedOutput: Record<string, unknown>;
}

export interface CatalogEntry {
  name: string;
  tier: 1 | 2 | 3;
  category: string;
  description: string;
  tags: string[];
  version?: string;
  inputSchema: Record<string, unknown>;
  outputSchema?: Record<string, unknown>;
  examples?: CatalogExample[];
  handler?: (args: Record<string, unknown>) => Promise<unknown>;
  deprecated?: boolean;
  deprecatedMessage?: string;
  [key: string]: unknown;
}

export const toolCatalog = new Map<string, CatalogEntry>();

export function registerTier1(entry: Omit<CatalogEntry, "tier">): void {
  toolCatalog.set(entry.name, { ...entry, tier: 1 });
}

export function registerTier2(entry: Omit<CatalogEntry, "tier">): void {
  toolCatalog.set(entry.name, { ...entry, tier: 2 });
}

export function registerStub(entry: Omit<CatalogEntry, "tier" | "handler">): void {
  toolCatalog.set(entry.name, { ...entry, tier: 3 });
}
```

## Tier 2: Hidden Tools

Registered in the catalog but NOT in MCP's `tools/list`. Callable only through the ToolCall meta-tool.

```typescript
// src/tools/database-tools.ts
import { registerTier2 } from "./catalog.js";

// This tool is hidden from MCP tools/list
// but callable via ToolCall("Database.Query", {sql: "SELECT ..."})
registerTier2({
  name: "Database.Query",
  category: "Database",
  description: "Execute a read-only SQL query against the application database",
  tags: ["database", "database.query", "sql", "read"],
  inputSchema: {
    type: "object",
    properties: {
      sql: { type: "string", description: "SQL query (SELECT only)" },
      params: {
        type: "array",
        items: { type: "string" },
        description: "Parameterized query values",
      },
    },
    required: ["sql"],
  },
  examples: [
    {
      description: "Count users",
      input: { sql: "SELECT COUNT(*) as total FROM users" },
      expectedOutput: { rows: [{ total: 42 }] },
    },
  ],
  handler: async (args) => {
    const sql = args.sql as string;
    // Validate read-only
    if (!/^\s*SELECT/i.test(sql)) {
      throw new Error("Only SELECT queries are allowed");
    }
    // Execute query...
    return { rows: [] };
  },
});
```

## Tier 3: Stub Catalog

Metadata only. Not implemented. Used for roadmap discovery.

```typescript
// src/tools/stubs.ts
import { registerStub } from "./catalog.js";

registerStub({
  name: "Database.Migrate",
  category: "Database",
  description: "Run database migrations (planned for v2.0)",
  tags: ["database", "database.migrate", "migrations"],
  inputSchema: {
    type: "object",
    properties: {
      direction: { type: "string", enum: ["up", "down"] },
      target: { type: "string", description: "Target migration version" },
    },
    required: ["direction"],
  },
});

registerStub({
  name: "Monitoring.CreateAlert",
  category: "Monitoring",
  description: "Create a monitoring alert rule (planned for v2.0)",
  tags: ["monitoring", "monitoring.alerts", "alerting"],
  inputSchema: {
    type: "object",
    properties: {
      metric: { type: "string" },
      threshold: { type: "number" },
      operator: { type: "string", enum: ["gt", "lt", "eq"] },
    },
    required: ["metric", "threshold", "operator"],
  },
});
```

## Python Implementation

### Meta-Tools

```python
# src/tools/meta_tools.py
from src.tools.catalog import tool_catalog, CatalogEntry


def register_meta_tools(mcp) -> None:
    """Register Tier 1 meta-tools with the MCP server."""

    @mcp.tool()
    def ToolSummary(tier: str = "all", category: str | None = None) -> dict:
        """List all available tools grouped by hierarchical category.

        Args:
            tier: Filter by tier ('all', '1', '2', '3'). Default: all.
            category: Filter by category prefix (e.g., 'Database').
        """
        entries = list(tool_catalog.values())

        if tier != "all":
            entries = [e for e in entries if e["tier"] == int(tier)]
        if category:
            entries = [
                e for e in entries
                if e["category"].lower().startswith(category.lower())
            ]

        groups: dict[str, list] = {}
        for entry in entries:
            cat = entry.get("category", "Uncategorized")
            if cat not in groups:
                groups[cat] = []
            groups[cat].append({
                "name": entry["name"],
                "tier": entry["tier"],
                "description": entry["description"],
            })
        return groups

    @mcp.tool()
    def ToolSearch(query: str, mode: str = "text") -> list[dict]:
        """Search for tools by name substring or semantic intent.

        Args:
            query: Search query.
            mode: 'text' for substring match, 'intent' for semantic. Default: text.
        """
        q = query.lower()
        results = []
        for entry in tool_catalog.values():
            if mode == "text":
                if (q in entry["name"].lower()
                    or q in entry["description"].lower()
                    or any(q in t.lower() for t in entry.get("tags", []))):
                    results.append({
                        "name": entry["name"],
                        "tier": entry["tier"],
                        "category": entry["category"],
                        "description": entry["description"],
                    })
            else:
                results.append({
                    "name": entry["name"],
                    "tier": entry["tier"],
                    "description": entry["description"],
                })
        return results

    @mcp.tool()
    def ToolDefinition(name: str) -> dict:
        """Get the full JSON Schema definition for a specific tool.

        Args:
            name: Exact tool name.
        """
        entry = tool_catalog.get(name)
        if not entry:
            return {"error": f"Tool not found: {name}"}
        return {
            "name": entry["name"],
            "tier": entry["tier"],
            "category": entry["category"],
            "description": entry["description"],
            "input_schema": entry.get("input_schema", {}),
            "tags": entry.get("tags", []),
        }

    @mcp.tool()
    def ToolHelp(name: str) -> str:
        """Get detailed usage instructions and examples for a specific tool.

        Args:
            name: Exact tool name.
        """
        entry = tool_catalog.get(name)
        if not entry:
            return f"Tool not found: {name}"

        lines = [
            f"# {entry['name']}",
            "",
            entry["description"],
            f"Tier: {entry['tier']}",
            f"Category: {entry['category']}",
            f"Tags: {', '.join(entry.get('tags', []))}",
        ]
        for ex in entry.get("examples", []):
            lines.append(f"\nExample: {ex['description']}")
            lines.append(f"Input: {ex['input']}")
            lines.append(f"Expected: {ex['expected_output']}")
        return "\n".join(lines)

    @mcp.tool()
    def ToolCall(name: str, arguments: dict | None = None) -> dict:
        """Execute a hidden (Tier 2) tool by name.

        Args:
            name: Exact tool name to call.
            arguments: Tool arguments as a dictionary.
        """
        entry = tool_catalog.get(name)
        if not entry:
            return {"error": f"Tool not found: {name}"}
        if entry["tier"] == 3:
            return {"error": f"Tool '{name}' is a stub (not yet implemented)"}
        handler = entry.get("handler")
        if not handler:
            return {"error": f"Tool '{name}' has no handler"}
        try:
            return handler(arguments or {})
        except Exception as e:
            return {"error": f"Error calling {name}: {e}"}
```

### Catalog

```python
# src/tools/catalog.py
from typing import Any, Callable

CatalogEntry = dict[str, Any]

tool_catalog: dict[str, CatalogEntry] = {}


def register_tier1(entry: CatalogEntry) -> None:
    entry["tier"] = 1
    tool_catalog[entry["name"]] = entry


def register_tier2(entry: CatalogEntry) -> None:
    entry["tier"] = 2
    tool_catalog[entry["name"]] = entry


def register_stub(entry: CatalogEntry) -> None:
    entry["tier"] = 3
    tool_catalog[entry["name"]] = entry
```

## Tag Derivation

Categories like `"Database.Query"` auto-generate hierarchical tags:

```
Category: "Database.Query"
Generated tags: ["database", "database.query"]

Category: "Browser.Screenshots.Capture"
Generated tags: ["browser", "browser.screenshots", "browser.screenshots.capture"]
```

### Implementation

```typescript
function deriveTags(category: string): string[] {
  const parts = category.toLowerCase().split(".");
  const tags: string[] = [];
  for (let i = 0; i < parts.length; i++) {
    tags.push(parts.slice(0, i + 1).join("."));
  }
  return tags;
}

// Usage:
deriveTags("Database.Query")
// => ["database", "database.query"]
```

```python
def derive_tags(category: str) -> list[str]:
    parts = category.lower().split(".")
    return [".".join(parts[: i + 1]) for i in range(len(parts))]
```

## When to Use Each Tier

| Scenario | Tier | Rationale |
|---|---|---|
| Meta-tools (ToolSummary, ToolSearch, etc.) | 1 | Must be directly callable by MCP clients |
| Core tools called frequently by the LLM | 1 | Direct access, lower latency |
| Specialized tools used occasionally | 2 | Keeps tools/list clean, discoverable via meta-tools |
| Administrative/dangerous tools | 2 | Requires explicit ToolCall dispatch, adds a friction layer |
| Planned but unimplemented tools | 3 | Visible in ToolSummary for roadmap, errors clearly on call |
| Deprecated tools | 2 | Move from Tier 1 to Tier 2 during deprecation window |
