---
id: US-024
title: "Similar Blogs Discovery on Blog Profile"
slug: "similar-blogs"
personas: [P-006, P-001]
epic: "Blog Profile"
priority: "could-have"
complexity: "M"
tags: [discovery, recommendation, similar, niche, reader]
---

# US-024: Similar Blogs Discovery on Blog Profile

## User Story

**As a** blog reader (P-006),
**I want to** see a list of similar blogs recommended on a blog's profile page,
**So that** I can discover other quality blogs in the same niche without leaving the platform.

## Acceptance Criteria

- [ ] Given I am on a blog's public profile, when the page loads, then a "Similar Blogs" sidebar or section displays up to 6 recommended blogs from the same niche
- [ ] Given similar blogs are displayed, when the list renders, then each recommendation shows: blog name, composite score, primary niche tag, and the owner's avatar
- [ ] Given the similarity algorithm runs, when selecting recommendations, then it prioritizes blogs sharing at least 2 niche tags with the viewed blog, then sorts by composite score descending, excluding the viewed blog itself
- [ ] Given I click a recommended blog, when the click is followed, then I am taken to that blog's public profile page (US-021)
- [ ] Given there are fewer than 3 blogs in the same niche, when the section renders, then it falls back to "Top blogs this week" from the platform's broader catalog

## Notes

Similarity computation can be pre-computed nightly (not real-time per request) to avoid latency. Consider adding user behavior signals (clicks, time-on-profile) to refine recommendations in a future iteration. Related: US-021 (public blog profile), US-006 (niche tags).
