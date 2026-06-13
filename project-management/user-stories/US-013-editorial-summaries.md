---
id: US-013
title: "Editorial Summary on Site Cards"
slug: "editorial-summaries"
personas: [P-001, P-003, P-004]
epic: "Site Listings"
priority: "must-have"
complexity: "S"
tags: [editorial, summary, curation, site-card]
---

# US-013: Editorial Summary on Site Cards

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** read a concise human-written summary of each listed site,
**So that** I know what I'm clicking on before I leave the directory.

## Acceptance Criteria

- [ ] Given I view any site card in a listing, when the card renders, then a 1–2 sentence editorial summary is displayed below the site name.
- [ ] Given a site was auto-submitted and has no human-authored summary yet, when the card renders, then an AI-generated summary is shown with a subtle "AI summary" indicator.
- [ ] Given I am an editor (P-005), when I review a site in the moderation queue, then I can author or override the summary before approving.

## Notes

Summaries are a key trust signal — they signal human curation over automated aggregation. The "AI summary" indicator keeps the product honest without hiding useful content. Connects to US-012 (score breakdown) and US-018 (Editor's Pick badge).
