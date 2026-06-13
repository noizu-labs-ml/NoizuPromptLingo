---
id: US-019
title: "Tags on Site Listings"
slug: "tags-on-listings"
personas: [P-001, P-002, P-003, P-008]
epic: "Site Listings"
priority: "should-have"
complexity: "S"
tags: [tags, filtering, discovery, cross-category]
---

# US-019: Tags on Site Listings

## User Story

**As an** Indie Web Developer (P-002),
**I want to** see topic tags on each site card,
**So that** I can quickly understand the site's focus and click a tag to find similar sites across categories.

## Acceptance Criteria

- [ ] Given I view a site card, when it renders, then up to 5 tags are displayed as clickable chips below the summary.
- [ ] Given I click a tag on any site card, when I navigate, then I arrive at a tag page listing all sites across all categories that share that tag.
- [ ] Given a site has no tags assigned, when its card renders, then no tag chips are displayed (no empty chip placeholder).

## Notes

Tags are the connective tissue for cross-category discovery (US-025). Tags should be normalized (lowercase, hyphenated) and drawn from a controlled vocabulary to avoid fragmentation. Community Curators (P-008) may suggest tags during submission.
