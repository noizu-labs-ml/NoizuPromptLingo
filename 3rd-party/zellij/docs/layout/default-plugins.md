# default-plugins/ Layout

Built-in WASM plugins compiled into the Zellij binary. Each is a standalone
Rust crate targeting `wasm32-wasi`.

```
default-plugins/
├── status-bar/                 # Bottom status bar (mode indicator, keys)
├── tab-bar/                    # Tab bar at top of screen
├── compact-bar/                # Combined tab + status bar
├── strider/                    # File explorer sidebar
├── session-manager/            # Session list and management
├── configuration/              # Settings UI
├── plugin-manager/             # Plugin management UI
├── layout-manager/             # Layout browser and manager
├── about/                      # About screen
├── link/                       # Clickable link handler
├── share/                      # Session sharing
├── multiple-select/            # Multi-select interface
└── fixture-plugin-for-tests/   # Test-only fixture plugin
```
