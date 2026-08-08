# Tool Catalog Explorer

| Field | Value |
|-------|-------|
| **ID** | `tool-catalog-explorer` |
| **Category** | AI-Specific |
| **Used In** | 08-mcp-api-keys-setup, 40-mock-mcp-builder |

## Description

Browses the MCP tool surface exposed by a key or a mock server, supporting both keyword and semantic search over tool names/descriptions. On MCP API Keys & Setup it lists live tools on a minted key; on Mock MCP Builder it lists the tools the builder inferred from a prose description, pending review.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Search box plus result list |
| **Expanded** | Results list wired to an adjacent Tool Definition Panel for the selected tool |

## Props / Configuration

- `tools` — the catalog to search (live key tools, or generated tool candidates)
- `searchMode` — `keyword` \| `semantic`
- `onSelectTool`

## Interactions

- User searches by keyword or semantic intent → results filter live
- User selects a tool → the paired Tool Definition Panel opens with its full schema
