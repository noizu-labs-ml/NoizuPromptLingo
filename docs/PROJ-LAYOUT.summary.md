# Project Layout Summary — NoizuPromptLingo

Companion tree for [PROJ-LAYOUT.md](PROJ-LAYOUT.md).

```
NoizuPromptLingo/
├── frontend/                       # Next.js console → frontend/docs/PROJ-LAYOUT.md
│   ├── src/                        #   App Router, components, lib, theme YAML
│   ├── e2e/                        #   Playwright
│   ├── public/
│   └── docs/
├── backend/                        # Phoenix API + MCP → backend/docs/PROJ-LAYOUT.md
│   ├── lib/noizu_prompt_lingua/    #   domains, mcp, entities, schema
│   ├── lib/noizu_prompt_lingua_web/ #   controllers, plugs, channels
│   ├── config/
│   ├── db/changelog/               #   Liquibase 000–073
│   ├── priv/                       #   conventions, seeds, unicode-codex, downloads
│   └── test/
├── nginx/                          # Reverse proxy
├── helm/
│   ├── start-app/                  #   App chart
│   └── npl-mcp/                    #   MCP chart
├── design/                         # Themes + asset prompts
├── docs/                           # PROJ-LAYOUT*, PROJ-ARCH*, PROJ-SCHEMA*, audits
├── local-mcp/                      # Downloadable filesystem MCP
├── browser-controller/             # Playwright relay client
├── remote-access-client/           # frpc tunnel client
├── sandbox/                        # Combined sandbox runtime
├── agents/                         # Agent prompt defs
├── commands/                       # Workflow / slash-command docs
├── project-management/             # Personas, screens, user stories, roadmap
├── sub-agent-prompts/
├── scripts/                        # gen-env.sh, cert helpers
├── docker-compose*.yaml|yml
├── Dockerfile.sandbox
├── .env.example
├── Makefile
└── README.md
```
