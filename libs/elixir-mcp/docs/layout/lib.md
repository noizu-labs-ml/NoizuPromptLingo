# lib/ — Source Code

```
lib/noizu/
├── mcp/
│   ├── protocol/
│   │   ├── methods.ex              # Method name constants and dispatch
│   │   └── version.ex              # Protocol version negotiation
│   ├── server/
│   │   ├── features/
│   │   │   ├── completion.ex       # Autocomplete/completion support
│   │   │   ├── pagination.ex       # Cursor-based pagination
│   │   │   ├── prompts.ex          # Prompt listing and retrieval
│   │   │   ├── resources.ex        # Resource listing, reading, subscriptions
│   │   │   └── tools.ex            # Tool listing and invocation
│   │   ├── tool/
│   │   │   └── fields.ex           # Tool input field definitions
│   │   ├── prompt.ex               # Prompt struct and definition DSL
│   │   ├── resource_template.ex    # Resource template struct
│   │   ├── resource.ex             # Resource struct
│   │   ├── session.ex              # Per-connection session GenServer
│   │   ├── supervisor.ex           # Session supervisor
│   │   └── tool.ex                 # Tool struct and definition DSL
│   ├── transport/
│   │   ├── stdio.ex                # Stdio transport (production)
│   │   └── test.ex                 # In-process transport (testing)
│   ├── types/
│   │   ├── content.ex              # Text/image/audio/resource content types
│   │   ├── implementation.ex       # Implementation info struct
│   │   ├── prompt_message.ex       # PromptMessage struct
│   │   ├── prompt.ex               # Prompt type struct
│   │   ├── resource_contents.ex    # Resource read response types
│   │   ├── resource_template.ex    # ResourceTemplate type struct
│   │   ├── resource.ex             # Resource type struct
│   │   ├── tool_result.ex          # Tool call result struct
│   │   └── tool.ex                 # Tool type struct
│   ├── ctx.ex                      # Request context (metadata, progress)
│   ├── error.ex                    # Structured error types
│   ├── json_rpc.ex                 # JSON-RPC 2.0 message handling
│   ├── peer.ex                     # Client-side peer interaction
│   ├── schema.ex                   # JSV schema loading and validation
│   ├── server.ex                   # Server behaviour and macros
│   ├── test.ex                     # Test helpers and assertions
│   ├── transport.ex                # Transport behaviour
│   └── uri_template.ex             # RFC 6570 URI template expansion
└── mcp.ex                          # Top-level Noizu.MCP module
```
