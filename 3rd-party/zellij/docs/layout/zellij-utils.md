# zellij-utils/ Layout

Shared utility crate: configuration parsing, IPC protocol, KDL serialization,
and the plugin API contract.

```
zellij-utils/src/
├── input/                      # User-facing configuration
│   ├── actions.rs              #   Action enum (all user actions)
│   ├── config.rs               #   Config file parsing
│   ├── keybinds.rs             #   Keybinding definitions
│   ├── layout.rs               #   Layout file structures
│   ├── options.rs              #   Runtime options
│   ├── theme.rs                #   Theme definitions
│   ├── plugins.rs              #   Plugin configuration
│   ├── permission.rs           #   Plugin permission model
│   ├── command.rs              #   Command definitions
│   ├── mouse.rs                #   Mouse event types
│   ├── cli_assets.rs           #   Embedded default assets
│   └── web_client.rs           #   Web client config
├── kdl/                        # KDL format support
│   ├── mod.rs                  #   KDL serialization/deserialization
│   ├── kdl_layout_parser.rs    #   Layout-specific KDL parsing
│   └── snapshots/              #   Insta test snapshots
├── client_server_contract/     # IPC protocol (protobuf)
│   ├── client_to_server.proto  #   Client→Server messages
│   ├── server_to_client.proto  #   Server→Client messages
│   ├── common_types.proto      #   Shared protobuf types
│   └── mod.rs                  #   Generated code re-exports
├── ipc/                        # IPC transport
│   ├── enum_conversions.rs     #   Enum ↔ protobuf conversions
│   └── protobuf_conversion.rs  #   Protobuf serialization
├── plugin_api/                 # Plugin API definitions
├── lib.rs                      # Crate root
├── channels.rs                 # Channel abstractions
├── cli.rs                      # CLI argument definitions (clap)
├── consts.rs                   # Constants (paths, defaults)
├── envs.rs                     # Environment variable handling
├── errors.rs                   # Error types
├── logging.rs                  # Log setup
├── pane_size.rs                # Pane geometry types
├── position.rs                 # Position/coordinate types
├── session_serialization.rs    # Session save/restore
└── shared.rs                   # Misc shared utilities
```
