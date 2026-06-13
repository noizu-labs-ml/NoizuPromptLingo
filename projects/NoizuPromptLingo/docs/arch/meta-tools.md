# Meta Tool Architecture

## Overview

Instead of registering all 125 tools directly (which overwhelms clients with large tool lists), the NPL MCP server uses a **three-tier tool pattern**: 11 MCP-visible tools are registered at startup, 22 hidden tools are callable via `ToolCall`, and 92 stub tools are discoverable but return stub status. All tools are unified into a single catalog by `build_catalog()`. Every MCP-registered tool additionally carries FastMCP 3.x-native `tags` (derived from the NPL category hierarchy) and `meta` keys (`npl_category`, `npl_discoverable`).

```
Client ──MCP──> ToolSummary / ToolSearch / ToolCall
                       │
                       ▼
              Unified Catalog (125 tools)
              ┌──────────────────────────────┐
              │ MCP-Visible (11)             │
              │   Discovery (5), NPLSpec,    │
              │   ToolSessions (2),          │
              │   Instructions (3)           │
              │ Hidden/Discoverable (22)     │
              │   Browser (5): ToMarkdown,   │
              │     Ping, Download,          │
              │     Screenshot, Rest         │
              │   Utility (1): Secret        │
              │   Instructions (3): Update,  │
              │     ActiveVersion, Versions  │
              │   Project Management (13)    │
              │     Projects (3),            │
              │     UserPersonas (5),        │
              │     UserStories (5)          │
              │ Stubs (92)                   │
              │   Scripts (5), Artifacts (5),│
              │   Reviews (6), Sessions (4), │
              │   Chat (8), Browser.* (32),  │
              │   Task Queues (13),          │
              │   Executors (11),            │
              │   PM file-based (8)          │
              └──────────────────────────────┘
```

## Registration Mechanisms

| Mechanism | Used For | What It Does |
|-----------|----------|--------------|
| `@mcp_discoverable(mcp, name=, category=, ...)` | The 11 MCP-visible tools in `launcher.py` | Applies `@mcp.tool(tags=..., meta=...)` + `@discoverable(mcp_registered=True)`, auto-derives tags/meta from NPL category |
| `register_discoverable(name, category=, fn=, ...)` | The 22 hidden tools in `discoverable_tools.py` | Records tool in `_DISCOVERABLE_TOOLS`; tags auto-derived from category; stays hidden from FastMCP `tools/list` |
| `STUB_CATALOG` entries | The 92 stub tools in `stub_catalog.py` | Static data read by `build_catalog()`; tags applied at catalog-build time |

## Discovery Tools

These 5 discovery tools are part of the 11 MCP-visible tools:

| Tool | Purpose |
|------|---------|
| **ToolSummary** | Browse catalog: list tools by category, drill into subcategories, look up single tool |
| **ToolSearch** | Search by text (substring) or intent (LLM-powered semantic) |
| **ToolDefinition** | Get full definitions for one or more catalog tools by name |
| **ToolHelp** | Get LLM-driven instructions on how to use a tool for a specific task |
| **ToolCall** | Call any catalog tool by name; returns dispatched result, `"mcp"`, `"stub"`, or `"error"` |

## ToolCall Status Values

`ToolCall` distinguishes four outcomes:

| Status | Condition | Client Action |
|--------|-----------|---------------|
| (dispatched result) | Tool is in `_DISCOVERABLE_TOOLS` | Use the returned result directly |
| `"mcp"` | Tool is MCP-registered | Call it directly via the MCP `tools/call` protocol instead |
| `"stub"` | Tool is in `STUB_CATALOG` only | No implementation available; await future version |
| `"error"` | Tool name not found or invocation failed | Check name or argument shape |

## File Structure

```
src/npl_mcp/
├── launcher.py                    # create_app() — 11 MCP tools via @mcp_discoverable
├── convention_formatter.py        # NPLSpec tool — NPL definition generation
├── meta_tools/
│   ├── __init__.py                # exports catalog helpers
│   ├── catalog.py                 # @discoverable, @mcp_discoverable, register_discoverable,
│   │                              #   build_catalog(), call_tool(), _category_to_tags()
│   ├── discoverable_tools.py      # register_all() — 22 hidden tools
│   ├── stub_catalog.py            # 92 stub tool definitions (STUB_CATALOG + STUB_CATEGORIES)
│   ├── summary.py                 # tool_summary() implementation
│   ├── search.py                  # tool_search() implementation (text + LLM intent)
│   ├── definition.py              # tool_definition() implementation
│   ├── help.py                    # tool_help() implementation
│   ├── inference_cache.py         # In-memory LLM response cache
│   └── llm_client.py              # LiteLLM proxy: chat_completion(), describe_image()
└── markdown/
    └── image_descriptions.py      # ImageDescriptionCache + inject_image_descriptions()
```

## Catalog Data Model

`ToolEntry` (TypedDict, `total=False`) — every entry in the unified catalog:

| Field | Required | Source |
|-------|----------|--------|
| `name` | yes | Tool name |
| `category` | yes | NPL hierarchical category (e.g. `"Browser.Screenshots"`) |
| `description` | yes | One-line description |
| `parameters` | yes | `list[ToolParam]` — extracted from signature, JSON schema, or stub definition |
| `tags` | optional | Auto-derived from category hierarchy (e.g. `{"browser", "browser.screenshots"}`) |
| `title` | optional | From FastMCP `Tool.title` if set |
| `version` | optional | From FastMCP `Tool.version` if set |

