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
│   ├── agents/                     #   Agent catalog and registry
│   │   ├── __init__.py
│   │   └── catalog.py              #     Agent listing and loading
│   │
│   ├── api/                        #   FastAPI REST router
│   │   ├── __init__.py
│   │   └── router.py               #     HTTP API endpoints
│   │
│   ├── browser/                    #   Browser/network tools
│   │   ├── __init__.py
│   │   ├── ping.py                 #     URL ping tool
│   │   ├── screenshot.py           #     Page screenshot tool
│   │   ├── download.py             #     File download tool
│   │   ├── rest.py                 #     REST API client tool
│   │   ├── secrets.py              #     Secret management tool
│   │   ├── to_markdown.py          #     URL-to-markdown conversion
│   │   ├── capture.py              #     Page capture tool
│   │   ├── checkpoint.py           #     Page checkpoint/snapshot tool
│   │   ├── diff.py                 #     Page diff comparison tool
│   │   ├── interact.py             #     Browser interaction tool
│   │   └── report.py               #     Browser report generation
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
│   ├── artifacts/                  #   Versioned artifact management (CRUD + revisions)
│   │   ├── __init__.py
│   │   └── artifacts.py            #     artifact_create/get/list/add_revision
│   ├── chat/                       #   Chat rooms + messages (REST CRUD)
│   │   ├── __init__.py
│   │   └── chat.py                 #     room_list/create/get, message_list/create
│   ├── sessions/                   #   Generic session lifecycle (work-sessions)
│   │   ├── __init__.py
│   │   └── sessions.py             #     session_create/get/list/update
│   ├── tasks/                      #   Task CRUD with status tracking
│   │   ├── __init__.py
│   │   └── tasks.py                #     task_create/get/list/update_status
│   ├── pipes/                      #   Agent input/output pipe management
│   │   ├── __init__.py
│   │   └── pipes.py                #     Agent pipe CRUD and messaging
│   │
│   ├── skills/                     #   Skill validation
│   │   ├── __init__.py
│   │   └── validator.py            #     Skill syntax and structure validation
│   │
│   ├── executors/                  #   Tasker agent management (stubs)
│   └── scripts/                    #   Shell script wrappers (stubs)
│
├── npl_persona/                    # Persona simulation CLI package
│   ├── __init__.py
│   ├── cli.py                      #   CLI entry point
│   ├── persona.py                  #   Core persona simulation engine
│   ├── models.py                   #   Data models
│   ├── config.py                   #   Configuration management
│   ├── analysis.py                 #   Persona analysis tools
│   ├── journal.py                  #   Persona journal/memory system
│   ├── knowledge.py                #   Knowledge base management
│   ├── tasks.py                    #   Persona task handling
│   ├── teams.py                    #   Multi-persona team management
│   ├── templates.py                #   Persona templates
│   ├── parsers.py                  #   Input parsing utilities
│   ├── paths.py                    #   Path management
│   ├── io.py                       #   I/O utilities
│   └── compat.py                   #   Compatibility helpers
│
└── mcp.py                          # Minimal FastMCP server (hello tool, SSE on 127.0.0.1:8765)
```

## Active vs Stub Modules

Active modules with implementations:
- `agents/` — Agent catalog and registry
- `api/` — FastAPI REST router
- `artifacts/` — Versioned artifact storage (create/get/list/add_revision)
- `browser/` — Ping, Screenshot, Download, Rest, Secrets, ToMarkdown, Capture, Checkpoint, Diff, Interact, Report
- `chat/` — Chat rooms + messages REST CRUD (npl_chat_rooms / npl_chat_messages)
- `instructions/` — Instruction CRUD + versioning + vector embeddings (create/get/list/update)
- `markdown/` — Full markdown conversion, viewing, caching, filtering, image descriptions
- `meta_tools/` — Tool catalog, search (text + LLM intent), definition, help, summaries, caching
- `npl/` — NPL YAML loading, syntax parsing, reference resolution
- `pipes/` — Agent input/output pipe management
- `pm_tools/` — PRD, user story, and persona access (file-based + database-backed)
- `sessions/` — Generic work-session lifecycle (npl_generic_sessions)
- `skills/` — Skill validation tools
- `storage/` — PostgreSQL async connection pool
- `tasks/` — Task CRUD with status transitions (npl_tasks)
- `tool_sessions/` — Tool session lifecycle and project management
- `launcher.py` — Server lifecycle management
- `convention_formatter.py` — NPL convention YAML formatting

Separate package:
- `npl_persona/` — Persona simulation CLI (analysis, journal, knowledge, teams, templates)

Stub modules (tools raise `NotImplementedError`):
- `executors/`, `scripts/`
