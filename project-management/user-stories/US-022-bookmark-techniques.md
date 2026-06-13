---
id: US-022
title: "Bookmark Techniques for Later Reference"
slug: "bookmark-techniques"
personas: [P-001, P-002, P-006, P-008]
epic: "Attack Catalog"
priority: "could-have"
complexity: "S"
tags: [catalog, bookmarks, saved, personal, reference]
---

# US-022: Bookmark Techniques for Later Reference

## User Story

**As a** researcher building a personal reference library (P-001, P-002, P-006, P-008),
**I want to** bookmark techniques I want to revisit,
**So that** I can quickly return to relevant techniques without re-running searches or navigating the taxonomy each time.

## Acceptance Criteria

- [ ] Given I am viewing a technique detail page while authenticated, when I click the bookmark icon, then the technique is added to my bookmarks and the icon changes to indicate saved state
- [ ] Given I click the bookmark icon on an already-bookmarked technique, when the action completes, then the technique is removed from my bookmarks with an undo option available for 5 seconds
- [ ] Given I navigate to my bookmarks list, when the page loads, then I see all bookmarked techniques with their name, severity badge, category, and last-updated date — sortable and filterable
- [ ] Given I am unauthenticated and click the bookmark icon, when the action is triggered, then I am shown a sign-in prompt with a note that my bookmark will be saved after login

## Notes

Bookmarks persist server-side to a user account. Bookmarks are private by default. Relates to US-025 (notifications on bookmarked technique updates). Bookmark counts per technique are not shown publicly to prevent gaming.
