# Project Layout Summary — backend

```
backend/
├── lib/
│   ├── noizu_prompt_lingua.ex
│   ├── noizu_prompt_lingua/          # → layout/lib.md
│   │   ├── application.ex
│   │   ├── domains/                  # artifacts, assets, browser, campaigns, chat, …
│   │   ├── mcp/                      # orgs, projects, sessions, tool_guard
│   │   ├── entities/
│   │   ├── schema/
│   │   ├── npl/
│   │   ├── tools/
│   │   ├── auth/ · authz/ · workers/
│   │   ├── repo.ex · guardian.ex · …
│   ├── noizu_prompt_lingua_web.ex
│   ├── noizu_prompt_lingua_web/
│   │   ├── endpoint.ex · router.ex
│   │   ├── controllers/
│   │   ├── plugs/
│   │   └── channels/
│   ├── mix/tasks/
│   └── supports/
├── config/
├── db/changelog/                     # Liquibase 000–073
├── priv/
│   ├── conventions/
│   ├── unicode-codex/
│   ├── repo/
│   ├── skills/
│   └── static/downloads/
├── test/
├── docs/
├── vendor/noizu_labs_pm/
├── Dockerfile · Dockerfile.dev
├── mix.exs · mix.lock
└── .env
```
