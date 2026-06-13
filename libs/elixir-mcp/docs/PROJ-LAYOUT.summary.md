# Project Layout Summary

```
noizu-mcp/
├── lib/noizu/
│   ├── mcp/
│   │   ├── inspector/         # Inspector subsystem (session, plug, handler, tap_transport)
│   │   ├── inspector.ex       # Noizu.MCP.Inspector supervisor
│   │   ├── auth/              # OAuth, static auth, token verification, plugs
│   │   ├── client/            # Client-side handler
│   │   ├── protocol/          # Method constants, version negotiation
│   │   ├── server/            # Session, supervisor, event store, feature modules
│   │   │   ├── features/      # Completion, pagination, prompts, resources, tools
│   │   │   └── tool/          # Tool field definitions
│   │   ├── transport/         # Stdio, SSE, streamable HTTP, test transports
│   │   │   └── streamable_http/  # HTTP client, plug, sink
│   │   ├── types/             # Content, prompt, resource, root, tool structs
│   │   ├── client.ex          # Client behaviour
│   │   ├── ctx.ex             # Request context
│   │   ├── error.ex           # Error types
│   │   ├── json_rpc.ex        # JSON-RPC 2.0
│   │   ├── peer.ex            # Client peer interaction
│   │   ├── schema.ex          # JSV schema validation
│   │   ├── server.ex          # Server behaviour
│   │   ├── test.ex            # Test helpers
│   │   ├── transport.ex       # Transport behaviour
│   │   └── uri_template.ex    # URI template expansion
│   └── mcp.ex                 # Top-level module
├── test/                      # Unit, integration, conformance, e2e tests
│   ├── noizu/mcp/server/      # Server tests (tool)
│   └── noizu/mcp/transport/   # Transport tests (SSE, streamable HTTP)
├── priv/spec/                 # MCP JSON Schema
├── priv/inspector/            # Inspector browser UI (vanilla ES modules, no build step)
├── lib/mix/tasks/mcp.client.ex  # mix mcp.client Mix task
├── docs/                      # Guides, changelogs, arch docs, MCP spec references
├── guides/                    # ExDoc guides (9 files)
├── cheatsheets/               # ExDoc cheatsheets
├── examples/                  # echo_stdio, agent_client, http_kitchen_sink, no_dsl_server
├── mix.exs                    # Project config
└── README.md
```
