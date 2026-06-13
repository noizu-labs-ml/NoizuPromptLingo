# Web Frontend Layout

Next.js 15 (App Router) frontend — accessibility-first game client.

```
web/
├── cypress/                            # Cypress test support
│   ├── fixtures/
│   │   └── user.json                   # Test user fixture data
│   ├── support/
│   │   ├── commands.ts                 # Custom Cypress commands
│   │   └── e2e.ts                      # E2E support config
│   └── tsconfig.json                   # Cypress TypeScript config
├── e2e/                                # BDD feature specs
│   ├── features/                       # Gherkin .feature files
│   │   ├── accessibility.feature
│   │   ├── authentication.feature
│   │   ├── game.feature
│   │   ├── landing.feature
│   │   └── navigation.feature
│   └── step_definitions/               # Step implementations
│       ├── accessibility.ts
│       ├── authentication.ts
│       ├── common.ts
│       ├── game.ts
│       ├── landing.ts
│       └── navigation.ts
├── public/                             # Static assets
│   ├── images/
│   │   ├── carousel/                   # Landing page carousel images (6 files)
│   │   ├── banner.jpg                  # Main banner
│   │   ├── login-banner.jpg            # Login page banner
│   │   ├── logo.png                    # Site logo
│   │   ├── sand-golem.png              # Game art
│   │   └── stone-golem.png             # Game art
│   ├── favicon.ico
│   └── *.svg                           # Next.js default icons
├── src/
│   ├── app/                            # App Router pages
│   │   ├── components/
│   │   │   ├── site-shell.tsx          # SiteHeader + SiteFooter
│   │   │   └── site-shell.tsx.cy.yaml  # Cypress selectors (14)
│   │   ├── contact/page.tsx            # Contact page
│   │   ├── cookie/page.tsx             # Cookie policy
│   │   ├── create-character/           # Character creation (27 selectors)
│   │   ├── game/                       # Main game view (20 selectors)
│   │   ├── login/                      # Login form (8 selectors)
│   │   ├── privacy/page.tsx            # Privacy policy
│   │   ├── signup/                     # Signup form (8 selectors)
│   │   ├── terms/page.tsx              # Terms of service
│   │   ├── globals.css                 # Global styles
│   │   ├── layout.tsx                  # Root layout
│   │   ├── page.tsx                    # Landing page (12 selectors)
│   │   └── page.tsx.cy.yaml            # Landing Cypress selectors
│   ├── context/
│   │   └── auth.tsx                    # Auth context provider
│   └── lib/
│       ├── api.ts                      # Backend API client
│       └── cy-attrs.ts                 # cyAttrs() helper for test selectors
├── .cypress-cucumber-preprocessorrc.json
├── cypress.config.ts                   # Cypress configuration
├── Dockerfile                          # Production container
├── eslint.config.mjs                   # ESLint configuration
├── next.config.ts                      # Next.js configuration
├── package.json                        # Dependencies and scripts
├── postcss.config.mjs                  # PostCSS configuration
└── tsconfig.json                       # TypeScript configuration
```

Each route directory contains `page.tsx` and a co-located `.cy.yaml` sidecar
documenting Cypress test selectors. See [../README.md](../README.md) for the
sidecar schema and quick reference.
