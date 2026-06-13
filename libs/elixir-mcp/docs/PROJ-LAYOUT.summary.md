# Project Layout Summary

```
noizu-mcp/
├── lib/noizu/
│   ├── mcp/
│   │   ├── protocol/          # Method constants, version negotiation
│   │   ├── server/            # Session, supervisor, feature modules
│   │   │   ├── features/      # Completion, pagination, prompts, resources, tools
│   │   │   └── tool/          # Tool field definitions
│   │   ├── transport/         # Stdio and test transports
│   │   ├── types/             # Content, prompt, resource, tool structs
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
├── priv/spec/                 # MCP JSON Schema
├── docs/                      # Guides, changelogs, MCP spec references
├── examples/echo_stdio/       # Minimal example server
├── mix.exs                    # Project config
└── README.md
```
