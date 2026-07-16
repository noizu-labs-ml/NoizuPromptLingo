# Tool Definition Panel

| Field | Value |
|-------|-------|
| **ID** | `tool-definition-panel` |
| **Category** | AI-Specific |
| **Used In** | 08-mcp-api-keys-setup, 40-mock-mcp-builder |

## Description

Full schema and contextual help for a single MCP tool. Read-only when inspecting a live key's tool (MCP API Keys & Setup); editable when refining a generated tool's schema before publishing a mock server (Mock MCP Builder).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full schema view/editor with parameter list and descriptions |

## Props / Configuration

- `tool` — the selected tool's schema/definition
- `editable` — enables manual refinement of the schema instead of read-only display

## Interactions

- Read-only mode: user reviews the schema and contextual help for understanding/integration purposes
- Editable mode: user modifies fields/parameters, then the containing screen's publish action persists the change
