---
id: US-025
title: "Cross-Category Discovery via Tags"
slug: "cross-category-discovery-via-tags"
personas: [P-001, P-002, P-003, P-008]
epic: "Discovery & Exploration"
priority: "won't-have-yet"
complexity: "M"
tags: [tags, cross-category, discovery, tag-pages]
---

# US-025: Cross-Category Discovery via Tags

## User Story

**As an** Indie Web Developer (P-002),
**I want to** browse a tag page that shows all sites across the entire directory sharing that tag,
**So that** I can discover related sites that span multiple categories without being confined to the category tree.

## Acceptance Criteria

- [ ] Given I click a tag on any site card (US-019), when the tag page loads, then I see all approved sites tagged with that term, sorted by composite quality score descending.
- [ ] Given I am on a tag page, when the page loads, then I see which categories the results span (e.g., "Found in: Technology, Design, Creative Writing").
- [ ] Given a tag has fewer than 3 sites, when its tag page would render, then instead I am shown a message: "Not enough sites tagged with '{tag}' yet — check back soon."

## Notes

Tag pages are deferred to a later milestone because they require: a stable tag taxonomy (controlled vocabulary), sufficient directory breadth to make cross-category results meaningful, and tag page SEO considerations. They depend on US-019 (tags on listings) being fully implemented and the taxonomy curated. Should be revisited when directory has 500+ sites.