## ToolSummary Behavior

### Default (no arguments)
Returns all non-Discovery tools grouped by category:
```json
{
  "categories": {
    "NPL": [{"name": "NPLSpec", "description": "..."}],
    "Browser": [{"name": "ToMarkdown", ...}, ...],
    "Instructions": [...],
    ...
  }
}
```

### Category drill-down
`ToolSummary(filter="Browser")` expands a category to show its tools and subcategories:
```json
{
  "category": "Browser",
  "tool_count": 37,
  "tools": [/* direct tools: ToMarkdown, Ping, Download, Screenshot, Rest */],
  "subcategories": [
    {"name": "Browser.Screenshots", "tool_count": 3},
    {"name": "Browser.Navigation", "tool_count": 5},
    ...
  ]
}
```

### Comma-separated multi-query
`ToolSummary(filter="Scripts,Browser#ToMarkdown")` returns multiple results in a single call:
```json
{
  "results": [
    {"category": "Scripts", "tool_count": 5, "tools": [...]},
    {"name": "ToMarkdown", "category": "Browser", "parameters": [...]}
  ]
}
```

### Single tool lookup
`ToolSummary(filter="Browser#ToMarkdown")` returns the full definition including parameters:
```json
{
  "name": "ToMarkdown",
  "category": "Browser",
  "description": "...",
  "parameters": [
    {"name": "source", "type": "str", "required": true, "description": "..."},
    ...
  ]
}
```

## ToolSearch Modes

### Text mode (default)
Case-insensitive substring matching against tool names and descriptions. Priority: exact name > partial name > description match.

### Intent mode
LLM-powered semantic search through LiteLLM proxy. Sends the full catalog to an LLM with the user's natural language query. Returns relevance-ranked results with explanations of how each tool helps. Falls back to text search on LLM timeout/error.

## Image Description System

`ToMarkdown` supports `with_image_descriptions=True` to inject LLM-generated descriptions after each `![alt](url)` image reference in the output markdown.

### Cache
- **File**: `.tmp/cache/image_descriptions.yaml`
- **Key**: `"{image_uri}::{model}"`
- **Value**: `{description: str, created_at: str}`
- Persists across sessions, checked before calling LLM

### Flow
1. Parse markdown for `![alt](uri)` patterns
2. Check YAML cache for each image+model pair
3. Cache miss: call `describe_image()` via LiteLLM (multimodal LLM)
4. Inject: `![alt](uri)\n\n> **Image**: {description}\n`
5. Graceful degradation: LLM failures skip description (don't break the document)

## LiteLLM Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `NPL_LITELLM_URL` | `http://localhost:4111/v1` | LiteLLM proxy base URL |
| `NPL_LITELLM_KEY` | `sk-litellm-master-key-12345` | API key |
| `NPL_LITELLM_MODEL` | `groq/openai/gpt-oss-120b` | Default model for intent search |

Image descriptions use a separate multimodal model parameter passed through the same LiteLLM proxy.

## FastMCP 3.x Integration

The catalog layer stays **independent of FastMCP's `AggregateProvider`** because:

- Our hidden-but-callable semantic has no native 3.x equivalent (`enabled=False` would make tools uncallable via `mcp.call_tool()`).
- Stubs are catalog data, not `Tool` objects — `AggregateProvider` only merges providers that return Tools.
- Hierarchical categories (`Browser.Screenshots`) need to coexist with flat tags; we populate both.

`build_catalog()` consumes `await mcp.list_tools()` (3.x API) and reads each tool's native `tags`, `title`, and `version` onto the `ToolEntry`. MCP-native clients can filter by `meta["npl_category"]` or `meta["fastmcp"]["tags"]` (the wire-format location for FastMCP tags).

## Category Reference

| Category | Implemented | Stubs | Description |
|----------|-------------|-------|-------------|
| Discovery | 5 (MCP) | 0 | ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall |
| NPL | 1 (MCP) | 0 | NPLSpec — NPL definition generation |
| ToolSessions | 2 (MCP) | 0 | Session generate + retrieve |
| Instructions | 3 (MCP) + 3 (hidden) | 0 | CRUD + versioning + embeddings search |
| Project Management | 13 (hidden) | 8 | DB: Projects (3), Personas (5), Stories (5); Stubs: file-based PM tools |
| Browser | 5 (hidden) | 32 | ToMarkdown, Ping, Download, Screenshot, Rest + 8 stub subcategories |
| Utility | 1 (hidden) | 0 | Secret management |
| Scripts | 0 | 5 | Shell script wrappers |
| Artifacts | 0 | 5 | Versioned artifact management |
| Reviews | 0 | 6 | Review workflows |
| Sessions | 0 | 4 | Session lifecycle |
| Chat | 0 | 8 | Event-sourced chat rooms |
| Task Queues | 0 | 13 | Task queue management |
| Executors | 0 | 11 | Agent lifecycle management |

**Total**: 125 tools (11 MCP-visible, 22 hidden via ToolCall, 92 stubs)
