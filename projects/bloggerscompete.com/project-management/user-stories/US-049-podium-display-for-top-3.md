---
id: US-049
title: "Podium Display for Top 3"
slug: "podium-display-for-top-3"
personas: [P-001, P-002, P-006]
epic: "Leaderboards"
priority: "should-have"
complexity: "M"
tags: [leaderboard, podium, top-3, ui, gamification, recognition]
---

# US-049: Podium Display for Top 3

## User Story

**As a** top-ranked blogger on the platform (P-002),
**I want to** see the top 3 leaderboard positions displayed in a prominent podium format,
**So that** reaching the top 3 feels like a meaningful achievement worthy of recognition and sharing.

## Acceptance Criteria

- [ ] Given I view the Leaderboard page, when it renders, then the top 3 blogs are displayed in a podium layout (2nd–1st–3rd stepped height) above the standard ranked list
- [ ] Given the podium renders, when I view it, then each podium position shows: blog avatar, blog name, blogger handle, overall score, and a medal icon (gold/silver/bronze)
- [ ] Given a podium position belongs to my blog, when I view it, then my podium card has a visual highlight (glow, border, or accent) distinguishing it as "yours"
- [ ] Given a niche filter is active, when I view the podium, then it shows the top 3 for that niche, not the global top 3
- [ ] Given I click on a podium card, when the click is registered, then I am taken to that blog's public profile page
- [ ] Given I am in the top 3, when I view my podium position, then a "Share my achievement" button generates a shareable image card (Open Graph format) I can post to social media

## Notes

The podium is a high-visibility reward for top performers and a discovery mechanism for readers. The shareable image card (OG card generation) may be a separate story if complexity warrants it. Podium should update whenever leaderboard scores refresh. Related to US-045 (global leaderboard), US-047 (niche filter). Blog reader P-006 uses the podium as a quick shortcut to top-quality blogs.
