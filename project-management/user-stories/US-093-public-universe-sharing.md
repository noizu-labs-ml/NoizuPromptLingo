---
id: US-093
title: "Public Universe Sharing"
slug: "public-universe-sharing"
personas: [P-001, P-004, P-005, P-008]
epic: "Collaboration & Sharing"
priority: "should-have"
complexity: "M"
tags: [collaboration, sharing, public, discovery, community]
---

# US-093: Public Universe Sharing

## User Story

**As a** worldbuilder who wants to share my work with an audience (P-001, P-004, P-005, P-008),
**I want to** publish my universe publicly with a shareable URL,
**So that** readers, fans, and the community can explore my world without needing an account.

## Acceptance Criteria

- [ ] Given I am the universe owner, when I toggle "Make public" in Universe Settings and confirm, then the universe is accessible at a public URL (e.g., `therobotknows.com/u/{slug}`) without authentication.
- [ ] Given a visitor navigates to a public universe URL, when the page loads, then they see the universe title, description, and a browseable list of canon entries, but cannot edit anything.
- [ ] Given I mark specific canon entries as "private," when the universe is public, then those private entries are excluded from the public view and their titles are not revealed.
- [ ] Given I toggle a universe back to private, when the change is saved, then the public URL immediately returns a 404 or access-denied page.
- [ ] Given a public universe exists, when it is indexed by search engines, then the page has appropriate Open Graph tags (title, description, image) for rich link previews.

## Notes

Depends on US-092 (collaborator roles). Related: US-094 (reader-facing codex view), US-087 (content moderation). Public universes are subject to moderation policy. SEO-friendly URLs require unique universe slugs enforced at creation time.
