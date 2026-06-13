---
id: US-053
title: "Share Prompt via Link"
slug: "share-prompt-via-link"
personas: [P-001, P-002, P-006, P-008]
epic: "Social & Collaboration"
priority: "must-have"
complexity: "S"
tags: [sharing, link, permalink]
---

# US-053: Share Prompt via Link

## User Story

**As a** content creator (P-006),
**I want to** copy a direct permalink to any prompt,
**So that** I can share it with my audience outside the platform via newsletters, blogs, or chat.

## Acceptance Criteria

- [ ] Given any prompt page, when I click the "Share" or "Copy Link" button, then the canonical URL is copied to my clipboard
- [ ] Given a shared permalink, when an unauthenticated user visits it, then the prompt is fully readable without requiring login
- [ ] Given a shared permalink, when it is pasted into a social platform that supports Open Graph, then a rich preview card is shown with the prompt title and description
- [ ] Given a prompt that has been deleted, when someone visits its permalink, then a 404 or "prompt removed" page is shown

## Notes

Open Graph meta tags (og:title, og:description, og:url) must be server-rendered for the prompt detail page. Canonical URLs should use a stable slug or numeric ID to survive title edits.
