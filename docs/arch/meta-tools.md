# Meta Tool Architecture

## Overview

Instead of registering all ~103 MCP tools directly (which overwhelms clients with large tool lists), the NPL MCP server uses a **meta tool pattern**: discovery tools are visible at startup. All catalog tools are callable on the same server scope and discoverable through these discovery tools.

```
Client ──MCP──> ToolSummary / ToolSearch
                       │
                       ▼
              Static TOOL_CATALOG (96 tools)
              ┌─────────────────────────┐
              │ Scripts (5)             │
              │ Artifacts (5)           │
              │ Reviews (6)             │
              │ Sessions (4)            │
              │ Chat (8)                │
              │ Browser (36)            │
              │   ├─ Screenshots (3)    │
              │   ├─ Navigation (5)     │
              │   ├─ Input (7)          │
              │   ├─ Query (5)          │
              │   ├─ Session (3)        │
              │   ├─ Wait (2)           │
              │   ├─ Inject (2)         │
              │   ├─ Storage (5)        │
              │   └─ [4 exposed tools]  │
              │ Task Queues (13)        │
              │ Executors (11)          │
              │ Project Management (8)  │
              └─────────────────────────┘
```

## Registered MCP Tools

These 5 discovery tools are visible to MCP clients at startup:

| Tool | Purpose |
|------|---------|
| **ToolSummary** | Browse catalog: list exposed tools, drill into categories, look up single tool |
| **ToolSearch** | Search by text (substring) or intent (LLM-powered semantic) |
| **ToolDefinition** | Get full definitions for one or more catalog tools by name |
| **ToolHelp** | Get LLM-driven instructions on how to use a tool for a specific task |
| **ToolCall** | Call any catalog tool by name, whether pinned or not |

## Exposed Tools

Four tools are highlighted in ToolSummary's default view (no filter argument). These are the "recommended" utility tools that clients should know about:

| Tool | Category | Description |
|------|----------|-------------|
| **ToMarkdown** | Browser | Convert URL/file to markdown with filter, collapse, image descriptions |
| **Ping** | Browser | Check connectivity to a URL |
| **Download** | Browser | Download URL or copy file to local path |
| **Screenshot** | Browser | Capture screenshot of URL with optional resize |

These are discoverable via ToolSummary/ToolSearch and callable on the same server scope via ToolCall.

## File Structure

```
src/npl_mcp/
├── launcher.py                    # create_app() - ToolSummary, ToolSearch, ToolCall
├── meta_tools/
│   ├── __init__.py                # exports tool_summary, tool_search, tool_pin
│   ├── catalog.py                 # CATEGORIES, TOOL_CATALOG, EXPOSED_TOOL_NAMES
│   ├── summary.py                 # tool_summary() implementation
│   ├── search.py                  # tool_search() implementation
│   ├── pin.py                     # tool_pin(), CatalogStubTool, CORE_TOOLS
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

| Category | Tools | Description |
|----------|-------|-------------|
| Scripts | 5 | Shell script wrappers |
| Artifacts | 5 | Versioned artifact management |
| Reviews | 6 | Review workflows |
| Sessions | 4 | Session lifecycle |
| Chat | 8 | Event-sourced chat rooms |
| Browser | 36 | Browser automation + utility tools |
| Browser.Screenshots | 3 | Capture and compare screenshots |
| Browser.Navigation | 5 | Navigate, scroll, history |
| Browser.Input | 7 | Click, type, form interaction |
| Browser.Query | 5 | Read text, HTML, evaluate JS |
| Browser.Session | 3 | Browser session management |
| Browser.Wait | 2 | Wait for elements/network |
| Browser.Inject | 2 | Inject JS/CSS |
| Browser.Storage | 5 | Cookies and localStorage |
| Task Queues | 13 | Task queue management |
| Executors | 11 | Agent lifecycle management |
| Project Management | 8 | PRDs, stories, personas |

**Total**: 103 tools (5 discovery visible at startup, all callable via ToolCall)
