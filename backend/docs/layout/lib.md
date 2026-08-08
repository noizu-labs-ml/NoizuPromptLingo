# lib/ — Elixir source map

OTP modules under `noizu_prompt_lingua/` and HTTP/MCP surface under `noizu_prompt_lingua_web/`.

## noizu_prompt_lingua/

```
noizu_prompt_lingua/
├── application.ex                  # OTP app supervisor tree
├── repo.ex · entity_repo.ex · redis.ex · cache.ex · storage.ex
├── guardian.ex · mailer.ex · feature_flags.ex · uuid.ex · token.ex
├── release.ex · pm_core.ex · events.ex · events/webhook_handler.ex
├── auth/                           # registration tokens, SSO helpers, token store
├── authz/                          # policy_evaluator, UUID helpers
├── npl.ex · npl/                   # Convention engine (loader, parser, resolver, layout)
├── mcp.ex · mcp_auth.ex · mcp_servers.ex · mcp_sockets.ex · mcp_custom_scopes.ex
├── mcp/                            # Tenancy + client MCP + identity guard
│   ├── organizations/ · projects/ · sessions/ · clients/
│   ├── custom.ex · resolve.ex · args.ex · tool_guard.ex
│   └── …/tools/                    # Per-server MCP tool modules
├── tools/                          # Root discovery: ToolSummary/Search/Definition/Call/Help
│   ├── catalog.ex · mcp_overview.ex
│   └── npl_load.ex · npl_spec.ex
├── domains/                        # Product domains (context + mcp.ex + tools/)
│   ├── artifacts/ · assets/ · browser/
│   ├── campaigns/ · market/ · customers/ · marketing_content.ex
│   ├── chat/ · wiki/ · review/ · tickets/ · dashboard/
│   ├── personas/ · memory/ · instructions/
│   ├── github/ · notifications/ · pubsub/
│   ├── mock_mcp/ · remote_access/ · unicode_codex/
│   ├── markdown/ · links/ · mcp_overview/
│   └── …
├── entities/                       # Entity framework wrappers (users, orgs, sessions, authz, media, …)
├── schema/                         # Ecto schemas mirroring Liquibase tables
├── services/                       # Cross-cutting attach / comment / watch
├── media/transform.ex
├── github/client.ex
├── protocols/erp.ex
└── workers/                        # cleanup_worker + memory/* Oban jobs
```

### Domain pattern

Most entries under `domains/<name>/`:

| File | Role |
|------|------|
| `<name>.ex` | Context API (CRUD / workflows) |
| `mcp.ex` | MCP server registration for the domain |
| `tools/*.ex` | Individual MCP tool implementations |

### MCP surface

- Per-domain MCP hosts (subdomain routing) registered via `mcp_servers.ex` / domain `mcp.ex`
- Aggregated root `/mcp` discovery tools in `tools/`
- Custom scopes gateway: `mcp_custom_scopes.ex` + web `custom_mcp_gateway_controller`
- Mock MCP builder runtime: `domains/mock_mcp/`

## noizu_prompt_lingua_web/

```
noizu_prompt_lingua_web/
├── endpoint.ex · router.ex · telemetry.ex · gettext.ex · mcp_config.ex
├── controllers/                    # REST JSON + admin + media + MCP gateways
│   ├── auth_controller · sso_controller · health_controller
│   ├── organization · project · session · user · membership · token
│   ├── ticket · board · chat · wiki · artifact · asset · review
│   ├── persona · memory · instruction · github · browser*
│   ├── mock_mcp* · custom_mcp_gateway · npl · unicode_codex
│   ├── admin · policy · group · remote_access · voice_assistant · …
│   └── error_json.ex
├── plugs/
│   ├── auth_pipeline · auth_error_handler · cors
│   ├── require_admin · require_role · require_permission
│   ├── rate_limit · otel_logger_metadata · mock_mcp_gateway
└── channels/
    ├── user_socket.ex
    ├── org_channel.ex
    └── browser_channel.ex
```

## mix/tasks/ · supports/

- `mix/tasks/` — `personas.seed_members`, ticket seed/backfill, chat slug backfill
- `supports/` — shared types, Ecto serialized terms, LiveView event helpers, migration utils
