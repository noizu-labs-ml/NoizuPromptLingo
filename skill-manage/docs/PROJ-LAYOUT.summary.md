# Project Layout — Summary

```
skill-manage/
├── src/                        # Rust source
│   ├── main.rs                 #   entry + dispatch
│   ├── cli.rs                  #   clap CLI defs
│   ├── config.rs               #   config.yaml + env
│   ├── kinds.rs                #   core types
│   ├── sources.rs              #   source discovery
│   ├── link.rs                 #   symlink ops
│   ├── catalog.rs              #   catalog.yaml
│   ├── audit.rs                #   audit checks
│   ├── status.rs               #   status summary
│   ├── context.rs              #   context-budget helpers
│   └── tui/                    #   ratatui TUI
│       ├── mod.rs
│       ├── app.rs
│       └── ui.rs
├── schema/                     # example YAML configs
│   ├── config.example.yaml
│   └── catalog.example.yaml
├── docs/                       # documentation
│   ├── howto/
│   ├── PROJ-ARCH.md (+ summary)
│   ├── PROJ-FAQ.md (+ summary)
│   ├── PROJ-HOWTO.md (+ summary)
│   ├── PROJ-LAYOUT.md
│   └── PROJ-LAYOUT.summary.md
├── .gitignore
├── Cargo.toml
├── Cargo.lock
├── CHANGELOG.md
├── Makefile
└── README.md
```
