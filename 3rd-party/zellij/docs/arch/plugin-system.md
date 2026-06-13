# Plugin System

## Overview

Zellij plugins are WebAssembly modules compiled to `wasm32-unknown-unknown`. They run inside the Wasmi interpreter (a pure-Rust WASM VM), providing sandboxed execution without native code dependencies. Plugins implement the `ZellijPlugin` trait from the `zellij-tile` SDK crate.

## Plugin Lifecycle

```
Load → Update (event loop) → Render → Unload
```

1. **Load**: `PluginInstruction::Load` triggers `plugin.load(config: BTreeMap<String, String>)`. The plugin initializes state and subscribes to events.
2. **Update**: Events broadcast to the plugin via `plugin.update(event: Event) -> bool`. Returns `true` to request a re-render.
3. **Render**: `plugin.render(rows: usize, cols: usize)` prints UI output as a string. The host captures stdout and renders it into the plugin pane.
4. **Unload**: Resources freed, WASM memory released.

## SDK (`zellij-tile`)

```rust
use zellij_tile::prelude::*;

#[derive(Default)]
struct MyPlugin { /* state */ }

impl ZellijPlugin for MyPlugin {
    fn load(&mut self, config: BTreeMap<String, String>) { /* init */ }
    fn update(&mut self, event: Event) -> bool { /* handle event, return true to render */ }
    fn render(&mut self, rows: usize, cols: usize) { /* print UI */ }
}

register_plugin!(MyPlugin);
```

The `register_plugin!` macro generates the WASM export glue.

## Host-Plugin Communication

- **Events → Plugin**: The host sends `Event` variants (TabUpdate, ModeUpdate, Key, Mouse, Timer, etc.) — 50+ event types defined in `zellij-utils/src/data.rs`
- **Plugin → Host**: Plugins call exported host functions defined in `zellij_exports.rs` (206KB) — actions like opening panes, switching tabs, setting clipboard, requesting permissions
- **Serialization**: Protobuf encoding for structured data crossing the WASM boundary

## Plugin Workers

Plugins can spawn background workers via `post_message_to(worker_name, message)`. Workers run on dedicated thread pools (`plugin_worker.rs`) and can post results back to the plugin's update loop.

## Inter-Plugin Pipes

The `pipes.rs` module enables plugins to communicate with each other through named pipes. This supports workflows like the strider file browser sending `cd` commands to a terminal pane.

## Built-In Plugins (13)

| Plugin | Purpose |
|--------|---------|
| tab-bar | Horizontal tab switcher |
| status-bar | Mode indicator + keybind help |
| strider | File browser with pipe support |
| compact-bar | Compact mode display |
| configuration | Settings UI editor |
| plugin-manager | Install/uninstall plugins |
| session-manager | Session switcher |
| layout-manager | Layout switcher |
| about | Help/about screen |
| share | Session sharing |
| link | Hyperlink detection |
| multiple-select | Multi-selection UI |
| fixture-plugin-for-tests | Test harness plugin |

Built-in plugin WASM binaries are embedded in `assets/plugins/` and compiled via `cargo xtask build-plugins`.

## Security Model

- Each plugin runs in its own WASM memory sandbox
- No direct filesystem access — host mediates all I/O
- Permission system gates sensitive operations (e.g., running commands, accessing clipboard)
- Plugins request permissions via `RequestPermission` and the user approves/denies
