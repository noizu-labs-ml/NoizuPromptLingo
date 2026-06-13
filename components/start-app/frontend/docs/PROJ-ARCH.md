# Architecture — start-app/frontend

Next.js 15 (App Router) starter frontend with JWT authentication, a YAML-driven design system, and Docker-based deployment. Designed as the reusable starting point for all portfolio projects.

## System Diagram

```mermaid
graph TB
    subgraph Browser
        A[Next.js App Router] --> B[AuthProvider Context]
        A --> C[Navbar]
        A --> D[Pages]
    end

    subgraph "Build Pipeline"
        Y[YAML Theme Config] -->|generate-css| G[design-system.generated.css]
        G --> CSS[globals.css + Tailwind v4]
        PKG[@noizu/styleguide] -->|components| A
        PKG -->|generate.ts| G
    end

    subgraph "Backend (Elixir)"
        API["/api/v1/auth/*"]
    end

    B -->|JWT Bearer| API
    D -->|fetch via api.ts| API
```

## Core Components

| Component | Purpose |
|-----------|---------|
| `AuthProvider` | Client-side auth context — login, register, logout, JWT token management |
| `api.ts` | Fetch wrapper — auto-attaches Bearer token, hits `/api/v1/auth/*` endpoints |
| `generate-css.ts` | Build script — invokes styleguide package to compile YAML themes → CSS |
| `globals.css` | Imports generated CSS + Tailwind v4; bridges CSS vars to Tailwind `@theme` |
| `Navbar` | Sticky nav with auth-aware login/logout UI |
| `CookieConsentProvider` | Category-level cookie consent UI and saved preferences |
| Styleguide package | `@noizu/styleguide` — shared components (buttons, cards, viewer) |

## Authentication

Client-side JWT flow using `localStorage`. The `AuthProvider` wraps the entire app and exposes `useAuth()`.

→ *See [arch/auth.md](arch/auth.md) for details*

## Design System Pipeline

YAML config files define the entire visual language (colors, typography, spacing, layouts). At build time, `generate-css.ts` invokes the styleguide package which compiles them into `design-system.generated.css`. Tailwind v4 then bridges the generated CSS variables via `@theme`.

→ *See [arch/design-system.md](arch/design-system.md) for details*

## Cookie Consent & Analytics

The frontend includes a category-based consent layer for reusable project compliance:

- `src/lib/consent/` stores a versioned consent record in `localStorage` with `necessary`, `analytics`, `marketing`, and `preferences` categories.
- `necessary` is always enabled; optional categories default to disabled until the user chooses.
- `CookieConsentProvider` mounts a global banner and exposes `CookieSettingsButton` so users can reopen choices.
- `src/lib/analytics/` checks `hasConsent("analytics")` before initializing GA/PostHog, tracking page views, identifying users, or sending custom events.
- Runtime analytics keys can be configured by env/Helm, but provider scripts do not load until analytics consent is granted.

## Deployment

Multi-stage Docker build (deps → build → runtime) producing a standalone Next.js server. Verdaccio token (`NPM_TOKEN`) injected as a build secret for the `@noizu/styleguide` dependency.

→ *See [arch/deployment.md](arch/deployment.md) for details*

## Technology Stack

| Layer | Choice |
|-------|--------|
| Framework | Next.js 15 (App Router, React 19) |
| Styling | Tailwind CSS v4 + YAML-generated CSS custom properties |
| Auth | JWT (access + refresh tokens), localStorage |
| API Client | Native `fetch` with Bearer token injection |
| Components | `@noizu/styleguide` (Verdaccio — npm.noizu.com) |
| Build | TypeScript, `tsx` for scripts |
| Container | Docker multi-stage, Node 22 Alpine, standalone output |
| Backend | Elixir (separate service at `NEXT_PUBLIC_API_URL`) |

## Key Decisions

- **Why client-side auth**: Starter simplicity — no SSR session complexity, easy to swap later
- **Why YAML themes**: Minimizes tokens/context for AI agents to create and modify style guides; portable across portfolio projects
- **Why standalone Docker output**: Minimal runtime image, no `node_modules` in production
- **Why Tailwind `@theme` bridge**: Lets YAML-defined vars work with Tailwind utility classes
