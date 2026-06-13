---
id: US-071
title: "Share an MCP server link with a colleague"
slug: "share-server-link"
personas: [P-001, P-004]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "S"
tags: [social, sharing, deep-link, registry]
---

# US-071: Share an MCP Server Link with a Colleague

## User Story

**As a** AI/ML Engineer (P-004),
**I want to** share a link to an MCP server with a colleague,
**So that** I can recommend useful tools to my team and they can access the full detail page with a single click.

## Acceptance Criteria

- [ ] Given the user is viewing an MCP server detail page (US-054), when they click the "Share" button, then a share menu opens with options to: copy the direct URL, share via email, and generate an embeddable card snippet.
- [ ] Given the user selects "Copy link," when the URL is copied, then the system places the canonical server detail page URL on the clipboard and displays a brief "Link copied" confirmation toast.
- [ ] Given the user selects "Share via email," when the email compose dialog opens, then it pre-populates the subject with the server name and the body with a brief description and the server URL.
- [ ] Given the user selects the embed card option, when the snippet is generated, then it provides an HTML snippet or markdown link that renders as a compact card with the server name, description, and health status.
- [ ] Given a recipient clicks a shared server link, when they are not logged in, then the server detail page (US-054) loads in a public-readable mode with a prompt to sign in for full functionality (deployment, reviews).
- [ ] Given the user shares a link to a private server, when the recipient opens it, then they see an access-restricted page with a prompt to request access (US-073).

## Notes

All public servers have shareable URLs by default. Private servers can be shared but require the recipient to request access through the platform. Related: US-054, US-073, US-074.
