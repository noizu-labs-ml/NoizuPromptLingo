---
id: US-059
title: "View Curated Best-Of Editorial Lists"
slug: "view-best-of-editorial-lists"
personas: [P-001, P-004, P-003]
epic: "Collections & Lists"
priority: "must-have"
complexity: "M"
tags: [collections, editorial, curation, discovery, best-of]
---

# US-059: View Curated Best-Of Editorial Lists

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** browse editorial "Best of" lists curated by the gotta.cc team,
**So that** I can discover standout websites without having to search or browse the full directory.

## Acceptance Criteria

- [ ] Given I visit the homepage or a dedicated "Collections" section, when the page loads, then at least 3 featured editorial lists are prominently displayed with cover image, title, and short description
- [ ] Given I click an editorial list, when the list page loads, then all listed sites are shown as cards with name, summary, and score badge
- [ ] Given an editorial list page, when it is displayed, then a byline shows the editor's name and the date the list was last updated
- [ ] Given an editorial list, when I view it, then I can click any listed site to go to its detail page on gotta.cc
- [ ] Given an editorial list, when I am logged in, then I can follow the list to receive updates when new sites are added (see US-064)

## Notes

Editorial lists are the primary trust signal differentiating gotta.cc from algorithmic aggregators. Editors who create these lists use the workflow defined in US-067. Related: US-060 (personal collections), US-064 (follow collections), US-067 (editor curation workflow).
