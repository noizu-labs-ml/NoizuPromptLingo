# zellij-client/ Layout

Client-side crate: handles terminal input, stdin parsing, remote attach, and
web client serving.

```
zellij-client/src/
├── remote_attach/              # Remote session attachment
│   ├── auth.rs                 #   Authentication
│   ├── config.rs               #   Remote config
│   ├── http_client.rs          #   HTTP transport
│   ├── mod.rs                  #   Remote attach orchestration
│   └── websockets.rs           #   WebSocket transport
├── web_client/                 # Web-based terminal client
│   ├── authentication.rs       #   Web auth
│   ├── connection_manager.rs   #   Connection lifecycle
│   ├── http_handlers.rs        #   HTTP endpoints
│   ├── websocket_handlers.rs   #   WebSocket handlers
│   ├── message_handlers.rs     #   Message dispatch
│   ├── session_management.rs   #   Web session state
│   ├── server_listener.rs      #   Server event listener
│   ├── ipc_listener.rs         #   IPC event listener
│   └── types.rs                #   Shared types
├── old_config_converter/       # Legacy YAML config migration
│   ├── convert_old_yaml_files.rs
│   ├── old_config.rs
│   └── old_layout.rs
├── lib.rs                      # Crate root
├── cli_client.rs               # CLI client loop
├── input_handler.rs            # Keyboard/mouse input processing
├── keyboard_parser.rs          # Raw keyboard event parsing
├── stdin_handler.rs            # Stdin event loop (Unix)
├── stdin_handler_windows.rs    # Stdin event loop (Windows)
├── stdin_ansi_parser.rs        # ANSI escape sequence parser
├── os_input_output.rs          # OS I/O trait
├── os_input_output_unix.rs     # Unix implementation
├── os_input_output_windows.rs  # Windows implementation
└── command_is_executing.rs     # Execution state tracking
```
