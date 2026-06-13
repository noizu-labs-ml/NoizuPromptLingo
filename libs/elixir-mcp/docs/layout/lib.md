# lib/ — Source Code

```
lib/noizu/
├── mcp/
│   ├── inspector/
│   │   ├── handler.ex                 # Client.Handler impl — parks sampling/elicitation for browser
│   │   ├── plug.ex                    # Bandit Plug: REST + SSE bridge, auth, config export
│   │   ├── session.ex                 # Per-browser session GenServer (event fan-out, tool call async)
│   │   └── tap_transport.ex           # Transport wrapper mirroring raw frames to session
│   ├── auth/
│   │   ├── client_strategy.ex         # Auth strategy behaviour for clients
│   │   ├── oauth.ex                   # OAuth 2.0 flow implementation
│   │   ├── protected_resource_metadata_plug.ex  # Plug for protected resource metadata
│   │   ├── static.ex                  # Static token auth strategy
│   │   ├── token_verifier.ex          # Token verification logic
│   │   └── www_authenticate.ex        # WWW-Authenticate header handling
│   ├── client/
│   │   └── handler.ex                 # Client-side message handler
│   ├── protocol/
│   │   ├── methods.ex                 # Method name constants and dispatch
│   │   └── version.ex                 # Protocol version negotiation
│   ├── server/
│   │   ├── features/
│   │   │   ├── completion.ex          # Autocomplete/completion support
│   │   │   ├── pagination.ex          # Cursor-based pagination
│   │   │   ├── prompts.ex             # Prompt listing and retrieval
│   │   │   ├── resources.ex           # Resource listing, reading, subscriptions
│   │   │   └── tools.ex              # Tool listing and invocation
│   │   ├── tool/
│   │   │   └── fields.ex             # Tool input field definitions
│   │   ├── event_store.ex            # Server-sent event persistence
│   │   ├── prompt.ex                 # Prompt struct and definition DSL
│   │   ├── resource_template.ex      # Resource template struct
│   │   ├── resource.ex               # Resource struct
│   │   ├── session.ex                # Per-connection session GenServer
│   │   ├── supervisor.ex             # Session supervisor
│   │   └── tool.ex                   # Tool struct and definition DSL
│   ├── transport/
│   │   ├── streamable_http/
│   │   │   ├── client.ex             # Streamable HTTP client transport
│   │   │   ├── plug.ex               # Plug-based HTTP endpoint
│   │   │   └── sink.ex               # Response sink for SSE streams
│   │   ├── sse.ex                    # Server-Sent Events transport
│   │   ├── stdio_client.ex           # Stdio client-side transport
│   │   ├── stdio.ex                  # Stdio server transport (production)
│   │   ├── test_client.ex            # In-process client transport (testing)
│   │   └── test.ex                   # In-process server transport (testing)
│   ├── types/
│   │   ├── content.ex                # Text/image/audio/resource content types
│   │   ├── implementation.ex         # Implementation info struct
│   │   ├── prompt_message.ex         # PromptMessage struct
│   │   ├── prompt.ex                 # Prompt type struct
│   │   ├── resource_contents.ex      # Resource read response types
│   │   ├── resource_template.ex      # ResourceTemplate type struct
│   │   ├── resource.ex               # Resource type struct
│   │   ├── root.ex                   # Root type struct
│   │   ├── tool_result.ex            # Tool call result struct
│   │   └── tool.ex                   # Tool type struct
│   ├── inspector.ex                  # Noizu.MCP.Inspector supervisor
│   ├── client.ex                     # Client behaviour and macros
│   ├── ctx.ex                        # Request context (metadata, progress)
│   ├── error.ex                      # Structured error types
│   ├── json_rpc.ex                   # JSON-RPC 2.0 message handling
│   ├── peer.ex                       # Client-side peer interaction
│   ├── schema.ex                     # JSV schema loading and validation
│   ├── server.ex                     # Server behaviour and macros
│   ├── test.ex                       # Test helpers and assertions
│   ├── transport.ex                  # Transport behaviour
│   └── uri_template.ex               # RFC 6570 URI template expansion
└── mcp.ex                            # Top-level Noizu.MCP module
```
