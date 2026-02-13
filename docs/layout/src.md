# Source Code Layout

```
src/
├── npl_mcp/                        # Main NPL MCP package
│   ├── __init__.py                 #   Package init
│   ├── __main__.py                 #   Module entry point (`python -m npl_mcp`)
│   ├── launcher.py                 #   CLI entry point — PID mgmt, Uvicorn, --status/--stop
│   │
│   ├── markdown/                   #   Markdown processing tools
│   │   ├── __init__.py
│   │   ├── converter.py            #     Document-to-markdown conversion
│   │   ├── viewer.py               #     Filtered markdown viewing
│   │   ├── cache.py                #     Conversion result caching
│   │   ├── image_descriptions.py   #     Image description extraction
│   │   └── filters/                #     Content filtering engines
│   │       ├── __init__.py
│   │       ├── css.py              #       CSS selector filtering
│   │       ├── heading.py          #       Heading-path filtering
│   │       └── xpath.py            #       XPath filtering
│   │
│   ├── meta_tools/                 #   MCP tool discovery/catalog
│   │   ├── __init__.py
│   │   ├── catalog.py              #     Tool catalog management
│   │   ├── search.py               #     Tool search (text + intent)
│   │   ├── summary.py              #     Tool summary generation
│   │   └── llm_client.py           #     LLM client for intent search
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
│   │   ├── personas.py             #     Persona CRUD tools
│   │   ├── prds.py                 #     PRD access tools
│   │   ├── stories.py              #     User story tools
│   │   ├── utils.py                #     Shared utilities
│   │   └── exceptions.py           #     PM-specific exceptions
│   │
│   ├── web/                        #   Web interface
│   │   ├── static/                 #     Built frontend assets (gitignored)
│   │   └── .gitignore
│   │
│   ├── storage/                    #   PostgreSQL async wrapper (asyncpg)
│   ├── artifacts/                  #   Versioned artifact management (stubs)
│   ├── browser/                    #   Browser automation (stubs)
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
- `markdown/` — Full markdown conversion, viewing, caching, filtering
- `meta_tools/` — Tool catalog, search (text + LLM intent), summaries
- `npl/` — NPL YAML loading, syntax parsing, reference resolution
- `pm_tools/` — PRD, user story, and persona access via MCP tools
- `launcher.py` — Server lifecycle management

Stub modules (contain `__pycache__` only, tools raise `NotImplementedError`):
- `artifacts/`, `browser/`, `chat/`, `executors/`, `scripts/`, `sessions/`, `storage/`, `tasks/`
