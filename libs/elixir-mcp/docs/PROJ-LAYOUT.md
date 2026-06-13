# Project Layout

```
noizu-mcp/
├── lib/                        # Source code → [layout/lib.md](layout/lib.md)
│   └── noizu/
│       ├── mcp/                #   MCP protocol implementation
│       └── mcp.ex              #   Top-level module
├── test/                       # Test suites
│   ├── noizu/mcp/              #   Unit, integration, conformance, e2e tests
│   ├── support/                #   Test helpers (fixture_server.ex)
│   └── test_helper.exs         #   ExUnit config
├── priv/                       # Runtime assets
│   └── spec/2025-11-25/        #   MCP JSON Schema (schema.json)
├── docs/                       # Documentation → [layout/docs.md](layout/docs.md)
│   ├── 01–09-*.md              #   Feature guides and changelogs
│   └── specs/                  #   MCP spec versions (2025-03-26 → draft)
├── examples/                   # Example applications
│   └── echo_stdio/             #   Minimal stdio MCP server
├── .formatter.exs              # Elixir formatter config
├── .gitignore
├── .tool-versions              # asdf version pinning (erlang, elixir)
├── mix.exs                     # Project definition and dependencies
├── mix.lock                    # Locked dependency versions
└── README.md                   # Start here
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/noizu/mcp.ex` | Top-level `Noizu.MCP` module |
| `lib/noizu/mcp/server.ex` | `Noizu.MCP.Server` — main server behaviour |
| `lib/noizu/mcp/transport.ex` | Transport behaviour (stdio, test) |
| `lib/noizu/mcp/json_rpc.ex` | JSON-RPC 2.0 encode/decode |
| `lib/noizu/mcp/schema.ex` | JSV schema validation against MCP spec |
| `priv/spec/2025-11-25/schema.json` | Official MCP JSON Schema |
| `test/support/fixture_server.ex` | Reusable test server for all test suites |
