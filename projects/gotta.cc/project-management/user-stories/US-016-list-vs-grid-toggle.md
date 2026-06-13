---
id: US-016
title: "List vs Grid View Toggle"
slug: "list-vs-grid-toggle"
personas: [P-001, P-002, P-004]
epic: "Site Listings"
priority: "could-have"
complexity: "S"
tags: [view-toggle, grid, list, layout, preference]
---

# US-016: List vs Grid View Toggle

## User Story

**As an** Indie Web Developer (P-002),
**I want to** toggle between a compact list view and a visual grid view for site listings,
**So that** I can choose between scanning quickly (list) or browsing visually (grid with screenshots).

## Acceptance Criteria

- [ ] Given I am on a category listing page, when I click the view toggle, then the layout switches between list and grid without a page reload.
- [ ] Given I have chosen a view preference, when I navigate to another category, then my chosen view is remembered for the session.
- [ ] Given I am on a mobile device, when the page loads, then the view defaults to list mode regardless of any desktop preference (grid is desktop-optimized).

## Notes

Grid view is most valuable when screenshots (US-014) are available. List view should be the default as it works universally across devices and content states. Preference can be stored in localStorage; no login required.
