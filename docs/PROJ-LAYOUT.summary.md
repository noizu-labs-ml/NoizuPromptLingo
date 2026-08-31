# Project Layout — Summary

```
llm-toolkit/
├── bin/llm-toolkit             # Launcher (api/web/zellij, CLI, skill proxy)
├── packages/
│   ├── api/                    # Hono REST API + SQLite/FTS/vectors
│   │   └── src/{routes,services}/
│   ├── cli/                    # Ink TUI + one-shot commands
│   │   └── src/{commands,interactive}/
│   ├── shared/                 # Types, parsers, API launcher
│   │   └── src/{parsers,types}/
│   └── web/                    # Vite + React + Tailwind SPA
│       └── src/{components,context,hooks,pages,services,hostBridge.ts}/
├── apps/
│   └── macos/                  # Native Mac host (SwiftUI + WKWebView)
│       └── Sources/{LLMToolkitKit,LLMToolkit} + Tests
├── skill-manage/               # Rust skill/agent/command linker (own docs/)
│   ├── src/ + tui/
│   └── schema/
├── completions/                # bash + zsh completions
├── design/                     # Logos, mockups, style guide, sitemap
├── docs/
│   ├── arch/
│   ├── howto/
│   └── layout/                 # api, cli, shared, web detail trees
├── project-management/         # Personas, screens, components, user stories
├── CHANGELOG.md
├── INSTALL.md                  # Setup guide
├── Makefile                    # install + completions + skill-manage build
├── package.json                # Root workspace (dev:api|web|cli)
├── pnpm-lock.yaml
├── pnpm-workspace.yaml
├── tsconfig.base.json
└── README.md
```
