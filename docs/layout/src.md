# Source Code Layout

```
src/
├── npl_mcp/                        # Main NPL MCP package
│   ├── __init__.py                 #   Package init
│   ├── __main__.py                 #   Module entry point (`python -m npl_mcp`)
│   ├── launcher.py                 #   CLI entry point — PID mgmt, Uvicorn, --status/--stop
│   ├── convention_formatter.py     #   NPL convention YAML formatter
│   │
│   ├── markdown/                   #   Markdown processing tools
│   │   ├── __init__.py
│   │   ├── converter.py            #     Document-to-markdown conversion
│   │   ├── viewer.py               #     Filtered markdown viewing
│   │   ├── cache.py                #     Conversion result caching
│   │   ├── image_descriptions.py   #     LLM-powered image description (YAML-cached)
│   │   └── filters/                #     Content filtering engines
│   │       ├── __init__.py
│   │       ├── css.py              #       CSS selector filtering
│   │       ├── heading.py          #       Heading-path filtering
│   │       └── xpath.py            #       XPath filtering
│   │
│   ├── meta_tools/                 #   MCP tool discovery/catalog layer
│   │   ├── __init__.py
│   │   ├── catalog.py              #     Static catalog (104 tools, 19 categories)
│   │   ├── summary.py              #     ToolSummary: exposed tools + category drill-down
│   │   ├── search.py               #     ToolSearch: text + intent (LLM) modes
│   │   ├── definition.py           #     ToolDefinition: batch param lookup
│   │   ├── help.py                 #     ToolHelp: LLM-driven usage instructions
│   │   ├── discoverable_tools.py   #     Dynamic tool discovery and registration
│   │   ├── stub_catalog.py         #     Stub catalog for testing/fallback
│   │   ├── inference_cache.py      #     In-memory LLM cache (MD5-keyed)
│   │   └── llm_client.py           #     LiteLLM client (chat_completion, describe_image)
│   │
│   ├── npl/                        #   NPL syntax parser and loader
│   │   ├── __init__.py
│   │   ├── loader.py               #     Load NPL YAML specifications
│   │   ├── parser.py               #     Parse NPL syntax elements
│   │   ├── resolver.py             #     Resolve NPL references
│   │   ├── layout.py               #     NPL layout utilities
│   │   ├── filters.py              #     NPL content filters
│   │   └── exceptions.py           #     NPL-specific exceptions
│   │
│   ├── pm_tools/                   #   Project management MCP tools
│   │   ├── __init__.py
│   │   ├── personas.py             #     Persona CRUD tools (file-based)
│   │   ├── db_personas.py          #     Persona tools (database-backed)
│   │   ├── prds.py                 #     PRD access tools
│   │   ├── stories.py              #     User story tools (file-based)
│   │   ├── db_stories.py           #     User story tools (database-backed)
│   │   ├── db_projects.py          #     Project management tools (database-backed)
│   │   ├── utils.py                #     Shared utilities
│   │   └── exceptions.py           #     PM-specific exceptions
│   │
│   ├── browser/                    #   Browser/network tools (implemented)
│   │   ├── __init__.py
│   │   ├── ping.py                 #     URL ping tool
│   │   ├── screenshot.py           #     Page screenshot tool
│   │   ├── download.py             #     File download tool
│   │   ├── rest.py                 #     REST API client tool
│   │   ├── secrets.py              #     Secret management tool
│   │   └── to_markdown.py          #     URL-to-markdown conversion
│   │
│   ├── instructions/               #   Instruction management
│   │   ├── __init__.py
│   │   ├── instructions.py         #     Instruction CRUD and retrieval
│   │   └── embeddings.py           #     Vector embedding support
│   │
│   ├── tool_sessions/              #   Tool session management
│   │   ├── __init__.py
│   │   ├── tool_sessions.py        #     Session lifecycle and tracking
│   │   └── projects.py             #     Project-scoped session management
│   │
│   ├── storage/                    #   PostgreSQL async wrapper (asyncpg)
│   │   ├── __init__.py
│   │   └── pool.py                 #     Connection pool singleton
│   │
│   ├── web/                        #   Web interface
│   │   ├── static/                 #     Built frontend assets (gitignored)
│   │   └── .gitignore
│   │
│   ├── artifacts/                  #   Versioned artifact management (stubs)
│   ├── chat/                       #   Event-sourced chat rooms (stubs)
│   ├── executors/                  #   Tasker agent management (stubs)
│   ├── scripts/                    #   Shell script wrappers (stubs)
│   ├── sessions/                   #   Session lifecycle (stubs)
│   └── tasks/                      #   Task queues (stubs)
│
└── mcp.py                          # Minimal FastMCP server (hello tool, SSE on 127.0.0.1:8765)
```

## Active vs Stub Modules

Active modules with implementations:
- `markdown/` — Full markdown conversion, viewing, caching, filtering, image descriptions
- `meta_tools/` — Tool catalog, search (text + LLM intent), definition, help, summaries, caching
- `npl/` — NPL YAML loading, syntax parsing, reference resolution
- `pm_tools/` — PRD, user story, and persona access (file-based + database-backed)
- `instructions/` — Instruction management with vector embeddings
- `tool_sessions/` — Tool session lifecycle and project management
- `browser/` — Ping, Screenshot, Download, Rest, Secrets, ToMarkdown
- `storage/` — PostgreSQL async connection pool
- `launcher.py` — Server lifecycle management
- `convention_formatter.py` — NPL convention YAML formatting

Stub modules (tools raise `NotImplementedError`):
- `artifacts/`, `chat/`, `executors/`, `scripts/`, `sessions/`, `tasks/`
