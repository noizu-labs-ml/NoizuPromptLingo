# Frontend Architecture

## Stack

- **Framework**: Next.js 15 (App Router)
- **Styling**: Tailwind CSS 4 + YAML-driven design system via `@the-robot-lives/styleguide`
- **UI Components**: Headless UI (accessible primitives)
- **Code Editor**: Monaco Editor (policy YAML editing)
- **Notifications**: Sonner (toast notifications)
- **Language**: TypeScript 5.7

## Design System

Four YAML-driven themes defined in `design/theme/`:

| Theme | Character |
|-------|-----------|
| Bold | High-contrast, strong visual hierarchy |
| Enterprise | Professional, conservative, trust-oriented |
| Minimal | Clean, whitespace-forward, reduced chrome |
| Nocturne | Dark-mode-first, developer-oriented |

Each theme comprises 12 YAML config files (branding, color-modes, color-palette, globals, meta, page-layouts, semantic-classes, semantic-groups, shell-layouts, spacing, typography, vars).

CSS generation pipeline: `design/theme/` YAML → `src/scripts/generate-css.ts` → `public/themes/*.css` + `design-system.generated.css`.

Theme configs are mirrored into `app/frontend/src/config/` for build-time access.

## Route Structure

Three product surfaces share a unified auth system and global navigation:

- **JustMCP.it**: `/deploy/*` — upload, configure, auth, policy, dashboard, monitoring, logs
- **MCP Jumpstart**: `/scaffold/*` — template selection, configuration, review/download
- **SafeMCP**: `/policies/*`, `/audit`, `/simulate` — policy management, audit logs, simulation
- **Shared**: `/registry`, `/docs`, `/pricing`, `/settings`, `/dashboard`

See `design/SITEMAP.md` for the complete page flow diagram and route inventory.

## Current State

The frontend is in early scaffold stage — `page.tsx` redirects to `/styleguide` for design system preview. No backend integration yet. Four generated theme CSS files exist in `public/themes/`.
