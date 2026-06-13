# Project Layout

`direnv-config` — YAML-backed configuration layer for [direnv](https://direnv.net/). Rust CLI (`dc`) with multi-language SDK clients.

```
direnv-config/
├── src/                        # Rust CLI source
│   ├── cmd/                    #   Subcommands (get, set, env, init, list, bump, prune, purge, secrets, status, unset, yaml)
│   ├── store/                  #   Store operations (layout, meta, resolve, version)
│   ├── yaml/                   #   YAML utilities (flatten, merge, path expressions)
│   └── main.rs                 #   Entry point
├── bin/
│   └── dc-init                 #   Shell initializer (zsh hook, IPC watcher)
├── lib/
│   └── direnv-stdlib.sh        #   direnv stdlib extension (dc_yaml, dc_export, dc_set, etc.)
├── shell/
│   └── dc.zsh                  #   Zsh completions
├── sdk/                        # Read-only client libraries → [layout/sdk.md](layout/sdk.md)
│   ├── contract-tests/         #   Shared test fixtures and expectations
│   ├── elixir/                 #   Elixir SDK (:direnv_config)
│   ├── php/                    #   PHP SDK (noizu/direnv-config)
│   ├── python/                 #   Python SDK (noizu-direnv-config)
│   ├── typescript/             #   TypeScript SDK (@noizu/direnv-config)
│   └── README.md               #   SDK overview and quick-start
├── demo/                       # Demo environments for testing
│   ├── expected-state/         #   Expected resolved YAML per demo scenario
│   ├── k8/                     #   Simulated k8 infra tree with .envrc files
│   ├── root/                   #   Simulated project root with nested .envrc files
│   └── README.md               #   Demo usage guide
├── docs/                       # Documentation
│   ├── PROJ-LAYOUT.md          #   This file
│   └── PROJ-LAYOUT.summary.md  #   Quick-reference tree
├── Cargo.toml                  # Rust package manifest (binary: dc)
├── Makefile                    # Build, install, test, check, doctor, clean
├── CHANGELOG.md                # Release history
├── README.md                   # Project overview and usage
└── .gitignore                  # Excludes: target/
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `Makefile` | `make install` — builds binary, installs direnv stdlib, adds shell hook |
| `lib/direnv-stdlib.sh` | Symlinked to `~/.config/direnv/lib/dc.sh` by `make install` |
| `bin/dc-init` | Installed to `~/.local/bin/dc-init`; sourced in `.zshrc` |

## Installed Locations

| Component | Path |
|-----------|------|
| CLI binary | `~/.local/bin/dc` |
| Shell initializer | `~/.local/bin/dc-init` |
| direnv stdlib | `~/.config/direnv/lib/dc.sh` → symlink to `lib/direnv-stdlib.sh` |
| Runtime state | `~/.local/state/direnv-config/{path-hash}/` |
