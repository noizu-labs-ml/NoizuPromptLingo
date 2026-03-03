# Meta Tool Architecture

## Overview

Instead of registering all ~124 tools directly (which overwhelms clients with large tool lists), the NPL MCP server uses a **three-tier tool pattern**: 11 MCP-visible tools are registered at startup, 21 hidden tools are callable via `ToolCall`, and 92 stub tools are discoverable but return stub status. All tools are unified into a single catalog by `build_catalog()`.

```
Client ──MCP──> ToolSummary / ToolSearch / ToolCall
                       │
                       ▼
              Unified Catalog (~124 tools)
              ┌──────────────────────────────┐
              │ MCP-Visible (11)             │
              │   Discovery (5), NPLSpec,    │
              │   Sessions (2), Instructions (3) │
              │ Hidden/Discoverable (21)     │
              │   Browser (5): ToMarkdown,   │
              │     Ping, Download, Screenshot, Rest │
              │   Utility (1): Secret        │
              │   Instructions (3)           │
              │   Project Management (12)    │
              │ Stubs (92)                   │
              │   Scripts (5), Artifacts (5),│
              │   Reviews (6), Sessions (4), │
              │   Chat (8), Browser.* (28),  │
              │   Task Queues (13),          │
              │   Executors (11)             │
              └──────────────────────────────┘
```

## Discovery Tools

These 5 discovery tools are part of the 11 MCP-visible tools:

| Tool | Purpose |
|------|---------|
| **ToolSummary** | Browse catalog: list exposed tools, drill into categories, look up single tool |
| **ToolSearch** | Search by text (substring) or intent (LLM-powered semantic) |
| **ToolDefinition** | Get full definitions for one or more catalog tools by name |
| **ToolHelp** | Get LLM-driven instructions on how to use a tool for a specific task |
| **ToolCall** | Call any catalog tool by name, whether pinned or not |

## Exposed Tools

Five browser tools are highlighted in ToolSummary's default view (no filter argument). These are hidden tools callable via ToolCall:

| Tool | Category | Description |
|------|----------|-------------|
| **ToMarkdown** | Browser | Convert URL/file to markdown with filter, collapse, image descriptions |
| **Ping** | Browser | Check connectivity to a URL with optional sentinel validation |
| **Download** | Browser | Download URL or copy file to local path |
| **Screenshot** | Browser | Capture screenshot of URL with Playwright, optional resize |
| **Rest** | Browser | Full HTTP client with `${secret.NAME}` placeholder injection |

These are discoverable via ToolSummary/ToolSearch and callable via ToolCall.

## File Structure

```
src/npl_mcp/
├── launcher.py                    # create_app() — 11 MCP tools, create_asgi_app()
├── convention_formatter.py        # NPLSpec tool — NPL definition generation
├── meta_tools/
│   ├── __init__.py                # exports discoverable, build_catalog, init_catalog
│   ├── catalog.py                 # @discoverable decorator, build_catalog(), call_tool()
│   ├── discoverable_tools.py      # register_all() — 22 hidden tools
│   ├── stub_catalog.py            # 93 stub tool definitions
│   ├── summary.py                 # tool_summary() implementation
│   ├── search.py                  # tool_search() implementation
│   ├── definition.py              # tool_definition() implementation
│   ├── help.py                    # tool_help() implementation
│   ├── inference_cache.py         # In-memory LLM response cache
│   └── llm_client.py             # LiteLLM proxy: chat_completion(), describe_image()
└── markdown/
    └── image_descriptions.py      # ImageDescriptionCache + inject_image_descriptions()
```

## ToolSummary Behavior

### Default (no arguments)
Returns the 4 exposed tools with name and description:
```json
{
  "total_tools": 4,
  "tools": [
    {"name": "ToMarkdown", "description": "Convert file/URL to markdown..."},
    {"name": "Ping", "description": "Check connectivity to a URL."},
    ...
  ]
}
```

### Category drill-down
`ToolSummary(filter="Browser")` expands a category:
```json
{
  "category": "Browser",
  "tool_count": 36,
  "tools": [/* 4 direct tools: ToMarkdown, Ping, Download, Screenshot */],
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
`ToolSummary(filter="Browser#ToMarkdown")` returns full definition with parameters:
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
Case-insensitive substring matching against exposed tool names and descriptions. Priority: exact name > partial name > description match.

### Intent mode
LLM-powered semantic search through LiteLLM proxy. Sends the full exposed tool catalog to an LLM with the user's natural language query. Returns relevance-ranked results with explanations of how each tool helps. Falls back to text search on LLM timeout/error.

## Image Description System

ToMarkdown supports `with_image_descriptions=True` to inject LLM-generated descriptions after each `![alt](url)` image reference in the output markdown.

### Cache
- **File**: `.tmp/cache/image_descriptions.yaml`
- **Key**: `"{image_uri}::{model}"`
- **Value**: `{description: str, created_at: str}`
- Persists across sessions, checked before calling LLM

### Flow
1. Parse markdown for `![alt](uri)` patterns
2. Check YAML cache for each image+model pair
3. Cache miss: call `describe_image()` via LiteLLM (multi-modal LLM)
4. Inject: `![alt](uri)\n\n> **Image**: {description}\n`
5. Graceful degradation: LLM failures skip description (don't break document)

## LiteLLM Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `NPL_LITELLM_URL` | `http://localhost:4111/v1` | LiteLLM proxy base URL |
| `NPL_LITELLM_KEY` | `sk-litellm-master-key-12345` | API key |
| `NPL_LITELLM_MODEL` | `groq/openai/gpt-oss-120b` | Default model for intent search |

Image descriptions use a separate model parameter (default `openai/GPT5.2`) passed through the same LiteLLM proxy.

## Category Reference

| Category | Implemented | Stubs | Description |
|----------|-------------|-------|-------------|
| Discovery | 5 (MCP) | 0 | ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall |
| NPL | 1 (MCP) | 0 | NPLSpec — NPL definition generation |
| Tool Sessions | 2 (MCP) | 0 | Session generate + retrieve |
| Instructions | 3 (MCP) + 3 (hidden) | 0 | CRUD + versioning + embeddings search |
| Project Management | 13 (hidden) | 0 | Projects (3), Personas (5), Stories (5) — DB-backed |
| Browser | 5 (hidden) | ~28 | ToMarkdown, Ping, Download, Screenshot, Rest |
| Utility | 1 (hidden) | 0 | Secret management |
| Scripts | 0 | 5 | Shell script wrappers |
| Artifacts | 0 | 5 | Versioned artifact management |
| Reviews | 0 | 6 | Review workflows |
| Sessions | 0 | 4 | Session lifecycle |
| Chat | 0 | 8 | Event-sourced chat rooms |
| Task Queues | 0 | 13 | Task queue management |
| Executors | 0 | 11 | Agent lifecycle management |

**Total**: ~126 tools (11 MCP-visible, ~22 hidden via ToolCall, ~93 stubs)
