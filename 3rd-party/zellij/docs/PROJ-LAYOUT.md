# Project Layout

Zellij is a Rust workspace terminal multiplexer. The root crate (`src/`) is the
CLI entry point; core logic lives in workspace crates (`zellij-*`). Built-in
plugins are WASM modules under `default-plugins/`.

```
zellij/
├── src/                        # CLI entry point (binary crate)
│   ├── main.rs                 #   Binary entry (zellij)
│   ├── tmux_shim_main.rs       #   Binary entry (zellij-tmux-shim)
│   ├── commands.rs             #   CLI subcommands
│   ├── build.rs                #   Build script
│   └── tests/                  #   Integration & e2e tests
├── zellij-server/              # Server-side logic → [layout/zellij-server.md](layout/zellij-server.md)
│   ├── src/panes/              #   Pane grid, terminal, search
│   ├── src/plugins/            #   WASM plugin host
│   └── src/output/             #   Rendering output
├── zellij-client/              # Client-side logic → [layout/zellij-client.md](layout/zellij-client.md)
│   ├── src/remote_attach/      #   Remote session attach
│   └── src/web_client/         #   Web client support
├── zellij-utils/               # Shared utilities → [layout/zellij-utils.md](layout/zellij-utils.md)
│   ├── src/input/              #   Config, keybinds, layout parsing
│   ├── src/kdl/                #   KDL layout parser
│   └── src/plugin_api/         #   Plugin API definitions
├── zellij-tile/                # Plugin SDK (guest-side API)
├── zellij-tile-utils/          # Plugin SDK helpers
├── zellij-cct-tmux/            # Tmux compatibility shim (translates tmux CLI → Zellij IPC)
│   ├── src/commands/           #   Per-command tmux→Zellij translators
│   ├── src/zellij_bridge.rs    #   IPC bridge to Zellij server
│   └── docs/ARCHITECTURE.md    #   CCT-tmux design doc
├── bin/                        # Convenience symlinks
│   └── tmux -> ../target/release/zellij-tmux-shim
├── default-plugins/            # Built-in WASM plugins → [layout/default-plugins.md](layout/default-plugins.md)
│   ├── status-bar/             #   Bottom status bar
│   ├── tab-bar/                #   Tab bar
│   ├── strider/                #   File explorer
│   └── session-manager/        #   Session management
├── xtask/                      # Build automation tasks
├── docs/                       # Documentation
│   ├── ARCHITECTURE.md         #   Legacy architecture doc
│   ├── PROJ-ARCH.md            #   Current architecture reference
│   ├── arch/                   #   Detailed architecture docs
│   ├── TERMINOLOGY.md          #   Domain glossary
│   ├── RELEASE.md              #   Release process
│   └── ERROR_HANDLING.md       #   Error handling guide
├── example/                    # Example configs and layouts
│   ├── layouts/                #   Example layout files
│   └── themes/                 #   Example theme files
├── scripts/                    # Utility scripts
│   └── activate-tmux-compat.sh #   Enable tmux compat mode
├── .github/                    # CI/CD workflows
│   └── workflows/              #   rust.yml, release.yml, e2e.yml
├── assets/                     # Logos, icons, desktop entry
├── wix/                        # Windows installer (WiX)
├── .cargo/config.toml          # Cargo build configuration
├── .editorconfig               # Editor settings
├── .envrc                      # direnv — loads environment
├── .rustfmt.toml               # Rust formatting config
├── rust-toolchain.toml         # Pinned Rust toolchain
├── Cargo.toml                  # Workspace manifest
├── Cargo.lock                  # Dependency lockfile
├── docker-compose.yml          # Local dev services
├── claude-shim-setup.md        # Claude + tmux shim integration guide
└── README.md                   # Start here
```

## Key Files

| File | Purpose |
|------|---------|
| `Cargo.toml` | Workspace root — defines all member crates |
| `rust-toolchain.toml` | Pinned Rust version for builds |
| `.rustfmt.toml` | Shared formatting rules |
| `scripts/activate-tmux-compat.sh` | Activates tmux compatibility mode |
| `claude-shim-setup.md` | Guide for Claude Code + tmux shim integration |
| `.envrc` | direnv — run `direnv allow` |
