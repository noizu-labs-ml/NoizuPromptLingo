# lib/ — Elixir Source

```
lib/
├── noizu_prompt_lingua/
│   ├── domains/                    # MCP domain modules (business logic + tools)
│   │   ├── agents/                 #   Agent orchestration domain
│   │   │   ├── tools/              #     MCP tool handlers
│   │   │   └── agents.ex           #     Domain logic
│   │   ├── artifacts/              #   Versioned content objects
│   │   │   ├── tools/
│   │   │   ├── artifacts.ex
│   │   │   └── mcp.ex             #     MCP server registration
│   │   ├── assets/                 #   Media prompt entries, generation, publishing
│   │   │   ├── tools/
│   │   │   ├── assets.ex
│   │   │   ├── content_generator.ex
│   │   │   └── mcp.ex
│   │   ├── chat/                   #   Rooms, messages, events, notifications
│   │   │   ├── tools/
│   │   │   ├── chat.ex
│   │   │   └── mcp.ex
│   │   ├── mock_mcp/               #   Mock MCP tool definitions for testing
│   │   │   ├── tools/
│   │   │   ├── agent.ex
│   │   │   └── mock_mcp.ex
│   │   ├── projects/               #   Project CRUD + membership
│   │   │   ├── tools/
│   │   │   ├── mcp.ex
│   │   │   └── projects.ex
│   │   ├── review/                 #   Code review, overlays, comments
│   │   │   ├── tools/
│   │   │   ├── mcp.ex
│   │   │   └── reviews.ex
│   │   ├── sessions/               #   Work sessions grouping rooms/artifacts/tickets
│   │   │   ├── tools/
│   │   │   ├── mcp.ex
│   │   │   └── sessions.ex
│   │   ├── tickets/                #   Ticket queues, types, custom fields
│   │   │   ├── tools/
│   │   │   ├── definitions.ex      #     Field/type definition logic
│   │   │   ├── mcp.ex
│   │   │   ├── queues.ex
│   │   │   ├── seed.ex             #     Default ticket type seeding
│   │   │   └── tickets.ex
│   │   └── wiki/                   #   Spaces, pages, permissions
│   │       ├── tools/
│   │       ├── mcp.ex
│   │       └── wiki.ex
│   ├── npl/                        # NPL convention engine
│   │   ├── convention_formatter.ex #   YAML → formatted output
│   │   ├── definition.ex           #   Convention struct
│   │   ├── layout.ex               #   Layout helpers
│   │   ├── loader.ex               #   YAML file loader
│   │   ├── parser.ex               #   Convention parser
│   │   └── resolver.ex             #   Convention lookup
│   ├── plugs/
│   │   └── mcp_token_verifier.ex   # API key authentication plug
│   ├── schema/                     # Ecto schemas (35 files)
│   │   ├── session.ex              #   Sessions (+ project_id FK)
│   │   ├── project.ex              #   Projects (slug, owner)
│   │   ├── project_member.ex       #   Project membership (roles, invites)
│   │   ├── ticket.ex               #   Tickets (project-scoped)
│   │   ├── artifact.ex             #   Artifacts (project-scoped)
│   │   ├── user.ex                 #   Users
│   │   ├── mcp_api_key.ex          #   API keys for MCP auth
│   │   └── ...                     #   Chat, review, wiki, agent, asset schemas
│   ├── services/                   # Cross-cutting services
│   │   ├── attach.ex               #   Attachment handling
│   │   ├── comment.ex              #   Polymorphic comments
│   │   └── watch.ex                #   Watch/subscribe
│   ├── tools/                      # Root MCP tool handlers
│   │   ├── catalog.ex              #   Tool catalog/discovery
│   │   ├── npl_load.ex             #   Load NPL conventions
│   │   ├── npl_spec.ex             #   NPL specification lookup
│   │   ├── tool_call.ex            #   Generic tool invocation
│   │   ├── tool_definition.ex      #   Tool schema retrieval
│   │   ├── tool_help.ex            #   Tool help text
│   │   ├── tool_search.ex          #   Search tools by keyword
│   │   └── tool_summary.ex         #   Tool summary listing
│   ├── application.ex              # OTP supervision tree
│   ├── auth.ex                     # Authentication logic
│   ├── npl.ex                      # NPL public API
│   ├── repo.ex                     # Ecto Repo
│   └── token.ex                    # Token utilities
├── npl_web/
│   ├── controllers/                # Phoenix JSON controllers
│   ├── plugs/                      # Web-specific plugs
│   ├── endpoint.ex                 # Cowboy/Bandit endpoint
│   ├── error_json.ex               # Error serialization
│   ├── mcp_config.ex               # MCP subdomain routing config
│   └── router.ex                   # Routes (subdomain-based MCP routing)
├── noizu_prompt_lingua.ex          # Top-level module
└── npl_web.ex                      # Phoenix web macros
```

## Domain Pattern

Each domain under `domains/` follows a consistent structure:

- `mcp.ex` — MCP server GenServer (registers tools, handles subdomain routing)
- `{domain}.ex` — Business logic (CRUD, queries)
- `tools/` — Individual MCP tool modules (one per tool)
- `tools/overview.ex` — Domain overview tool (lists available tools + stats)

Domains are routed by subdomain: `{domain}.tobor.locker/mcp`
