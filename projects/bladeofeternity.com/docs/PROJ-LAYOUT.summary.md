# Project Layout — Summary

```
bladeofeternity.com/
├── web/                        # Next.js 15 frontend
│   ├── src/app/                #   Pages, components, styles
│   ├── e2e/                    #   BDD feature specs
│   ├── cypress/                #   Test support
│   └── public/                 #   Static assets
├── backend/                    # Elixir/Phoenix API
│   ├── lib/boe/                #   Business logic
│   ├── lib/boe_web/            #   Web layer
│   ├── priv/repo/migrations/   #   DB migrations
│   └── config/                 #   Configuration
├── project/                    # Product management
│   ├── personas/               #   10 user personas
│   └── user-stories/           #   100 user stories
├── design/                     # Style guide + UX architecture
├── docs/                       # Documentation + layout details
├── .gemini/                    # Gemini Code Assist config
├── .tool-versions              # asdf runtimes
├── docker-compose.yaml         # Local dev services
└── README.md                   # Project overview
```
