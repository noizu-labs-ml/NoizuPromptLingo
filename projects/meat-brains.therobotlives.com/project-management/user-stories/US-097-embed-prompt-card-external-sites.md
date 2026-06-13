---
id: US-097
title: "Embed Prompt Card on External Sites"
slug: "embed-prompt-card-external-sites"
personas: [P-001, P-005, P-006]
epic: "Integration & API"
priority: "won't-have-yet"
complexity: "M"
tags: [embed, widget, integration, sharing, developer]
---

# US-097: Embed Prompt Card on External Sites

## User Story

**As a** Content Creator (P-006) or Prompt Engineer (P-001),
**I want to** embed a live prompt card widget on my blog or website,
**So that** my audience can see the prompt, its vote score, and a link back to Meat Brains without leaving my site.

## Acceptance Criteria

- [ ] Given a logged-in user views a public prompt, when they click "Embed," then a modal displays an iframe snippet and oEmbed URL they can copy
- [ ] Given the iframe snippet is embedded in an external page, when the page is loaded, then the prompt card renders with title, truncated body, vote score, tag list, and a "View on Meat Brains" link
- [ ] Given the embedded prompt's vote score changes on the platform, when the embed is viewed, then it reflects the updated score within 5 minutes (cached, not real-time)
- [ ] Given an external site's CSP restricts iframes, when the embed request is made, then the oEmbed endpoint provides structured data that external embedding libraries (e.g., Embedly) can use as a fallback
- [ ] Given the embedded card is rendered, when it is loaded on a mobile viewport, then the card is responsive and does not overflow the parent container

## Notes

The embed iframe should be served from a dedicated `embed.meat-brains.therobotlives.com` subdomain to isolate it from the main app's cookie and security context. Rate limiting on the embed endpoint is critical as it will be served from arbitrary external domains. Deferring post-launch; SEO/virality value is secondary to core platform stability.
