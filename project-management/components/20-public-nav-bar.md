# Public Nav Bar

| Field | Value |
|-------|-------|
| **ID** | `public-nav-bar` |
| **Category** | Navigation & Layout |
| **Used In** | 01-landing-page, 02-login |

## Description

Top navigation shown to unauthenticated visitors, explicitly shared between the Landing and Login screens rather than reimplemented per screen.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Persistent top bar across all public/unauthenticated routes |

## Props / Configuration

- `links` — public nav destinations
- `ctaLabel` — primary call-to-action shown in the bar (e.g. "Log In")

## Interactions

- User clicks a nav link or the CTA → routes to the corresponding public screen (e.g. Login)
- Bar remains visible/sticky while the page content scrolls
