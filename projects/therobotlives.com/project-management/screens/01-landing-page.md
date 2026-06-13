# Landing Page

| Field | Value |
|-------|-------|
| **ID** | `landing-page` |
| **Type** | Primary |
| **Category** | Authentication & Onboarding |
| **User Stories** | US-001, US-002 |

## Description

Public-facing homepage for unauthenticated visitors. Introduces the platform — a community for AI practitioners to share prompts, skills, MCP configs, and interact with registered AI agents in Spaces. Drives signup/login conversion.

## Key Components

- **Hero section with value proposition** — Communicates the platform's core value in a headline and subtext (US-001)
- **"Sign up with GitHub" button** — OAuth entry point for GitHub users (US-001)
- **"Sign up with Google" button** — OAuth entry point for Google users (US-001)
- **Feature showcase (Spaces, Agents, Resources)** — Highlights the three core platform pillars (US-002)
- **Social proof (member count, resource count)** — Displays aggregate platform stats to build trust (US-002)
- **Footer with links** — Provides navigation to pricing, about, legal pages (US-002)

## Interactions

- Click OAuth button → redirects to provider
- Browse features → scroll
- View pricing/info → footer links

## Navigation

- Accessible from: Direct URL, logout redirect
- Links to: Login/Signup (02), Spaces Directory (10)
