# Scaffold Generation

| Field | Value |
|-------|-------|
| **ID** | `scaffold-generation` |
| **Type** | Storyboard |
| **Category** | Ink Phase |
| **User Stories** | INK-041, INK-042, INK-043, INK-044 |

## Description

Multi-step scaffold creation: select tech stack → configure deployment → generate project structure with design system. Visual file tree explorer with confirm/cancel before creation.

## Key Components

- **Tech Stack Cards** — 2-3 plain-English options with tradeoffs, build time, cost, complexity comparison (INK-042)
- **"Why This Stack?" Expandable** — Detailed rationale per stack option (INK-042)
- **Deployment Target Selector** — Vercel/Railway/Fly.io/Self-hosted with dry-run validation (INK-043)
- **File Tree Explorer** — Visual directory structure preview before generation (INK-041)
- **Component Library Preview** — Design tokens applied to Button/Input/Card/Layout in Storybook embed (INK-044)
- **Confirm/Cancel Gate** — Final confirmation before scaffold is created (INK-041)

## Interactions

- Step 1: Select tech stack (or accept AI recommendation)
- Step 2: Configure deployment target with env vars
- Step 3: Preview generated file tree
- Step 4: Preview component library with design tokens
- Confirm → scaffold is generated with progress indicator
- Cancel returns to step selection

## Navigation

- Accessible from: Draft phase completion, Dashboard "Continue" on Ink:Scaffold
- Links to: Agent Development screen
