---
id: US-007
title: "Browse Spaces"
slug: "browse-spaces"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Spaces"
priority: "must-have"
complexity: "S"
tags: [spaces, discoverability, search]
---

# US-007: Browse Spaces

## User Story

**As a** AI/ML Engineer (P-002),
**I want to** browse and discover spaces related to my interests,
**So that** I can find communities and resources relevant to my work.

## Acceptance Criteria

- [ ] Given any user, when they visit the spaces directory, then they see a list of public spaces sorted by member count (descending) with name, description, and visibility badge
- [ ] Given a user is browsing spaces, when they enter a search query in the search bar, then the list filters to spaces whose name or description includes the query (case-insensitive)
- [ ] Given a user is browsing spaces, when they click a visibility filter (Public/Restricted), then the list updates to show only matching spaces
- [ ] Given an unauthenticated user, when they view private spaces, then those spaces are hidden from the directory
- [ ] Given a user is browsing spaces, when they click on a space card, then they navigate to the space's detail page showing member count, thread count, and recent activity

## Notes

Spaces pagination: 20 per page. Search is client-side for MVP. Private spaces are never discoverable via directory; invite-only access only.