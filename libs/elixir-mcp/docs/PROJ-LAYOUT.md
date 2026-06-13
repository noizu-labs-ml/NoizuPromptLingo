# Project Layout

```
noizu-mcp/
├── lib/                        # Source code → [layout/lib.md](layout/lib.md)
│   └── noizu/
│       ├── mcp/                #   MCP protocol implementation
│       └── mcp.ex              #   Top-level module
├── test/                       # Test suites
│   ├── noizu/mcp/              #   Unit, integration, conformance, e2e tests
│   │   ├── server/             #   Server-specific tests (tool_test)
│   │   └── transport/          #   Transport tests (SSE, streamable HTTP)
│   ├── support/                #   Test helpers (fixture_server, fixture_auth)
│   └── test_helper.exs         #   ExUnit config
├── priv/                       # Runtime assets
│   ├── spec/2025-11-25/        #   MCP JSON Schema (schema.json)
│   └── inspector/              #   Inspector browser UI (vanilla ES modules, no build step)
├── docs/                       # Documentation → [layout/docs.md](layout/docs.md)
│   ├── arch/                   #   Architecture docs (peer, request-lifecycle, supervision)
│   ├── 01–09-*.md              #   Feature guides and changelogs
│   └── specs/                  #   MCP spec versions (2025-03-26 → draft)
├── guides/                     # ExDoc guides (getting_started, tools, testing, etc.)
├── cheatsheets/                # ExDoc cheatsheets (mcp.cheatmd)
├── examples/                   # Example applications
│   ├── echo_stdio/             #   Minimal stdio MCP server
│   ├── agent_client/           #   Agent-based MCP client
│   ├── http_kitchen_sink/      #   Full-featured HTTP server
│   └── no_dsl_server/          #   Server without DSL macros
├── .dialyzer_ignore.exs        # Dialyzer warning suppressions
├── .formatter.exs              # Elixir formatter config
├── .gitignore
├── .tool-versions              # asdf version pinning (elixir 1.19.5, erlang 28)
├── CHANGELOG.md                # Release history
├── LICENSE                     # Project license
├── mix.exs                     # Project definition and dependencies
├── mix.lock                    # Locked dependency versions
└── README.md                   # Start here
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/noizu/mcp.ex` | Top-level `Noizu.MCP` module |
| `lib/noizu/mcp/server.ex` | `Noizu.MCP.Server` — main server behaviour and DSL |
| `lib/noizu/mcp/client.ex` | `Noizu.MCP.Client` — client behaviour |
| `lib/noizu/mcp/transport.ex` | Transport behaviour (stdio, SSE, streamable HTTP, test) |
| `lib/noizu/mcp/peer.ex` | `Noizu.MCP.Peer` — client-side peer interaction |
| `lib/noizu/mcp/json_rpc.ex` | JSON-RPC 2.0 encode/decode |
| `lib/noizu/mcp/schema.ex` | JSV schema validation against MCP spec |
| `lib/noizu/mcp/inspector.ex` | `Noizu.MCP.Inspector` supervisor (Registry + DynamicSupervisor + Bandit) |
| `lib/noizu/mcp/inspector/` | Session, TapTransport, Handler, Plug — inspector subsystem |
| `lib/mix/tasks/mcp.client.ex` | `mix mcp.client` Mix task |
| `priv/inspector/` | Inspector browser UI (vanilla ES modules, no build step) |
| `lib/noizu/mcp/auth/` | OAuth/auth — strategies, token verification, plugs |
| `priv/spec/2025-11-25/schema.json` | Official MCP JSON Schema |
| `test/support/fixture_server.ex` | Reusable test server for all test suites |
| `test/support/fixture_auth.ex` | Auth test fixtures |
