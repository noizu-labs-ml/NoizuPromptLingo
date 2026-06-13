# Project Layout — Summary

```
zellij/
├── src/                        # CLI entry point (binary crate)
├── zellij-server/              # Server: panes, plugins, output
├── zellij-client/              # Client: input, remote attach, web
├── zellij-utils/               # Shared: config, IPC, KDL parsing
├── zellij-tile/                # Plugin SDK (guest-side)
├── zellij-tile-utils/          # Plugin SDK helpers
├── zellij-cct-tmux/            # Tmux compat shim (tmux CLI → Zellij IPC)
├── bin/                        # Convenience symlinks (tmux shim)
├── default-plugins/            # 13 built-in WASM plugins
├── xtask/                      # Build automation
├── docs/                       # Architecture & process docs
├── example/                    # Example configs, layouts, themes
├── scripts/                    # Utility scripts
├── .github/                    # CI/CD workflows
├── assets/                     # Logos, icons
├── wix/                        # Windows installer
├── Cargo.toml                  # Workspace manifest
└── README.md
```
