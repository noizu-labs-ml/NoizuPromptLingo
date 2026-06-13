# Architecture Summary — start-app/frontend

Next.js 15 App Router starter with JWT auth, YAML-driven design system, and Docker deployment.

## Components
- **AuthProvider** — client-side JWT context (login/register/logout via localStorage)
- **api.ts** — fetch wrapper with auto Bearer token injection, hits `/api/v1/auth/*`
- **generate-css.ts** — compiles YAML theme config → `design-system.generated.css` via styleguide pkg
- **globals.css** — imports generated CSS, bridges CSS vars to Tailwind v4 `@theme`
- **Navbar** — auth-aware sticky navigation
- **@the-robot-lives/styleguide** — shared component library (GitHub Packages)

## Data Flow
- YAML → styleguide generate.ts → generated CSS → Tailwind bridge → browser
- User action → AuthProvider → api.ts → Elixir backend at `NEXT_PUBLIC_API_URL`

## Stack
Next.js 15, React 19, Tailwind v4, JWT auth, Docker multi-stage (Node 22 Alpine standalone)
