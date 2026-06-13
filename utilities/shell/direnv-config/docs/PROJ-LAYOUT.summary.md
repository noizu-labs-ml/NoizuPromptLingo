# Project Layout — Summary

```
direnv-config/
├── src/                        # Rust CLI (dc)
│   ├── cmd/                    #   Subcommands
│   ├── store/                  #   Store operations
│   ├── yaml/                   #   YAML utilities
│   └── main.rs
├── bin/dc-init                 # Shell initializer
├── lib/direnv-stdlib.sh        # direnv stdlib extension
├── shell/dc.zsh                # Zsh completions
├── sdk/                        # Multi-language SDKs
│   ├── contract-tests/
│   ├── elixir/
│   ├── php/
│   ├── python/
│   └── typescript/
├── demo/                       # Demo/test environments
├── docs/                       # Documentation
├── Cargo.toml
├── Makefile
├── CHANGELOG.md
└── README.md
```
