---
id: US-022
title: "Trending Sites This Week"
slug: "trending-sites-this-week"
personas: [P-001, P-004, P-002, P-008]
epic: "Discovery & Exploration"
priority: "should-have"
complexity: "M"
tags: [trending, discovery, freshness, homepage, weekly]
---

# US-022: Trending Sites This Week

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** see a curated "trending this week" section on the homepage or discovery page,
**So that** I can find what the community is excited about right now without hunting for it.

## Acceptance Criteria

- [ ] Given I visit the homepage, when the page loads, then a "Trending This Week" section displays up to 10 sites with elevated recent visit or click-through activity.
- [ ] Given a site appears in the trending section, when I view its card, then it shows its category, composite score, and a "trending" indicator alongside normal card data.
- [ ] Given the trending list is computed, when it renders, then only sites with a quality score ≥ 50 are eligible (prevents low-quality viral noise).

## Notes

Trending is computed from click-through signals within the directory, not external social metrics. The quality floor prevents the trending list from being gamed by low-quality sites. Trending should reset weekly on a fixed day (e.g., Monday). Connects to US-023 (recently added).
