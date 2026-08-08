# src/ — Application source

```
src/
├── app/                                    # Next.js App Router
│   ├── layout.tsx · page.tsx · globals.css
│   ├── design-system.generated.css         # Output of generate-css (committed/build)
│   ├── error.tsx · global-error.tsx
│   ├── login/page.tsx
│   ├── auth/
│   │   ├── register/ · verify/ · verify-email/ · sso-callback/
│   ├── styleguide/ · sitemap/
│   └── app/                                # Authenticated shell
│       ├── layout.tsx · page.tsx
│       ├── organizations/ · profile/ · mcp-keys/
│       ├── admin/                          # Global admin
│       │   ├── page.tsx
│       │   ├── users/ · orgs/ · authz/
│       │   ├── github/ · llm-models/
│       │   ├── mcp-custom-scopes/ · media-providers/
│       └── [orgId]/                       # Org-scoped product UI
│           ├── page.tsx                    #   Org dashboard
│           ├── projects/ · sessions/
│           ├── tickets/ · ticket-fields/ · ticket-types/ · boards/
│           ├── chat/ · wiki/ · artifacts/ · assets/
│           ├── reviews/ · github/ · browser/
│           ├── personas/ · memory/ · instructions/
│           ├── mock-mcp/ · npl-conventions/ · unicode-codex/
│           ├── members/ · settings/
│           └── …
├── components/
│   ├── app-nav.tsx · app-sidebar.tsx · mobile-nav.tsx · navbar.tsx
│   ├── auth-card.tsx · org-dialogs.tsx · org-project-switcher.tsx
│   ├── console/                            # DataTable, DetailView, EditForm, …
│   ├── memory/                             # Memory cards / associations UI
│   ├── markdown.tsx · markdown-editor.tsx
│   ├── mcp-setup-panel.tsx
│   ├── analytics-provider.tsx · otel-provider.tsx · cookie-consent.tsx
│   ├── mini-realtime-voice-widget.tsx
│   ├── landing/hero-mascot.tsx
│   └── generated/demo.ts
├── config/
│   └── theme-style-guide/                  # YAML tokens → CSS generation
│       ├── branding.yaml · style-guide.meta.yaml · style-guide.vars.yaml
│       ├── style-guide.color-*.yaml · typography · spacing · …
│       └── style-guide.*.user.yaml         # Optional user overrides
├── context/
│   ├── auth.tsx · org.tsx · sidebar.tsx
├── hooks/
│   └── use-channel.ts                      # Phoenix channel subscription
├── i18n/
│   ├── config.ts · request.ts
│   └── messages/en.json
├── lib/
│   ├── api.ts · socket.ts · runtime-config.ts · org-resolve.ts
│   ├── llm-config.ts · otel.ts
│   ├── analytics/                          # GA + PostHog providers
│   ├── consent/
│   └── console/                            # Entity descriptors + registry
│       ├── registry.ts · types.ts · roles.ts · options.ts · render-hints.tsx
│       └── descriptors/                    # artifacts, boards, tickets, sessions, …
├── scripts/
│   └── generate-css.ts
├── proxy.ts
└── types/
    └── phoenix.d.ts
```

## Notes

- Org product pages live under `app/app/[orgId]/` (URL `/app/:orgId/...`).
- Console pages often compose `components/console/*` + `lib/console/descriptors/*`.
- Human login is Authentik OIDC-oriented; see root README (password routes may exist client-side but are disabled server-side).
- Theme source of truth for product brand also lives under repo `design/theme/`; frontend `config/theme-style-guide/` drives the Next CSS pipeline.
