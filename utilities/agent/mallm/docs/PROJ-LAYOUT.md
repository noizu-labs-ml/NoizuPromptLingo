# Project Layout

```
mallm/
├── src/                        # TypeScript source
│   ├── index.ts                #   CLI entry point (commander)
│   ├── resolver.ts             #   Resolution chain: project → user → native → help fallback
│   ├── formatter.ts            #   Markdown and JSON output formatters
│   ├── init.ts                 #   `mallm init` — stub generator (seeds from --help)
│   ├── help-parser.ts          #   Parses `--help` output into mallm structure
│   └── schema.ts               #   Schema types and validation helpers
├── schemas/                    # Validation
│   └── mallm.schema.json       #   JSON Schema for mallm.yaml format
├── examples/                   # Reference mallm.yaml files
│   ├── helm-upgrade.mallm.yaml #   Multi-option orchestrator tool example
│   └── docker-build.mallm.yaml #   Simpler build tool example
├── dist/                       # Compiled JS output (gitignored)
├── docs/                       # Documentation
│   └── PROJ-LAYOUT.md          #   This file
├── .gitignore                  # Ignores node_modules, dist
├── package.json                # mallm v0.1.0 — bin entry, scripts, deps
├── package-lock.json           # Lockfile
├── tsconfig.json               # TypeScript config
└── README.md                   # Usage, schema reference, resolution order
```

## Key Files

| File | Purpose |
|------|---------|
| `src/index.ts` | CLI commands: `show`, `init`, `list`, `validate`, `schema` |
| `src/resolver.ts` | 4-tier resolution: `.mallm/` → `~/.config/mallm/` → `--mallm` → `--help` |
| `schemas/mallm.schema.json` | Canonical schema defining the mallm.yaml format |
| `examples/*.mallm.yaml` | Working examples for reference and testing |

## Build & Install

```bash
npm install && npm run build   # Compile TypeScript
npm link                       # Make `mallm` available globally
```
