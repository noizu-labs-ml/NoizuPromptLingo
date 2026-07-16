# Landing / Marketing Page

| Field | Value |
|-------|-------|
| **ID** | `landing-page` |
| **Type** | Primary |
| **Category** | Public & Onboarding |
| **User Stories** | None (public marketing surface; pre-authentication) |

## Description

Public, unauthenticated marketing page at `/` that introduces NPL's platform — agentic work sessions, tickets, chat, and personas — to prospective users and drives them toward Login or Registration. Serves as the top-of-funnel entry point for both organic visitors and invited users following a shared link.

## Key Components

- **Hero Banner** — headline and value-proposition copy with primary CTA buttons
- **Feature Highlight Grid** — cards summarizing core product pillars (Sessions, Tickets, Chat, Personas)
- **Primary CTA Button Group** — "Log In" / "Get Started" actions routing into the auth flow
- **Public Nav Bar** — top navigation shown to unauthenticated visitors
- **Footer Nav Links** — links to docs, protocol/governance pages, contact

## Interactions

- Visitor clicks "Log In" → routes to Login (02)
- Visitor arriving via an invite link lands directly on Registration (04) instead of this page
- Visitor scrolls through feature sections; CTA buttons remain visible/sticky

## Navigation

- Accessible from: direct URL, external marketing links, search engines
- Links to: Login (02), Registration (Invite) (04)
