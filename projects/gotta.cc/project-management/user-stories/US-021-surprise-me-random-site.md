---
id: US-021
title: "Surprise Me — Random Site"
slug: "surprise-me-random-site"
personas: [P-001, P-004]
epic: "Discovery & Exploration"
priority: "must-have"
complexity: "S"
tags: [discovery, random, surprise, serendipity]
---

# US-021: Surprise Me — Random Site

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** click a button that takes me to a random high-quality site from anywhere in the directory,
**So that** I can discover something unexpected and interesting without any intent or search.

## Acceptance Criteria

- [ ] Given I click the "Surprise Me" button for a random site, when navigation completes, then I arrive at the site detail page for a randomly selected site with a quality score above a minimum threshold (e.g., ≥60/100).
- [ ] Given the random site page loads, when I read it, then a banner shows the site's category path and offers "Another one →" to trigger a second random site.
- [ ] Given I click "Another one" repeatedly, when each fires, then I do not see the same site twice within a 10-site session window.

## Notes

The minimum quality threshold prevents low-scored or unreachable sites from appearing in random draws. This is the site-level equivalent of US-007 (random category). Both should be accessible from persistent navigation. This is a defining UX feature of gotta.cc.
