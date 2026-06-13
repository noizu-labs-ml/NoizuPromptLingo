---
id: US-005
title: "Featured Picks Highlighted in Category"
slug: "featured-picks-in-category"
personas: [P-001, P-004, P-003]
epic: "Category Browsing"
priority: "must-have"
complexity: "S"
tags: [featured, editorial, curation, category]
---

# US-005: Featured Picks Highlighted in Category

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** see a small set of hand-picked standout sites at the top of each category,
**So that** I get an immediate "best of" recommendation without having to sort or scroll.

## Acceptance Criteria

- [ ] Given a category has Editor's Pick sites, when I load the category page, then up to 3 picks are displayed in a visually elevated section above the general listing.
- [ ] Given a featured site card is rendered, when I view it, then it displays the site name, one-line description, and composite quality score.
- [ ] Given no sites in a category have been editor-picked, when I load the category page, then the featured section is omitted entirely (not shown as empty).

## Notes

Featured picks are set by the editorial/moderation team (P-005). This connects to US-018 (Editor's Pick badge on individual site cards) and US-013 (score breakdown). The elevated visual treatment is the primary hook for casual browsers.
