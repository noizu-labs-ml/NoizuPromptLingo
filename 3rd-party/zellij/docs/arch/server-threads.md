# Server Threading Model

## Overview

The Zellij server is a multi-threaded process where each major subsystem runs on its own dedicated thread. Threads communicate exclusively through typed channels wrapped in `ThreadSenders` (defined in `zellij-server/src/thread_bus.rs`), which provide context-aware error propagation.

## Thread Details

### Route Thread (`route.rs` — 122KB)

The central message hub. Receives all `ClientToServerMsg` from connected clients via IPC, deserializes actions, and dispatches `ScreenInstruction`, `PtyInstruction`, or `PluginInstruction` to the appropriate thread. Also handles action completion notifications for blocking operations (e.g., waiting for a pane to open before sending input to it).

### Screen Thread (`screen.rs` — 435KB)

The largest module. Manages the entire visual state:
- **Tabs**: Container for panes; each tab has its own tiled and floating pane sets
- **Pane orchestration**: Creates, destroys, resizes, and focuses panes
- **Layout application**: Applies KDL layout definitions via `layout_applier.rs`
- **Rendering**: Converts pane character buffers to ANSI output sequences
- **Swap layouts**: Transitions between different pane arrangements

Key data structures:
- `Tab` — holds `BTreeMap<PaneId, Box<dyn Pane>>`, `TiledPanes`, `FloatingPanes`
- `TerminalPane` — contains `Grid` (character buffer with scrollback)
- `PluginPane` — renders WASM plugin output

### PTY Thread (`pty.rs` — 103KB)

Manages pseudo-terminal file descriptors:
- Spawns PTY processes for shell panes
- Reads byte streams from PTY stdout
- Parses VT escape sequences using the `vte` crate
- Forwards parsed terminal events to the Screen thread
- Handles PTY resize signals (SIGWINCH)

### Plugin Thread (`plugins/` — ~270KB total)

Runs the Wasmi WASM interpreter:
- `wasm_bridge.rs` (95KB): Core runtime — loads WASM modules, manages memory, executes functions
- `zellij_exports.rs` (206KB): Host functions exported to plugins (the plugin API surface)
- `plugin_loader.rs`: Loads `.wasm` files from filesystem or embedded assets
- `plugin_map.rs`: Registry of loaded plugin instances
- `plugin_worker.rs`: Worker thread pools for plugin background tasks
- `pipes.rs`: Inter-plugin communication channels

### PTY Writer Thread (`pty_writer.rs`)

Dedicated thread for writing bytes to PTY file descriptors. Separated from the PTY read thread to avoid blocking reads while writes are pending.

### Background Jobs Thread (`background_jobs.rs`)

Runs a tokio async executor for tasks like:
- File watching (via `notify` crate)
- HTTP requests for plugin downloads
- Deferred/scheduled operations

## Communication Pattern

```
Client IPC → Route → Screen → (render output) → Client IPC
                  → PTY → (terminal events) → Screen
                  → Plugin → (plugin render) → Screen
                  → Background Jobs
```

All inter-thread communication uses `SenderWithContext<T>` channels that carry error context for debugging thread panics.
