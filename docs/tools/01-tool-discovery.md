# Tool Discovery

The meta-discovery layer is always MCP-visible — these tools are the entry point for finding and invoking all other tools across every domain.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `ToolSummary` | visible | Browse tools by domain; drill into categories |
| `ToolSearch` | visible | Search tools by name, description, or intent |
| `ToolDefinition` | visible | Get full parameter schema for a tool |
| `ToolCall` | visible | Invoke any hidden tool by name with arguments |
| `ToolHelp` | visible | LLM-driven usage guidance for a tool |

---

### ToolSummary

Browse the tool catalog grouped by domain. Supports drilling into a specific domain or category, and inspecting individual tool details.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `filter` | str | no | Domain, category, or `Category#ToolName` to drill into. Comma-separated for multiple. Empty returns all domains. |

**Examples:**
- `ToolSummary()` — all tools grouped by domain
- `ToolSummary(filter="Ticket")` — all Ticket.* tools
- `ToolSummary(filter="Ticket#Ticket.Create")` — full definition of Ticket.Create
- `ToolSummary(filter="Chat,Review")` — multiple domains

---

### ToolSearch

Search the catalog by substring match or LLM-powered intent matching. Returns ranked results with name, description, and category.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `query` | str | yes | Search term or natural-language intent |
| `mode` | str | no | `"text"` (substring, default) or `"intent"` (LLM-powered semantic search) |
| `limit` | int | no | Max results to return (default 10) |

---

### ToolDefinition

Get the full parameter schema for one or more tools by name. Returns parameter names, types, required flags, and descriptions.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `tool` | str | yes | Tool name or comma-separated list of tool names |

---

### ToolCall

Invoke any hidden (discoverable) tool by name. This is the primary way to call domain tools that are not MCP-visible.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `tool` | str | yes | Exact tool name (e.g., `"Ticket.Create"`) |
| `arguments` | dict | no | Tool-specific arguments as a JSON object |

**Notes:**
- Supports alias resolution — old tool names (e.g., `Tasks.Create`) resolve to new names
- Returns the tool's result directly

---

### ToolHelp

Generate LLM-driven usage instructions for a tool applied to a specific task. Describes how to combine tools to accomplish a goal.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `task` | str | yes | Natural-language description of what you want to accomplish |
| `tool` | str | no | Specific tool to get help for. If omitted, recommends tools for the task. |
