# zellij-server/ Layout

Server-side crate: manages tabs, panes, plugins, and rendering output.

```
zellij-server/src/
├── panes/                      # Pane management
│   ├── grid.rs                 #   Terminal grid (cells, scrollback)
│   ├── terminal_pane.rs        #   Terminal pane implementation
│   ├── plugin_pane.rs          #   Plugin pane (WASM guest)
│   ├── terminal_character.rs   #   Character/style representation
│   ├── search.rs               #   In-pane text search
│   ├── selection.rs            #   Text selection
│   ├── sixel.rs                #   Sixel graphics support
│   ├── active_panes.rs         #   Active pane tracking
│   ├── alacritty_functions.rs  #   Terminal emulation (borrowed from alacritty)
│   ├── hyperlink_tracker.rs    #   OSC 8 hyperlink tracking
│   ├── link_handler.rs         #   Link detection
│   ├── floating_panes/         #   Floating pane grid and layout
│   └── tiled_panes/            #   Tiled pane grid, resizer, stacking
├── plugins/                    # WASM plugin host
│   ├── wasm_bridge.rs          #   WASM runtime bridge
│   ├── plugin_loader.rs        #   Plugin loading and instantiation
│   ├── plugin_map.rs           #   Plugin instance registry
│   ├── plugin_worker.rs        #   Background plugin workers
│   ├── zellij_exports.rs       #   Host functions exported to plugins
│   ├── pipes.rs                #   Plugin pipe communication
│   ├── pinned_executor.rs      #   Single-thread async executor
│   └── watch_filesystem.rs     #   File-watching for plugins
├── tab/                        # Tab management
│   ├── mod.rs                  #   Tab struct and logic
│   ├── layout_applier.rs       #   Apply layout definitions to tabs
│   ├── swap_layouts.rs         #   Layout swapping
│   ├── mouse_handler.rs        #   Mouse event routing
│   ├── clipboard.rs            #   Clipboard integration
│   └── copy_command.rs         #   Copy-to-clipboard command
├── output/                     # Rendering
│   └── mod.rs                  #   Render pane contents to terminal
├── ui/                         # UI components
├── background_jobs.rs          # Async background tasks
├── lib.rs                      # Crate root
├── os_input_output.rs          # OS-level I/O abstraction
├── route.rs                    # Message routing between components
├── screen.rs                   # Screen manager (all tabs)
├── session_layout_metadata.rs  # Layout serialization for sessions
├── terminal_bytes.rs           # Raw terminal byte processing
└── thread_bus.rs               # Inter-thread message bus
```
