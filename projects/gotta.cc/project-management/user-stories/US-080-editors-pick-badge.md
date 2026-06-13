---
id: US-080
title: "Editor's Pick Badge for 90+ Composite Score"
slug: "editors-pick-badge"
personas: [P-001, P-003, P-004]
epic: "Quality Scoring Engine"
priority: "should-have"
complexity: "S"
tags: [scoring, badge, editorial, discovery, trust]
---

# US-080: Editor's Pick Badge for 90+ Composite Score

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** see a visual badge on exceptional sites without having to read scores,
**So that** I can quickly identify the best listings in a category without cognitive overhead.

## Acceptance Criteria

- [ ] Given a site has a composite quality score of 90 or above, when it appears in any listing or search result, then it displays an "Editor's Pick" badge adjacent to its title
- [ ] Given a site's score drops below 88 after recalculation (with a hysteresis buffer to prevent flickering), when the recalculation is applied, then the Editor's Pick badge is removed
- [ ] Given I am viewing a site detail page with an Editor's Pick badge, when I click or tap the badge, then a tooltip or modal explains the scoring threshold required to earn it
- [ ] Given the Editor's Pick filter is available in category browsing, when I apply it, then only 90+ scored sites are shown in the listing

## Notes

The 2-point hysteresis buffer (awarded at 90, removed at 88) prevents badge instability from minor score fluctuations. The badge should be visually distinctive but not visually dominant — it signals quality without overwhelming the listing design. See US-081 for score history trends.
