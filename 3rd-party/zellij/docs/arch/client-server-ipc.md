# Client-Server IPC

## Connection

Clients connect to the server via a Unix domain socket at:
```
/run/user/{uid}/zellij-session-{name}.sock
```

Multiple clients can attach to the same session simultaneously (collaborative multiplexing). Each client is identified by a `ClientId`.

## Protocol

Messages are serialized using Protobuf (prost crate). Schemas live in `zellij-utils/assets/prost/*.proto` with generated code in `zellij-utils/src/client_server_contract/`.

### Client → Server (`ClientToServerMsg`)

| Message | Purpose |
|---------|---------|
| `Action` | User action — key press, mouse click, pane operation |
| `TerminalInput` | Raw bytes to forward to active PTY |
| `ClientExited` | Client disconnecting cleanly |
| `UpdatePixelDimensions` | Terminal window resized |
| `RequestPermission` | Plugin permission request forwarded from client |

### Server → Client (`ServerToClientMsg`)

| Message | Purpose |
|---------|---------|
| `TerminalOutput` | Rendered frame as ANSI escape sequences |
| `LayoutMetadata` | Current pane tree structure (for status bar) |
| `Mode` | Input mode changed (normal, locked, pane, tab, etc.) |
| `PaletteUpdate` | Color scheme change |
| `ForwardQueryToHost` | Request system info from client environment |

## Message Flow Example

**User presses a key:**

```
1. Client: stdin → stdin_ansi_parser → keyboard_parser → Action
2. Client: Serialize Action as ClientToServerMsg
3. IPC: Send over Unix socket
4. Server Route thread: Deserialize, dispatch to Screen/PTY/Plugin
5. Server Screen: Update pane state, re-render character buffer
6. Server: Serialize rendered output as ServerToClientMsg::TerminalOutput
7. IPC: Send over Unix socket
8. Client: Write ANSI sequences to terminal stdout
```

## Web Client (Optional)

When the `web_server_capability` feature is enabled, `zellij-client/src/web_client/` runs an Axum HTTP server that upgrades to WebSocket. This enables browser-based access to Zellij sessions. The web client uses a separate Protobuf contract defined in `zellij-utils/assets/prost_web_server/`.
