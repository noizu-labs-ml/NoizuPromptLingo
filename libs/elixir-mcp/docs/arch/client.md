# Client Architecture

## Design

`Noizu.MCP.Client` is a GenServer that wraps `Noizu.MCP.Peer` in `:client` role. It manages the full lifecycle: transport startup, handshake, request/response tracking, and server-initiated request dispatch.

## Lifecycle

1. `start_link/1` boots the GenServer with transport config and options
2. GenServer spawns the appropriate transport (`Stdio.Client`, `StreamableHTTP.Client`, or `Test.Client`)
3. `Peer.init_request/1` builds the `initialize` message; transport sends it
4. Transport delivers the server's response; Peer emits `{:initialize_result, ...}`
5. `Peer.initialized/1` sends the `notifications/initialized` notification
6. Peer emits `{:ready, ...}`; queued calls are flushed

## Call queuing

Calls to `list_tools/2`, `call_tool/3`, etc. made before the handshake completes are held in a queue. Once `{:ready, ...}` fires, queued calls are dispatched in order.

## Server-initiated requests

When the server sends `sampling/createMessage` or `elicitation/create`, the Client dispatches to the user's `Client.Handler` module in a supervised task. Only callbacks that the handler implements are advertised as capabilities during the handshake.

## Transports

The Client uses the `Noizu.MCP.Transport.Client` behaviour:

| Transport | Module | Use case |
|-----------|--------|----------|
| Stdio | `Transport.Stdio.Client` | Spawn subprocess, speak JSON-RPC over stdin/stdout |
| Streamable HTTP | `Transport.StreamableHTTP.Client` | POST messages, receive SSE stream; Req-based |
| Test | `Transport.Test.Client` | In-VM connection to a `Noizu.MCP.Server` |

Transport selection is driven by the `:transport` option: `{:stdio, ...}`, `{:streamable_http, ...}`, `{:test, ...}`, or `{module, opts}`.

## Roots

Roots are passed via `:roots` at startup and can be updated with `set_roots/2`, which triggers a `notifications/roots/list_changed` notification to the server.
