# Project Layout Summary

```
NoizuPromptLingo/
├── config/                     # Elixir/Phoenix configs (dev, prod, runtime, test)
├── db/                         # Liquibase migrations + Dockerfile
├── design/                     # UI prototypes
├── docs/                       # Documentation + MCP tool guides
│   ├── tools/                  #   Per-domain tool reference
│   └── layout/                 #   Detailed layout breakdowns
├── helm/npl-mcp/               # K8s Helm chart
├── lib/                        # Elixir source
│   ├── noizu_prompt_lingua/    #   Core app
│   │   ├── domains/            #     10 MCP domains (agents, artifacts, assets, chat, mock_mcp, projects, review, sessions, tickets, wiki)
│   │   ├── npl/                #     NPL convention engine
│   │   ├── plugs/              #     Auth plugs
│   │   ├── schema/             #     35 Ecto schemas
│   │   ├── services/           #     Cross-cutting (attach, comment, watch)
│   │   └── tools/              #     Root MCP tools (discovery, NPL load/spec)
│   └── npl_web/                #   Phoenix endpoint + router
├── nginx/                      # Reverse proxy configs + Docker build
├── priv/                       # Conventions YAML, Ecto migrations, skills
├── test/                       # ExUnit tests
├── web/                        # Next.js dashboard (App Router)
│   ├── app/                    #   Pages (dashboard, chat, tickets, reviews, projects)
│   ├── components/             #   Shared components
│   └── lib/                    #   API client
├── docker-compose.yml
├── Dockerfile.elixir
├── Dockerfile.nextjs
├── mix.exs
└── .env.example
```
