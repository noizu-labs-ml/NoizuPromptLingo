# Project Layout

pnpm monorepo (Claude Assist / llm-toolkit): search, browse, edit, and extract artifacts from coding-agent conversations. TypeScript packages under `packages/`; embedded Rust skill linker under `skill-manage/`.

```
llm-toolkit/
├── bin/                              # Installed launcher
│   └── llm-toolkit                   #   bash: api/web (zellij), CLI, skill-manage proxy
├── packages/                         # pnpm workspaces (pnpm-workspace.yaml → packages/*)
│   ├── api/                          #   Hono REST API + SQLite/FTS/vectors → [layout/api.md](layout/api.md)
│   ├── cli/                          #   Ink TUI + one-shot commands → [layout/cli.md](layout/cli.md)
│   ├── shared/                       #   Types, JSONL parsers, API launcher → [layout/shared.md](layout/shared.md)
│   └── web/                          #   Vite + React + Tailwind SPA → [layout/web.md](layout/web.md)
├── apps/
│   └── macos/                        #   Native Mac host → [layout/macos.md](layout/macos.md)
├── skill-manage/                     # Rust CLI/TUI — skills/agents/commands symlink manager
│   ├── src/                          #   clap + ratatui sources (main, link, catalog, audit, tui/…)
│   ├── schema/                       #   config.example.yaml, catalog.example.yaml
│   ├── docs/                         #   Nested PROJ-* docs → skill-manage/docs/PROJ-LAYOUT.md
│   ├── Cargo.toml                    #   crate manifest
│   ├── Makefile                      #   cargo build/test/install helpers
│   └── README.md                     #   skill-manage usage
├── completions/                      # Shell completions for launcher + skill surface
│   ├── llm-toolkit.bash              #   bash-completion v2
│   └── _llm-toolkit                  #   zsh (fpath site-functions)
├── design/                           # Visual design assets
│   ├── logos/                        #   SVG logo variants + preview.html
│   ├── mockup-*.svg                  #   dashboard, search, thread viewer mockups
│   ├── SITEMAP.md                    #   Information architecture
│   ├── style-guide.md                #   Design system tokens/rules
│   └── README.md                     #   Design overview
├── docs/                             # Project documentation (this tree)
│   ├── arch/                         #   Detail: data-flow, storage, agent-watch-dog
│   ├── howto/                        #   Task guides (provider, convert, edit, export, manage)
│   ├── layout/                       #   Per-package trees (api, cli, shared, web, macos)
│   ├── PROJ-ARCH.md                  #   Architecture overview
│   ├── PROJ-ARCH.summary.md
│   ├── PROJ-FAQ.md
│   ├── PROJ-FAQ.summary.md
│   ├── PROJ-HOWTO.md
│   ├── PROJ-HOWTO.summary.md
│   ├── PROJ-LAYOUT.md                #   This file
│   └── PROJ-LAYOUT.summary.md
├── project-management/               # Product/PM artifacts (not runtime)
│   ├── components/                   #   UI component specs (01–40 + index.yaml)
│   ├── personas/                     #   Persona briefs (P-001… + index.yaml)
│   ├── screens/                      #   Screen/TUI/CLI output specs (01–42 + index.yaml)
│   ├── user-stories/                 #   US-001…US-100 + index.yaml
│   ├── ROADMAP.md
│   └── README.md
├── .gitignore                        # node_modules, dist, *.db, coverage, …
├── CHANGELOG.md                      # Release notes
├── INSTALL.md                        # Setup and install guide
├── Makefile                          # compile/test/install/completions (skill-manage + symlink)
├── package.json                      # Root workspace scripts: dev:api, dev:web, dev:cli
├── pnpm-lock.yaml                    # Lockfile — setup-required
├── pnpm-workspace.yaml               # packages/* workspace config
├── tsconfig.base.json                # Shared TypeScript base config
└── README.md                         # Project overview — start here
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `pnpm-lock.yaml` / `package.json` | `pnpm install` (Node ≥ 18, pnpm ≥ 8) |
| `Makefile` | `make install` → deps + `~/.local/bin/llm-toolkit` + completions + skill-manage schema share |
| `INSTALL.md` | First-time setup walkthrough |
| `skill-manage` config | `skill-manage init-config` / env vars — see `skill-manage/docs/PROJ-LAYOUT.md` |
| Runtime data | Default DB dir `~/.llm-toolkit/` (auto-created on API boot) |
| `apps/macos` | `make macos` / `make macos-run` (Swift 5.10+, macOS 14+) |
