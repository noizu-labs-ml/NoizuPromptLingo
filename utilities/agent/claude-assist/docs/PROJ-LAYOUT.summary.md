# Project Layout — Summary

```
claude-assist/
├── packages/
│   ├── api/                    # REST API server (Express + SQLite)
│   │   └── src/{routes,services}/
│   ├── cli/                    # TUI client (Ink)
│   │   └── src/commands/
│   ├── shared/                 # Types, parsers, utilities
│   │   └── src/{parsers,types}/
│   └── web/                    # Browser UI (Vite + React + Tailwind)
│       └── src/{components,hooks,pages}/
├── docs/                       # Architecture and layout documentation
│   ├── arch/
│   └── layout/
├── design/                     # Logos, mockups, style guide
├── package.json                # Root workspace
├── pnpm-workspace.yaml         # Workspace config
├── tsconfig.base.json          # Shared TS config
├── INSTALL.md                  # Setup guide
└── README.md
```
